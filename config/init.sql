CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE TABLE "pessoas" (
    "id" UUID PRIMARY KEY DEFAULT uuidv7(),
    "apelido" VARCHAR(32) UNIQUE NOT NULL,
    "nome" VARCHAR(100) NOT NULL,
    "nascimento" DATE NOT NULL,
    "stack" VARCHAR(32)[] DEFAULT ARRAY[]::VARCHAR(32)[],
    "busca" TEXT
);

-- GIN index on array contents
CREATE INDEX idx_busca_trgm ON "pessoas"
USING gin (busca gin_trgm_ops);