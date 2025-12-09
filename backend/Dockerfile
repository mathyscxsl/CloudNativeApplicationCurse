FROM node:18-alpine AS build

RUN apk add --no-cache bash git openssl

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . ./
RUN npx prisma generate

FROM node:18-alpine
RUN apk add --no-cache bash git openssl

WORKDIR /app
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app ./

ENV NODE_ENV=production
ENV DATABASE_URL=postgresql://admin:admin123@postgres:5432/gym?schema=public

EXPOSE 3000

CMD npx prisma migrate deploy && node src/index.js
