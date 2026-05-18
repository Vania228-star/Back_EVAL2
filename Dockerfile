FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install

FROM node:18-alpine
WORKDIR /app

RUN addgroup -S nodegroup && adduser -S nodeuser -G nodegroup

COPY --from=builder --chown=nodeuser:nodegroup /app/node_modules ./node_modules

COPY --chown=nodeuser:nodegroup . .

USER nodeuser
EXPOSE 8000
CMD ["node", "server.js"]