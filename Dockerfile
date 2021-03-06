FROM alpine:3.4

#
# Inspired by:
#
#     https://github.com/mhart/alpine-node
#     https://github.com/cusspvz/node.docker
#     https://github.com/Wonderfall/dockerfiles/tree/master/nodejs
#

# The Node.js version to be installed (without the `v` prefix).
ARG NODE_VERSION=6.9.1

# The npm version to be installed.
ARG NPM_VERSION=3

#
# Build dependencies (not using Alpine `build-base` package to get only
# what we need).
#
#     curl              To fetch the source (Alpine's `wget` have a
#                       "Connection reset by peer" error on Node.js
#                       website).
#     build-base        The build-essentials of Alpine.
#     python            Node.js build chain depends on Python.
#     linux-headers     Node.js depends on some Linux headers.
#     paxctl            Used after compilation to give runtime code
#                       execution capabilities to Node.js binary
#                       (required to run).
#
ARG BUILD_DEPS='curl make gcc g++ binutils-gold python linux-headers paxctl'

#
# Runtime dependencies for Node.js, should not be removed after build.
# Could be removed if building Node.js with `--fully-static` but this
# doesn't allow native bindings in other packages.
#
ARG RUNTIME_DEPS='libgcc libstdc++'

#
# Add dependencies, fetch latest packages list in memory and do not
# cache it.
#
# Get the source for the required Node.js version and extract it.
#
# See <https://github.com/nodejs/node#unix--macintosh>.
#
# The `--without-snapshot` flag is used because V8 snapshots are
# not supported for this architecture. More info on
# <https://github.com/nodejs/node/issues/4212>.
#
# See <https://github.com/mhart/alpine-node/issues/5> for why, and
# eventually paxctl man page <http://man.he.net/man1/paxctl>.
#
# Apply a fix for <https://github.com/npm/npm/issues/9863>.
#
RUN apk add --no-cache ${BUILD_DEPS} ${RUNTIME_DEPS} && \
    curl -s "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}.tar.xz" | tar xJ && \
    cd "/node-v${NODE_VERSION}" && \
    ./configure --without-snapshot --prefix=/usr && \
    make && \
    make install && \
    paxctl -cm /usr/bin/node && \
    cd "$(npm root -g)/npm" && \
    npm install fs-extra && \
    sed -i -e 's/graceful-fs/fs-extra/' -e 's/fs\.rename/fs.move/' lib/utils/rename.js && \
    npm install -g "npm@${NPM_VERSION}" && \
    apk del linux-headers paxctl && \
    find /usr/lib/node_modules/npm -name test -type d | xargs rm -rf && \
    rm -rf "/node-v${NODE_VERSION}" /usr/lib/node_modules/npm/man /usr/lib/node_modules/npm/doc /usr/lib/node_modules/npm/html /root/.npm /root/.node-gyp /tmp/* /var/tmp/* /var/cache/apk/* /usr/share/
