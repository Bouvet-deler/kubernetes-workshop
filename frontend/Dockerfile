FROM node:lts-alpine AS build

WORKDIR /app

COPY . ./
RUN npm ci --omit dev
RUN npm run build

ENTRYPOINT [ "HOST=127.0.0.1" "PORT=4000" "node" "build" ]