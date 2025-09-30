import { redis } from "bun";

// Using the default client (reads connection info from environment)
// process.env.REDIS_URL is used by default
export const client = redis;