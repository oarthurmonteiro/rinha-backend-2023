import { zValidator } from '@hono/zod-validator'
import { Hono } from 'hono'
import z from 'zod/v4'
import { client as db } from './infra/database/client'
import { client as cache } from './infra/cache/client'
import { logger } from 'hono/logger'

const app = new Hono()

// const worker = new Worker('./src/worker.ts', {type: 'module'});

function parsePayloadToPerson(payload: z.infer<typeof pessoaInputDto>) {
  const id = crypto.randomUUID();
  const pessoa = {
    ...payload,
    // nascimento: new Date(payload.nascimento),
    id: id
  }
  // worker.postMessage({ pessoa });

  return pessoa;
}

app.use(logger())
app.get('/', (c) => {
  return c.text('Hello Hono!')
})

app.get('/health', (c) => {
  c.status(204);
  return c.text('');
});

const str = z.string({
  error: (iss) => {
    if (iss.input === null) {
      return 'nullValue';
    } 
  }
}).min(1);

const pessoa = z.object({
  id: z.uuidv4(),
  apelido: str.max(32),
  nome: str.max(100),
  nascimento: z.iso.date(),
  stack: z.array(str.max(32).toLowerCase())
})

export type Pessoa = z.infer<typeof pessoa>

const pessoaInputDto = pessoa.omit({id: true}) 
// z.object({
//   apelido: str.max(32),
//   nome: str.max(100),
//   nascimento: z.iso.date(),
//   stack: z.array(str.max(32).toLowerCase()).optional()
// });
    
app.post('/pessoas', 
  zValidator(
    'json', 
    pessoaInputDto
 ,
    (result, c) => {
      if (!result.success) {

        const semanticErrors = result.error.issues.filter(
          issue => issue.code === "invalid_type"
        );

        const error = z.flattenError(result.error);
        
        if (semanticErrors.length > 0) {
          return c.json(error, 400);
        }

        return c.json(error, 422);
      }
    }
  ),
  async (c) => {

    const payload = c.req.valid('json');

    if (await cache.sismember('nicknames', payload.apelido)) {
      return c.json({'not_possible': 'already taken'}, 400);
    }
    
    // Enqueue job for async processing
    const pessoa = parsePayloadToPerson(payload);
    const pessoaAsString = JSON.stringify(pessoa);

    // do something 
    await cache.set(pessoa.id, pessoaAsString);
    await cache.sadd('nicknames', payload.apelido);
    await cache.rpush('to_register', pessoaAsString);
    
    c.header('Location', '/pessoas/' + pessoa.id)
    return c.json(pessoa, 201);
})

app.get('/pessoas/:id', async (c) => {

  const id = c.req.param('id');

  const pessoaCacheada = await cache.get(id);
  if (pessoaCacheada) {
    return c.json(pessoaCacheada);
  }

  const pessoa = await db.pessoas.findUnique({where: {id}});
  if (!pessoa) return c.json({error: 'Not found'}, 404)

  return c.json({pessoa}, 200);
})

app.get(
  '/pessoas', 
  zValidator(
    'query', 
    z.object({
      t: z.string().min(1).toLowerCase()
    })
  ),
  async (c) => {
    const searchQuery = c.req.valid('query').t

    const pessoas = await db.pessoas.findMany({
      take: 50,
      where: {
        busca: {contains: searchQuery}
      },
      omit: {busca: true}
    })

    return c.json(pessoas);
})

app.get('/contagem-pessoas', async (c) => {
  
  return c.text("" + await db.pessoas.count());

})


export default app
