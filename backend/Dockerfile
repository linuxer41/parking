FROM oven/bun:alpine AS builder

WORKDIR /app

COPY package.json bun.lock ./
RUN bun install

COPY . .
RUN bun build --target=bun src/index.ts --outdir=./dist

CMD ["bun", "run", "src/index.ts"]

# FROM oven/bun:alpine

# WORKDIR /app

# # Instalar dependencias de PostgreSQL
# RUN apk add --no-cache postgresql-client

# # Copiar solo los archivos necesarios para la ejecución
# COPY --from=builder /app/dist /app/dist
# # COPY --from=builder /app/node_modules /app/node_modules
# COPY --from=builder /app/package.json /app/

# EXPOSE 3000

# CMD ["bun", "run", "dist/index.js"] 