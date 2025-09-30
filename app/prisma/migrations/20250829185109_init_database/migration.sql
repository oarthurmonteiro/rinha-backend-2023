-- CreateTable
CREATE TABLE "Pessoas" (
    "id" UUID NOT NULL,
    "apelido" VARCHAR(32) NOT NULL,
    "nome" VARCHAR(100) NOT NULL,
    "nascimento" DATE NOT NULL,
    "stack" VARCHAR(32)[] DEFAULT ARRAY[]::VARCHAR(32)[],
    "busca" TEXT NOT NULL,

    CONSTRAINT "Pessoas_pkey" PRIMARY KEY ("id")
);


-- CreateIndex
CREATE UNIQUE INDEX "Pessoas_id_key" ON "Pessoas"("id");

-- CreateIndex
CREATE UNIQUE INDEX "Pessoas_apelido_key" ON "Pessoas"("apelido");

-- CreateIndex
CREATE EXTENSION IF NOT EXISTS PG_TRGM;
CREATE INDEX IF NOT EXISTS "Pessoas_busca_idx_trgm" ON "Pessoas" USING GIST ("busca" GIST_TRGM_OPS(SIGLEN=64));
