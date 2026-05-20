FROM node:22.12-alpine AS builder

# COPY . /app
# COPY tsconfig.json /tsconfig.json

WORKDIR /app

COPY package*.json tsconfig.json index.ts ./

# RUN --mount=type=cache,target=/root/.npm npm install
RUN --mount=type=cache,target=/root/.npm-production npm ci # --ignore-scripts --omit-dev
RUN npx tsc --allowSyntheticDefaultImports --skipLibCheck


FROM node:22-alpine AS release

WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./package.json

# RUN npm ci --ignore-scripts --omit-dev
RUN --mount=type=cache,target=/root/.npm npm ci --omit=dev --ignore-scripts

ENTRYPOINT ["node", "dist/index.js"]