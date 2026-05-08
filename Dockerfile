 # Etapa 1: Construcción (builder)
  FROM node:18-alpine AS builder
  WORKDIR /app

  # Copiar archivos de dependencias primero (aprovecha la caché de Docker)
  COPY package*.json ./
  RUN npm ci --only=production

  # Copiar el resto del código
  COPY . .

  # Construir la aplicación Next.js (genera .next/standalone y .next/static)
  RUN npm run build

  # Etapa 2: Ejecución (runner)
  FROM node:18-alpine AS runner
  WORKDIR /app

  # Variables de entorno necesarias para Next.js y Railway
  ENV NODE_ENV=production
  ENV PORT=3000
  ENV NEXT_TELEMETRY_DISABLED=1

  # Copiar solo los archivos necesarios de la etapa builder
  COPY --from=builder /app/package*.json ./
  COPY --from=builder /app/.next/standalone ./
  COPY --from=builder /app/.next/static ./.next/static
  COPY --from=builder /app/public ./public

  # Exponer el puerto (Railway lo usará)
  EXPOSE 3000

  # Comando para iniciar la aplicación en modo standalone
  CMD ["node", "server.js"]