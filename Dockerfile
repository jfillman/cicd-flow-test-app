# Thin packaging Dockerfile - deliberately does NOT run npm itself. The platform's
# build-image Task runs build.sh (this repo's own build.sh) inside the resolved
# build-agent image BEFORE this Dockerfile builds, producing node_modules in the shared
# workspace. This file just packages what's already been built. See
# platform-cicd's catalog/tasks/build-image.yaml for the two-phase build/package split.
FROM node:20-alpine
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
