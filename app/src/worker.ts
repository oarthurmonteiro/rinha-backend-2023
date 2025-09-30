import type { Pessoas } from '@prisma/client';
import type { Pessoa } from '.';
import { client as cache } from './infra/cache/client';
import { client as db } from './infra/database/client';

const BATCH_SIZE = 100
;
const MAX_WAIT_MS = 1000; // flush even if <50 after 2s

async function processQueue() {
  let batch: Pessoas[] = [];
  let timer: NodeJS.Timeout | null = null;

  async function flush() {
    if (batch.length === 0) return;

    const toInsert = [...batch];
    batch = [];

    try {
      console.log(`📤 Inserting ${toInsert.length} rows into Postgres`);
      await db.pessoas.createMany({ data: toInsert}); // Prisma batch insert
    } catch (err) {
      console.error("❌ Insert failed:", err);
      // push back failed batch into cache if needed
      toInsert.forEach(async item => await cache.rpush('to_register', JSON.stringify(item)));
      // await cache.rpush("to_register", toInsert.map((item) => JSON.stringify(item)));
    }
  }

  while (true) {
    const item = await cache.lpop("to_register"); // blocks
    if (!item) continue;

    const pessoa: Pessoa = JSON.parse(item);

    batch.push({
      ...pessoa, 
      nascimento: new Date(pessoa.nascimento),
      busca: pessoa.nome + pessoa.apelido + pessoa.stack?.toString()
    });

    if (!timer) {
      timer = setTimeout(() => {
        flush().finally(() => { timer = null });
      }, MAX_WAIT_MS);
    }

    if (batch.length >= BATCH_SIZE) {
      if (timer) clearTimeout(timer);
      await flush();
      timer = null;
    }
  }
}

processQueue();