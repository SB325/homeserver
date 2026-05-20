FROM node:22.12-alpine AS builder
WORKDIR /app

# 1. Copy package files first to maximize build caching
COPY package*.json tsconfig.json ./

# 2. Install dependencies (including devDependencies needed for compiling)
RUN --mount=type=cache,target=/root/.npm \
    npm install

# 3. Copy the rest of the source code and build
COPY . .
RUN npm run build

# 4. Create isolated production dependency layer
RUN --mount=type=cache,target=/root/.npm \
    npm ci --ignore-scripts --omit=dev

FROM node:22-alpine AS release
ENV NODE_ENV=production
WORKDIR /app

# 5. Copy only the compiled code and production dependencies
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules /node_modules
COPY --from=builder /app/package*.json /package*.json


ENTRYPOINT ["node", "dist/index.js"]