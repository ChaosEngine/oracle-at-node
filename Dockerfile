# syntax = docker/dockerfile:experimental
FROM node:lts AS build
RUN apt-get update && apt-get install -y libaio1 wget unzip
WORKDIR /app
ADD package.json package-lock.json index.js dbconfig.js /app/
RUN --mount=type=cache,target=/root/.npm --mount=type=cache,target=./node_modules npm install

RUN wget https://download.oracle.com/otn_software/linux/instantclient/211000/instantclient-basiclite-linux.x64-21.1.0.0.0.zip && \
	unzip -o instantclient-basiclite-linux.x64-21.1.0.0.0.zip && \
	rm -f instantclient-basiclite-linux.x64-21.1.0.0.0.zip && \
	cd ./instantclient_21_1 && rm -f *jdbc* *occi* *mysql* *mql1* *ipc1* *jar uidrvci genezi adrci && \
	cd ..

RUN echo "$(pwd)"/instantclient_21_1 > /etc/ld.so.conf.d/oracle-instantclient.conf && \
	ldconfig

COPY . .
RUN cp ./wallet/* "$(pwd)"/instantclient_21_1/network/admin/

CMD exec node index.js
