# Thin packaging Dockerfile - deliberately does NOT run npm itself. The platform's
# build-image Task runs build.sh (this repo's own build.sh) inside the resolved
# build-agent image BEFORE this Dockerfile builds, producing node_modules in the shared
# workspace. This file just packages what's already been built. See
# platform-cicd's catalog/tasks/build-image.yaml for the two-phase build/package split.
FROM node:20-alpine

# Live-confirmed Trivy findings (governance.imageScan): every "Node.js (node-pkg)" CVE
# Trivy reports on this image comes from npm's OWN bundled internal dependencies
# (/usr/local/lib/node_modules/npm/node_modules/...) shipped inside the node:20-alpine
# base image - not this app's own dependency tree (confirmed: none of tar/glob/
# cross-spawn/brace-expansion/minimatch/ip-address/sigstore appear anywhere in this
# repo's own package-lock.json). This image never runs npm itself (see this file's own
# header) - only `node server.js` at runtime - so npm's own tooling is pure unused
# attack surface here; removing it is what actually clears those findings, not a base-
# image version bump (the CVEs live in npm's vendored deps, which come along in every
# node:*-alpine tag regardless of Node.js version, until npm ships a fix upstream).
# apk upgrade patches the other two findings (libssl3/libcrypto3, one Alpine point
# release behind at build time).
RUN apk upgrade --no-cache \
    && rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx /usr/local/bin/corepack

WORKDIR /app
COPY package*.json server.js ./
COPY node_modules ./node_modules

# Official node images already ship a non-root `node` user at uid 1000 - adduser'ing a
# second uid-1000 user collides and fails the build. Use the one that's already there.
USER node

ENV NODE_ENV=production
ENV PORT=3000
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
  CMD node -e "require('http').get('http://localhost:3000/healthz',r=>process.exit(r.statusCode===200?0:1)).on('error',()=>process.exit(1))"

CMD ["node", "server.js"]
