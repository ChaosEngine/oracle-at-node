# syntax = docker/dockerfile:experimental
FROM oraclelinux:7-slim AS build
RUN  yum -y install oracle-release-el7 oracle-nodejs-release-el7 && \
     yum -y install oracle-instantclient19.10-basiclite && \
	 yum -y install nodejs && \
     rm -rf /var/cache/yum
WORKDIR /app
ADD package.json package-lock.json /app/
RUN npm install

COPY . .
RUN cp ./wallet/* /usr/lib/oracle/19.10/client64/lib/network/admin/




##FROM node:lts-slim
##RUN apt-get update && apt-get install -y libaio1 && rm -rf /var/lib/apt/lists/*
##WORKDIR /app
##COPY --from=build /app/ ./
#RUN echo "$(pwd)"/instantclient_21_1 > /etc/ld.so.conf.d/oracle-instantclient.conf && \
#	ldconfig

CMD exec node index.js