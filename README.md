# Base Alpine Linux Node.js Docker images

> Homemade grass-fed lightweight base images for Node.js on top of Alpine
> Linux for super tiny secure and efficient Node.js containers.

## Motivation

While there are [already][alpine-node-dockerfile]
[existing][alpine-node-dockerfile-edge] Alpine Linux Node.js
[images][alpine-node-dockerfile-wonderfall], none allows us to extend
them in a building context; using any Node.js module requiring
compilation force us to explicitly download again all build tools and
Python.

[alpine-node-dockerfile]: https://github.com/mhart/alpine-node/blob/master/Dockerfile
[alpine-node-dockerfile-edge]: https://github.com/cusspvz/node.docker/blob/master/Dockerfile
[alpine-node-dockerfile-wonderfall]: https://github.com/Wonderfall/dockerfiles/blob/master/nodejs/stable/Dockerfile

That's why we made this repo, to build an Alpine Linux Node.js Docker
image including all build dependencies, where you can install modules
that require compilation without extra steps.

## Usage

```sh
docker build -t alpine-node:dev --rm .
```

You can configure the `NODE_VERSION` and `NPM_VERSION` build arguments:

```sh
docker build -t alpine-node:dev --rm . \
    --build-arg NODE_VERSION=4.2.6 \
    --build-arg NPM_VERSION=3
```

**Note:** `NODE_VERSION` have to be the exact version, while
`NPM_VERSION` supports any `npm install` specification.

## Example

Here's an example Dockerfile to build a Node.js application with modules
requiring compilation, on top of our base image:

```dockerfile
FROM alpine-node:dev

RUN mkdir /app
WORKDIR /app

COPY package.json .
RUN npm install --production
COPY . .

CMD npm start
```
