FROM node:24.1.0-alpine3.20 AS dependencies

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm ci --omit=dev --ignore-scripts --no-audit --no-fund


FROM node:24.1.0-alpine3.20

WORKDIR /app

ENV NODE_ENV=production

# index.js uses curl and openssl; gcompat supports the downloaded glibc binaries.
RUN apk add --no-cache openssl curl gcompat bash \
 && rm -rf /usr/local/lib/node_modules/npm \
            /usr/local/lib/node_modules/corepack \
            /opt/yarn*

COPY --from=dependencies /app/node_modules ./node_modules
COPY index.js package.json ./

EXPOSE 3000/tcp

RUN chmod 0555 index.js

CMD ["node", "index.js"]
