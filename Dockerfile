FROM node:18-slim AS builder
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-slim
RUN useradd -m innovatech_backend
WORKDIR /usr/src/app
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY . .
RUN chown -R innovatech_backend:innovatech_backend /usr/src/app
USER innovatech_backend

EXPOSE 8000
CMD ["node", "index.js"]