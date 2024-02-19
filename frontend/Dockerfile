FROM node:lts-alpine AS build

WORKDIR /app

COPY . ./
RUN npm ci
RUN npm run build

FROM node:lts-alpine AS run

COPY --from=build /app/package.json /app/package-lock.json ./
COPY --from=build /app/build build

RUN npm ci --omit dev

CMD [ "node", "build" ]