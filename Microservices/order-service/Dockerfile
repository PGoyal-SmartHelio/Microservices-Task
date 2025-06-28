FROM node:18 as builder

WORKDIR /app

COPY . .

RUN npm install --only=production

FROM node:18-slim

WORKDIR /app

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/app.js ./app.js

EXPOSE ${ORDER_SERVICE_PORT}

CMD ["npm", "start"]