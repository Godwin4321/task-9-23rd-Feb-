# ---------- Stage 1: Build ----------
FROM node:18 AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

RUN npm run build

# ---------- Stage 2: Production ----------
FROM node:18

WORKDIR /app

ENV NODE_ENV=production

COPY --from=builder /app ./

EXPOSE 1337

CMD ["npm", "start"]