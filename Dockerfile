# syntax = docker/dockerfile:experimental
FROM node:lts AS build
RUN apt-get update && apt-get install -y libaio1 wget unzip
COPY . .
