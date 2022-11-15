# syntax = docker/dockerfile:experimental
FROM node:lts-slim AS build
RUN apt-get update && apt-get install -y libaio1 wget unzip && \
	rm -rf /var/lib/apt/lists/*
WORKDIR /app
ADD package.json package-lock.json /app/
RUN npm install

RUN wget https://download.oracle.com/otn_software/linux/instantclient/218000/instantclient-basiclite-linux.x64-21.8.0.0.0dbru.zip && \
	unzip -o *.zip && \
	rm -f *.zip && \
	cd ./instantclient_* && rm -f *jdbc* *occi* *mysql* *mql1* *ipc1* *jar uidrvci genezi adrci && \
	cd ..

COPY src/* .
COPY ./wallet/* instantclient_21_8/network/admin/




#FROM node:lts-slim
#RUN apt-get update && apt-get install -y libaio1 && rm -rf /var/lib/apt/lists/*
#WORKDIR /app
#COPY --from=build /app/ ./
RUN echo "$(pwd)"/instantclient_21_8 > /etc/ld.so.conf.d/oracle-instantclient.conf && \
	ldconfig

CMD exec node index.js