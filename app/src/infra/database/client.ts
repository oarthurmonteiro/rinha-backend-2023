import { PrismaPg } from '@prisma/adapter-pg'
import { PrismaClient } from '@prisma/client'

const connectionString = `${process.env.DATABASE_URL}`

const adapter = new PrismaPg({ connectionString });
export const client = new PrismaClient({ adapter, log: [{ emit: "event", level: "query", },], });

// client.$use(async (params, next) => {
//   const before = Date.now()
//   const result = await next(params)
//   const after = Date.now()

  
//   console.info(`${(new Date).toString()} Query ${params.model}.${params.action} took ${after - before}ms`)

//   return result
// })

// client.$on("query", async (e) => {
//   console.info(`Query: ${e.query}`)
//   console.info(`Params: ${e.params}`)
// });