FROM alpine-node:dev

RUN mkdir /app
WORKDIR /app

ONBUILD COPY package.json .
ONBUILD RUN npm install --production
ONBUILD COPY . .
ONBUILD RUN /clean

CMD npm start
