# syntax = docker/dockerfile:experimental
FROM node:lts-slim AS build
WORKDIR /app

ADD package.json package-lock.json pnpm* /app/
RUN corepack enable pnpm && pnpm install

COPY src/* .
COPY ./wallet/* instantclient/network/admin/




CMD exec node index.js
