(Files content cropped to 300k characters, download full ingest to see more)
================================================
FILE: README.md
================================================
<p align="center">
  <img src="https://content.umami.is/website/images/umami-logo.png" alt="Umami Logo" width="100">
</p>

<h1 align="center">Umami</h1>

<p align="center">
  <i>Umami is a simple, fast, privacy-focused alternative to Google Analytics.</i>
</p>

<p align="center">
  <a href="https://github.com/umami-software/umami/releases"><img src="https://img.shields.io/github/release/umami-software/umami.svg" alt="GitHub Release" /></a>
  <a href="https://github.com/umami-software/umami/blob/master/LICENSE"><img src="https://img.shields.io/github/license/umami-software/umami.svg" alt="MIT License" /></a>
  <a href="https://github.com/umami-software/umami/actions"><img src="https://img.shields.io/github/actions/workflow/status/umami-software/umami/ci.yml" alt="Build Status" /></a>
  <a href="https://analytics.umami.is/share/LGazGOecbDtaIwDr/umami.is" style="text-decoration: none;"><img src="https://img.shields.io/badge/Try%20Demo%20Now-Click%20Here-brightgreen" alt="Umami Demo" /></a>
</p>

---

## 🚀 Getting Started

A detailed getting started guide can be found at [umami.is/docs](https://umami.is/docs/).

---

## 🛠 Installing from Source

### Requirements

- A server with Node.js version 18.18+.
- A PostgreSQL database version v12.14+.

### Get the source code and install packages

```bash
git clone https://github.com/umami-software/umami.git
cd umami
pnpm install
```

### Configure Umami

Create an `.env` file with the following:

```bash
DATABASE_URL=connection-url
```

The connection URL format:

```bash
postgresql://username:mypassword@localhost:5432/mydb
```

### Build the Application

```bash
pnpm run build
```

The build step will create tables in your database if you are installing for the first time. It will also create a login user with username **admin** and password **umami**.

### Start the Application

```bash
pnpm run start
```

By default, this will launch the application on `http://localhost:3000`. You will need to either [proxy](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/) requests from your web server or change the [port](https://nextjs.org/docs/api-reference/cli#production) to serve the application directly.

---

## 🐳 Installing with Docker

Umami provides Docker images as well as a Docker compose file for easy deployment.

Docker image:

```bash
docker pull docker.umami.is/umami-software/umami:latest
```

Docker compose (Runs Umami with a PostgreSQL database):

```bash
docker compose up -d
```

---

## 🔄 Getting Updates

To get the latest features, simply do a pull, install any new dependencies, and rebuild:

```bash
git pull
pnpm install
pnpm build
```

To update the Docker image, simply pull the new images and rebuild:

```bash
docker compose pull
docker compose up --force-recreate -d
```

---

## 🛟 Support

<p align="center">
  <a href="https://github.com/umami-software/umami"><img src="https://img.shields.io/badge/GitHub--blue?style=social&logo=github" alt="GitHub" /></a>
  <a href="https://twitter.com/umami_software"><img src="https://img.shields.io/badge/Twitter--blue?style=social&logo=twitter" alt="Twitter" /></a>
  <a href="https://linkedin.com/company/umami-software"><img src="https://img.shields.io/badge/LinkedIn--blue?style=social&logo=linkedin" alt="LinkedIn" /></a>
  <a href="https://umami.is/discord"><img src="https://img.shields.io/badge/Discord--blue?style=social&logo=discord" alt="Discord" /></a>
</p>

[release-shield]: https://img.shields.io/github/release/umami-software/umami.svg
[releases-url]: https://github.com/umami-software/umami/releases
[license-shield]: https://img.shields.io/github/license/umami-software/umami.svg
[license-url]: https://github.com/umami-software/umami/blob/master/LICENSE
[build-shield]: https://img.shields.io/github/actions/workflow/status/umami-software/umami/ci.yml
[build-url]: https://github.com/umami-software/umami/actions
[github-shield]: https://img.shields.io/badge/GitHub--blue?style=social&logo=github
[github-url]: https://github.com/umami-software/umami
[twitter-shield]: https://img.shields.io/badge/Twitter--blue?style=social&logo=twitter
[twitter-url]: https://twitter.com/umami_software
[linkedin-shield]: https://img.shields.io/badge/LinkedIn--blue?style=social&logo=linkedin
[linkedin-url]: https://linkedin.com/company/umami-software
[discord-shield]: https://img.shields.io/badge/Discord--blue?style=social&logo=discord
[discord-url]: https://discord.com/invite/4dz4zcXYrQ



================================================
FILE: app.json
================================================
{
  "name": "Umami",
  "description": "Umami is a simple, fast, website analytics alternative to Google Analytics.",
  "keywords": ["analytics", "charts", "statistics", "web-analytics"],
  "website": "https://umami.is",
  "repository": "https://github.com/umami-software/umami",
  "addons": ["heroku-postgresql"],
  "env": {
    "APP_SECRET": {
      "description": "Used to generate unique values for your installation",
      "required": true,
      "generator": "secret"
    }
  },
  "success_url": "/"
}



================================================
FILE: biome.json
================================================
{
  "$schema": "https://biomejs.dev/schemas/2.3.6/schema.json",
  "vcs": {
    "enabled": true,
    "clientKind": "git",
    "useIgnoreFile": true
  },
  "files": {
    "includes": ["**", "!!**/dist"]
  },
  "formatter": {
    "enabled": true,
    "lineWidth": 100,
    "indentStyle": "space",
    "indentWidth": 2,
    "lineEnding": "lf"
  },
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true,
      "a11y": "off",
      "correctness": {
        "useExhaustiveDependencies": "off"
      },
      "style": {
        "noDescendingSpecificity": "off"
      },
      "complexity": {
        "noImportantStyles": "off"
      },
      "suspicious": {
        "noArrayIndexKey": "off",
        "noExplicitAny": "off",
        "noImplicitAnyLet": "off"
      },
      "performance": {
        "noImgElement": "off"
      }
    }
  },
  "javascript": {
    "formatter": {
      "quoteStyle": "single",
      "trailingCommas": "all",
      "arrowParentheses": "asNeeded"
    }
  },
  "css": {
    "formatter": {
      "enabled": true,
      "indentStyle": "space",
      "indentWidth": 2,
      "lineEnding": "lf"
    }
  },
  "assist": {
    "enabled": true,
    "actions": {
      "source": {
        "organizeImports": "on"
      }
    }
  }
}



================================================
FILE: cypress.config.ts
================================================
import { defineConfig } from 'cypress';

export default defineConfig({
  e2e: {
    baseUrl: 'http://localhost:3000',
  },
  // default username / password on init
  env: {
    umami_user: 'admin',
    umami_password: 'umami',
    umami_user_id: '41e2b680-648e-4b09-bcd7-3e2b10c06264',
  },
});



================================================
FILE: docker-compose.yml
================================================
---
services:
  umami:
    image: ghcr.io/umami-software/umami:latest
    ports:
      - "3000:3000"
    environment:
      DATABASE_URL: postgresql://umami:umami@db:5432/umami
      APP_SECRET: replace-me-with-a-random-string
    depends_on:
      db:
        condition: service_healthy
    init: true
    restart: always
    healthcheck:
      test: ["CMD-SHELL", "curl http://localhost:3000/api/heartbeat"]
      interval: 5s
      timeout: 5s
      retries: 5
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: umami
      POSTGRES_USER: umami
      POSTGRES_PASSWORD: umami
    volumes:
      - umami-db-data:/var/lib/postgresql/data
    restart: always
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $${POSTGRES_USER} -d $${POSTGRES_DB}"]
      interval: 5s
      timeout: 5s
      retries: 5
volumes:
  umami-db-data:



================================================
FILE: Dockerfile
================================================
ARG NODE_IMAGE_VERSION="22-alpine"

# Install dependencies only when needed
FROM node:${NODE_IMAGE_VERSION} AS deps
# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm
RUN pnpm install --frozen-lockfile

# Rebuild the source code only when needed
FROM node:${NODE_IMAGE_VERSION} AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
COPY docker/middleware.ts ./src

ARG BASE_PATH

ENV BASE_PATH=$BASE_PATH
ENV NEXT_TELEMETRY_DISABLED=1
ENV DATABASE_URL="postgresql://user:pass@localhost:5432/dummy"

RUN npm run build-docker

# Production image, copy all the files and run next
FROM node:${NODE_IMAGE_VERSION} AS runner
WORKDIR /app

ARG PRISMA_VERSION="6.19.0"
ARG NODE_OPTIONS

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_OPTIONS=$NODE_OPTIONS

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs
RUN set -x \
    && apk add --no-cache curl \
    && npm install -g pnpm

# Script dependencies
RUN pnpm --allow-build='@prisma/engines' add npm-run-all dotenv chalk semver \
    prisma@${PRISMA_VERSION} \
    @prisma/adapter-pg@${PRISMA_VERSION}

COPY --from=builder --chown=nextjs:nodejs /app/public ./public
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/scripts ./scripts
COPY --from=builder /app/generated ./generated

# Automatically leverage output traces to reduce image size
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV HOSTNAME=0.0.0.0
ENV PORT=3000

CMD ["pnpm", "start-docker"]



================================================
FILE: jest.config.ts
================================================
export default {
  roots: ['./src'],
  testMatch: ['**/__tests__/**/*.+(ts|tsx|js)', '**/?(*.)+(spec|test).+(ts|tsx|js)'],
  transform: {
    '^.+\\.(ts|tsx)$': 'ts-jest',
  },
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },
};



================================================
FILE: LICENSE
================================================
MIT License

Copyright (c) 2022 Umami Software, Inc. <hello@umami.is>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.


================================================
FILE: netlify.toml
================================================
[functions]
included_files = ["node_modules/.geo/**"]

[[plugins]]
package = "@netlify/plugin-nextjs"



================================================
FILE: next-env.d.ts
================================================
/// <reference types="next" />
/// <reference types="next/image-types/global" />
/// <reference path="./.next/types/routes.d.ts" />

// NOTE: This file should not be edited
// see https://nextjs.org/docs/app/api-reference/config/typescript for more information.



================================================
FILE: next.config.ts
================================================
import 'dotenv/config';
import pkg from './package.json' with { type: 'json' };

const TRACKER_SCRIPT = '/script.js';

const basePath = process.env.BASE_PATH || '';
const cloudMode = process.env.CLOUD_MODE || '';
const cloudUrl = process.env.CLOUD_URL || '';
const collectApiEndpoint = process.env.COLLECT_API_ENDPOINT || '';
const corsMaxAge = process.env.CORS_MAX_AGE || '';
const defaultLocale = process.env.DEFAULT_LOCALE || '';
const forceSSL = process.env.FORCE_SSL || '';
const frameAncestors = process.env.ALLOWED_FRAME_URLS || '';
const trackerScriptName = process.env.TRACKER_SCRIPT_NAME || '';
const trackerScriptURL = process.env.TRACKER_SCRIPT_URL || '';

const contentSecurityPolicy = `
  default-src 'self';
  img-src 'self' https: data:;
  script-src 'self' 'unsafe-eval' 'unsafe-inline';
  style-src 'self' 'unsafe-inline';
  connect-src 'self' https:;
  frame-ancestors 'self' ${frameAncestors};
`;

const defaultHeaders = [
  {
    key: 'X-DNS-Prefetch-Control',
    value: 'on',
  },
  {
    key: 'Content-Security-Policy',
    value: contentSecurityPolicy.replace(/\s{2,}/g, ' ').trim(),
  },
];

if (forceSSL) {
  defaultHeaders.push({
    key: 'Strict-Transport-Security',
    value: 'max-age=63072000; includeSubDomains; preload',
  });
}

const trackerHeaders = [
  {
    key: 'Access-Control-Allow-Origin',
    value: '*',
  },
  {
    key: 'Cache-Control',
    value: 'public, max-age=86400, must-revalidate',
  },
];

const apiHeaders = [
  {
    key: 'Access-Control-Allow-Origin',
    value: '*',
  },
  {
    key: 'Access-Control-Allow-Headers',
    value: '*',
  },
  {
    key: 'Access-Control-Allow-Methods',
    value: 'GET, DELETE, POST, PUT',
  },
  {
    key: 'Access-Control-Max-Age',
    value: corsMaxAge || '86400',
  },
  {
    key: 'Cache-Control',
    value: 'no-cache',
  },
];

const headers = [
  {
    source: '/api/:path*',
    headers: apiHeaders,
  },
  {
    source: '/:path*',
    headers: defaultHeaders,
  },
  {
    source: TRACKER_SCRIPT,
    headers: trackerHeaders,
  },
];

const rewrites = [];

if (trackerScriptURL) {
  rewrites.push({
    source: TRACKER_SCRIPT,
    destination: trackerScriptURL,
  });
}

if (collectApiEndpoint) {
  headers.push({
    source: collectApiEndpoint,
    headers: apiHeaders,
  });

  rewrites.push({
    source: collectApiEndpoint,
    destination: '/api/send',
  });
}

const redirects = [
  {
    source: '/settings',
    destination: '/settings/preferences',
    permanent: false,
  },
  {
    source: '/teams/:id',
    destination: '/teams/:id/websites',
    permanent: false,
  },
  {
    source: '/teams/:id/settings',
    destination: '/teams/:id/settings/preferences',
    permanent: false,
  },
  {
    source: '/admin',
    destination: '/admin/users',
    permanent: false,
  },
];

// Adding rewrites + headers for all alternative tracker script names.
if (trackerScriptName) {
  const names = trackerScriptName?.split(',').map(name => name.trim());

  if (names) {
    names.forEach(name => {
      const normalizedSource = `/${name.replace(/^\/+/, '')}`;

      rewrites.push({
        source: normalizedSource,
        destination: TRACKER_SCRIPT,
      });

      headers.push({
        source: normalizedSource,
        headers: trackerHeaders,
      });
    });
  }
}

if (cloudMode) {
  rewrites.push({
    source: '/script.js',
    destination: 'https://cloud.umami.is/script.js',
  });
}

/** @type {import('next').NextConfig} */
export default {
  reactStrictMode: false,
  env: {
    basePath,
    cloudMode,
    cloudUrl,
    currentVersion: pkg.version,
    defaultLocale,
  },
  basePath,
  output: 'standalone',
  eslint: {
    ignoreDuringBuilds: true,
  },
  typescript: {
    ignoreBuildErrors: true,
  },
  async headers() {
    return headers;
  },
  async rewrites() {
    return [
      ...rewrites,
      {
        source: '/telemetry.js',
        destination: '/api/scripts/telemetry',
      },
      {
        source: '/teams/:teamId/:path*',
        destination: '/:path*',
      },
    ];
  },
  async redirects() {
    return [...redirects];
  },
};



================================================
FILE: package.components.json
================================================
{
  "name": "@umami/components",
  "version": "0.130.0",
  "description": "Umami React components.",
  "author": "Mike Cao <mike@mikecao.com>",
  "license": "MIT",
  "type": "module",
  "main": "./index.js",
  "types": "./index.d.ts"
}



================================================
FILE: package.json
================================================
{
  "name": "umami",
  "version": "3.0.3",
  "description": "A modern, privacy-focused alternative to Google Analytics.",
  "author": "Umami Software, Inc. <hello@umami.is>",
  "license": "MIT",
  "homepage": "https://umami.is",
  "repository": {
    "type": "git",
    "url": "https://github.com/umami-software/umami.git"
  },
  "type": "module",
  "scripts": {
    "dev": "next dev -p 3001 --turbo",
    "build": "npm-run-all check-env build-db check-db build-tracker build-geo build-app",
    "start": "next start",
    "build-docker": "npm-run-all build-db build-tracker build-geo build-app",
    "start-docker": "npm-run-all check-db update-tracker start-server",
    "start-env": "node scripts/start-env.js",
    "start-server": "node server.js",
    "build-app": "next build --turbo",
    "build-icons": "svgr ./src/assets --out-dir src/components/svg --typescript",
    "build-components": "tsup",
    "build-tracker": "rollup -c rollup.tracker.config.js",
    "build-prisma-client": "node scripts/build-prisma-client.js",
    "build-lang": "npm-run-all format-lang compile-lang download-country-names download-language-names clean-lang",
    "build-geo": "node scripts/build-geo.js",
    "build-db": "npm-run-all build-db-client build-prisma-client",
    "build-db-schema": "prisma db pull",
    "build-db-client": "prisma generate",
    "update-tracker": "node scripts/update-tracker.js",
    "update-db": "prisma migrate deploy",
    "check-db": "node scripts/check-db.js",
    "check-env": "node scripts/check-env.js",
    "copy-db-files": "node scripts/copy-db-files.js",
    "extract-messages": "formatjs extract \"src/components/messages.ts\" --out-file build/extracted-messages.json",
    "merge-messages": "node scripts/merge-messages.js",
    "generate-lang": "npm-run-all extract-messages merge-messages",
    "format-lang": "node scripts/format-lang.js",
    "compile-lang": "formatjs compile-folder --ast build/messages public/intl/messages",
    "clean-lang": "prettier --write ./public/intl/**/*.json",
    "download-country-names": "node scripts/download-country-names.js",
    "download-language-names": "node scripts/download-language-names.js",
    "change-password": "node scripts/change-password.js",
    "prepare": "node -e \"if (process.env.NODE_ENV !== 'production'){process.exit(1)} \" || husky install",
    "postbuild": "node scripts/postbuild.js",
    "test": "jest",
    "cypress-open": "cypress open cypress run",
    "cypress-run": "cypress run cypress run",
    "seed-data": "tsx scripts/seed-data.ts",
    "lint": "biome lint .",
    "format": "biome format --write .",
    "check": "biome check --write"
  },
  "lint-staged": {
    "**/*.{js,jsx,ts,tsx,json,css}": [
      "biome check --write --no-errors-on-unmatched --files-ignore-unknown=true"
    ]
  },
  "cacheDirectories": [
    ".next/cache"
  ],
  "dependencies": {
    "@clickhouse/client": "^1.12.0",
    "@date-fns/utc": "^1.2.0",
    "@dicebear/collection": "^9.2.3",
    "@dicebear/core": "^9.2.3",
    "@fontsource/inter": "^5.2.8",
    "@hello-pangea/dnd": "^17.0.0",
    "@prisma/adapter-pg": "^6.18.0",
    "@prisma/client": "^6.18.0",
    "@prisma/extension-read-replicas": "^0.4.1",
    "@react-spring/web": "^10.0.3",
    "@svgr/cli": "^8.1.0",
    "@tanstack/react-query": "^5.90.11",
    "@umami/react-zen": "^0.211.0",
    "@umami/redis-client": "^0.29.0",
    "bcryptjs": "^3.0.2",
    "chalk": "^5.6.2",
    "chart.js": "^4.5.1",
    "chartjs-adapter-date-fns": "^3.0.0",
    "classnames": "^2.3.1",
    "colord": "^2.9.2",
    "cors": "^2.8.5",
    "cross-spawn": "^7.0.3",
    "date-fns": "^2.23.0",
    "date-fns-tz": "^1.1.4",
    "debug": "^4.4.3",
    "del": "^6.0.0",
    "detect-browser": "^5.2.0",
    "dotenv": "^17.2.3",
    "esbuild": "^0.25.11",
    "fs-extra": "^11.3.2",
    "immer": "^10.2.0",
    "ipaddr.js": "^2.3.0",
    "is-ci": "^3.0.1",
    "is-docker": "^3.0.0",
    "is-localhost-ip": "^2.0.0",
    "isbot": "^5.1.31",
    "jsonwebtoken": "^9.0.2",
    "jszip": "^3.10.1",
    "kafkajs": "^2.1.0",
    "lucide-react": "^0.543.0",
    "maxmind": "^5.0.0",
    "next": "^15.5.9",
    "node-fetch": "^3.2.8",
    "npm-run-all": "^4.1.5",
    "papaparse": "^5.5.3",
    "pg": "^8.16.3",
    "prisma": "^6.18.0",
    "pure-rand": "^7.0.1",
    "react": "^19.2.3",
    "react-dom": "^19.2.3",
    "react-error-boundary": "^4.0.4",
    "react-intl": "^7.1.14",
    "react-simple-maps": "^2.3.0",
    "react-use-measure": "^2.0.4",
    "react-window": "^1.8.6",
    "request-ip": "^3.3.0",
    "semver": "^7.7.3",
    "serialize-error": "^12.0.0",
    "thenby": "^1.3.4",
    "ua-parser-js": "^2.0.6",
    "uuid": "^11.1.0",
    "zod": "^4.1.13",
    "zustand": "^5.0.9"
  },
  "devDependencies": {
    "@biomejs/biome": "^2.3.8",
    "@formatjs/cli": "^4.2.29",
    "@netlify/plugin-nextjs": "^5.15.1",
    "@rollup/plugin-alias": "^5.0.0",
    "@rollup/plugin-commonjs": "^25.0.4",
    "@rollup/plugin-json": "^6.0.0",
    "@rollup/plugin-node-resolve": "^15.2.0",
    "@rollup/plugin-replace": "^5.0.2",
    "@rollup/plugin-terser": "^0.4.4",
    "@rollup/plugin-typescript": "^12.3.0",
    "@types/jest": "^30.0.0",
    "@types/node": "^24.9.2",
    "@types/react": "^19.2.7",
    "@types/react-dom": "^19.2.2",
    "@types/react-window": "^1.8.8",
    "babel-plugin-react-compiler": "19.1.0-rc.2",
    "cross-env": "^10.1.0",
    "cypress": "^13.6.6",
    "extract-react-intl-messages": "^4.1.1",
    "husky": "^9.1.7",
    "jest": "^29.7.0",
    "lint-staged": "^16.2.6",
    "postcss": "^8.5.6",
    "postcss-flexbugs-fixes": "^5.0.2",
    "postcss-import": "^15.1.0",
    "postcss-preset-env": "7.8.3",
    "prompts": "2.4.2",
    "rollup": "^4.52.5",
    "rollup-plugin-copy": "^3.4.0",
    "rollup-plugin-delete": "^3.0.1",
    "rollup-plugin-dts": "^6.3.0",
    "rollup-plugin-node-externals": "^8.1.1",
    "rollup-plugin-peer-deps-external": "^2.2.4",
    "rollup-plugin-postcss": "^4.0.2",
    "stylelint": "^15.10.1",
    "stylelint-config-css-modules": "^4.5.1",
    "stylelint-config-prettier": "^9.0.3",
    "stylelint-config-recommended": "^14.0.0",
    "tar": "^6.1.2",
    "ts-jest": "^29.4.6",
    "ts-node": "^10.9.1",
    "tsup": "^8.5.0",
    "tsx": "^4.19.0",
    "typescript": "^5.9.3"
  }
}



================================================
FILE: pnpm-workspace.yaml
================================================
packages:
  - '**'
ignoredBuiltDependencies:
  - cypress
  - esbuild
  - sharp
onlyBuiltDependencies:
  - '@prisma/client'
  - '@prisma/engines'
  - prisma



================================================
FILE: postcss.config.js
================================================
export default {
  plugins: [
    'postcss-flexbugs-fixes',
    [
      'postcss-preset-env',
      {
        autoprefixer: {
          flexbox: 'no-2009',
        },
        stage: 3,
        features: {
          'custom-properties': false,
        },
      },
    ],
  ],
};



================================================
FILE: prisma.config.ts
================================================
import 'dotenv/config';
import { defineConfig, env } from 'prisma/config';

export default defineConfig({
  datasource: {
    url: env('DATABASE_URL'),
  },
});



================================================
FILE: rollup.tracker.config.js
================================================
import 'dotenv/config';
import replace from '@rollup/plugin-replace';
import terser from '@rollup/plugin-terser';

export default {
  input: 'src/tracker/index.js',
  output: {
    file: 'public/script.js',
    format: 'iife',
  },
  plugins: [
    replace({
      __COLLECT_API_HOST__: process.env.COLLECT_API_HOST || '',
      __COLLECT_API_ENDPOINT__: process.env.COLLECT_API_ENDPOINT || '/api/send',
      delimiters: ['', ''],
      preventAssignment: true,
    }),
    terser({ compress: { evaluate: false } }),
  ],
};



================================================
FILE: tsconfig.json
================================================
{
  "compilerOptions": {
    "target": "es2022",
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "lib": ["dom", "dom.iterable", "esnext"],
    "skipLibCheck": true,
    "esModuleInterop": true,
    "noImplicitAny": false,
    "preserveConstEnums": true,
    "removeComments": true,
    "sourceMap": true,
    "allowSyntheticDefaultImports": true,
    "forceConsistentCasingInFileNames": true,
    "allowJs": true,
    "strict": true,
    "strictNullChecks": false,
    "noEmit": true,
    "jsx": "preserve",
    "incremental": false,
    "baseUrl": ".",
    "outDir": "./build",
    "paths": {
      "@/*": ["./src/*"]
    },
    "plugins": [
      {
        "name": "next"
      }
    ]
  },
  "include": ["**/*.ts", "**/*.tsx", "**/*.js", "**/*.jsx", "next-env.d.ts", ".next/types/**/*.ts"],
  "exclude": ["node_modules", "./cypress.config.ts", "cypress"]
}



================================================
FILE: tsconfig.prisma.json
================================================
{
  "extends": "./tsconfig.json",
  "include": ["src/generated/prisma/client.ts"],
  "compilerOptions": {
    "outDir": "generated/prisma",
    "module": "ESNext",
    "moduleResolution": "Node",
    "target": "ES2020",
    "declaration": false,
    "noEmit": false
  }
}



================================================
FILE: tsup.config.js
================================================
import { defineConfig } from 'tsup';

export default defineConfig({
  entry: { index: 'src/index.ts' },
  format: ['esm'],
  outDir: 'dist',
  dts: true,
  splitting: false,
  sourcemap: false,
  clean: false,
  external: ['react', 'react-dom', 'react/jsx-runtime', '@swc/helpers'],
  esbuildOptions(options) {
    options.jsx = 'automatic';
  },
});



================================================
FILE: .dockerignore
================================================
.git
docker-compose.yml
Dockerfile
.gitignore
.DS_Store
node_modules
.idea
.env
.env.*
scripts/seed
scripts/seed-data.ts



================================================
FILE: .stylelintrc.json
================================================
{
  "extends": ["stylelint-config-recommended", "stylelint-config-css-modules"],
  "rules": {
    "no-descending-specificity": null
  }
}



================================================
FILE: cypress/docker-compose.yml
================================================
---
version: '3'
services:
  umami:
    build: ../
    #image: ghcr.io/umami-software/umami:postgresql-latest
    ports:
      - '3000:3000'
    environment:
      DATABASE_URL: postgresql://umami:umami@db:5432/umami
      DATABASE_TYPE: postgresql
      APP_SECRET: replace-me-with-a-random-string
    depends_on:
      db:
        condition: service_healthy
    restart: always
    healthcheck:
      test: ['CMD-SHELL', 'curl http://localhost:3000/api/heartbeat']
      interval: 5s
      timeout: 5s
      retries: 5
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: umami
      POSTGRES_USER: umami
      POSTGRES_PASSWORD: umami
    volumes:
      - umami-db-data:/var/lib/postgresql/data
    restart: always
    healthcheck:
      test: ['CMD-SHELL', 'pg_isready -U $${POSTGRES_USER} -d $${POSTGRES_DB}']
      interval: 5s
      timeout: 5s
      retries: 5
  cypress:
    image: 'cypress/included:13.6.0'
    depends_on:
      - umami
      - db
    environment:
      - CYPRESS_baseUrl=http://umami:3000
      - CYPRESS_umami_user=admin
      - CYPRESS_umami_password=umami
    volumes:
      - ./tsconfig.json:/tsconfig.json
      - ../cypress.config.ts:/cypress.config.ts
      - ./:/cypress
      - ../node_modules/:/node_modules
      - ../src/lib/crypto.ts:/src/lib/crypto.ts
volumes:
  umami-db-data:



================================================
FILE: cypress/tsconfig.json
================================================
{
  "compilerOptions": {
    "target": "es5",
    "lib": ["es5", "dom"],
    "types": ["cypress", "node"]
  },
  "include": ["**/*.ts", "../cypress.config.ts"]
}



================================================
FILE: cypress/e2e/api-team.cy.ts
================================================
describe('Team API tests', () => {
  Cypress.session.clearAllSavedSessions();

  let teamId;
  let userId;

  before(() => {
    cy.login(Cypress.env('umami_user'), Cypress.env('umami_password'));
    cy.fixture('users').then(data => {
      const userCreate = data.userCreate;
      cy.request({
        method: 'POST',
        url: '/api/users',
        headers: {
          'Content-Type': 'application/json',
          Authorization: Cypress.env('authorization'),
        },
        body: userCreate,
      }).then(response => {
        userId = response.body.id;
        expect(response.status).to.eq(200);
        expect(response.body).to.have.property('username', 'cypress1');
        expect(response.body).to.have.property('role', 'user');
      });
    });
  });

  it('Creates a team.', () => {
    cy.fixture('teams').then(data => {
      const teamCreate = data.teamCreate;
      cy.request({
        method: 'POST',
        url: '/api/teams',
        headers: {
          'Content-Type': 'application/json',
          Authorization: Cypress.env('authorization'),
        },
        body: teamCreate,
      }).then(response => {
        teamId = response.body[0].id;
        expect(response.status).to.eq(200);
        expect(response.body[0]).to.have.property('name', 'cypress');
        expect(response.body[1]).to.have.property('role', 'team-owner');
      });
    });
  });

  it('Gets a teams by ID.', () => {
    cy.request({
      method: 'GET',
      url: `/api/teams/${teamId}`,
      headers: {
        'Content-Type': 'application/json',
        Authorization: Cypress.env('authorization'),
      },
    }).then(response => {
      expect(response.status).to.eq(200);
      expect(response.body).to.have.property('id', teamId);
    });
  });

  it('Updates a team.', () => {
    cy.fixture('teams').then(data => {
      const teamUpdate = data.teamUpdate;
      cy.request({
        method: 'POST',
        url: `/api/teams/${teamId}`,
        headers: {
          'Content-Type': 'application/json',
          Authorization: Cypress.env('authorization'),
        },
        body: teamUpdate,
      }).then(response => {
        expect(response.status).to.eq(200);
        expect(response.body).to.have.property('id', teamId);
        expect(response.body).to.have.property('name', 'cypressUpdate');
      });
    });
  });

  it('Get all users that belong to a team.', () => {
    cy.request({
      method: 'GET',
      url: `/api/teams/${teamId}/users`,
      headers: {
        'Content-Type': 'application/json',
        Authorization: Cypress.env('authorization'),
      },
    }).then(response => {
      expect(response.status).to.eq(200);
      expect(response.body.data[0]).to.have.property('id');
      expect(response.body.data[0]).to.have.property('teamId');
      expect(response.body.data[0]).to.have.property('userId');
      expect(response.body.data[0]).to.have.property('user');
    });
  });

  it('Get a user belonging to a team.', () => {
    cy.request({
      method: 'GET',
      url: `/api/teams/${teamId}/users/${Cypress.env('umami_user_id')}`,
      headers: {
        'Content-Type': 'application/json',
        Authorization: Cypress.env('authorization'),
      },
    }).then(response => {
      expect(response.status).to.eq(200);
      expect(response.body).to.have.property('teamId');
      expect(response.body).to.have.property('userId');
      expect(response.body).to.have.property('role');
    });
  });

  it('Get all websites belonging to a team.', () => {
    cy.request({
      method: 'GET',
      url: `/api/teams/${teamId}/websites`,
      headers: {
        'Content-Type': 'application/json',
        Authorization: Cypress.env('authorization'),
      },
    }).then(response => {
      expect(response.status).to.eq(200);
      expect(response.body).to.have.property('data');
    });
  });

  it('Add a user to a team.', () => {
    cy.request({
      method: 'POST',
      url: `/api/teams/${teamId}/users`,
      headers: {
        'Content-Type': 'application/json',
        Authorization: Cypress.env('authorization'),
      },
      body: {
        userId,
        role: 'team-member',
      },
    }).then(response => {
      expect(response.status).to.eq(200);
      expect(response.body).to.have.property('userId', userId);
      expect(response.body).to.have.property('role', 'team-member');
    });
  });

  it(`Update a user's role on a team.`, () => {
    cy.request({
      method: 'POST',
      url: `/api/teams/${teamId}/users/${userId}`,
      headers: {
        'Content-Type': 'application/json',
        Authorization: Cypress.env('authorization'),
      },
      body: {
        role: 'team-view-only',
      },
    }).then(response => {
      expect(response.status).to.eq(200);
      expect(response.body).to.have.property('userId', userId);
      expect(response.body).to.have.property('role', 'team-view-only');
    });
  });

  it(`Remove a user from a team.`, () => {
    cy.request({
      method: 'DELETE',
      url: `/api/teams/${teamId}/users/${userId}`,
      headers: {
        'Content-Type': 'application/json',
        Authorization: Cypress.env('authorization'),
      },
    }).then(response => {
      expect(response.status).to.eq(200);
    });
  });

  it('Deletes a team.', () => {
    cy.request({
      method: 'DELETE',
      url: `/api/teams/${teamId}`,
      headers: {
        'Content-Type': 'application/json',
        Authorization: Cypress.env('authorization'),
      },
    }).then(response => {
      expect(response.status).to.eq(200);
      expect(response.body).to.have.property('ok', true);
    });
  });

  // it('Gets all teams that belong to a user.', () => {
  //   cy.request({
  //     method: 'GET',
  //     url: `/api/users/${userId}/teams`,
  //     headers: {
  //       'Content-Type': 'application/json',
  //       Authorization: Cypress.env('authorization'),
  //     },
  //   }).then(response => {
  //     expect(response.status).to.eq(200);
  //     expect(response.body).to.have.property('data');
  //   });
  // });

  after(() => {
    cy.deleteUser(userId);
  });
});



================================================
FILE: cypress/e2e/api-user.cy.ts
================================================
describe('User API tests', () => {
  Cypress.session.clearAllSavedSessions();

  before(() => {
    cy.login(Cypress.env('umami_user'), Cypress.env('umami_password'));
  });

  let userId;

  it('Creates a user.', () => {
    cy.fixture('users').then(data => {
      const userCreate = data.userCreate;
      cy.request({
        method: 'POST',
        url: '/api/users',
        headers: {
          'Content-Type': 'application/json',
          Authorization: Cypress.env('authorization'),
        },
        body: userCreate,
      }).then(response => {
        userId = response.body.id;
        expect(response.status).to.eq(200);
        expect(response.body).to.have.property('username', 'cypress1');
        expect(response.body).to.have.property('role', 'user');
      });
    });
  });

  it('Returns all users. Admin access is required.', () => {
    cy.request({
      method: 'GET',
      url: '/api/admin/users',
      headers: {
        'Content-Type': 'application/json',
        Authorization: Cypress.env('authorization'),
      },
    }).then(response => {
      expect(response.status).to.eq(200);
      expect(response.body.data[0]).to.have.property('id');
      expect(response.body.data[0]).to.have.property('username');
      expect(response.body.data[0]).to.have.property('password');
      expect(response.body.data[0]).to.have.property('role');
    });
  });

  it('Updates a user.', () => {
    cy.fixture('users').then(data => {
      const userUpdate = data.userUpdate;
      cy.request({
        method: 'POST',
        url: `/api/users/${userId}`,
        headers: {
          'Content-Type': 'application/json',
          Authorization: Cypress.env('authorization'),
        },
        body: userUpdate,
      }).then(response => {
        userId = response.body.id;
        expect(response.status).to.eq(200);
        expect(response.body).to.have.property('id', userId);
        expect(response.body).to.have.property('username', 'cypress1');
        expect(response.body).to.have.property('role', 'view-only');
      });
    });
  });

  it('Gets a user by ID.', () => {
    cy.request({
      method: 'GET',
      url: `/api/users/${userId}`,
      headers: {
        'Content-Type': 'application/json',
        Authorization: Cypress.env('authorization'),
      },
    }).then(response => {
      expect(response.status).to.eq(200);
      expect(response.body).to.have.property('id', userId);
      expect(response.body).to.have.property('username', 'cypress1');
      expect(response.body).to.have.property('role', 'view-only');
    });
  });

  it('Deletes a user.', () => {
    cy.request({
      method: 'DELETE',
      url: `/api/users/${userId}`,
      headers: {
        'Content-Type': 'application/json',
        Authorization: Cypress.env('authorization'),
      },
    }).then(response => {
      expect(response.status).to.eq(200);
      expect(response.body).to.have.property('ok', true);
    });
  });

  it('Gets all websites that belong to a user.', () => {
    cy.request({
      method: 'GET',
      url: `/api/users/${userId}/websites`,
      headers: {
        'Content-Type': 'application/json',
        Authorization: Cypress.env('authorization'),
      },
    }).then(response => {
      expect(response.status).to.eq(200);
      expect(response.body).to.have.property('data');
    });
  });

  it('Gets all teams that belong to a user.', () => {
    cy.request({
      method: 'GET',
      url: `/api/users/${userId}/teams`,
      headers: {
        'Content-Type': 'application/json',
        Authorization: Cypress.env('authorization'),
      },
    }).then(response => {
      expect(response.status).to.eq(200);
      expect(response.body).to.have.property('data');
    });
  });
});



================================================
FILE: cypress/e2e/api-website.cy.ts
================================================
import { uuid } from '../../src/lib/crypto';

describe('Website API tests', () => {
  Cypress.session.clearAllSavedSessions();

  let websiteId;
  let teamId;

  before(() => {
    cy.login(Cypress.env('umami_user'), Cypress.env('umami_password'));
    cy.fixture('teams').then(data => {
      const teamCreate = data.teamCreate;
      cy.request({
        method: 'POST',
        url: '/api/teams',
        headers: {
          'Content-Type': 'application/json',
          Authorization: Cypress.env('authorization'),
        },
        body: teamCreate,
      }).then(response => {
        teamId = response.body[0].id;
        expect(response.status).to.eq(200);
        expect(response.body[0]).to.have.property('name', 'cypress');
        expect(response.body[1]).to.have.property('role', 'team-owner');
      });
    });
  });

  it('Creates a website for user.', () => {
    cy.fixture('websites').then(data => {
      const websiteCreate = data.websiteCreate;
      cy.request({
        method: 'POST',
        url: '/api/websites',
        headers: {
          'Content-Type': 'application/json',
          Authorization: Cypress.env('authorization'),
        },
        body: websiteCreate,
      }).then(response => {
        websiteId = response.body.id;
        expect(response.status).to.eq(200);
        expect(response.body).to.have.property('name', 'Cypress Website');
        expect(response.body).to.have.property('domain', 'cypress.com');
      });
    });
  });

  it('Creates a website for team.', () => {
    cy.request({
      method: 'POST',
      url: '/api/websites',
      headers: {
        'Content-Type': 'application/json',
        Authorization: Cypress.env('authorization'),
      },
      body: {
        name: 'Team Website',
        domain: 'teamwebsite.com',
        teamId: teamId,
      },
    }).then(response => {
      expect(response.status).to.eq(200);
      expect(response.body).to.have.property('name', 'Team Website');
      expect(response.body).to.have.property('domain', 'teamwebsite.com');
    });
  });

  it('Creates a website with a fixed ID.', () => {
    cy.fixture('websites').then(data => {
      const websiteCreate = data.websiteCreate;
      const fixedId = uuid();
      cy.request({
        method: 'POST',
        url: '/api/websites',
        headers: {
          'Content-Type': 'application/json',
          Authorization: Cypress.env('authorization'),
        },
        body: { ...websiteCreate, id: fixedId },
      }).then(response => {
        expect(response.status).to.eq(200);
        expect(response.body).to.have.property('id', fixedId);
        expect(response.body).to.have.property('name', 'Cypress Website');
        expect(response.body).to.have.property('domain', 'cypress.com');

        // cleanup
        cy.request({
          method: 'DELETE',
          url: `/api/websites/${fixedId}`,
          headers: {
            'Content-Type': 'application/json',
            Authorization: Cypress.env('authorization'),
          },
        });
      });
    });
  });

  it('Returns all tracked websites.', () => {
    cy.request({
      method: 'GET',
      url: '/api/websites',
      headers: {
        'Content-Type': 'application/json',
        Authorization: Cypress.env('authorization'),
      },
    }).then(response => {
      expect(response.status).to.eq(200);
      expect(response.body.data[0]).to.have.property('id');
      expect(response.body.data[0]).to.have.property('name');
      expect(response.body.data[0]).to.have.property('domain');
    });
  });

  it('Gets a website by ID.', () => {
    cy.request({
      method: 'GET',
      url: `/api/websites/${websiteId}`,
      headers: {
        'Content-Type': 'application/json',
        Authorization: Cypress.env('authorization'),
      },
    }).then(response => {
      expect(response.status).to.eq(200);
      expect(response.body).to.have.property('name', 'Cypress Website');
      expect(response.body).to.have.property('domain', 'cypress.com');
    });
  });

  it('Updates a website.', () => {
    cy.fixture('websites').then(data => {
      const websiteUpdate = data.websiteUpdate;
      cy.request({
        method: 'POST',
        url: `/api/websites/${websiteId}`,
        headers: {
          'Content-Type': 'application/json',
          Authorization: Cypress.env('authorization'),
        },
        body: websiteUpdate,
      }).then(response => {
        websiteId = response.body.id;
        expect(response.status).to.eq(200);
        expect(response.body).to.have.property('name', 'Cypress Website Updated');
        expect(response.body).to.have.property('domain', 'cypressupdated.com');
      });
    });
  });

  it('Updates a website with only shareId.', () => {
    cy.request({
      method: 'POST',
      url: `/api/websites/${websiteId}`,
      headers: {
        'Content-Type': 'application/json',
        Authorization: Cypress.env('authorization'),
      },
      body: { shareId: 'ABCDEF' },
    }).then(response => {
      expect(response.status).to.eq(200);
      expect(response.body).to.have.property('shareId', 'ABCDEF');
    });
  });

  it('Resets a website by removing all data related to the website.', () => {
    cy.request({
      method: 'POST',
      url: `/api/websites/${websiteId}/reset`,
      headers: {
        'Content-Type': 'application/json',
        Authorization: Cypress.env('authorization'),
      },
    }).then(response => {
      expect(response.status).to.eq(200);
      expect(response.body).to.have.property('ok', true);
    });
  });

  it('Deletes a website.', () => {
    cy.request({
      method: 'DELETE',
      url: `/api/websites/${websiteId}`,
      headers: {
        'Content-Type': 'application/json',
        Authorization: Cypress.env('authorization'),
      },
    }).then(response => {
      expect(response.status).to.eq(200);
      expect(response.body).to.have.property('ok', true);
    });
  });

  after(() => {
    cy.deleteTeam(teamId);
  });
});



================================================
FILE: cypress/e2e/login.cy.ts
================================================
describe('Login tests', () => {
  beforeEach(() => {
    cy.visit('/login');
  });

  it(
    'logs user in with correct credentials and logs user out',
    {
      defaultCommandTimeout: 10000,
    },
    () => {
      cy.getDataTest('input-username').find('input').as('inputUsername').click();
      cy.get('@inputUsername').type(Cypress.env('umami_user'), { delay: 0 });
      cy.get('@inputUsername').click();
      cy.getDataTest('input-password')
        .find('input')
        .type(Cypress.env('umami_password'), { delay: 0 });
      cy.getDataTest('button-submit').click();
      cy.url().should('eq', Cypress.config().baseUrl + '/dashboard');
      cy.logout();
    },
  );

  it('login with blank inputs or incorrect credentials', () => {
    cy.getDataTest('button-submit').click();
    cy.contains(/Required/i).should('be.visible');

    cy.getDataTest('input-username').find('input').as('inputUsername');
    cy.get('@inputUsername').click();
    cy.get('@inputUsername').type(Cypress.env('umami_user'), { delay: 0 });
    cy.get('@inputUsername').click();
    cy.getDataTest('input-password').find('input').type('wrongpassword', { delay: 0 });
    cy.getDataTest('button-submit').click();
    cy.contains(/Incorrect username and\/or password./i).should('be.visible');
  });
});



================================================
FILE: cypress/e2e/user.cy.ts
================================================
describe('User tests', () => {
  Cypress.session.clearAllSavedSessions();

  beforeEach(() => {
    cy.login(Cypress.env('umami_user'), Cypress.env('umami_password'));
    cy.visit('/settings/users');
  });

  it('Add a User', () => {
    // add user
    cy.contains(/Create user/i).should('be.visible');
    cy.getDataTest('button-create-user').click();
    cy.getDataTest('input-username').find('input').as('inputName').click();
    cy.get('@inputName').type('Test-user', { delay: 0 });
    cy.getDataTest('input-password').find('input').as('inputPassword').click();
    cy.get('@inputPassword').type('testPasswordCypress', { delay: 0 });
    cy.getDataTest('dropdown-role').click();
    cy.getDataTest('dropdown-item-user').click();
    cy.getDataTest('button-submit').click();
    cy.get('td[label="Username"]').should('contain.text', 'Test-user');
    cy.get('td[label="Role"]').should('contain.text', 'User');
  });

  it('Edit a User role and password', () => {
    // edit user
    cy.get('table tbody tr')
      .contains('td', /Test-user/i)
      .parent()
      .within(() => {
        cy.getDataTest('link-button-edit').click(); // Clicks the button inside the row
      });
    cy.getDataTest('input-password').find('input').as('inputPassword').click();
    cy.get('@inputPassword').type('newPassword', { delay: 0 });
    cy.getDataTest('dropdown-role').click();
    cy.getDataTest('dropdown-item-viewOnly').click();
    cy.getDataTest('button-submit').click();

    cy.visit('/settings/users');
    cy.get('table tbody tr')
      .contains('td', /Test-user/i)
      .parent()
      .should('contain.text', 'View only');

    cy.logout();
    cy.url().should('eq', Cypress.config().baseUrl + '/login');
    cy.getDataTest('input-username').find('input').as('inputUsername').click();
    cy.get('@inputUsername').type('Test-user', { delay: 0 });
    cy.get('@inputUsername').click();
    cy.getDataTest('input-password').find('input').type('newPassword', { delay: 0 });
    cy.getDataTest('button-submit').click();
    cy.url().should('eq', Cypress.config().baseUrl + '/dashboard');
  });

  it('Delete a user', () => {
    // delete user
    cy.get('table tbody tr')
      .contains('td', /Test-user/i)
      .parent()
      .within(() => {
        cy.getDataTest('button-delete').click(); // Clicks the button inside the row
      });
    cy.contains(/Are you sure you want to delete Test-user?/i).should('be.visible');
    cy.getDataTest('button-confirm').click();
  });
});



================================================
FILE: cypress/e2e/website.cy.ts
================================================
describe('Website tests', () => {
  Cypress.session.clearAllSavedSessions();

  beforeEach(() => {
    cy.login(Cypress.env('umami_user'), Cypress.env('umami_password'));
  });

  it('Add a website', () => {
    // add website
    cy.visit('/settings/websites');
    cy.getDataTest('button-website-add').click();
    cy.contains(/Add website/i).should('be.visible');
    cy.getDataTest('input-name').find('input').as('inputUsername').click();
    cy.getDataTest('input-name').find('input').type('Add test', { delay: 0 });
    cy.getDataTest('input-domain').find('input').click();
    cy.getDataTest('input-domain').find('input').type('addtest.com', { delay: 0 });
    cy.getDataTest('button-submit').click();
    cy.get('td[label="Name"]').should('contain.text', 'Add test');
    cy.get('td[label="Domain"]').should('contain.text', 'addtest.com');

    // clean-up data
    cy.getDataTest('link-button-edit').first().click();
    cy.contains(/Details/i).should('be.visible');
    cy.getDataTest('text-field-websiteId')
      .find('input')
      .then($input => {
        const websiteId = $input[0].value;
        cy.deleteWebsite(websiteId);
      });
    cy.visit('/settings/websites');
    cy.contains(/Add test/i).should('not.exist');
  });

  it('Edit a website', () => {
    // prep data
    cy.addWebsite('Update test', 'updatetest.com');
    cy.visit('/settings/websites');

    // edit website
    cy.getDataTest('link-button-edit').first().click();
    cy.contains(/Details/i).should('be.visible');
    cy.getDataTest('input-name').find('input').click();
    cy.getDataTest('input-name').find('input').clear();
    cy.getDataTest('input-name').find('input').type('Updated website', { delay: 0 });
    cy.getDataTest('input-domain').find('input').click();
    cy.getDataTest('input-domain').find('input').clear();
    cy.getDataTest('input-domain').find('input').type('updatedwebsite.com', { delay: 0 });
    cy.getDataTest('button-submit').click({ force: true });
    cy.getDataTest('input-name').find('input').should('have.value', 'Updated website');
    cy.getDataTest('input-domain').find('input').should('have.value', 'updatedwebsite.com');

    // verify tracking script
    cy.get('div')
      .contains(/Tracking code/i)
      .click();
    cy.get('textarea').should('contain.text', Cypress.config().baseUrl + '/script.js');

    // clean-up data
    cy.get('div')
      .contains(/Details/i)
      .click();
    cy.contains(/Details/i).should('be.visible');
    cy.getDataTest('text-field-websiteId')
      .find('input')
      .then($input => {
        const websiteId = $input[0].value;
        cy.deleteWebsite(websiteId);
      });
    cy.visit('/settings/websites');
    cy.contains(/Add test/i).should('not.exist');
  });

  it('Delete a website', () => {
    // prep data
    cy.addWebsite('Delete test', 'deletetest.com');
    cy.visit('/settings/websites');

    // delete website
    cy.getDataTest('link-button-edit').first().click();
    cy.contains(/Data/i).should('be.visible');
    cy.get('div').contains(/Data/i).click();
    cy.contains(/All website data will be deleted./i).should('be.visible');
    cy.getDataTest('button-delete').click();
    cy.contains(/Type DELETE in the box below to confirm./i).should('be.visible');
    cy.get('input[name="confirm"').type('DELETE');
    cy.get('button[type="submit"]').click();
    cy.contains(/Delete test/i).should('not.exist');
  });
});



================================================
FILE: cypress/fixtures/teams.json
================================================
{
  "teamCreate": {
    "name": "cypress"
  },
  "teamUpdate": {
    "name": "cypressUpdate"
  }
}



================================================
FILE: cypress/fixtures/users.json
================================================
{
  "userCreate": {
    "username": "cypress1",
    "password": "password",
    "role": "user"
  },
  "userUpdate": {
    "username": "cypress1",
    "role": "view-only"
  }
}



================================================
FILE: cypress/fixtures/websites.json
================================================
{
  "websiteCreate": {
    "name": "Cypress Website",
    "domain": "cypress.com"
  },
  "websiteUpdate": {
    "name": "Cypress Website Updated",
    "domain": "cypressupdated.com"
  }
}



================================================
FILE: cypress/support/e2e.ts
================================================
/// <reference types="cypress" />
import { uuid } from '../../src/lib/crypto';

Cypress.Commands.add('getDataTest', (value: string) => {
  return cy.get(`[data-test=${value}]`);
});

Cypress.Commands.add('logout', () => {
  cy.getDataTest('button-profile').click();
  cy.getDataTest('item-logout').click();
  cy.url().should('eq', Cypress.config().baseUrl + '/login');
});

Cypress.Commands.add('login', (username: string, password: string) => {
  cy.session([username, password], () => {
    cy.request({
      method: 'POST',
      url: '/api/auth/login',
      body: {
        username,
        password,
      },
    })
      .then(response => {
        Cypress.env('authorization', `bearer ${response.body.token}`);
        window.localStorage.setItem('umami.auth', JSON.stringify(response.body.token));
      })
      .its('status')
      .should('eq', 200);
  });
});

Cypress.Commands.add('addWebsite', (name: string, domain: string) => {
  cy.request({
    method: 'POST',
    url: '/api/websites',
    headers: {
      'Content-Type': 'application/json',
      Authorization: Cypress.env('authorization'),
    },
    body: {
      id: uuid(),
      createdBy: '41e2b680-648e-4b09-bcd7-3e2b10c06264',
      name: name,
      domain: domain,
    },
  }).then(response => {
    expect(response.status).to.eq(200);
  });
});

Cypress.Commands.add('deleteWebsite', (websiteId: string) => {
  cy.request({
    method: 'DELETE',
    url: `/api/websites/${websiteId}`,
    headers: {
      'Content-Type': 'application/json',
      Authorization: Cypress.env('authorization'),
    },
  }).then(response => {
    expect(response.status).to.eq(200);
  });
});

Cypress.Commands.add('addUser', (username: string, password: string, role: string) => {
  cy.request({
    method: 'POST',
    url: '/api/users',
    headers: {
      'Content-Type': 'application/json',
      Authorization: Cypress.env('authorization'),
    },
    body: {
      username: username,
      password: password,
      role: role,
    },
  }).then(response => {
    expect(response.status).to.eq(200);
  });
});

Cypress.Commands.add('deleteUser', (userId: string) => {
  cy.request({
    method: 'DELETE',
    url: `/api/users/${userId}`,
    headers: {
      'Content-Type': 'application/json',
      Authorization: Cypress.env('authorization'),
    },
  }).then(response => {
    expect(response.status).to.eq(200);
  });
});

Cypress.Commands.add('addTeam', (name: string) => {
  cy.request({
    method: 'POST',
    url: '/api/teams',
    headers: {
      'Content-Type': 'application/json',
      Authorization: Cypress.env('authorization'),
    },
    body: {
      name: name,
    },
  }).then(response => {
    expect(response.status).to.eq(200);
  });
});

Cypress.Commands.add('deleteTeam', (teamId: string) => {
  cy.request({
    method: 'DELETE',
    url: `/api/teams/${teamId}`,
    headers: {
      'Content-Type': 'application/json',
      Authorization: Cypress.env('authorization'),
    },
  }).then(response => {
    expect(response.status).to.eq(200);
  });
});



================================================
FILE: cypress/support/index.d.ts
================================================
/// <reference types="cypress" />
/* global JQuery */

declare namespace Cypress {
  interface Chainable {
    /**
     * Custom command to select DOM element by data-test attribute.
     * @example cy.getDataTest('greeting')
     */
    getDataTest(value: string): Chainable<JQuery<HTMLElement>>;
    /**
     * Custom command to logout through UI.
     * @example cy.logout()
     */
    logout(): Chainable<JQuery<HTMLElement>>;
    /**
     * Custom command to login user into the app.
     * @example cy.login('admin', 'password)
     */
    login(username: string, password: string): Chainable<JQuery<HTMLElement>>;
    /**
     * Custom command to create a website
     * @example cy.addWebsite('test', 'test.com')
     */
    addWebsite(name: string, domain: string): Chainable<JQuery<HTMLElement>>;
    /**
     * Custom command to delete a website
     * @example cy.deleteWebsite('02d89813-7a72-41e1-87f0-8d668f85008b')
     */
    deleteWebsite(websiteId: string): Chainable<JQuery<HTMLElement>>;
    /**
     * Custom command to create a website
     * @example cy.deleteWebsite('02d89813-7a72-41e1-87f0-8d668f85008b')
     */
    /**
     * Custom command to create a user
     * @example cy.addUser('cypress', 'password', 'User')
     */
    addUser(username: string, password: string, role: string): Chainable<JQuery<HTMLElement>>;
    /**
     * Custom command to delete a user
     * @example cy.deleteUser('02d89813-7a72-41e1-87f0-8d668f85008b')
     */
    deleteUser(userId: string): Chainable<JQuery<HTMLElement>>;
    /**
     * Custom command to create a team
     * @example cy.addTeam('cypressTeam')
     */
    addTeam(name: string): Chainable<JQuery<HTMLElement>>;
    /**
     * Custom command to create a website
     * @example cy.deleteTeam('02d89813-7a72-41e1-87f0-8d668f85008b')
     */
    deleteTeam(teamId: string): Chainable<JQuery<HTMLElement>>;
  }
}



================================================
FILE: db/clickhouse/schema.sql
================================================
-- Create Event
CREATE TABLE umami.website_event
(
    website_id UUID,
    session_id UUID,
    visit_id UUID,
    event_id UUID,
    --sessions
    hostname LowCardinality(String),
    browser LowCardinality(String),
    os LowCardinality(String),
    device LowCardinality(String),
    screen LowCardinality(String),
    language LowCardinality(String),
    country LowCardinality(String),
    region LowCardinality(String),
    city String,
    --pageviews
    url_path String,
    url_query String,
    utm_source String,
    utm_medium String,
    utm_campaign String,
    utm_content String,
    utm_term String,
    referrer_path String,
    referrer_query String,
    referrer_domain String,
    page_title String,
    --clickIDs
    gclid String,
    fbclid String,
    msclkid String,
    ttclid String,
    li_fat_id String,
    twclid String,
    --events
    event_type UInt32,
    event_name String,
    tag String,
    distinct_id String,
    created_at DateTime('UTC'),
    job_id Nullable(UUID)
)
ENGINE = MergeTree
    PARTITION BY toYYYYMM(created_at)
    ORDER BY (toStartOfHour(created_at), website_id, session_id, visit_id, created_at)
    PRIMARY KEY (toStartOfHour(created_at), website_id, session_id, visit_id)
    SETTINGS index_granularity = 8192;

CREATE TABLE umami.event_data
(
    website_id UUID,
    session_id UUID,
    event_id UUID,
    url_path String,
    event_name String,
    data_key String,
    string_value Nullable(String),
    number_value Nullable(Decimal(22, 4)),
    date_value Nullable(DateTime('UTC')),
    data_type UInt32,
    created_at DateTime('UTC'),
    job_id Nullable(UUID)
)
ENGINE = MergeTree
    ORDER BY (website_id, event_id, data_key, created_at)
    SETTINGS index_granularity = 8192;

CREATE TABLE umami.session_data
(
    website_id UUID,
    session_id UUID,
    data_key String,
    string_value Nullable(String),
    number_value Nullable(Decimal(22, 4)),
    date_value Nullable(DateTime('UTC')),
    data_type UInt32,
    distinct_id String,
    created_at DateTime('UTC'),
    job_id Nullable(UUID)
)
ENGINE = ReplacingMergeTree
    ORDER BY (website_id, session_id, data_key)
    SETTINGS index_granularity = 8192;

-- stats hourly
CREATE TABLE umami.website_event_stats_hourly
(
    website_id UUID,
    session_id UUID,
    visit_id UUID,
    hostname SimpleAggregateFunction(groupArrayArray, Array(String)),
    browser LowCardinality(String),
    os LowCardinality(String),
    device LowCardinality(String),
    screen LowCardinality(String),
    language LowCardinality(String),
    country LowCardinality(String),
    region LowCardinality(String),
    city String,
    entry_url AggregateFunction(argMin, String, DateTime('UTC')),
    exit_url AggregateFunction(argMax, String, DateTime('UTC')),
    url_path SimpleAggregateFunction(groupArrayArray, Array(String)),
    url_query SimpleAggregateFunction(groupArrayArray, Array(String)),
    utm_source SimpleAggregateFunction(groupArrayArray, Array(String)),
    utm_medium SimpleAggregateFunction(groupArrayArray, Array(String)),
    utm_campaign SimpleAggregateFunction(groupArrayArray, Array(String)),
    utm_content SimpleAggregateFunction(groupArrayArray, Array(String)),
    utm_term SimpleAggregateFunction(groupArrayArray, Array(String)),
    referrer_domain SimpleAggregateFunction(groupArrayArray, Array(String)),
    page_title SimpleAggregateFunction(groupArrayArray, Array(String)),
    gclid SimpleAggregateFunction(groupArrayArray, Array(String)),
    fbclid SimpleAggregateFunction(groupArrayArray, Array(String)),
    msclkid SimpleAggregateFunction(groupArrayArray, Array(String)),
    ttclid SimpleAggregateFunction(groupArrayArray, Array(String)),
    li_fat_id SimpleAggregateFunction(groupArrayArray, Array(String)),
    twclid SimpleAggregateFunction(groupArrayArray, Array(String)),
    event_type UInt32,
    event_name SimpleAggregateFunction(groupArrayArray, Array(String)),
    views SimpleAggregateFunction(sum, UInt64),
    min_time SimpleAggregateFunction(min, DateTime('UTC')),
    max_time SimpleAggregateFunction(max, DateTime('UTC')),
    tag SimpleAggregateFunction(groupArrayArray, Array(String)),
    distinct_id String,
    created_at Datetime('UTC')
)
ENGINE = AggregatingMergeTree
    PARTITION BY toYYYYMM(created_at)
    ORDER BY (
        website_id,
        event_type,
        toStartOfHour(created_at),
        cityHash64(visit_id),
        visit_id
    )
    SAMPLE BY cityHash64(visit_id);

CREATE MATERIALIZED VIEW umami.website_event_stats_hourly_mv
TO umami.website_event_stats_hourly
AS
SELECT
    website_id,
    session_id,
    visit_id,
    hostnames as hostname,
    browser,
    os,
    device,
    screen,
    language,
    country,
    region,
    city,
    entry_url,
    exit_url,
    url_paths as url_path,
    url_query,
    utm_source,
    utm_medium,
    utm_campaign,
    utm_content,
    utm_term,
    referrer_domain,
    page_title,
    gclid,
    fbclid,
    msclkid,
    ttclid,
    li_fat_id,
    twclid,
    event_type,
    event_name,
    views,
    min_time,
    max_time,
    tag,
    distinct_id,
    timestamp as created_at
FROM (SELECT
    website_id,
    session_id,
    visit_id,
    arrayFilter(x -> x != '', groupArray(hostname)) hostnames,
    browser,
    os,
    device,
    screen,
    language,
    country,
    region,
    city,
    argMinState(url_path, created_at) entry_url,
    argMaxState(url_path, created_at) exit_url,
    arrayFilter(x -> x != '', groupArray(url_path)) as url_paths,
    arrayFilter(x -> x != '', groupArray(url_query)) url_query,
    arrayFilter(x -> x != '', groupArray(utm_source)) utm_source,
    arrayFilter(x -> x != '', groupArray(utm_medium)) utm_medium,
    arrayFilter(x -> x != '', groupArray(utm_campaign)) utm_campaign,
    arrayFilter(x -> x != '', groupArray(utm_content)) utm_content,
    arrayFilter(x -> x != '', groupArray(utm_term)) utm_term,
    arrayFilter(x -> x != '' and x != hostname, groupArray(referrer_domain)) referrer_domain,
    arrayFilter(x -> x != '', groupArray(page_title)) page_title,
    arrayFilter(x -> x != '', groupArray(gclid)) gclid,
    arrayFilter(x -> x != '', groupArray(fbclid)) fbclid,
    arrayFilter(x -> x != '', groupArray(msclkid)) msclkid,
    arrayFilter(x -> x != '', groupArray(ttclid)) ttclid,
    arrayFilter(x -> x != '', groupArray(li_fat_id)) li_fat_id,
    arrayFilter(x -> x != '', groupArray(twclid)) twclid,
    event_type,
    if(event_type = 2, groupArray(event_name), []) event_name,
    sumIf(1, event_type != 2) views,
    min(created_at) min_time,
    max(created_at) max_time,
    arrayFilter(x -> x != '', groupArray(tag)) tag,
    distinct_id,
    toStartOfHour(created_at) timestamp
FROM umami.website_event
GROUP BY website_id,
    session_id,
    visit_id,
    hostname,
    browser,
    os,
    device,
    screen,
    language,
    country,
    region,
    city,
    event_type,
    distinct_id,
    timestamp);

-- projections
ALTER TABLE umami.website_event 
ADD PROJECTION website_event_url_path_projection (
SELECT * ORDER BY toStartOfDay(created_at), website_id, url_path, created_at
);

ALTER TABLE umami.website_event MATERIALIZE PROJECTION website_event_url_path_projection;

ALTER TABLE umami.website_event 
ADD PROJECTION website_event_referrer_domain_projection (
SELECT * ORDER BY toStartOfDay(created_at), website_id, referrer_domain, created_at
);

ALTER TABLE umami.website_event MATERIALIZE PROJECTION website_event_referrer_domain_projection;

-- revenue
CREATE TABLE umami.website_revenue
(
    website_id UUID,
    session_id UUID,
    event_id UUID,
    event_name String,
    currency String,
    revenue DECIMAL(18,4),
    created_at DateTime('UTC')
)
ENGINE = MergeTree
    PARTITION BY toYYYYMM(created_at)
    ORDER BY (website_id, session_id, created_at)
    SETTINGS index_granularity = 8192;


CREATE MATERIALIZED VIEW umami.website_revenue_mv
TO umami.website_revenue
AS
SELECT DISTINCT
    ed.website_id,
    ed.session_id,
    ed.event_id,
    ed.event_name,
    c.currency,
    coalesce(toDecimal64(ed.number_value, 2), toDecimal64(ed.string_value, 2)) revenue,
    ed.created_at
FROM umami.event_data ed
JOIN (SELECT event_id, string_value as currency
        FROM umami.event_data
        WHERE positionCaseInsensitive(data_key, 'currency') > 0) c
      ON c.event_id = ed.event_id
WHERE positionCaseInsensitive(data_key, 'revenue') > 0;



================================================
FILE: db/clickhouse/migrations/01_edit_keys.sql
================================================
-- edit event_data values
ALTER TABLE "event_data" RENAME COLUMN "event_date_value" TO "date_value";
ALTER TABLE "event_data" RENAME COLUMN "event_numeric_value" TO "number_value";
ALTER TABLE "event_data" RENAME COLUMN "event_string_value" TO "string_value";
ALTER TABLE "event_data" RENAME COLUMN "event_data_type" TO "data_type";

-- add job_id
ALTER TABLE "website_event" ADD COLUMN "job_id" UUID AFTER "created_at";
ALTER TABLE "event_data" ADD COLUMN "job_id" UUID AFTER "created_at";

-- update event_data string
alter table umami.event_data
update string_value = number_value
where data_type = 2

alter table umami.event_data
update string_value = replaceOne(concat(CAST(toDateTime(date_value, 'UTC'), 'String'),'Z'), ' ', 'T')
where data_type = 4


================================================
FILE: db/clickhouse/migrations/02_add_visit_id.sql
================================================
CREATE TABLE umami.website_event_join
(
    session_id UUID,
    visit_id UUID,
    created_at DateTime('UTC')
)
    engine = MergeTree
        ORDER BY (session_id, created_at)
        SETTINGS index_granularity = 8192;

INSERT INTO umami.website_event_join
SELECT DISTINCT
    s.session_id,
    generateUUIDv4() visit_id,
    s.created_at
FROM (SELECT DISTINCT session_id,
        date_trunc('hour', created_at) created_at
    FROM website_event) s;

-- create new table
CREATE TABLE umami.website_event_new
(
    website_id UUID,
    session_id UUID,
    visit_id UUID,
    event_id UUID,
    hostname LowCardinality(String),
    browser LowCardinality(String),
    os LowCardinality(String),
    device LowCardinality(String),
    screen LowCardinality(String),
    language LowCardinality(String),
    country LowCardinality(String),
    subdivision1 LowCardinality(String),
    subdivision2 LowCardinality(String),
    city String,
    url_path String,
    url_query String,
    referrer_path String,
    referrer_query String,
    referrer_domain String,
    page_title String,
    event_type UInt32,
    event_name String,
    created_at DateTime('UTC'),
    job_id UUID
)
    engine = MergeTree
        ORDER BY (website_id, session_id, created_at)
        SETTINGS index_granularity = 8192;

INSERT INTO umami.website_event_new
SELECT we.website_id,
    we.session_id,
    j.visit_id,
    we.event_id,
    we.hostname,
    we.browser,
    we.os,
    we.device,
    we.screen,
    we.language,
    we.country,
    we.subdivision1,
    we.subdivision2,
    we.city,
    we.url_path,
    we.url_query,
    we.referrer_path,
    we.referrer_query,
    we.referrer_domain,
    we.page_title,
    we.event_type,
    we.event_name,
    we.created_at,
    we.job_id
FROM umami.website_event we
JOIN umami.website_event_join j
    ON we.session_id = j.session_id
        and date_trunc('hour', we.created_at) = j.created_at

RENAME TABLE umami.website_event TO umami.website_event_old;
RENAME TABLE umami.website_event_new TO umami.website_event;

/*

 DROP TABLE umami.website_event_old
 DROP TABLE umami.website_event_join

 */


================================================
FILE: db/clickhouse/migrations/03_session_data.sql
================================================
CREATE TABLE umami.event_data_new
(
    website_id UUID,
    session_id UUID,
    event_id UUID,
    url_path String,
    event_name String,
    data_key String,
    string_value Nullable(String),
    number_value Nullable(Decimal64(4)),
    date_value Nullable(DateTime('UTC')),
    data_type UInt32,
    created_at DateTime('UTC'),
    job_id Nullable(UUID)
)
    engine = MergeTree
        ORDER BY (website_id, event_id, data_key, created_at)
        SETTINGS index_granularity = 8192;

INSERT INTO umami.event_data_new
SELECT website_id,
    session_id,
    event_id,
    url_path,
    event_name,
    event_key,
    string_value,
    number_value,
    date_value,
    data_type,
    created_at,
    NULL
FROM umami.event_data;

CREATE TABLE umami.session_data
(
    website_id UUID,
    session_id UUID,
    data_key String,
    string_value Nullable(String),
    number_value Nullable(Decimal64(4)),
    date_value Nullable(DateTime('UTC')),
    data_type UInt32,
    created_at DateTime('UTC'),
    job_id Nullable(UUID)
)
    engine = MergeTree
        ORDER BY (website_id, session_id, data_key, created_at)
        SETTINGS index_granularity = 8192;

RENAME TABLE umami.event_data TO umami.event_data_old;
RENAME TABLE umami.event_data_new TO umami.event_data;

/*
DROP TABLE umami.event_data_old
 */




================================================
FILE: db/clickhouse/migrations/04_add_tag.sql
================================================
-- add tag column
ALTER TABLE umami.website_event ADD COLUMN "tag" String AFTER "event_name";
ALTER TABLE umami.website_event_stats_hourly ADD COLUMN "tag" SimpleAggregateFunction(groupArrayArray, Array(String)) AFTER "max_time";

-- update materialized view
DROP TABLE umami.website_event_stats_hourly_mv;

CREATE MATERIALIZED VIEW umami.website_event_stats_hourly_mv
TO umami.website_event_stats_hourly
AS
SELECT
    website_id,
    session_id,
    visit_id,
    hostname,
    browser,
    os,
    device,
    screen,
    language,
    country,
    subdivision1,
    city,
    entry_url,
    exit_url,
    url_paths as url_path,
    url_query,
    referrer_domain,
    page_title,
    event_type,
    event_name,
    views,
    min_time,
    max_time,
    tag,
    timestamp as created_at
FROM (SELECT
    website_id,
    session_id,
    visit_id,
    hostname,
    browser,
    os,
    device,
    screen,
    language,
    country,
    subdivision1,
    city,
    argMinState(url_path, created_at) entry_url,
    argMaxState(url_path, created_at) exit_url,
    arrayFilter(x -> x != '', groupArray(url_path)) as url_paths,
    arrayFilter(x -> x != '', groupArray(url_query)) url_query,
    arrayFilter(x -> x != '', groupArray(referrer_domain)) referrer_domain,
    arrayFilter(x -> x != '', groupArray(page_title)) page_title,
    event_type,
    if(event_type = 2, groupArray(event_name), []) event_name,
    sumIf(1, event_type = 1) views,
    min(created_at) min_time,
    max(created_at) max_time,
    arrayFilter(x -> x != '', groupArray(tag)) tag,
    toStartOfHour(created_at) timestamp
FROM umami.website_event
GROUP BY website_id,
    session_id,
    visit_id,
    hostname,
    browser,
    os,
    device,
    screen,
    language,
    country,
    subdivision1,
    city,
    event_type,
    timestamp);


================================================
FILE: db/clickhouse/migrations/05_add_utm_clid.sql
================================================
-- Create Event
CREATE TABLE umami.website_event_new
(
    website_id UUID,
    session_id UUID,
    visit_id UUID,
    event_id UUID,
    --sessions
    hostname LowCardinality(String),
    browser LowCardinality(String),
    os LowCardinality(String),
    device LowCardinality(String),
    screen LowCardinality(String),
    language LowCardinality(String),
    country LowCardinality(String),
    subdivision1 LowCardinality(String),
    subdivision2 LowCardinality(String),
    city String,
    --pageviews
    url_path String,
    url_query String,
    utm_source String,
    utm_medium String,
    utm_campaign String,
    utm_content String,
    utm_term String,
    referrer_path String,
    referrer_query String,
    referrer_domain String,
    page_title String,
    --clickIDs
    gclid String,
    fbclid String,
    msclkid String,
    ttclid String,
    li_fat_id String,
    twclid String,
    --events
    event_type UInt32,
    event_name String,
    tag String,
    created_at DateTime('UTC'),
    job_id Nullable(UUID)
)
ENGINE = MergeTree
    PARTITION BY toYYYYMM(created_at)
    ORDER BY (toStartOfHour(created_at), website_id, session_id, visit_id, created_at)
    PRIMARY KEY (toStartOfHour(created_at), website_id, session_id, visit_id)
    SETTINGS index_granularity = 8192;

-- stats hourly
CREATE TABLE umami.website_event_stats_hourly_new
(
    website_id UUID,
    session_id UUID,
    visit_id UUID,
    hostname LowCardinality(String),
    browser LowCardinality(String),
    os LowCardinality(String),
    device LowCardinality(String),
    screen LowCardinality(String),
    language LowCardinality(String),
    country LowCardinality(String),
    subdivision1 LowCardinality(String),
    city String,
    entry_url AggregateFunction(argMin, String, DateTime('UTC')),
    exit_url AggregateFunction(argMax, String, DateTime('UTC')),
    url_path SimpleAggregateFunction(groupArrayArray, Array(String)),
    url_query SimpleAggregateFunction(groupArrayArray, Array(String)),
    utm_source SimpleAggregateFunction(groupArrayArray, Array(String)),
    utm_medium SimpleAggregateFunction(groupArrayArray, Array(String)),
    utm_campaign SimpleAggregateFunction(groupArrayArray, Array(String)),
    utm_content SimpleAggregateFunction(groupArrayArray, Array(String)),
    utm_term SimpleAggregateFunction(groupArrayArray, Array(String)),
    referrer_domain SimpleAggregateFunction(groupArrayArray, Array(String)),
    page_title SimpleAggregateFunction(groupArrayArray, Array(String)),
    gclid SimpleAggregateFunction(groupArrayArray, Array(String)),
    fbclid SimpleAggregateFunction(groupArrayArray, Array(String)),
    msclkid SimpleAggregateFunction(groupArrayArray, Array(String)),
    ttclid SimpleAggregateFunction(groupArrayArray, Array(String)),
    li_fat_id SimpleAggregateFunction(groupArrayArray, Array(String)),
    twclid SimpleAggregateFunction(groupArrayArray, Array(String)),
    event_type UInt32,
    event_name SimpleAggregateFunction(groupArrayArray, Array(String)),
    views SimpleAggregateFunction(sum, UInt64),
    min_time SimpleAggregateFunction(min, DateTime('UTC')),
    max_time SimpleAggregateFunction(max, DateTime('UTC')),
    tag SimpleAggregateFunction(groupArrayArray, Array(String)),
    created_at Datetime('UTC')
)
ENGINE = AggregatingMergeTree
    PARTITION BY toYYYYMM(created_at)
    ORDER BY (
        website_id,
        event_type,
        toStartOfHour(created_at),
        cityHash64(visit_id),
        visit_id
    )
    SAMPLE BY cityHash64(visit_id);

CREATE MATERIALIZED VIEW umami.website_event_stats_hourly_mv_new
TO umami.website_event_stats_hourly_new
AS
SELECT
    website_id,
    session_id,
    visit_id,
    hostname,
    browser,
    os,
    device,
    screen,
    language,
    country,
    subdivision1,
    city,
    entry_url,
    exit_url,
    url_paths as url_path,
    url_query,
    utm_source,
    utm_medium,
    utm_campaign,
    utm_content,
    utm_term,
    referrer_domain,
    page_title,
    gclid,
    fbclid,
    msclkid,
    ttclid,
    li_fat_id,
    twclid,
    event_type,
    event_name,
    views,
    min_time,
    max_time,
    tag,
    timestamp as created_at
FROM (SELECT
    website_id,
    session_id,
    visit_id,
    hostname,
    browser,
    os,
    device,
    screen,
    language,
    country,
    subdivision1,
    city,
    argMinState(url_path, created_at) entry_url,
    argMaxState(url_path, created_at) exit_url,
    arrayFilter(x -> x != '', groupArray(url_path)) as url_paths,
    arrayFilter(x -> x != '', groupArray(url_query)) url_query,
    arrayFilter(x -> x != '', groupArray(utm_source)) utm_source,
    arrayFilter(x -> x != '', groupArray(utm_medium)) utm_medium,
    arrayFilter(x -> x != '', groupArray(utm_campaign)) utm_campaign,
    arrayFilter(x -> x != '', groupArray(utm_content)) utm_content,
    arrayFilter(x -> x != '', groupArray(utm_term)) utm_term,
    arrayFilter(x -> x != '', groupArray(referrer_domain)) referrer_domain,
    arrayFilter(x -> x != '', groupArray(page_title)) page_title,
    arrayFilter(x -> x != '', groupArray(gclid)) gclid,
    arrayFilter(x -> x != '', groupArray(fbclid)) fbclid,
    arrayFilter(x -> x != '', groupArray(msclkid)) msclkid,
    arrayFilter(x -> x != '', groupArray(ttclid)) ttclid,
    arrayFilter(x -> x != '', groupArray(li_fat_id)) li_fat_id,
    arrayFilter(x -> x != '', groupArray(twclid)) twclid,
    event_type,
    if(event_type = 2, groupArray(event_name), []) event_name,
    sumIf(1, event_type = 1) views,
    min(created_at) min_time,
    max(created_at) max_time,
    arrayFilter(x -> x != '', groupArray(tag)) tag,
    toStartOfHour(created_at) timestamp
FROM umami.website_event_new
GROUP BY website_id,
    session_id,
    visit_id,
    hostname,
    browser,
    os,
    device,
    screen,
    language,
    country,
    subdivision1,
    city,
    event_type,
    timestamp);

-- projections
ALTER TABLE umami.website_event_new
ADD PROJECTION website_event_url_path_projection (
SELECT * ORDER BY toStartOfDay(created_at), website_id, url_path, created_at
);

ALTER TABLE umami.website_event_new MATERIALIZE PROJECTION website_event_url_path_projection;

ALTER TABLE umami.website_event_new
ADD PROJECTION website_event_referrer_domain_projection (
SELECT * ORDER BY toStartOfDay(created_at), website_id, referrer_domain, created_at
);

ALTER TABLE umami.website_event_new MATERIALIZE PROJECTION website_event_referrer_domain_projection;

-- migration
INSERT INTO umami.website_event_new
SELECT website_id, session_id, visit_id, event_id, hostname, browser, os, device, screen, language, country, subdivision1, subdivision2, city, url_path, url_query,
    extract(url_query, 'utm_source=([^&]*)') AS utm_source,
    extract(url_query, 'utm_medium=([^&]*)') AS utm_medium,
    extract(url_query, 'utm_campaign=([^&]*)') AS utm_campaign,
    extract(url_query, 'utm_content=([^&]*)') AS utm_content,
    extract(url_query, 'utm_term=([^&]*)') AS utm_term,referrer_path, referrer_query, referrer_domain,
    page_title,
    extract(url_query, 'gclid=([^&]*)') gclid,
    extract(url_query, 'fbclid=([^&]*)') fbclid,
    extract(url_query, 'msclkid=([^&]*)') msclkid,
    extract(url_query, 'ttclid=([^&]*)') ttclid,
    extract(url_query, 'li_fat_id=([^&]*)') li_fat_id,
    extract(url_query, 'twclid=([^&]*)') twclid,
    event_type, event_name, tag, created_at, job_id
FROM umami.website_event

-- rename tables
RENAME TABLE umami.website_event TO umami.website_event_old;
RENAME TABLE umami.website_event_new TO umami.website_event;

RENAME TABLE umami.website_event_stats_hourly TO umami.website_event_stats_hourly_old;
RENAME TABLE umami.website_event_stats_hourly_new TO umami.website_event_stats_hourly;

RENAME TABLE umami.website_event_stats_hourly_mv TO umami.website_event_stats_hourly_mv_old;
RENAME TABLE umami.website_event_stats_hourly_mv_new TO umami.website_event_stats_hourly_mv;

-- recreate view
DROP TABLE umami.website_event_stats_hourly_mv;

CREATE MATERIALIZED VIEW umami.website_event_stats_hourly_mv
TO umami.website_event_stats_hourly
AS
SELECT
    website_id,
    session_id,
    visit_id,
    hostname,
    browser,
    os,
    device,
    screen,
    language,
    country,
    subdivision1,
    city,
    entry_url,
    exit_url,
    url_paths as url_path,
    url_query,
    utm_source,
    utm_medium,
    utm_campaign,
    utm_content,
    utm_term,
    referrer_domain,
    page_title,
    gclid,
    fbclid,
    msclkid,
    ttclid,
    li_fat_id,
    twclid,
    event_type,
    event_name,
    views,
    min_time,
    max_time,
    tag,
    timestamp as created_at
FROM (SELECT
    website_id,
    session_id,
    visit_id,
    hostname,
    browser,
    os,
    device,
    screen,
    language,
    country,
    subdivision1,
    city,
    argMinState(url_path, created_at) entry_url,
    argMaxState(url_path, created_at) exit_url,
    arrayFilter(x -> x != '', groupArray(url_path)) as url_paths,
    arrayFilter(x -> x != '', groupArray(url_query)) url_query,
    arrayFilter(x -> x != '', groupArray(utm_source)) utm_source,
    arrayFilter(x -> x != '', groupArray(utm_medium)) utm_medium,
    arrayFilter(x -> x != '', groupArray(utm_campaign)) utm_campaign,
    arrayFilter(x -> x != '', groupArray(utm_content)) utm_content,
    arrayFilter(x -> x != '', groupArray(utm_term)) utm_term,
    arrayFilter(x -> x != '', groupArray(referrer_domain)) referrer_domain,
    arrayFilter(x -> x != '', groupArray(page_title)) page_title,
    arrayFilter(x -> x != '', groupArray(gclid)) gclid,
    arrayFilter(x -> x != '', groupArray(fbclid)) fbclid,
    arrayFilter(x -> x != '', groupArray(msclkid)) msclkid,
    arrayFilter(x -> x != '', groupArray(ttclid)) ttclid,
    arrayFilter(x -> x != '', groupArray(li_fat_id)) li_fat_id,
    arrayFilter(x -> x != '', groupArray(twclid)) twclid,
    event_type,
    if(event_type = 2, groupArray(event_name), []) event_name,
    sumIf(1, event_type = 1) views,
    min(created_at) min_time,
    max(created_at) max_time,
    arrayFilter(x -> x != '', groupArray(tag)) tag,
    toStartOfHour(created_at) timestamp
FROM umami.website_event
GROUP BY website_id,
    session_id,
    visit_id,
    hostname,
    browser,
    os,
    device,
    screen,
    language,
    country,
    subdivision1,
    city,
    event_type,
    timestamp);


================================================
FILE: db/clickhouse/migrations/06_update_subdivision.sql
================================================
-- drop projections
ALTER TABLE umami.website_event  DROP PROJECTION website_event_url_path_projection;
ALTER TABLE umami.website_event  DROP PROJECTION website_event_referrer_domain_projection;

--drop view
DROP TABLE umami.website_event_stats_hourly_mv;

-- rename columns
ALTER TABLE umami.website_event RENAME COLUMN "subdivision1" TO "region";
ALTER TABLE umami.website_event_stats_hourly RENAME COLUMN "subdivision1" TO "region";

-- drop columns
ALTER TABLE umami.website_event DROP COLUMN "subdivision2";

-- recreate projections
ALTER TABLE umami.website_event 
ADD PROJECTION website_event_url_path_projection (
SELECT * ORDER BY toStartOfDay(created_at), website_id, url_path, created_at
);

ALTER TABLE umami.website_event MATERIALIZE PROJECTION website_event_url_path_projection;

ALTER TABLE umami.website_event 
ADD PROJECTION website_event_referrer_domain_projection (
SELECT * ORDER BY toStartOfDay(created_at), website_id, referrer_domain, created_at
);

ALTER TABLE umami.website_event MATERIALIZE PROJECTION website_event_referrer_domain_projection;

-- recreate view
CREATE MATERIALIZED VIEW umami.website_event_stats_hourly_mv
TO umami.website_event_stats_hourly
AS
SELECT
    website_id,
    session_id,
    visit_id,
    hostname,
    browser,
    os,
    device,
    screen,
    language,
    country,
    region,
    city,
    entry_url,
    exit_url,
    url_paths as url_path,
    url_query,
    utm_source,
    utm_medium,
    utm_campaign,
    utm_content,
    utm_term,
    referrer_domain,
    page_title,
    gclid,
    fbclid,
    msclkid,
    ttclid,
    li_fat_id,
    twclid,
    event_type,
    event_name,
    views,
    min_time,
    max_time,
    tag,
    timestamp as created_at
FROM (SELECT
    website_id,
    session_id,
    visit_id,
    hostname,
    browser,
    os,
    device,
    screen,
    language,
    country,
    region,
    city,
    argMinState(url_path, created_at) entry_url,
    argMaxState(url_path, created_at) exit_url,
    arrayFilter(x -> x != '', groupArray(url_path)) as url_paths,
    arrayFilter(x -> x != '', groupArray(url_query)) url_query,
    arrayFilter(x -> x != '', groupArray(utm_source)) utm_source,
    arrayFilter(x -> x != '', groupArray(utm_medium)) utm_medium,
    arrayFilter(x -> x != '', groupArray(utm_campaign)) utm_campaign,
    arrayFilter(x -> x != '', groupArray(utm_content)) utm_content,
    arrayFilter(x -> x != '', groupArray(utm_term)) utm_term,
    arrayFilter(x -> x != '', groupArray(referrer_domain)) referrer_domain,
    arrayFilter(x -> x != '', groupArray(page_title)) page_title,
    arrayFilter(x -> x != '', groupArray(gclid)) gclid,
    arrayFilter(x -> x != '', groupArray(fbclid)) fbclid,
    arrayFilter(x -> x != '', groupArray(msclkid)) msclkid,
    arrayFilter(x -> x != '', groupArray(ttclid)) ttclid,
    arrayFilter(x -> x != '', groupArray(li_fat_id)) li_fat_id,
    arrayFilter(x -> x != '', groupArray(twclid)) twclid,
    event_type,
    if(event_type = 2, groupArray(event_name), []) event_name,
    sumIf(1, event_type = 1) views,
    min(created_at) min_time,
    max(created_at) max_time,
    arrayFilter(x -> x != '', groupArray(tag)) tag,
    toStartOfHour(created_at) timestamp
FROM umami.website_event
GROUP BY website_id,
    session_id,
    visit_id,
    hostname,
    browser,
    os,
    device,
    screen,
    language,
    country,
    region,
    city,
    event_type,
    timestamp);


================================================
FILE: db/clickhouse/migrations/07_add_distinct_id.sql
================================================
-- add tag column
ALTER TABLE umami.website_event ADD COLUMN "distinct_id" String AFTER "tag";
ALTER TABLE umami.website_event_stats_hourly ADD COLUMN "distinct_id" String AFTER "tag";
ALTER TABLE umami.session_data ADD COLUMN "distinct_id" String AFTER "data_type";

-- update materialized view
DROP TABLE umami.website_event_stats_hourly_mv;

CREATE MATERIALIZED VIEW umami.website_event_stats_hourly_mv
TO umami.website_event_stats_hourly
AS
SELECT
    website_id,
    session_id,
    visit_id,
    hostname,
    browser,
    os,
    device,
    screen,
    language,
    country,
    region,
    city,
    entry_url,
    exit_url,
    url_paths as url_path,
    url_query,
    utm_source,
    utm_medium,
    utm_campaign,
    utm_content,
    utm_term,
    referrer_domain,
    page_title,
    gclid,
    fbclid,
    msclkid,
    ttclid,
    li_fat_id,
    twclid,
    event_type,
    event_name,
    views,
    min_time,
    max_time,
    tag,
    distinct_id,
    timestamp as created_at
FROM (SELECT
    website_id,
    session_id,
    visit_id,
    hostname,
    browser,
    os,
    device,
    screen,
    language,
    country,
    region,
    city,
    argMinState(url_path, created_at) entry_url,
    argMaxState(url_path, created_at) exit_url,
    arrayFilter(x -> x != '', groupArray(url_path)) as url_paths,
    arrayFilter(x -> x != '', groupArray(url_query)) url_query,
    arrayFilter(x -> x != '', groupArray(utm_source)) utm_source,
    arrayFilter(x -> x != '', groupArray(utm_medium)) utm_medium,
    arrayFilter(x -> x != '', groupArray(utm_campaign)) utm_campaign,
    arrayFilter(x -> x != '', groupArray(utm_content)) utm_content,
    arrayFilter(x -> x != '', groupArray(utm_term)) utm_term,
    arrayFilter(x -> x != '', groupArray(referrer_domain)) referrer_domain,
    arrayFilter(x -> x != '', groupArray(page_title)) page_title,
    arrayFilter(x -> x != '', groupArray(gclid)) gclid,
    arrayFilter(x -> x != '', groupArray(fbclid)) fbclid,
    arrayFilter(x -> x != '', groupArray(msclkid)) msclkid,
    arrayFilter(x -> x != '', groupArray(ttclid)) ttclid,
    arrayFilter(x -> x != '', groupArray(li_fat_id)) li_fat_id,
    arrayFilter(x -> x != '', groupArray(twclid)) twclid,
    event_type,
    if(event_type = 2, groupArray(event_name), []) event_name,
    sumIf(1, event_type = 1) views,
    min(created_at) min_time,
    max(created_at) max_time,
    arrayFilter(x -> x != '', groupArray(tag)) tag,
    distinct_id,
    toStartOfHour(created_at) timestamp
FROM umami.website_event
GROUP BY website_id,
    session_id,
    visit_id,
    hostname,
    browser,
    os,
    device,
    screen,
    language,
    country,
    region,
    city,
    event_type,
    distinct_id,
    timestamp);


================================================
FILE: db/clickhouse/migrations/08_update_hostname_view.sql
================================================
-- create new hourly table
CREATE TABLE umami.website_event_stats_hourly_new
(
    website_id UUID,
    session_id UUID,
    visit_id UUID,
    hostname SimpleAggregateFunction(groupArrayArray, Array(String)),
    browser LowCardinality(String),
    os LowCardinality(String),
    device LowCardinality(String),
    screen LowCardinality(String),
    language LowCardinality(String),
    country LowCardinality(String),
    region LowCardinality(String),
    city String,
    entry_url AggregateFunction(argMin, String, DateTime('UTC')),
    exit_url AggregateFunction(argMax, String, DateTime('UTC')),
    url_path SimpleAggregateFunction(groupArrayArray, Array(String)),
    url_query SimpleAggregateFunction(groupArrayArray, Array(String)),
    utm_source SimpleAggregateFunction(groupArrayArray, Array(String)),
    utm_medium SimpleAggregateFunction(groupArrayArray, Array(String)),
    utm_campaign SimpleAggregateFunction(groupArrayArray, Array(String)),
    utm_content SimpleAggregateFunction(groupArrayArray, Array(String)),
    utm_term SimpleAggregateFunction(groupArrayArray, Array(String)),
    referrer_domain SimpleAggregateFunction(groupArrayArray, Array(String)),
    page_title SimpleAggregateFunction(groupArrayArray, Array(String)),
    gclid SimpleAggregateFunction(groupArrayArray, Array(String)),
    fbclid SimpleAggregateFunction(groupArrayArray, Array(String)),
    msclkid SimpleAggregateFunction(groupArrayArray, Array(String)),
    ttclid SimpleAggregateFunction(groupArrayArray, Array(String)),
    li_fat_id SimpleAggregateFunction(groupArrayArray, Array(String)),
    twclid SimpleAggregateFunction(groupArrayArray, Array(String)),
    event_type UInt32,
    event_name SimpleAggregateFunction(groupArrayArray, Array(String)),
    views SimpleAggregateFunction(sum, UInt64),
    min_time SimpleAggregateFunction(min, DateTime('UTC')),
    max_time SimpleAggregateFunction(max, DateTime('UTC')),
    tag SimpleAggregateFunction(groupArrayArray, Array(String)),
    distinct_id String,
    created_at Datetime('UTC')
)
ENGINE = AggregatingMergeTree
    PARTITION BY toYYYYMM(created_at)
    ORDER BY (
        website_id,
        event_type,
        toStartOfHour(created_at),
        cityHash64(visit_id),
        visit_id
    )
    SAMPLE BY cityHash64(visit_id);

-- create view
CREATE MATERIALIZED VIEW umami.website_event_stats_hourly_mv_new
TO umami.website_event_stats_hourly_new
AS
SELECT
    website_id,
    session_id,
    visit_id,
    hostnames as hostname,
    browser,
    os,
    device,
    screen,
    language,
    country,
    region,
    city,
    entry_url,
    exit_url,
    url_paths as url_path,
    url_query,
    utm_source,
    utm_medium,
    utm_campaign,
    utm_content,
    utm_term,
    referrer_domain,
    page_title,
    gclid,
    fbclid,
    msclkid,
    ttclid,
    li_fat_id,
    twclid,
    event_type,
    event_name,
    views,
    min_time,
    max_time,
    tag,
    distinct_id,
    timestamp as created_at
FROM (SELECT
    website_id,
    session_id,
    visit_id,
    arrayFilter(x -> x != '', groupArray(hostname)) hostnames,
    browser,
    os,
    device,
    screen,
    language,
    country,
    region,
    city,
    argMinState(url_path, created_at) entry_url,
    argMaxState(url_path, created_at) exit_url,
    arrayFilter(x -> x != '', groupArray(url_path)) as url_paths,
    arrayFilter(x -> x != '', groupArray(url_query)) url_query,
    arrayFilter(x -> x != '', groupArray(utm_source)) utm_source,
    arrayFilter(x -> x != '', groupArray(utm_medium)) utm_medium,
    arrayFilter(x -> x != '', groupArray(utm_campaign)) utm_campaign,
    arrayFilter(x -> x != '', groupArray(utm_content)) utm_content,
    arrayFilter(x -> x != '', groupArray(utm_term)) utm_term,
    arrayFilter(x -> x != '' and x != hostname, groupArray(referrer_domain)) referrer_domain,
    arrayFilter(x -> x != '', groupArray(page_title)) page_title,
    arrayFilter(x -> x != '', groupArray(gclid)) gclid,
    arrayFilter(x -> x != '', groupArray(fbclid)) fbclid,
    arrayFilter(x -> x != '', groupArray(msclkid)) msclkid,
    arrayFilter(x -> x != '', groupArray(ttclid)) ttclid,
    arrayFilter(x -> x != '', groupArray(li_fat_id)) li_fat_id,
    arrayFilter(x -> x != '', groupArray(twclid)) twclid,
    event_type,
    if(event_type = 2, groupArray(event_name), []) event_name,
    sumIf(1, event_type = 1) views,
    min(created_at) min_time,
    max(created_at) max_time,
    arrayFilter(x -> x != '', groupArray(tag)) tag,
    distinct_id,
    toStartOfHour(created_at) timestamp
FROM umami.website_event
GROUP BY website_id,
    session_id,
    visit_id,
    hostname,
    browser,
    os,
    device,
    screen,
    language,
    country,
    region,
    city,
    event_type,
    distinct_id,
    timestamp);

-- rename tables
RENAME TABLE umami.website_event_stats_hourly TO umami.website_event_stats_hourly_old;
RENAME TABLE umami.website_event_stats_hourly_new TO umami.website_event_stats_hourly;

-- drop views
DROP TABLE umami.website_event_stats_hourly_mv;
DROP TABLE umami.website_event_stats_hourly_mv_new;

-- recreate view
CREATE MATERIALIZED VIEW umami.website_event_stats_hourly_mv
TO umami.website_event_stats_hourly
AS
SELECT
    website_id,
    session_id,
    visit_id,
    hostnames as hostname,
    browser,
    os,
    device,
    screen,
    language,
    country,
    region,
    city,
    entry_url,
    exit_url,
    url_paths as url_path,
    url_query,
    utm_source,
    utm_medium,
    utm_campaign,
    utm_content,
    utm_term,
    referrer_domain,
    page_title,
    gclid,
    fbclid,
    msclkid,
    ttclid,
    li_fat_id,
    twclid,
    event_type,
    event_name,
    views,
    min_time,
    max_time,
    tag,
    distinct_id,
    timestamp as created_at
FROM (SELECT
    website_id,
    session_id,
    visit_id,
    arrayFilter(x -> x != '', groupArray(hostname)) hostnames,
    browser,
    os,
    device,
    screen,
    language,
    country,
    region,
    city,
    argMinState(url_path, created_at) entry_url,
    argMaxState(url_path, created_at) exit_url,
    arrayFilter(x -> x != '', groupArray(url_path)) as url_paths,
    arrayFilter(x -> x != '', groupArray(url_query)) url_query,
    arrayFilter(x -> x != '', groupArray(utm_source)) utm_source,
    arrayFilter(x -> x != '', groupArray(utm_medium)) utm_medium,
    arrayFilter(x -> x != '', groupArray(utm_campaign)) utm_campaign,
    arrayFilter(x -> x != '', groupArray(utm_content)) utm_content,
    arrayFilter(x -> x != '', groupArray(utm_term)) utm_term,
    arrayFilter(x -> x != '' and x != hostname, groupArray(referrer_domain)) referrer_domain,
    arrayFilter(x -> x != '', groupArray(page_title)) page_title,
    arrayFilter(x -> x != '', groupArray(gclid)) gclid,
    arrayFilter(x -> x != '', groupArray(fbclid)) fbclid,
    arrayFilter(x -> x != '', groupArray(msclkid)) msclkid,
    arrayFilter(x -> x != '', groupArray(ttclid)) ttclid,
    arrayFilter(x -> x != '', groupArray(li_fat_id)) li_fat_id,
    arrayFilter(x -> x != '', groupArray(twclid)) twclid,
    event_type,
    if(event_type = 2, groupArray(event_name), []) event_name,
    sumIf(1, event_type = 1) views,
    min(created_at) min_time,
    max(created_at) max_time,
    arrayFilter(x -> x != '', groupArray(tag)) tag,
    distinct_id,
    toStartOfHour(created_at) timestamp
FROM umami.website_event
GROUP BY website_id,
    session_id,
    visit_id,
    hostname,
    browser,
    os,
    device,
    screen,
    language,
    country,
    region,
    city,
    event_type,
    distinct_id,
    timestamp);



================================================
FILE: db/postgresql/data-migrations/convert-utm-clid-columns.sql
================================================
-----------------------------------------------------
-- PostgreSQL
-----------------------------------------------------
UPDATE "website_event" we
SET fbclid = LEFT(url.fbclid, 255),
    gclid = LEFT(url.gclid, 255),
    li_fat_id = LEFT(url.li_fat_id, 255),
    msclkid = LEFT(url.msclkid, 255),
    ttclid = LEFT(url.ttclid, 255),
    twclid = LEFT(url.twclid, 255),
    utm_campaign = LEFT(url.utm_campaign, 255),
    utm_content = LEFT(url.utm_content, 255),
    utm_medium = LEFT(url.utm_medium, 255),
    utm_source = LEFT(url.utm_source, 255),
    utm_term = LEFT(url.utm_term, 255)
FROM (SELECT event_id, website_id, session_id,
          (regexp_matches(url_query, '(?:[&?]|^)fbclid=([^&]+)', 'i'))[1] AS fbclid,
          (regexp_matches(url_query, '(?:[&?]|^)gclid=([^&]+)', 'i'))[1] AS gclid,
          (regexp_matches(url_query, '(?:[&?]|^)li_fat_id=([^&]+)', 'i'))[1] AS li_fat_id,
          (regexp_matches(url_query, '(?:[&?]|^)msclkid=([^&]+)', 'i'))[1] AS msclkid,
          (regexp_matches(url_query, '(?:[&?]|^)ttclid=([^&]+)', 'i'))[1] AS ttclid,
          (regexp_matches(url_query, '(?:[&?]|^)twclid=([^&]+)', 'i'))[1] AS twclid,
          (regexp_matches(url_query, '(?:[&?]|^)utm_campaign=([^&]+)', 'i'))[1] AS utm_campaign,
          (regexp_matches(url_query, '(?:[&?]|^)utm_content=([^&]+)', 'i'))[1] AS utm_content,
          (regexp_matches(url_query, '(?:[&?]|^)utm_medium=([^&]+)', 'i'))[1] AS utm_medium,
          (regexp_matches(url_query, '(?:[&?]|^)utm_source=([^&]+)', 'i'))[1] AS utm_source,
          (regexp_matches(url_query, '(?:[&?]|^)utm_term=([^&]+)', 'i'))[1] AS utm_term
    FROM "website_event"
    WHERE url_query IS NOT NULL) url
WHERE we.event_id = url.event_id
    and we.session_id = url.session_id
    and we.website_id = url.website_id;

-----------------------------------------------------
-- MySQL
-----------------------------------------------------
UPDATE `website_event`
SET fbclid = LEFT(SUBSTRING_INDEX(SUBSTRING_INDEX(REGEXP_SUBSTR(url_query, '(?:[&?]|^)fbclid=[^&]+'), '=', -1), '&', 1), 255),
    gclid = LEFT(SUBSTRING_INDEX(SUBSTRING_INDEX(REGEXP_SUBSTR(url_query, '(?:[&?]|^)gclid=[^&]+'), '=', -1), '&', 1), 255),
    li_fat_id = LEFT(SUBSTRING_INDEX(SUBSTRING_INDEX(REGEXP_SUBSTR(url_query, '(?:[&?]|^)li_fat_id=[^&]+'), '=', -1), '&', 1), 255),
    msclkid = LEFT(SUBSTRING_INDEX(SUBSTRING_INDEX(REGEXP_SUBSTR(url_query, '(?:[&?]|^)msclkid=[^&]+'), '=', -1), '&', 1), 255),
    ttclid = LEFT(SUBSTRING_INDEX(SUBSTRING_INDEX(REGEXP_SUBSTR(url_query, '(?:[&?]|^)ttclid=[^&]+'), '=', -1), '&', 1), 255),
    twclid = LEFT(SUBSTRING_INDEX(SUBSTRING_INDEX(REGEXP_SUBSTR(url_query, '(?:[&?]|^)twclid=[^&]+'), '=', -1), '&', 1), 255),
    utm_campaign = LEFT(SUBSTRING_INDEX(SUBSTRING_INDEX(REGEXP_SUBSTR(url_query, '(?:[&?]|^)utm_campaign=[^&]+'), '=', -1), '&', 1), 255),
    utm_content = LEFT(SUBSTRING_INDEX(SUBSTRING_INDEX(REGEXP_SUBSTR(url_query, '(?:[&?]|^)utm_content=[^&]+'), '=', -1), '&', 1), 255),
    utm_medium = LEFT(SUBSTRING_INDEX(SUBSTRING_INDEX(REGEXP_SUBSTR(url_query, '(?:[&?]|^)utm_medium=[^&]+'), '=', -1), '&', 1), 255),
    utm_source = LEFT(SUBSTRING_INDEX(SUBSTRING_INDEX(REGEXP_SUBSTR(url_query, '(?:[&?]|^)utm_source=[^&]+'), '=', -1), '&', 1), 255),
    utm_term = LEFT(SUBSTRING_INDEX(SUBSTRING_INDEX(REGEXP_SUBSTR(url_query, '(?:[&?]|^)utm_term=[^&]+'), '=', -1), '&', 1), 255)
WHERE url_query IS NOT NULL;



================================================
FILE: db/postgresql/data-migrations/populate-revenue-table.sql
================================================
-----------------------------------------------------
-- PostgreSQL
-----------------------------------------------------
INSERT INTO "revenue"
SELECT gen_random_uuid() revenue_id,
    ed.website_id,
    we.session_id,
    we.event_id,
    we.event_name,
    currency.string_value currency,
    coalesce(ed.number_value, cast(ed.string_value as numeric(19,4))) revenue,
    ed.created_at
FROM event_data ed
JOIN website_event we 
ON we.event_id = ed.website_event_id
JOIN (SELECT website_event_id, string_value
      FROM event_data
      WHERE data_key ilike '%currency%') currency
ON currency.website_event_id = ed.website_event_id
WHERE ed.data_key ilike '%revenue%';

-----------------------------------------------------
-- MySQL
-----------------------------------------------------
INSERT INTO `revenue`
SELECT UUID() revenue_id,
    ed.website_id,
    we.session_id,
    we.event_id,
    we.event_name,
    currency.string_value currency,
    coalesce(ed.number_value, cast(ed.string_value as decimal(19,4))) revenue,
    ed.created_at
FROM event_data ed
JOIN website_event we
ON we.event_id = ed.website_event_id
JOIN (SELECT website_event_id, string_value
      FROM event_data
      WHERE data_key like '%currency%') currency
ON currency.website_event_id = ed.website_event_id
WHERE ed.data_key like '%revenue%';


================================================
FILE: docker/middleware.ts
================================================
import { type NextRequest, NextResponse } from 'next/server';

export const config = {
  matcher: '/:path*',
};

const TRACKER_PATH = '/script.js';
const COLLECT_PATH = '/api/send';
const LOGIN_PATH = '/login';

const apiHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': '*',
  'Access-Control-Allow-Methods': 'GET, DELETE, POST, PUT',
  'Access-Control-Max-Age': process.env.CORS_MAX_AGE || '86400',
  'Cache-Control': 'no-cache',
};

const trackerHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Cache-Control': 'public, max-age=86400, must-revalidate',
};

function customCollectEndpoint(request: NextRequest) {
  const collectEndpoint = process.env.COLLECT_API_ENDPOINT;

  if (collectEndpoint) {
    const url = request.nextUrl.clone();

    if (url.pathname.endsWith(collectEndpoint)) {
      url.pathname = COLLECT_PATH;
      return NextResponse.rewrite(url, { headers: apiHeaders });
    }
  }
}

function customScriptName(request: NextRequest) {
  const scriptName = process.env.TRACKER_SCRIPT_NAME;

  if (scriptName) {
    const url = request.nextUrl.clone();
    const names = scriptName.split(',').map(name => name.trim().replace(/^\/+/, ''));

    if (names.find(name => url.pathname.endsWith(name))) {
      url.pathname = TRACKER_PATH;
      return NextResponse.rewrite(url, { headers: trackerHeaders });
    }
  }
}

function customScriptUrl(request: NextRequest) {
  const scriptUrl = process.env.TRACKER_SCRIPT_URL;

  if (scriptUrl && request.nextUrl.pathname.endsWith(TRACKER_PATH)) {
    return NextResponse.rewrite(scriptUrl, { headers: trackerHeaders });
  }
}

function disableLogin(request: NextRequest) {
  const loginDisabled = process.env.DISABLE_LOGIN;

  if (loginDisabled && request.nextUrl.pathname.endsWith(LOGIN_PATH)) {
    return new NextResponse('Access denied', { status: 403 });
  }
}

export default function middleware(req: NextRequest) {
  const fns = [customCollectEndpoint, customScriptName, customScriptUrl, disableLogin];

  for (const fn of fns) {
    const res = fn(req);
    if (res) {
      return res;
    }
  }

  return NextResponse.next();
}



================================================
FILE: podman/README.md
================================================
# How to deploy umami on podman


## How to use

1. Rename `env.sample` to `.env`
2. Edit `.env` file. At the minimum set the passwords.
3. Start umami by running `podman-compose up -d`.

If you need to stop umami, you can do so by running `podman-compose down`.


### Install systemd service (optional)

If you want to install a systemd service to run umami, you can use the provided
systemd service.

Edit `umami.service` and change these two variables:


	WorkingDirectory=/opt/apps/umami
	EnvironmentFile=/opt/apps/umami/.env

`WorkingDirectory` should be changed to the path in which `podman-compose.yml`
is located.

`EnvironmentFile` should be changed to the path in which your `.env`file is
located.

You can run the script `install-systemd-user-service` to install the systemd
service under the current user.


	./install-systemd-user-service

Note: this script will enable the service and also start it. So it will assume
that umami is not currently running.  If you started it previously, bring it
down using:

	podman-compose down



## Compatibility

These files should be compatible with podman 4.3+.

I have tested this on Debian GNU/Linux 12 (bookworm) and with the podman that
is distributed with the official Debian stable mirrors (podman
v4.3.1+ds1-8+deb12u1, podman-compose v1.0.3-3).



================================================
FILE: podman/env.sample
================================================
# Rename this file to .env and modify the values
#
# Connection string for Umami’s database.
# If you use the bundled DB container, "db" is the hostname.
DATABASE_URL=postgresql://umami:replace-me-with-a-random-string@db:5432/umami

# Database type (e.g. postgresql)
DATABASE_TYPE=postgresql

# A secret string used by Umami (replace with a strong random string)
APP_SECRET=replace-me-with-a-random-string

# Postgres container defaults.
POSTGRES_DB=umami
POSTGRES_USER=umami
POSTGRES_PASSWORD=replace-me-with-a-random-string



================================================
FILE: podman/install-systemd-user-service
================================================
#!/bin/bash
set -e
service_name="umami"
mkdir -p ~/.config/systemd/user
cp $service_name.service ~/.config/systemd/user


systemctl --user daemon-reload
systemctl --user enable $service_name.service
systemctl --user start $service_name.service



================================================
FILE: podman/podman-compose.yml
================================================
version: "3.8"

services:
  umami:
    container_name: umami
    image: ghcr.io/umami-software/umami:postgresql-latest
    ports:
      - "127.0.0.1:3000:3000"
    environment:
      DATABASE_URL: ${DATABASE_URL}
      DATABASE_TYPE: ${DATABASE_TYPE}
      APP_SECRET: ${APP_SECRET}
    depends_on:
      db:
        condition: service_healthy
    init: true
    restart: always
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:3000/api/heartbeat || exit 1"]
      interval: 5s
      timeout: 5s
      retries: 5

  db:
    container_name: umami-db
    image: docker.io/library/postgres:15-alpine
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - umami-db-data:/var/lib/postgresql/data:Z
    restart: always
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  umami-db-data:



================================================
FILE: podman/umami.service
================================================
[Unit]
Description=Umami Container Stack via Podman-Compose
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/apps/umami
EnvironmentFile=/opt/apps/umami/.env
ExecStart=/usr/bin/podman-compose -f podman-compose.yml up -d
ExecStop=/usr/bin/podman-compose -f podman-compose.yml down
RemainAfterExit=yes

[Install]
WantedBy=default.target



================================================
FILE: prisma/schema.prisma
================================================
generator client {
  provider   = "prisma-client"
  output     = "../src/generated/prisma"
  engineType = "client"
}

datasource db {
  provider     = "postgresql"
  url          = env("DATABASE_URL")
  relationMode = "prisma"
}

model User {
  id          String    @id @unique @map("user_id") @db.Uuid
  username    String    @unique @db.VarChar(255)
  password    String    @db.VarChar(60)
  role        String    @map("role") @db.VarChar(50)
  logoUrl     String?   @map("logo_url") @db.VarChar(2183)
  displayName String?   @map("display_name") @db.VarChar(255)
  createdAt   DateTime? @default(now()) @map("created_at") @db.Timestamptz(6)
  updatedAt   DateTime? @updatedAt @map("updated_at") @db.Timestamptz(6)
  deletedAt   DateTime? @map("deleted_at") @db.Timestamptz(6)

  websites  Website[]  @relation("user")
  createdBy Website[]  @relation("createUser")
  links     Link[]     @relation("user")
  pixels    Pixel[]    @relation("user")
  teams     TeamUser[]
  reports   Report[]

  @@map("user")
}

model Session {
  id         String    @id @unique @map("session_id") @db.Uuid
  websiteId  String    @map("website_id") @db.Uuid
  browser    String?   @db.VarChar(20)
  os         String?   @db.VarChar(20)
  device     String?   @db.VarChar(20)
  screen     String?   @db.VarChar(11)
  language   String?   @db.VarChar(35)
  country    String?   @db.Char(2)
  region     String?   @db.VarChar(20)
  city       String?   @db.VarChar(50)
  distinctId String?   @map("distinct_id") @db.VarChar(50)
  createdAt  DateTime? @default(now()) @map("created_at") @db.Timestamptz(6)

  websiteEvents WebsiteEvent[]
  sessionData   SessionData[]
  revenue       Revenue[]

  @@index([createdAt])
  @@index([websiteId])
  @@index([websiteId, createdAt])
  @@index([websiteId, createdAt, browser])
  @@index([websiteId, createdAt, os])
  @@index([websiteId, createdAt, device])
  @@index([websiteId, createdAt, screen])
  @@index([websiteId, createdAt, language])
  @@index([websiteId, createdAt, country])
  @@index([websiteId, createdAt, region])
  @@index([websiteId, createdAt, city])
  @@map("session")
}

model Website {
  id        String    @id @unique @map("website_id") @db.Uuid
  name      String    @db.VarChar(100)
  domain    String?   @db.VarChar(500)
  shareId   String?   @unique @map("share_id") @db.VarChar(50)
  resetAt   DateTime? @map("reset_at") @db.Timestamptz(6)
  userId    String?   @map("user_id") @db.Uuid
  teamId    String?   @map("team_id") @db.Uuid
  createdBy String?   @map("created_by") @db.Uuid
  createdAt DateTime? @default(now()) @map("created_at") @db.Timestamptz(6)
  updatedAt DateTime? @updatedAt @map("updated_at") @db.Timestamptz(6)
  deletedAt DateTime? @map("deleted_at") @db.Timestamptz(6)

  user        User?         @relation("user", fields: [userId], references: [id])
  createUser  User?         @relation("createUser", fields: [createdBy], references: [id])
  team        Team?         @relation(fields: [teamId], references: [id])
  eventData   EventData[]
  reports     Report[]
  revenue     Revenue[]
  segments    Segment[]
  sessionData SessionData[]

  @@index([userId])
  @@index([teamId])
  @@index([createdAt])
  @@index([shareId])
  @@index([createdBy])
  @@map("website")
}

model WebsiteEvent {
  id             String    @id() @map("event_id") @db.Uuid
  websiteId      String    @map("website_id") @db.Uuid
  sessionId      String    @map("session_id") @db.Uuid
  visitId        String    @map("visit_id") @db.Uuid
  createdAt      DateTime? @default(now()) @map("created_at") @db.Timestamptz(6)
  urlPath        String    @map("url_path") @db.VarChar(500)
  urlQuery       String?   @map("url_query") @db.VarChar(500)
  utmSource      String?   @map("utm_source") @db.VarChar(255)
  utmMedium      String?   @map("utm_medium") @db.VarChar(255)
  utmCampaign    String?   @map("utm_campaign") @db.VarChar(255)
  utmContent     String?   @map("utm_content") @db.VarChar(255)
  utmTerm        String?   @map("utm_term") @db.VarChar(255)
  referrerPath   String?   @map("referrer_path") @db.VarChar(500)
  referrerQuery  String?   @map("referrer_query") @db.VarChar(500)
  referrerDomain String?   @map("referrer_domain") @db.VarChar(500)
  pageTitle      String?   @map("page_title") @db.VarChar(500)
  gclid          String?   @db.VarChar(255)
  fbclid         String?   @db.VarChar(255)
  msclkid        String?   @db.VarChar(255)
  ttclid         String?   @db.VarChar(255)
  lifatid        String?   @map("li_fat_id") @db.VarChar(255)
  twclid         String?   @db.VarChar(255)
  eventType      Int       @default(1) @map("event_type") @db.Integer
  eventName      String?   @map("event_name") @db.VarChar(50)
  tag            String?   @db.VarChar(50)
  hostname       String?   @db.VarChar(100)

  eventData EventData[]
  session   Session     @relation(fields: [sessionId], references: [id])

  @@index([createdAt])
  @@index([sessionId])
  @@index([visitId])
  @@index([websiteId])
  @@index([websiteId, createdAt])
  @@index([websiteId, createdAt, urlPath])
  @@index([websiteId, createdAt, urlQuery])
  @@index([websiteId, createdAt, referrerDomain])
  @@index([websiteId, createdAt, pageTitle])
  @@index([websiteId, createdAt, eventName])
  @@index([websiteId, createdAt, tag])
  @@index([websiteId, sessionId, createdAt])
  @@index([websiteId, visitId, createdAt])
  @@index([websiteId, createdAt, hostname])
  @@map("website_event")
}

model EventData {
  id             String    @id() @map("event_data_id") @db.Uuid
  websiteId      String    @map("website_id") @db.Uuid
  websiteEventId String    @map("website_event_id") @db.Uuid
  dataKey        String    @map("data_key") @db.VarChar(500)
  stringValue    String?   @map("string_value") @db.VarChar(500)
  numberValue    Decimal?  @map("number_value") @db.Decimal(19, 4)
  dateValue      DateTime? @map("date_value") @db.Timestamptz(6)
  dataType       Int       @map("data_type") @db.Integer
  createdAt      DateTime? @default(now()) @map("created_at") @db.Timestamptz(6)

  website      Website      @relation(fields: [websiteId], references: [id])
  websiteEvent WebsiteEvent @relation(fields: [websiteEventId], references: [id])

  @@index([createdAt])
  @@index([websiteId])
  @@index([websiteEventId])
  @@index([websiteId, createdAt])
  @@index([websiteId, createdAt, dataKey])
  @@map("event_data")
}

model SessionData {
  id          String    @id() @map("session_data_id") @db.Uuid
  websiteId   String    @map("website_id") @db.Uuid
  sessionId   String    @map("session_id") @db.Uuid
  dataKey     String    @map("data_key") @db.VarChar(500)
  stringValue String?   @map("string_value") @db.VarChar(500)
  numberValue Decimal?  @map("number_value") @db.Decimal(19, 4)
  dateValue   DateTime? @map("date_value") @db.Timestamptz(6)
  dataType    Int       @map("data_type") @db.Integer
  distinctId  String?   @map("distinct_id") @db.VarChar(50)
  createdAt   DateTime? @default(now()) @map("created_at") @db.Timestamptz(6)

  website Website @relation(fields: [websiteId], references: [id])
  session Session @relation(fields: [sessionId], references: [id])

  @@index([createdAt])
  @@index([websiteId])
  @@index([sessionId])
  @@index([sessionId, createdAt])
  @@index([websiteId, createdAt, dataKey])
  @@map("session_data")
}

model Team {
  id         String    @id() @unique() @map("team_id") @db.Uuid
  name       String    @db.VarChar(50)
  accessCode String?   @unique @map("access_code") @db.VarChar(50)
  logoUrl    String?   @map("logo_url") @db.VarChar(2183)
  createdAt  DateTime? @default(now()) @map("created_at") @db.Timestamptz(6)
  updatedAt  DateTime? @updatedAt @map("updated_at") @db.Timestamptz(6)
  deletedAt  DateTime? @map("deleted_at") @db.Timestamptz(6)

  websites Website[]
  members  TeamUser[]
  links    Link[]
  pixels   Pixel[]

  @@index([accessCode])
  @@map("team")
}

model TeamUser {
  id        String    @id() @unique() @map("team_user_id") @db.Uuid
  teamId    String    @map("team_id") @db.Uuid
  userId    String    @map("user_id") @db.Uuid
  role      String    @db.VarChar(50)
  createdAt DateTime? @default(now()) @map("created_at") @db.Timestamptz(6)
  updatedAt DateTime? @updatedAt @map("updated_at") @db.Timestamptz(6)

  team Team @relation(fields: [teamId], references: [id])
  user User @relation(fields: [userId], references: [id])

  @@index([teamId])
  @@index([userId])
  @@map("team_user")
}

model Report {
  id          String    @id() @unique() @map("report_id") @db.Uuid
  userId      String    @map("user_id") @db.Uuid
  websiteId   String    @map("website_id") @db.Uuid
  type        String    @db.VarChar(50)
  name        String    @db.VarChar(200)
  description String    @db.VarChar(500)
  parameters  Json
  createdAt   DateTime? @default(now()) @map("created_at") @db.Timestamptz(6)
  updatedAt   DateTime? @updatedAt @map("updated_at") @db.Timestamptz(6)

  user    User    @relation(fields: [userId], references: [id])
  website Website @relation(fields: [websiteId], references: [id])

  @@index([userId])
  @@index([websiteId])
  @@index([type])
  @@index([name])
  @@map("report")
}

model Segment {
  id         String    @id() @unique() @map("segment_id") @db.Uuid
  websiteId  String    @map("website_id") @db.Uuid
  type       String    @db.VarChar(50)
  name       String    @db.VarChar(200)
  parameters Json
  createdAt  DateTime? @default(now()) @map("created_at") @db.Timestamptz(6)
  updatedAt  DateTime? @updatedAt @map("updated_at") @db.Timestamptz(6)

  website Website @relation(fields: [websiteId], references: [id])

  @@index([websiteId])
  @@map("segment")
}

model Revenue {
  id        String    @id() @unique() @map("revenue_id") @db.Uuid
  websiteId String    @map("website_id") @db.Uuid
  sessionId String    @map("session_id") @db.Uuid
  eventId   String    @map("event_id") @db.Uuid
  eventName String    @map("event_name") @db.VarChar(50)
  currency  String    @db.VarChar(10)
  revenue   Decimal?  @db.Decimal(19, 4)
  createdAt DateTime? @default(now()) @map("created_at") @db.Timestamptz(6)

  website Website @relation(fields: [websiteId], references: [id])
  session Session @relation(fields: [sessionId], references: [id])

  @@index([websiteId])
  @@index([sessionId])
  @@index([websiteId, createdAt])
  @@index([websiteId, sessionId, createdAt])
  @@map("revenue")
}

model Link {
  id        String    @id() @unique() @map("link_id") @db.Uuid
  name      String    @db.VarChar(100)
  url       String    @db.VarChar(500)
  slug      String    @unique() @db.VarChar(100)
  userId    String?   @map("user_id") @db.Uuid
  teamId    String?   @map("team_id") @db.Uuid
  createdAt DateTime? @default(now()) @map("created_at") @db.Timestamptz(6)
  updatedAt DateTime? @updatedAt @map("updated_at") @db.Timestamptz(6)
  deletedAt DateTime? @map("deleted_at") @db.Timestamptz(6)

  user User? @relation("user", fields: [userId], references: [id])
  team Team? @relation(fields: [teamId], references: [id])

  @@index([slug])
  @@index([userId])
  @@index([teamId])
  @@index([createdAt])
  @@map("link")
}

model Pixel {
  id        String    @id() @unique() @map("pixel_id") @db.Uuid
  name      String    @db.VarChar(100)
  slug      String    @unique() @db.VarChar(100)
  userId    String?   @map("user_id") @db.Uuid
  teamId    String?   @map("team_id") @db.Uuid
  createdAt DateTime? @default(now()) @map("created_at") @db.Timestamptz(6)
  updatedAt DateTime? @updatedAt @map("updated_at") @db.Timestamptz(6)
  deletedAt DateTime? @map("deleted_at") @db.Timestamptz(6)

  user User? @relation("user", fields: [userId], references: [id])
  team Team? @relation(fields: [teamId], references: [id])

  @@index([slug])
  @@index([userId])
  @@index([teamId])
  @@index([createdAt])
  @@map("pixel")
}



================================================
FILE: prisma/migrations/migration_lock.toml
================================================
# Please do not edit this file manually
# It should be added in your version-control system (e.g., Git)
provider = "postgresql"



================================================
FILE: prisma/migrations/01_init/migration.sql
================================================
-- CreateExtension
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- CreateTable
CREATE TABLE "user" (
    "user_id" UUID NOT NULL,
    "username" VARCHAR(255) NOT NULL,
    "password" VARCHAR(60) NOT NULL,
    "role" VARCHAR(50) NOT NULL,
    "created_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6),
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "user_pkey" PRIMARY KEY ("user_id")
);

-- CreateTable
CREATE TABLE "session" (
    "session_id" UUID NOT NULL,
    "website_id" UUID NOT NULL,
    "hostname" VARCHAR(100),
    "browser" VARCHAR(20),
    "os" VARCHAR(20),
    "device" VARCHAR(20),
    "screen" VARCHAR(11),
    "language" VARCHAR(35),
    "country" CHAR(2),
    "subdivision1" VARCHAR(20),
    "subdivision2" VARCHAR(50),
    "city" VARCHAR(50),
    "created_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "session_pkey" PRIMARY KEY ("session_id")
);

-- CreateTable
CREATE TABLE "website" (
    "website_id" UUID NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "domain" VARCHAR(500),
    "share_id" VARCHAR(50),
    "reset_at" TIMESTAMPTZ(6),
    "user_id" UUID,
    "created_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6),
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "website_pkey" PRIMARY KEY ("website_id")
);

-- CreateTable
CREATE TABLE "website_event" (
    "event_id" UUID NOT NULL,
    "website_id" UUID NOT NULL,
    "session_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,
    "url_path" VARCHAR(500) NOT NULL,
    "url_query" VARCHAR(500),
    "referrer_path" VARCHAR(500),
    "referrer_query" VARCHAR(500),
    "referrer_domain" VARCHAR(500),
    "page_title" VARCHAR(500),
    "event_type" INTEGER NOT NULL DEFAULT 1,
    "event_name" VARCHAR(50),

    CONSTRAINT "website_event_pkey" PRIMARY KEY ("event_id")
);

-- CreateTable
CREATE TABLE "event_data" (
    "event_id" UUID NOT NULL,
    "website_id" UUID NOT NULL,
    "website_event_id" UUID NOT NULL,
    "event_key" VARCHAR(500) NOT NULL,
    "event_string_value" VARCHAR(500),
    "event_numeric_value" DECIMAL(19,4),
    "event_date_value" TIMESTAMPTZ(6),
    "event_data_type" INTEGER NOT NULL,
    "created_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "event_data_pkey" PRIMARY KEY ("event_id")
);

-- CreateTable
CREATE TABLE "team" (
    "team_id" UUID NOT NULL,
    "name" VARCHAR(50) NOT NULL,
    "access_code" VARCHAR(50),
    "created_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6),

    CONSTRAINT "team_pkey" PRIMARY KEY ("team_id")
);

-- CreateTable
CREATE TABLE "team_user" (
    "team_user_id" UUID NOT NULL,
    "team_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "role" VARCHAR(50) NOT NULL,
    "created_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6),

    CONSTRAINT "team_user_pkey" PRIMARY KEY ("team_user_id")
);

-- CreateTable
CREATE TABLE "team_website" (
    "team_website_id" UUID NOT NULL,
    "team_id" UUID NOT NULL,
    "website_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "team_website_pkey" PRIMARY KEY ("team_website_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "user_user_id_key" ON "user"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_username_key" ON "user"("username");

-- CreateIndex
CREATE UNIQUE INDEX "session_session_id_key" ON "session"("session_id");

-- CreateIndex
CREATE INDEX "session_created_at_idx" ON "session"("created_at");

-- CreateIndex
CREATE INDEX "session_website_id_idx" ON "session"("website_id");

-- CreateIndex
CREATE UNIQUE INDEX "website_website_id_key" ON "website"("website_id");

-- CreateIndex
CREATE UNIQUE INDEX "website_share_id_key" ON "website"("share_id");

-- CreateIndex
CREATE INDEX "website_user_id_idx" ON "website"("user_id");

-- CreateIndex
CREATE INDEX "website_created_at_idx" ON "website"("created_at");

-- CreateIndex
CREATE INDEX "website_share_id_idx" ON "website"("share_id");

-- CreateIndex
CREATE INDEX "website_event_created_at_idx" ON "website_event"("created_at");

-- CreateIndex
CREATE INDEX "website_event_session_id_idx" ON "website_event"("session_id");

-- CreateIndex
CREATE INDEX "website_event_website_id_idx" ON "website_event"("website_id");

-- CreateIndex
CREATE INDEX "website_event_website_id_created_at_idx" ON "website_event"("website_id", "created_at");

-- CreateIndex
CREATE INDEX "website_event_website_id_session_id_created_at_idx" ON "website_event"("website_id", "session_id", "created_at");

-- CreateIndex
CREATE INDEX "event_data_created_at_idx" ON "event_data"("created_at");

-- CreateIndex
CREATE INDEX "event_data_website_id_idx" ON "event_data"("website_id");

-- CreateIndex
CREATE INDEX "event_data_website_event_id_idx" ON "event_data"("website_event_id");

-- CreateIndex
CREATE UNIQUE INDEX "team_team_id_key" ON "team"("team_id");

-- CreateIndex
CREATE UNIQUE INDEX "team_access_code_key" ON "team"("access_code");

-- CreateIndex
CREATE INDEX "team_access_code_idx" ON "team"("access_code");

-- CreateIndex
CREATE UNIQUE INDEX "team_user_team_user_id_key" ON "team_user"("team_user_id");

-- CreateIndex
CREATE INDEX "team_user_team_id_idx" ON "team_user"("team_id");

-- CreateIndex
CREATE INDEX "team_user_user_id_idx" ON "team_user"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "team_website_team_website_id_key" ON "team_website"("team_website_id");

-- CreateIndex
CREATE INDEX "team_website_team_id_idx" ON "team_website"("team_id");

-- CreateIndex
CREATE INDEX "team_website_website_id_idx" ON "team_website"("website_id");

-- AddSystemUser
INSERT INTO "user" (user_id, username, role, password) VALUES ('41e2b680-648e-4b09-bcd7-3e2b10c06264' , 'admin', 'admin', '$2b$10$BUli0c.muyCW1ErNJc3jL.vFRFtFJWrT8/GcR4A.sUdCznaXiqFXa');


================================================
FILE: prisma/migrations/02_report_schema_session_data/migration.sql
================================================
-- AlterTable
ALTER TABLE "event_data" RENAME COLUMN "event_data_type" TO "data_type";
ALTER TABLE "event_data" RENAME COLUMN "event_date_value" TO "date_value";
ALTER TABLE "event_data" RENAME COLUMN "event_id" TO "event_data_id";
ALTER TABLE "event_data" RENAME COLUMN "event_numeric_value" TO "number_value";
ALTER TABLE "event_data" RENAME COLUMN "event_string_value" TO "string_value";

-- CreateTable
CREATE TABLE "session_data" (
    "session_data_id" UUID NOT NULL,
    "website_id" UUID NOT NULL,
    "session_id" UUID NOT NULL,
    "session_key" VARCHAR(500) NOT NULL,
    "string_value" VARCHAR(500),
    "number_value" DECIMAL(19,4),
    "date_value" TIMESTAMPTZ(6),
    "data_type" INTEGER NOT NULL,
    "created_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "session_data_pkey" PRIMARY KEY ("session_data_id")
);

-- CreateTable
CREATE TABLE "report" (
    "report_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "website_id" UUID NOT NULL,
    "type" VARCHAR(200) NOT NULL,
    "name" VARCHAR(200) NOT NULL,
    "description" VARCHAR(500) NOT NULL,
    "parameters" VARCHAR(6000) NOT NULL,
    "created_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6),

    CONSTRAINT "report_pkey" PRIMARY KEY ("report_id")
);

-- CreateIndex
CREATE INDEX "session_data_created_at_idx" ON "session_data"("created_at");

-- CreateIndex
CREATE INDEX "session_data_website_id_idx" ON "session_data"("website_id");

-- CreateIndex
CREATE INDEX "session_data_session_id_idx" ON "session_data"("session_id");

-- CreateIndex
CREATE UNIQUE INDEX "report_report_id_key" ON "report"("report_id");

-- CreateIndex
CREATE INDEX "report_user_id_idx" ON "report"("user_id");

-- CreateIndex
CREATE INDEX "report_website_id_idx" ON "report"("website_id");

-- CreateIndex
CREATE INDEX "report_type_idx" ON "report"("type");

-- CreateIndex
CREATE INDEX "report_name_idx" ON "report"("name");

-- EventData migration
UPDATE "event_data"
SET string_value = number_value
WHERE data_type = 2;

UPDATE "event_data"
SET string_value = CONCAT(REPLACE(TO_CHAR(date_value, 'YYYY-MM-DD HH24:MI:SS'), ' ', 'T'), 'Z')
WHERE data_type = 4;


================================================
FILE: prisma/migrations/03_metric_performance_index/migration.sql
================================================
-- CreateIndex
CREATE INDEX "event_data_website_id_created_at_idx" ON "event_data"("website_id", "created_at");

-- CreateIndex
CREATE INDEX "event_data_website_id_created_at_event_key_idx" ON "event_data"("website_id", "created_at", "event_key");

-- CreateIndex
CREATE INDEX "session_website_id_created_at_idx" ON "session"("website_id", "created_at");

-- CreateIndex
CREATE INDEX "session_website_id_created_at_hostname_idx" ON "session"("website_id", "created_at", "hostname");

-- CreateIndex
CREATE INDEX "session_website_id_created_at_browser_idx" ON "session"("website_id", "created_at", "browser");

-- CreateIndex
CREATE INDEX "session_website_id_created_at_os_idx" ON "session"("website_id", "created_at", "os");

-- CreateIndex
CREATE INDEX "session_website_id_created_at_device_idx" ON "session"("website_id", "created_at", "device");

-- CreateIndex
CREATE INDEX "session_website_id_created_at_screen_idx" ON "session"("website_id", "created_at", "screen");

-- CreateIndex
CREATE INDEX "session_website_id_created_at_language_idx" ON "session"("website_id", "created_at", "language");

-- CreateIndex
CREATE INDEX "session_website_id_created_at_country_idx" ON "session"("website_id", "created_at", "country");

-- CreateIndex
CREATE INDEX "session_website_id_created_at_subdivision1_idx" ON "session"("website_id", "created_at", "subdivision1");

-- CreateIndex
CREATE INDEX "session_website_id_created_at_city_idx" ON "session"("website_id", "created_at", "city");

-- CreateIndex
CREATE INDEX "website_event_website_id_created_at_url_path_idx" ON "website_event"("website_id", "created_at", "url_path");

-- CreateIndex
CREATE INDEX "website_event_website_id_created_at_url_query_idx" ON "website_event"("website_id", "created_at", "url_query");

-- CreateIndex
CREATE INDEX "website_event_website_id_created_at_referrer_domain_idx" ON "website_event"("website_id", "created_at", "referrer_domain");

-- CreateIndex
CREATE INDEX "website_event_website_id_created_at_page_title_idx" ON "website_event"("website_id", "created_at", "page_title");

-- CreateIndex
CREATE INDEX "website_event_website_id_created_at_event_name_idx" ON "website_event"("website_id", "created_at", "event_name");



================================================
FILE: prisma/migrations/04_team_redesign/migration.sql
================================================
/*
  Warnings:

  - You are about to drop the `team_website` table. If the table is not empty, all the data it contains will be lost.

*/
-- AlterTable
ALTER TABLE "team" ADD COLUMN     "deleted_at" TIMESTAMPTZ(6),
ADD COLUMN     "logo_url" VARCHAR(2183);

-- AlterTable
ALTER TABLE "user" ADD COLUMN     "display_name" VARCHAR(255),
ADD COLUMN     "logo_url" VARCHAR(2183);

-- AlterTable
ALTER TABLE "website" ADD COLUMN     "created_by" UUID,
ADD COLUMN     "team_id" UUID;

-- MigrateData
UPDATE "website" SET created_by = user_id WHERE team_id IS NULL;

-- DropTable
DROP TABLE "team_website";

-- CreateIndex
CREATE INDEX "website_team_id_idx" ON "website"("team_id");

-- CreateIndex
CREATE INDEX "website_created_by_idx" ON "website"("created_by");


================================================
FILE: prisma/migrations/05_add_visit_id/migration.sql
================================================
-- AlterTable
ALTER TABLE "website_event" ADD COLUMN "visit_id" UUID NULL;

UPDATE "website_event" we
SET visit_id = a.uuid
FROM (SELECT DISTINCT
        s.session_id,
        s.visit_time,
        gen_random_uuid() uuid
    FROM (SELECT DISTINCT session_id,
            date_trunc('hour', created_at) visit_time
        FROM "website_event") s) a
WHERE we.session_id = a.session_id 
    and date_trunc('hour', we.created_at) = a.visit_time;

ALTER TABLE "website_event" ALTER COLUMN "visit_id" SET NOT NULL;

-- CreateIndex
CREATE INDEX "website_event_visit_id_idx" ON "website_event"("visit_id");

-- CreateIndex
CREATE INDEX "website_event_website_id_visit_id_created_at_idx" ON "website_event"("website_id", "visit_id", "created_at");


================================================
FILE: prisma/migrations/06_session_data/migration.sql
================================================
-- DropIndex
DROP INDEX IF EXISTS "event_data_website_id_created_at_event_key_idx";

-- AlterTable
ALTER TABLE "event_data" RENAME COLUMN "event_key" TO "data_key";

-- AlterTable
ALTER TABLE "session_data" DROP COLUMN "deleted_at";
ALTER TABLE "session_data" RENAME COLUMN "session_key" TO "data_key";

-- CreateIndex
CREATE INDEX "event_data_website_id_created_at_data_key_idx" ON "event_data"("website_id", "created_at", "data_key");

-- CreateIndex
CREATE INDEX "session_data_session_id_created_at_idx" ON "session_data"("session_id", "created_at");

-- CreateIndex
CREATE INDEX "session_data_website_id_created_at_data_key_idx" ON "session_data"("website_id", "created_at", "data_key");



================================================
FILE: prisma/migrations/07_add_tag/migration.sql
================================================
-- AlterTable
ALTER TABLE "website_event" ADD COLUMN     "tag" VARCHAR(50);

-- CreateIndex
CREATE INDEX "website_event_website_id_created_at_tag_idx" ON "website_event"("website_id", "created_at", "tag");



================================================
FILE: prisma/migrations/08_add_utm_clid/migration.sql
================================================
-- AlterTable
ALTER TABLE "website_event" 
ADD COLUMN     "fbclid" VARCHAR(255),
ADD COLUMN     "gclid" VARCHAR(255),
ADD COLUMN     "li_fat_id" VARCHAR(255),
ADD COLUMN     "msclkid" VARCHAR(255),
ADD COLUMN     "ttclid" VARCHAR(255),
ADD COLUMN     "twclid" VARCHAR(255),
ADD COLUMN     "utm_campaign" VARCHAR(255),
ADD COLUMN     "utm_content" VARCHAR(255),
ADD COLUMN     "utm_medium" VARCHAR(255),
ADD COLUMN     "utm_source" VARCHAR(255),
ADD COLUMN     "utm_term" VARCHAR(255);



================================================
FILE: prisma/migrations/09_update_hostname_region/migration.sql
================================================
-- AlterTable
ALTER TABLE "website_event" ADD COLUMN     "hostname" VARCHAR(100);

-- DataMigration
UPDATE "website_event" w
SET hostname = s.hostname
FROM "session" s
WHERE s.website_id = w.website_id
    and s.session_id = w.session_id;

-- DropIndex
DROP INDEX IF EXISTS "session_website_id_created_at_hostname_idx";
DROP INDEX IF EXISTS "session_website_id_created_at_subdivision1_idx";

-- AlterTable
ALTER TABLE "session" RENAME COLUMN "subdivision1" TO "region";
ALTER TABLE "session" DROP COLUMN "subdivision2";
ALTER TABLE "session" DROP COLUMN "hostname";

-- CreateIndex
CREATE INDEX "website_event_website_id_created_at_hostname_idx" ON "website_event"("website_id", "created_at", "hostname");
CREATE INDEX "session_website_id_created_at_region_idx" ON "session"("website_id", "created_at", "region");






================================================
FILE: prisma/migrations/10_add_distinct_id/migration.sql
================================================
-- AlterTable
ALTER TABLE "session" ADD COLUMN     "distinct_id" VARCHAR(50);

-- AlterTable
ALTER TABLE "session_data" ADD COLUMN     "distinct_id" VARCHAR(50);



================================================
FILE: prisma/migrations/11_add_segment/migration.sql
================================================
-- CreateTable
CREATE TABLE "segment" (
    "segment_id" UUID NOT NULL,
    "website_id" UUID NOT NULL,
    "type" VARCHAR(200) NOT NULL,
    "name" VARCHAR(200) NOT NULL,
    "parameters" JSONB NOT NULL,
    "created_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6),

    CONSTRAINT "segment_pkey" PRIMARY KEY ("segment_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "segment_segment_id_key" ON "segment"("segment_id");

-- CreateIndex
CREATE INDEX "segment_website_id_idx" ON "segment"("website_id");



================================================
FILE: prisma/migrations/12_update_report_parameter/migration.sql
================================================
-- AlterTable
ALTER TABLE "report"
ALTER COLUMN "parameters" SET DATA TYPE JSONB USING parameters::JSONB;



================================================
FILE: prisma/migrations/13_add_revenue/migration.sql
================================================
-- CreateTable
CREATE TABLE "revenue" (
    "revenue_id" UUID NOT NULL,
    "website_id" UUID NOT NULL,
    "session_id" UUID NOT NULL,
    "event_id" UUID NOT NULL,
    "event_name" VARCHAR(50) NOT NULL,
    "currency" VARCHAR(100) NOT NULL,
    "revenue" DECIMAL(19,4),
    "created_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "revenue_pkey" PRIMARY KEY ("revenue_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "revenue_revenue_id_key" ON "revenue"("revenue_id");

-- CreateIndex
CREATE INDEX "revenue_website_id_idx" ON "revenue"("website_id");

-- CreateIndex
CREATE INDEX "revenue_session_id_idx" ON "revenue"("session_id");

-- CreateIndex
CREATE INDEX "revenue_website_id_created_at_idx" ON "revenue"("website_id", "created_at");

-- CreateIndex
CREATE INDEX "revenue_website_id_session_id_created_at_idx" ON "revenue"("website_id", "session_id", "created_at");



================================================
FILE: prisma/migrations/14_add_link_and_pixel/migration.sql
================================================
-- AlterTable
ALTER TABLE "report" ALTER COLUMN "type" SET DATA TYPE VARCHAR(50);

-- AlterTable
ALTER TABLE "revenue" ALTER COLUMN "currency" SET DATA TYPE VARCHAR(10);

-- AlterTable
ALTER TABLE "segment" ALTER COLUMN "type" SET DATA TYPE VARCHAR(50);

-- CreateTable
CREATE TABLE "link" (
    "link_id" UUID NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "url" VARCHAR(500) NOT NULL,
    "slug" VARCHAR(100) NOT NULL,
    "user_id" UUID,
    "team_id" UUID,
    "created_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6),
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "link_pkey" PRIMARY KEY ("link_id")
);

-- CreateTable
CREATE TABLE "pixel" (
    "pixel_id" UUID NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "slug" VARCHAR(100) NOT NULL,
    "user_id" UUID,
    "team_id" UUID,
    "created_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6),
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "pixel_pkey" PRIMARY KEY ("pixel_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "link_link_id_key" ON "link"("link_id");

-- CreateIndex
CREATE UNIQUE INDEX "link_slug_key" ON "link"("slug");

-- CreateIndex
CREATE INDEX "link_slug_idx" ON "link"("slug");

-- CreateIndex
CREATE INDEX "link_user_id_idx" ON "link"("user_id");

-- CreateIndex
CREATE INDEX "link_team_id_idx" ON "link"("team_id");

-- CreateIndex
CREATE INDEX "link_created_at_idx" ON "link"("created_at");

-- CreateIndex
CREATE UNIQUE INDEX "pixel_pixel_id_key" ON "pixel"("pixel_id");

-- CreateIndex
CREATE UNIQUE INDEX "pixel_slug_key" ON "pixel"("slug");

-- CreateIndex
CREATE INDEX "pixel_slug_idx" ON "pixel"("slug");

-- CreateIndex
CREATE INDEX "pixel_user_id_idx" ON "pixel"("user_id");

-- CreateIndex
CREATE INDEX "pixel_team_id_idx" ON "pixel"("team_id");

-- CreateIndex
CREATE INDEX "pixel_created_at_idx" ON "pixel"("created_at");

-- DataMigration Funnel
DELETE FROM "report" WHERE type = 'funnel' and jsonb_array_length(parameters->'steps') = 1;
UPDATE "report" SET parameters = parameters - 'websiteId' - 'dateRange' - 'urls' WHERE type = 'funnel';

UPDATE "report"
SET parameters = jsonb_set(
    parameters,
    '{steps}',
    (
      SELECT jsonb_agg(
               CASE
                 WHEN step->>'type' = 'url'
                 THEN jsonb_set(step, '{type}', '"path"')
                 ELSE step
               END
             )
      FROM jsonb_array_elements(parameters->'steps') step
    )
)
WHERE type = 'funnel'
    and parameters @> '{"steps":[{"type":"url"}]}';

-- DataMigration Goals
UPDATE "report" SET type = 'goal' WHERE type = 'goals';

INSERT INTO "report" (report_id, user_id, website_id, type, name, description, parameters, created_at, updated_at)
SELECT gen_random_uuid(),
    user_id,
    website_id,
    'goal',
    concat(name, ' - ', elem ->> 'value'),
    description,
    jsonb_build_object(
           'type', CASE WHEN elem ->> 'type' = 'url' THEN 'path'
                        ELSE elem ->> 'type' END,
           'value', elem ->> 'value'
       ) AS parameters,
    created_at,
    updated_at
FROM "report"
CROSS JOIN LATERAL jsonb_array_elements(parameters -> 'goals') elem
WHERE type = 'goal'
    and elem ->> 'type' IN ('event', 'url');

DELETE FROM "report" WHERE type = 'goal' and parameters ? 'goals';


================================================
FILE: public/browserconfig.xml
================================================
<?xml version="1.0" encoding="utf-8"?>
<browserconfig>
    <msapplication>
        <tile>
            <square150x150logo src="/mstile-150x150.png"/>
            <TileColor>#da532c</TileColor>
        </tile>
    </msapplication>
</browserconfig>



================================================
FILE: public/robots.txt
================================================
User-agent: *
Disallow: /



================================================
FILE: public/site.webmanifest
================================================
{
  "name": "",
  "short_name": "",
  "icons": [
    {
      "src": "/android-chrome-192x192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "/android-chrome-512x512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ],
  "theme_color": "#ffffff",
  "background_color": "#ffffff",
  "display": "standalone"
}



================================================
FILE: public/intl/country/am-ET.json
================================================
{
  "HU": "\u1200\u1295\u130b\u122a",
  "HT": "\u1200\u12ed\u1272",
  "IN": "\u1205\u1295\u12f5",
  "HN": "\u1206\u1295\u12f1\u122b\u1235",
  "HK": "\u1206\u1295\u130d \u12ae\u1295\u130d \u120d\u12e9 \u12e8\u12a0\u1235\u1270\u12f3\u12f0\u122d \u12ad\u120d\u120d \u127b\u12ed\u1293",
  "LU": "\u1209\u12ad\u1230\u121d\u1260\u122d\u130d",
  "LY": "\u120a\u1262\u12eb",
  "LB": "\u120a\u1263\u1296\u1235",
  "LT": "\u120a\u1271\u12cc\u1292\u12eb",
  "LI": "\u120a\u127d\u1270\u1295\u1235\u1273\u12ed\u1295",
  "LV": "\u120b\u1275\u126a\u12eb",
  "LA": "\u120b\u12a6\u1235",
  "LR": "\u120b\u12ed\u1264\u122a\u12eb",
  "LS": "\u120c\u1236\u1276",
  "FM": "\u121a\u12ad\u122e\u1294\u12e2\u12eb",
  "ML": "\u121b\u120a",
  "MW": "\u121b\u120b\u12ca",
  "MY": "\u121b\u120c\u12e2\u12eb",
  "MT": "\u121b\u120d\u1273",
  "MV": "\u121b\u120d\u12f2\u126d\u1235",
  "MH": "\u121b\u122d\u123b\u120d \u12a0\u12ed\u120b\u1295\u12f5",
  "MQ": "\u121b\u122d\u1272\u1292\u12ad",
  "MO": "\u121b\u12ab\u12a1 \u120d\u12e9 \u12e8\u12a0\u1235\u1270\u12f3\u12f0\u122d \u12ad\u120d\u120d \u127b\u12ed\u1293",
  "CF": "\u121b\u12d5\u12a8\u120b\u12ca \u12a0\u134d\u122a\u12ab \u122a\u1351\u1265\u120a\u12ad",
  "MM": "\u121b\u12ed\u1293\u121b\u122d(\u1260\u122d\u121b)",
  "MG": "\u121b\u12f3\u130b\u1235\u12ab\u122d",
  "MX": "\u121c\u12ad\u1232\u12ae",
  "YT": "\u121c\u12ed\u12a6\u1274",
  "EH": "\u121d\u12d5\u122b\u1263\u12ca \u1233\u1205\u122b",
  "MD": "\u121e\u120d\u12f6\u126b",
  "MU": "\u121e\u122a\u1238\u1235",
  "MR": "\u121e\u122a\u1274\u1292\u12eb",
  "MA": "\u121e\u122e\u12ae",
  "MC": "\u121e\u1293\u12ae",
  "ME": "\u121e\u1295\u1270\u1294\u130d\u122e",
  "MS": "\u121e\u1295\u1275\u1234\u122b\u1275",
  "MN": "\u121e\u1295\u130e\u120a\u12eb",
  "MZ": "\u121e\u12db\u121d\u1262\u12ad",
  "RU": "\u1229\u1235\u12eb",
  "RW": "\u1229\u12cb\u1295\u12f3",
  "RE": "\u122a\u12e9\u1292\u12e8\u1295",
  "RO": "\u122e\u121c\u1292\u12eb",
  "SB": "\u1230\u120e\u121e\u1295 \u12f0\u1234\u1275",
  "MK": "\u1230\u121c\u1295 \u1218\u1244\u12f6\u1295\u12eb",
  "KP": "\u1230\u121c\u1295 \u12ae\u122a\u12eb",
  "RS": "\u1230\u122d\u1265\u12eb",
  "SO": "\u1231\u121b\u120c",
  "SR": "\u1231\u122a\u1293\u121d",
  "SZ": "\u1231\u12cb\u12da\u120b\u1295\u12f5",
  "SD": "\u1231\u12f3\u1295",
  "LK": "\u1232\u122a\u120b\u1295\u12ab",
  "SY": "\u1232\u122a\u12eb",
  "SC": "\u1232\u123c\u120d\u1235",
  "SX": "\u1232\u1295\u1275 \u121b\u122d\u1270\u1295",
  "SG": "\u1232\u1295\u130b\u1356\u122d",
  "WS": "\u1233\u121e\u12a0",
  "SM": "\u1233\u1295 \u121b\u122a\u1296",
  "ST": "\u1233\u12a6 \u1276\u121c \u12a5\u1293 \u1355\u122a\u1295\u1232\u1354",
  "SA": "\u1233\u12cd\u12f5\u12a0\u1228\u1262\u12eb",
  "CY": "\u1233\u12ed\u1355\u1228\u1235",
  "SL": "\u1234\u122b\u120a\u12ee\u1295",
  "SN": "\u1234\u1294\u130b\u120d",
  "SH": "\u1234\u1295\u1275 \u1204\u1208\u1293",
  "LC": "\u1234\u1295\u1275 \u1209\u127a\u12eb",
  "MF": "\u1234\u1295\u1275 \u121b\u122d\u1272\u1295",
  "SK": "\u1235\u120e\u126b\u12aa\u12eb",
  "SI": "\u1235\u120e\u126c\u1292\u12eb",
  "SJ": "\u1235\u126b\u120d\u1263\u122d\u12f5 \u12a5\u1293 \u1303\u1295 \u121b\u12e8\u1295",
  "CH": "\u1235\u12ca\u12d8\u122d\u120b\u1295\u12f5",
  "SE": "\u1235\u12ca\u12f5\u1295",
  "ES": "\u1235\u1354\u1295",
  "BL": "\u1245\u12f1\u1235 \u1260\u122d\u1274\u120e\u121c",
  "VC": "\u1245\u12f1\u1235 \u126a\u1295\u1234\u1295\u1275 \u12a5\u1293 \u130d\u122c\u1293\u12f2\u1295\u1235",
  "KN": "\u1245\u12f1\u1235 \u12aa\u1275\u1235 \u12a5\u1293 \u1294\u126a\u1235",
  "PM": "\u1245\u12f1\u1235 \u1352\u12ec\u122d \u12a5\u1293 \u121a\u12a9\u12a4\u120e\u1295",
  "BZ": "\u1260\u120a\u12dd",
  "BT": "\u1261\u1205\u1273\u1295",
  "BG": "\u1261\u120d\u130c\u122a\u12eb",
  "BF": "\u1261\u122d\u12aa\u1293 \u134b\u1236",
  "BV": "\u1261\u126c\u1275 \u12f0\u1234\u1275",
  "BS": "\u1263\u1203\u121b\u1235",
  "BH": "\u1263\u1205\u122c\u1295",
  "BB": "\u1263\u122d\u1264\u12f6\u1235",
  "BD": "\u1263\u1295\u130d\u120b\u12f2\u123d",
  "BY": "\u1264\u120b\u1229\u1235",
  "BE": "\u1264\u120d\u1304\u121d",
  "BM": "\u1264\u122d\u1219\u12f3",
  "BJ": "\u1264\u1292\u1295",
  "BN": "\u1265\u1229\u1292",
  "BI": "\u1265\u1229\u1295\u12f2",
  "BR": "\u1265\u122b\u12da\u120d",
  "BO": "\u1266\u120a\u126a\u12eb",
  "BA": "\u1266\u1235\u1292\u12eb \u12a5\u1293 \u1204\u122d\u12de\u130e\u126a\u1292\u12eb",
  "BW": "\u1266\u1275\u1235\u12cb\u1293",
  "VA": "\u126b\u1272\u12ab\u1295 \u12a8\u1270\u121b",
  "VU": "\u126b\u1291\u12a0\u1271",
  "VN": "\u126c\u1275\u1293\u121d",
  "VE": "\u126c\u1295\u12d9\u12cc\u120b",
  "TR": "\u1271\u122d\u12ad",
  "TM": "\u1271\u122d\u12ad\u121c\u1292\u1235\u1273\u1295",
  "TV": "\u1271\u126b\u1209",
  "TN": "\u1271\u1292\u12da\u12eb",
  "TL": "\u1272\u121e\u122d \u120c\u1235\u1274",
  "TZ": "\u1273\u1295\u12db\u1292\u12eb",
  "TH": "\u1273\u12ed\u120b\u1295\u12f5",
  "TW": "\u1273\u12ed\u12cb\u1295",
  "TJ": "\u1273\u1303\u12aa\u1235\u1273\u1295",
  "TT": "\u1275\u122a\u1293\u12f3\u12f5 \u12a5\u1293 \u1276\u1264\u130e",
  "TO": "\u1276\u1295\u130b",
  "TK": "\u1276\u12ad\u120b\u12cd",
  "TG": "\u1276\u1310",
  "CL": "\u127a\u120a",
  "CN": "\u127b\u12ed\u1293",
  "TD": "\u127b\u12f5",
  "CZ": "\u127c\u127a\u12eb",
  "NU": "\u1292\u12a1\u12ed",
  "NI": "\u1292\u12ab\u122b\u1313",
  "NC": "\u1292\u12cd \u12ab\u120c\u12f6\u1292\u12eb",
  "NZ": "\u1292\u12cd \u12da\u120b\u1295\u12f5",
  "NE": "\u1292\u1300\u122d",
  "NA": "\u1293\u121a\u1262\u12eb",
  "NR": "\u1293\u12a1\u1229",
  "NG": "\u1293\u12ed\u1304\u122a\u12eb",
  "NL": "\u1294\u12d8\u122d\u120b\u1295\u12f5",
  "NP": "\u1294\u1353\u120d",
  "NO": "\u1296\u122d\u12cc\u12ed",
  "NF": "\u1296\u122d\u134e\u120d\u12ad \u12f0\u1234\u1275",
  "AL": "\u12a0\u120d\u1263\u1292\u12eb",
  "DZ": "\u12a0\u120d\u1304\u122a\u12eb",
  "AW": "\u12a0\u1229\u1263",
  "AM": "\u12a0\u122d\u121c\u1292\u12eb",
  "AR": "\u12a0\u122d\u1300\u1295\u1272\u1293",
  "AG": "\u12a0\u1295\u1272\u1313 \u12a5\u1293 \u1263\u1229\u12f3",
  "AQ": "\u12a0\u1295\u1273\u122d\u12ad\u1272\u12ab",
  "AD": "\u12a0\u1295\u12f6\u122b",
  "AI": "\u12a0\u1295\u1309\u12ed\u120b",
  "AO": "\u12a0\u1295\u1310\u120b",
  "AU": "\u12a0\u12cd\u1235\u1275\u122b\u120d\u12eb",
  "AZ": "\u12a0\u12d8\u122d\u1263\u1303\u1295",
  "IE": "\u12a0\u12e8\u122d\u120b\u1295\u12f5",
  "IM": "\u12a0\u12ed\u120d \u12a6\u134d \u121b\u1295",
  "IS": "\u12a0\u12ed\u1235\u120b\u1295\u12f5",
  "AF": "\u12a0\u134d\u130b\u1292\u1235\u1273\u1295",
  "UY": "\u12a1\u122b\u1313\u12ed",
  "UZ": "\u12a1\u12dd\u1264\u12aa\u1235\u1273\u1295",
  "IQ": "\u12a2\u122b\u1245",
  "IR": "\u12a2\u122b\u1295",
  "ET": "\u12a2\u1275\u12ee\u1335\u12eb",
  "ID": "\u12a2\u1295\u12f6\u1294\u12e2\u12eb",
  "GQ": "\u12a2\u12b3\u1276\u122a\u12eb\u120d \u130a\u1292",
  "EC": "\u12a2\u12b3\u12f6\u122d",
  "SV": "\u12a4\u120d \u1233\u120d\u126b\u12f6\u122d",
  "ER": "\u12a4\u122d\u1275\u122b",
  "EE": "\u12a4\u1235\u1276\u1292\u12eb",
  "IL": "\u12a5\u1235\u122b\u12a4\u120d",
  "OM": "\u12a6\u121b\u1295",
  "AT": "\u12a6\u1235\u1275\u122a\u12eb",
  "CW": "\u12a9\u122b\u1233\u12ce",
  "CU": "\u12a9\u1263",
  "CK": "\u12a9\u12ad \u12f0\u1234\u1276\u127d",
  "KI": "\u12aa\u122a\u1263\u1272",
  "KG": "\u12aa\u122d\u130a\u1235\u1273\u1295",
  "CM": "\u12ab\u121c\u1229\u1295",
  "KH": "\u12ab\u121d\u1266\u12f2\u12eb",
  "CA": "\u12ab\u1293\u12f3",
  "KZ": "\u12ab\u12db\u12aa\u1235\u1273\u1295",
  "KY": "\u12ab\u12ed\u121b\u1295 \u12f0\u1234\u1276\u127d",
  "KE": "\u12ac\u1295\u12eb",
  "CV": "\u12ac\u1355 \u126c\u122d\u12f4",
  "CX": "\u12ad\u122a\u1235\u121b\u1235 \u12f0\u1234\u1275",
  "HR": "\u12ad\u122e\u12a4\u123d\u12eb",
  "KW": "\u12ad\u12cc\u1275",
  "CO": "\u12ae\u120e\u121d\u1262\u12eb",
  "KM": "\u12ae\u121e\u122e\u1235",
  "XK": "\u12ee\u1236\u126e",
  "CR": "\u12ae\u1235\u1273\u122a\u12ab",
  "CI": "\u12ae\u1275 \u12f2\u126f\u122d",
  "CG": "\u12ae\u1295\u130e \u1265\u122b\u12db\u126a\u120d",
  "CD": "\u12ae\u1295\u130e-\u12aa\u1295\u123b\u1233",
  "CC": "\u12ae\u12ae\u1235(\u12ac\u120a\u1295\u130d) \u12f0\u1234\u1276\u127d",
  "QA": "\u12b3\u1273\u122d",
  "HM": "\u12bd\u122d\u12f5 \u12f0\u1234\u1276\u127d\u1293 \u121b\u12ad\u12f6\u1293\u120d\u12f5 \u12f0\u1234\u1276\u127d",
  "WF": "\u12cb\u120a\u1235 \u12a5\u1293 \u1349\u1271\u1293 \u12f0\u1234\u1276\u127d",
  "ZW": "\u12da\u121d\u1267\u1264",
  "ZM": "\u12db\u121d\u1262\u12eb",
  "YE": "\u12e8\u1218\u1295",
  "MP": "\u12e8\u1230\u121c\u1293\u12ca \u121b\u122a\u12eb\u1293 \u12f0\u1234\u1276\u127d",
  "IO": "\u12e8\u1265\u122a\u1273\u1292\u12eb \u1205\u1295\u12f5 \u12cd\u1242\u12eb\u1296\u1235 \u130d\u12db\u1275",
  "AE": "\u12e8\u1270\u1263\u1260\u1229\u1275 \u12d3\u1228\u1265 \u12a4\u121d\u122c\u1275\u1235",
  "TC": "\u12e8\u1271\u122d\u12ae\u127d\u1293 \u12e8\u12ab\u12a2\u12ae\u1235 \u12f0\u1234\u1276\u127d",
  "AX": "\u12e8\u12a0\u120b\u1295\u12f5 \u12f0\u1234\u1276\u127d",
  "AS": "\u12e8\u12a0\u121c\u122a\u12ab \u1233\u121e\u12a0",
  "VI": "\u12e8\u12a0\u121c\u122a\u12ab \u1268\u122d\u1302\u1295 \u12f0\u1234\u1276\u127d",
  "VG": "\u12e8\u12a5\u1295\u130d\u120a\u12dd \u1268\u122d\u1302\u1295 \u12f0\u1234\u1276\u127d",
  "BQ": "\u12e8\u12ab\u122a\u1262\u12eb\u1295 \u1294\u12d8\u122d\u120b\u1295\u12f5\u1235",
  "UM": "\u12e8\u12e9 \u12a4\u1235 \u1320\u1228\u134d \u120b\u12ed \u12eb\u1209 \u12f0\u1234\u1276\u127d",
  "TF": "\u12e8\u1348\u1228\u1295\u1233\u12ed \u12f0\u1261\u1263\u12ca \u130d\u12db\u1276\u127d",
  "GF": "\u12e8\u1348\u1228\u1295\u1233\u12ed \u1309\u12ca\u12a0\u1293",
  "PF": "\u12e8\u1348\u1228\u1295\u1233\u12ed \u1356\u120a\u1294\u12e2\u12eb",
  "FO": "\u12e8\u134b\u122e \u12f0\u1234\u1276\u127d",
  "PS": "\u12e8\u134d\u120d\u1235\u1324\u121d \u130d\u12db\u1275",
  "FK": "\u12e8\u134e\u12ad\u120b\u1295\u12f5 \u12f0\u1234\u1276\u127d",
  "US": "\u12e9\u1293\u12ed\u1275\u12f5 \u1235\u1274\u1275\u1235",
  "GB": "\u12e9\u1293\u12ed\u1275\u12f5 \u12aa\u1295\u130d\u12f0\u121d",
  "UA": "\u12e9\u12ad\u122c\u1295",
  "UG": "\u12e9\u130b\u1295\u12f3",
  "SS": "\u12f0\u1261\u1265 \u1231\u12f3\u1295",
  "ZA": "\u12f0\u1261\u1265 \u12a0\u134d\u122a\u12ab",
  "KR": "\u12f0\u1261\u1265 \u12ae\u122a\u12eb",
  "GS": "\u12f0\u1261\u1265 \u1306\u122d\u1302\u12eb \u12a5\u1293 \u12e8\u12f0\u1261\u1265 \u1233\u1295\u12f5\u12ca\u127d \u12f0\u1234\u1276\u127d",
  "DK": "\u12f4\u1295\u121b\u122d\u12ad",
  "DO": "\u12f6\u1218\u1292\u12ab\u1295 \u122a\u1351\u1265\u120a\u12ad",
  "DM": "\u12f6\u121a\u1292\u12ab",
  "DE": "\u1300\u122d\u1218\u1295",
  "JE": "\u1300\u122d\u1232",
  "DJ": "\u1302\u1261\u1272",
  "GI": "\u1302\u1265\u122b\u120d\u1270\u122d",
  "JM": "\u1303\u121b\u12ed\u12ab",
  "JP": "\u1303\u1353\u1295",
  "JO": "\u1306\u122d\u12f3\u1295",
  "GE": "\u1306\u122d\u1302\u12eb",
  "GG": "\u1309\u122d\u1290\u1232",
  "GU": "\u1309\u12cb\u121d",
  "GT": "\u1309\u12cb\u1272\u121b\u120b",
  "GP": "\u1309\u12cb\u12f0\u1209\u1355",
  "GY": "\u1309\u12eb\u1293",
  "GN": "\u130a\u1292",
  "GW": "\u130a\u1292 \u1262\u1233\u12a6",
  "GM": "\u130b\u121d\u1262\u12eb",
  "GA": "\u130b\u1266\u1295",
  "GH": "\u130b\u1293",
  "GL": "\u130d\u122a\u1295\u120b\u1295\u12f5",
  "GR": "\u130d\u122a\u12ad",
  "GD": "\u130d\u122c\u1293\u12f3",
  "EG": "\u130d\u1265\u133d",
  "IT": "\u1323\u120a\u12eb\u1295",
  "FR": "\u1348\u1228\u1295\u1233\u12ed",
  "PH": "\u134a\u120a\u1352\u1295\u1235",
  "FI": "\u134a\u1295\u120b\u1295\u12f5",
  "FJ": "\u134a\u1302",
  "PN": "\u1352\u1275\u12ab\u12a2\u122d\u1295 \u12a0\u12ed\u1235\u120b\u1295\u12f5",
  "PW": "\u1353\u120b\u12cd",
  "PY": "\u1353\u122b\u1313\u12ed",
  "PA": "\u1353\u1293\u121b",
  "PK": "\u1353\u12aa\u1235\u1273\u1295",
  "PG": "\u1353\u1351\u12cb \u1292\u12cd \u130a\u1292",
  "PE": "\u1354\u1229",
  "PL": "\u1356\u120b\u1295\u12f5",
  "PT": "\u1356\u122d\u1271\u130b\u120d",
  "PR": "\u1356\u122d\u1273 \u122a\u12ae"
}



================================================
FILE: public/intl/country/ar-SA.json
================================================
{
  "IS": "\u0622\u064a\u0633\u0644\u0646\u062f\u0627",
  "ET": "\u0625\u062b\u064a\u0648\u0628\u064a\u0627",
  "AZ": "\u0623\u0630\u0631\u0628\u064a\u062c\u0627\u0646",
  "AM": "\u0623\u0631\u0645\u064a\u0646\u064a\u0627",
  "AW": "\u0623\u0631\u0648\u0628\u0627",
  "ER": "\u0625\u0631\u064a\u062a\u0631\u064a\u0627",
  "ES": "\u0625\u0633\u0628\u0627\u0646\u064a\u0627",
  "AU": "\u0623\u0633\u062a\u0631\u0627\u0644\u064a\u0627",
  "EE": "\u0625\u0633\u062a\u0648\u0646\u064a\u0627",
  "IL": "\u0625\u0633\u0631\u0627\u0626\u064a\u0644",
  "SZ": "\u0625\u0633\u0648\u0627\u062a\u064a\u0646\u064a",
  "AF": "\u0623\u0641\u063a\u0627\u0646\u0633\u062a\u0627\u0646",
  "PS": "\u0627\u0644\u0623\u0631\u0627\u0636\u064a \u0627\u0644\u0641\u0644\u0633\u0637\u064a\u0646\u064a\u0629",
  "AR": "\u0627\u0644\u0623\u0631\u062c\u0646\u062a\u064a\u0646",
  "JO": "\u0627\u0644\u0623\u0631\u062f\u0646",
  "TF": "\u0627\u0644\u0623\u0642\u0627\u0644\u064a\u0645 \u0627\u0644\u062c\u0646\u0648\u0628\u064a\u0629 \u0627\u0644\u0641\u0631\u0646\u0633\u064a\u0629",
  "IO": "\u0627\u0644\u0625\u0642\u0644\u064a\u0645 \u0627\u0644\u0628\u0631\u064a\u0637\u0627\u0646\u064a \u0641\u064a \u0627\u0644\u0645\u062d\u064a\u0637 \u0627\u0644\u0647\u0646\u062f\u064a",
  "EC": "\u0627\u0644\u0625\u0643\u0648\u0627\u062f\u0648\u0631",
  "AE": "\u0627\u0644\u0625\u0645\u0627\u0631\u0627\u062a \u0627\u0644\u0639\u0631\u0628\u064a\u0629 \u0627\u0644\u0645\u062a\u062d\u062f\u0629",
  "AL": "\u0623\u0644\u0628\u0627\u0646\u064a\u0627",
  "BH": "\u0627\u0644\u0628\u062d\u0631\u064a\u0646",
  "BR": "\u0627\u0644\u0628\u0631\u0627\u0632\u064a\u0644",
  "PT": "\u0627\u0644\u0628\u0631\u062a\u063a\u0627\u0644",
  "BA": "\u0627\u0644\u0628\u0648\u0633\u0646\u0629 \u0648\u0627\u0644\u0647\u0631\u0633\u0643",
  "CZ": "\u0627\u0644\u062a\u0634\u064a\u0643",
  "ME": "\u0627\u0644\u062c\u0628\u0644 \u0627\u0644\u0623\u0633\u0648\u062f",
  "DZ": "\u0627\u0644\u062c\u0632\u0627\u0626\u0631",
  "DK": "\u0627\u0644\u062f\u0627\u0646\u0645\u0631\u0643",
  "CV": "\u0627\u0644\u0631\u0623\u0633 \u0627\u0644\u0623\u062e\u0636\u0631",
  "SV": "\u0627\u0644\u0633\u0644\u0641\u0627\u062f\u0648\u0631",
  "SN": "\u0627\u0644\u0633\u0646\u063a\u0627\u0644",
  "SD": "\u0627\u0644\u0633\u0648\u062f\u0627\u0646",
  "SE": "\u0627\u0644\u0633\u0648\u064a\u062f",
  "EH": "\u0627\u0644\u0635\u062d\u0631\u0627\u0621 \u0627\u0644\u063a\u0631\u0628\u064a\u0629",
  "SO": "\u0627\u0644\u0635\u0648\u0645\u0627\u0644",
  "CN": "\u0627\u0644\u0635\u064a\u0646",
  "IQ": "\u0627\u0644\u0639\u0631\u0627\u0642",
  "GA": "\u0627\u0644\u063a\u0627\u0628\u0648\u0646",
  "VA": "\u0627\u0644\u0641\u0627\u062a\u064a\u0643\u0627\u0646",
  "PH": "\u0627\u0644\u0641\u0644\u0628\u064a\u0646",
  "CM": "\u0627\u0644\u0643\u0627\u0645\u064a\u0631\u0648\u0646",
  "CG": "\u0627\u0644\u0643\u0648\u0646\u063a\u0648 - \u0628\u0631\u0627\u0632\u0627\u0641\u064a\u0644",
  "CD": "\u0627\u0644\u0643\u0648\u0646\u063a\u0648 - \u0643\u064a\u0646\u0634\u0627\u0633\u0627",
  "KW": "\u0627\u0644\u0643\u0648\u064a\u062a",
  "DE": "\u0623\u0644\u0645\u0627\u0646\u064a\u0627",
  "MA": "\u0627\u0644\u0645\u063a\u0631\u0628",
  "MX": "\u0627\u0644\u0645\u0643\u0633\u064a\u0643",
  "SA": "\u0627\u0644\u0645\u0645\u0644\u0643\u0629 \u0627\u0644\u0639\u0631\u0628\u064a\u0629 \u0627\u0644\u0633\u0639\u0648\u062f\u064a\u0629",
  "GB": "\u0627\u0644\u0645\u0645\u0644\u0643\u0629 \u0627\u0644\u0645\u062a\u062d\u062f\u0629",
  "NO": "\u0627\u0644\u0646\u0631\u0648\u064a\u062c",
  "AT": "\u0627\u0644\u0646\u0645\u0633\u0627",
  "NE": "\u0627\u0644\u0646\u064a\u062c\u0631",
  "IN": "\u0627\u0644\u0647\u0646\u062f",
  "US": "\u0627\u0644\u0648\u0644\u0627\u064a\u0627\u062a \u0627\u0644\u0645\u062a\u062d\u062f\u0629",
  "JP": "\u0627\u0644\u064a\u0627\u0628\u0627\u0646",
  "YE": "\u0627\u0644\u064a\u0645\u0646",
  "GR": "\u0627\u0644\u064a\u0648\u0646\u0627\u0646",
  "AQ": "\u0623\u0646\u062a\u0627\u0631\u0643\u062a\u064a\u0643\u0627",
  "AG": "\u0623\u0646\u062a\u064a\u063a\u0648\u0627 \u0648\u0628\u0631\u0628\u0648\u062f\u0627",
  "AD": "\u0623\u0646\u062f\u0648\u0631\u0627",
  "ID": "\u0625\u0646\u062f\u0648\u0646\u064a\u0633\u064a\u0627",
  "AO": "\u0623\u0646\u063a\u0648\u0644\u0627",
  "AI": "\u0623\u0646\u063a\u0648\u064a\u0644\u0627",
  "UY": "\u0623\u0648\u0631\u0648\u063a\u0648\u0627\u064a",
  "UZ": "\u0623\u0648\u0632\u0628\u0643\u0633\u062a\u0627\u0646",
  "UG": "\u0623\u0648\u063a\u0646\u062f\u0627",
  "UA": "\u0623\u0648\u0643\u0631\u0627\u0646\u064a\u0627",
  "IR": "\u0625\u064a\u0631\u0627\u0646",
  "IE": "\u0623\u064a\u0631\u0644\u0646\u062f\u0627",
  "IT": "\u0625\u064a\u0637\u0627\u0644\u064a\u0627",
  "PG": "\u0628\u0627\u0628\u0648\u0627 \u063a\u064a\u0646\u064a\u0627 \u0627\u0644\u062c\u062f\u064a\u062f\u0629",
  "PY": "\u0628\u0627\u0631\u0627\u063a\u0648\u0627\u064a",
  "PK": "\u0628\u0627\u0643\u0633\u062a\u0627\u0646",
  "PW": "\u0628\u0627\u0644\u0627\u0648",
  "BB": "\u0628\u0631\u0628\u0627\u062f\u0648\u0633",
  "BM": "\u0628\u0631\u0645\u0648\u062f\u0627",
  "BN": "\u0628\u0631\u0648\u0646\u0627\u064a",
  "BE": "\u0628\u0644\u062c\u064a\u0643\u0627",
  "BG": "\u0628\u0644\u063a\u0627\u0631\u064a\u0627",
  "BZ": "\u0628\u0644\u064a\u0632",
  "BD": "\u0628\u0646\u063a\u0644\u0627\u062f\u064a\u0634",
  "PA": "\u0628\u0646\u0645\u0627",
  "BJ": "\u0628\u0646\u064a\u0646",
  "BT": "\u0628\u0648\u062a\u0627\u0646",
  "BW": "\u0628\u0648\u062a\u0633\u0648\u0627\u0646\u0627",
  "PR": "\u0628\u0648\u0631\u062a\u0648\u0631\u064a\u0643\u0648",
  "BF": "\u0628\u0648\u0631\u0643\u064a\u0646\u0627 \u0641\u0627\u0633\u0648",
  "BI": "\u0628\u0648\u0631\u0648\u0646\u062f\u064a",
  "PL": "\u0628\u0648\u0644\u0646\u062f\u0627",
  "BO": "\u0628\u0648\u0644\u064a\u0641\u064a\u0627",
  "PF": "\u0628\u0648\u0644\u064a\u0646\u064a\u0632\u064a\u0627 \u0627\u0644\u0641\u0631\u0646\u0633\u064a\u0629",
  "PE": "\u0628\u064a\u0631\u0648",
  "BY": "\u0628\u064a\u0644\u0627\u0631\u0648\u0633",
  "TH": "\u062a\u0627\u064a\u0644\u0627\u0646\u062f",
  "TW": "\u062a\u0627\u064a\u0648\u0627\u0646",
  "TM": "\u062a\u0631\u0643\u0645\u0627\u0646\u0633\u062a\u0627\u0646",
  "TR": "\u062a\u0631\u0643\u064a\u0627",
  "TT": "\u062a\u0631\u064a\u0646\u064a\u062f\u0627\u062f \u0648\u062a\u0648\u0628\u0627\u063a\u0648",
  "TD": "\u062a\u0634\u0627\u062f",
  "CL": "\u062a\u0634\u064a\u0644\u064a",
  "TZ": "\u062a\u0646\u0632\u0627\u0646\u064a\u0627",
  "TG": "\u062a\u0648\u063a\u0648",
  "TV": "\u062a\u0648\u0641\u0627\u0644\u0648",
  "TK": "\u062a\u0648\u0643\u064a\u0644\u0648",
  "TN": "\u062a\u0648\u0646\u0633",
  "TO": "\u062a\u0648\u0646\u063a\u0627",
  "TL": "\u062a\u064a\u0645\u0648\u0631 - \u0644\u064a\u0634\u062a\u064a",
  "JM": "\u062c\u0627\u0645\u0627\u064a\u0643\u0627",
  "GI": "\u062c\u0628\u0644 \u0637\u0627\u0631\u0642",
  "AX": "\u062c\u0632\u0631 \u0622\u0644\u0627\u0646\u062f",
  "BS": "\u062c\u0632\u0631 \u0627\u0644\u0628\u0647\u0627\u0645\u0627",
  "KM": "\u062c\u0632\u0631 \u0627\u0644\u0642\u0645\u0631",
  "MQ": "\u062c\u0632\u0631 \u0627\u0644\u0645\u0627\u0631\u062a\u064a\u0646\u064a\u0643",
  "MV": "\u062c\u0632\u0631 \u0627\u0644\u0645\u0627\u0644\u062f\u064a\u0641",
  "UM": "\u062c\u0632\u0631 \u0627\u0644\u0648\u0644\u0627\u064a\u0627\u062a \u0627\u0644\u0645\u062a\u062d\u062f\u0629 \u0627\u0644\u0646\u0627\u0626\u064a\u0629",
  "PN": "\u062c\u0632\u0631 \u0628\u064a\u062a\u0643\u064a\u0631\u0646",
  "TC": "\u062c\u0632\u0631 \u062a\u0648\u0631\u0643\u0633 \u0648\u0643\u0627\u064a\u0643\u0648\u0633",
  "SB": "\u062c\u0632\u0631 \u0633\u0644\u064a\u0645\u0627\u0646",
  "FO": "\u062c\u0632\u0631 \u0641\u0627\u0631\u0648",
  "FK": "\u062c\u0632\u0631 \u0641\u0648\u0643\u0644\u0627\u0646\u062f",
  "VG": "\u062c\u0632\u0631 \u0641\u064a\u0631\u062c\u0646 \u0627\u0644\u0628\u0631\u064a\u0637\u0627\u0646\u064a\u0629",
  "VI": "\u062c\u0632\u0631 \u0641\u064a\u0631\u062c\u0646 \u0627\u0644\u062a\u0627\u0628\u0639\u0629 \u0644\u0644\u0648\u0644\u0627\u064a\u0627\u062a \u0627\u0644\u0645\u062a\u062d\u062f\u0629",
  "KY": "\u062c\u0632\u0631 \u0643\u0627\u064a\u0645\u0627\u0646",
  "CK": "\u062c\u0632\u0631 \u0643\u0648\u0643",
  "CC": "\u062c\u0632\u0631 \u0643\u0648\u0643\u0648\u0633 (\u0643\u064a\u0644\u064a\u0646\u063a)",
  "MH": "\u062c\u0632\u0631 \u0645\u0627\u0631\u0634\u0627\u0644",
  "MP": "\u062c\u0632\u0631 \u0645\u0627\u0631\u064a\u0627\u0646\u0627 \u0627\u0644\u0634\u0645\u0627\u0644\u064a\u0629",
  "WF": "\u062c\u0632\u0631 \u0648\u0627\u0644\u0633 \u0648\u0641\u0648\u062a\u0648\u0646\u0627",
  "BV": "\u062c\u0632\u064a\u0631\u0629 \u0628\u0648\u0641\u064a\u0647",
  "CX": "\u062c\u0632\u064a\u0631\u0629 \u0643\u0631\u064a\u0633\u0645\u0627\u0633",
  "IM": "\u062c\u0632\u064a\u0631\u0629 \u0645\u0627\u0646",
  "NF": "\u062c\u0632\u064a\u0631\u0629 \u0646\u0648\u0631\u0641\u0648\u0644\u0643",
  "HM": "\u062c\u0632\u064a\u0631\u0629 \u0647\u064a\u0631\u062f \u0648\u062c\u0632\u0631 \u0645\u0627\u0643\u062f\u0648\u0646\u0627\u0644\u062f",
  "CF": "\u062c\u0645\u0647\u0648\u0631\u064a\u0629 \u0623\u0641\u0631\u064a\u0642\u064a\u0627 \u0627\u0644\u0648\u0633\u0637\u0649",
  "DO": "\u062c\u0645\u0647\u0648\u0631\u064a\u0629 \u0627\u0644\u062f\u0648\u0645\u064a\u0646\u064a\u0643\u0627\u0646",
  "ZA": "\u062c\u0646\u0648\u0628 \u0623\u0641\u0631\u064a\u0642\u064a\u0627",
  "SS": "\u062c\u0646\u0648\u0628 \u0627\u0644\u0633\u0648\u062f\u0627\u0646",
  "GE": "\u062c\u0648\u0631\u062c\u064a\u0627",
  "GS": "\u062c\u0648\u0631\u062c\u064a\u0627 \u0627\u0644\u062c\u0646\u0648\u0628\u064a\u0629 \u0648\u062c\u0632\u0631 \u0633\u0627\u0646\u062f\u0648\u064a\u062a\u0634 \u0627\u0644\u062c\u0646\u0648\u0628\u064a\u0629",
  "DJ": "\u062c\u064a\u0628\u0648\u062a\u064a",
  "JE": "\u062c\u064a\u0631\u0633\u064a",
  "DM": "\u062f\u0648\u0645\u064a\u0646\u064a\u0643\u0627",
  "RW": "\u0631\u0648\u0627\u0646\u062f\u0627",
  "RU": "\u0631\u0648\u0633\u064a\u0627",
  "RO": "\u0631\u0648\u0645\u0627\u0646\u064a\u0627",
  "RE": "\u0631\u0648\u064a\u0646\u064a\u0648\u0646",
  "ZM": "\u0632\u0627\u0645\u0628\u064a\u0627",
  "ZW": "\u0632\u064a\u0645\u0628\u0627\u0628\u0648\u064a",
  "CI": "\u0633\u0627\u062d\u0644 \u0627\u0644\u0639\u0627\u062c",
  "WS": "\u0633\u0627\u0645\u0648\u0627",
  "AS": "\u0633\u0627\u0645\u0648\u0627 \u0627\u0644\u0623\u0645\u0631\u064a\u0643\u064a\u0629",
  "BL": "\u0633\u0627\u0646 \u0628\u0627\u0631\u062a\u0644\u064a\u0645\u064a",
  "PM": "\u0633\u0627\u0646 \u0628\u064a\u064a\u0631 \u0648\u0645\u0643\u0648\u064a\u0644\u0648\u0646",
  "MF": "\u0633\u0627\u0646 \u0645\u0627\u0631\u062a\u0646",
  "SM": "\u0633\u0627\u0646 \u0645\u0627\u0631\u064a\u0646\u0648",
  "VC": "\u0633\u0627\u0646\u062a \u0641\u0646\u0633\u0646\u062a \u0648\u062c\u0632\u0631 \u063a\u0631\u064a\u0646\u0627\u062f\u064a\u0646",
  "KN": "\u0633\u0627\u0646\u062a \u0643\u064a\u062a\u0633 \u0648\u0646\u064a\u0641\u064a\u0633",
  "LC": "\u0633\u0627\u0646\u062a \u0644\u0648\u0633\u064a\u0627",
  "SX": "\u0633\u0627\u0646\u062a \u0645\u0627\u0631\u062a\u0646",
  "SH": "\u0633\u0627\u0646\u062a \u0647\u064a\u0644\u064a\u0646\u0627",
  "ST": "\u0633\u0627\u0648 \u062a\u0648\u0645\u064a \u0648\u0628\u0631\u064a\u0646\u0633\u064a\u0628\u064a",
  "LK": "\u0633\u0631\u064a\u0644\u0627\u0646\u0643\u0627",
  "SJ": "\u0633\u0641\u0627\u0644\u0628\u0627\u0631\u062f \u0648\u062c\u0627\u0646 \u0645\u0627\u064a\u0646",
  "SK": "\u0633\u0644\u0648\u0641\u0627\u0643\u064a\u0627",
  "SI": "\u0633\u0644\u0648\u0641\u064a\u0646\u064a\u0627",
  "SG": "\u0633\u0646\u063a\u0627\u0641\u0648\u0631\u0629",
  "SY": "\u0633\u0648\u0631\u064a\u0627",
  "SR": "\u0633\u0648\u0631\u064a\u0646\u0627\u0645",
  "CH": "\u0633\u0648\u064a\u0633\u0631\u0627",
  "SL": "\u0633\u064a\u0631\u0627\u0644\u064a\u0648\u0646",
  "SC": "\u0633\u064a\u0634\u0644",
  "RS": "\u0635\u0631\u0628\u064a\u0627",
  "TJ": "\u0637\u0627\u062c\u064a\u0643\u0633\u062a\u0627\u0646",
  "OM": "\u0639\u064f\u0645\u0627\u0646",
  "GM": "\u063a\u0627\u0645\u0628\u064a\u0627",
  "GH": "\u063a\u0627\u0646\u0627",
  "GD": "\u063a\u0631\u064a\u0646\u0627\u062f\u0627",
  "GL": "\u063a\u0631\u064a\u0646\u0644\u0627\u0646\u062f",
  "GT": "\u063a\u0648\u0627\u062a\u064a\u0645\u0627\u0644\u0627",
  "GP": "\u063a\u0648\u0627\u062f\u0644\u0648\u0628",
  "GU": "\u063a\u0648\u0627\u0645",
  "GF": "\u063a\u0648\u064a\u0627\u0646\u0627 \u0627\u0644\u0641\u0631\u0646\u0633\u064a\u0629",
  "GY": "\u063a\u064a\u0627\u0646\u0627",
  "GG": "\u063a\u064a\u0631\u0646\u0632\u064a",
  "GN": "\u063a\u064a\u0646\u064a\u0627",
  "GQ": "\u063a\u064a\u0646\u064a\u0627 \u0627\u0644\u0627\u0633\u062a\u0648\u0627\u0626\u064a\u0629",
  "GW": "\u063a\u064a\u0646\u064a\u0627 \u0628\u064a\u0633\u0627\u0648",
  "VU": "\u0641\u0627\u0646\u0648\u0627\u062a\u0648",
  "FR": "\u0641\u0631\u0646\u0633\u0627",
  "VE": "\u0641\u0646\u0632\u0648\u064a\u0644\u0627",
  "FI": "\u0641\u0646\u0644\u0646\u062f\u0627",
  "VN": "\u0641\u064a\u062a\u0646\u0627\u0645",
  "FJ": "\u0641\u064a\u062c\u064a",
  "CY": "\u0642\u0628\u0631\u0635",
  "QA": "\u0642\u0637\u0631",
  "KG": "\u0642\u064a\u0631\u063a\u064a\u0632\u0633\u062a\u0627\u0646",
  "KZ": "\u0643\u0627\u0632\u0627\u062e\u0633\u062a\u0627\u0646",
  "NC": "\u0643\u0627\u0644\u064a\u062f\u0648\u0646\u064a\u0627 \u0627\u0644\u062c\u062f\u064a\u062f\u0629",
  "HR": "\u0643\u0631\u0648\u0627\u062a\u064a\u0627",
  "KH": "\u0643\u0645\u0628\u0648\u062f\u064a\u0627",
  "CA": "\u0643\u0646\u062f\u0627",
  "CU": "\u0643\u0648\u0628\u0627",
  "CW": "\u0643\u0648\u0631\u0627\u0633\u0627\u0648",
  "KR": "\u0643\u0648\u0631\u064a\u0627 \u0627\u0644\u062c\u0646\u0648\u0628\u064a\u0629",
  "XK": "\u0643\u0648\u0633\u0648\u0641\u0648",
  "KP": "\u0643\u0648\u0631\u064a\u0627 \u0627\u0644\u0634\u0645\u0627\u0644\u064a\u0629",
  "CR": "\u0643\u0648\u0633\u062a\u0627\u0631\u064a\u0643\u0627",
  "CO": "\u0643\u0648\u0644\u0648\u0645\u0628\u064a\u0627",
  "KI": "\u0643\u064a\u0631\u064a\u0628\u0627\u062a\u064a",
  "KE": "\u0643\u064a\u0646\u064a\u0627",
  "LV": "\u0644\u0627\u062a\u0641\u064a\u0627",
  "LA": "\u0644\u0627\u0648\u0633",
  "LB": "\u0644\u0628\u0646\u0627\u0646",
  "LU": "\u0644\u0648\u0643\u0633\u0645\u0628\u0648\u0631\u063a",
  "LY": "\u0644\u064a\u0628\u064a\u0627",
  "LR": "\u0644\u064a\u0628\u064a\u0631\u064a\u0627",
  "LT": "\u0644\u064a\u062a\u0648\u0627\u0646\u064a\u0627",
  "LI": "\u0644\u064a\u062e\u062a\u0646\u0634\u062a\u0627\u064a\u0646",
  "LS": "\u0644\u064a\u0633\u0648\u062a\u0648",
  "MO": "\u0645\u0627\u0643\u0627\u0648 \u0627\u0644\u0635\u064a\u0646\u064a\u0629 (\u0645\u0646\u0637\u0642\u0629 \u0625\u062f\u0627\u0631\u064a\u0629 \u062e\u0627\u0635\u0629)",
  "MT": "\u0645\u0627\u0644\u0637\u0627",
  "ML": "\u0645\u0627\u0644\u064a",
  "MY": "\u0645\u0627\u0644\u064a\u0632\u064a\u0627",
  "YT": "\u0645\u0627\u064a\u0648\u062a",
  "MG": "\u0645\u062f\u063a\u0634\u0642\u0631",
  "EG": "\u0645\u0635\u0631",
  "MK": "\u0645\u0642\u062f\u0648\u0646\u064a\u0627 \u0627\u0644\u0634\u0645\u0627\u0644\u064a\u0629",
  "MW": "\u0645\u0644\u0627\u0648\u064a",
  "MN": "\u0645\u0646\u063a\u0648\u0644\u064a\u0627",
  "MR": "\u0645\u0648\u0631\u064a\u062a\u0627\u0646\u064a\u0627",
  "MU": "\u0645\u0648\u0631\u064a\u0634\u064a\u0648\u0633",
  "MZ": "\u0645\u0648\u0632\u0645\u0628\u064a\u0642",
  "MD": "\u0645\u0648\u0644\u062f\u0648\u0641\u0627",
  "MC": "\u0645\u0648\u0646\u0627\u0643\u0648",
  "MS": "\u0645\u0648\u0646\u062a\u064a\u0633\u064a\u0631\u0627\u062a",
  "MM": "\u0645\u064a\u0627\u0646\u0645\u0627\u0631 (\u0628\u0648\u0631\u0645\u0627)",
  "FM": "\u0645\u064a\u0643\u0631\u0648\u0646\u064a\u0632\u064a\u0627",
  "NA": "\u0646\u0627\u0645\u064a\u0628\u064a\u0627",
  "NR": "\u0646\u0627\u0648\u0631\u0648",
  "NP": "\u0646\u064a\u0628\u0627\u0644",
  "NG": "\u0646\u064a\u062c\u064a\u0631\u064a\u0627",
  "NI": "\u0646\u064a\u0643\u0627\u0631\u0627\u063a\u0648\u0627",
  "NZ": "\u0646\u064a\u0648\u0632\u064a\u0644\u0646\u062f\u0627",
  "NU": "\u0646\u064a\u0648\u064a",
  "HT": "\u0647\u0627\u064a\u062a\u064a",
  "HN": "\u0647\u0646\u062f\u0648\u0631\u0627\u0633",
  "HU": "\u0647\u0646\u063a\u0627\u0631\u064a\u0627",
  "NL": "\u0647\u0648\u0644\u0646\u062f\u0627",
  "BQ": "\u0647\u0648\u0644\u0646\u062f\u0627 \u0627\u0644\u0643\u0627\u0631\u064a\u0628\u064a\u0629",
  "HK": "\u0647\u0648\u0646\u063a \u0643\u0648\u0646\u063a \u0627\u0644\u0635\u064a\u0646\u064a\u0629 (\u0645\u0646\u0637\u0642\u0629 \u0625\u062f\u0627\u0631\u064a\u0629 \u062e\u0627\u0635\u0629)"
}



================================================
FILE: public/intl/country/be-BY.json
================================================
{
  "AE": "\u0410\u0431\u2019\u044f\u0434\u043d\u0430\u043d\u044b\u044f \u0410\u0440\u0430\u0431\u0441\u043a\u0456\u044f \u042d\u043c\u0456\u0440\u0430\u0442\u044b",
  "AZ": "\u0410\u0437\u0435\u0440\u0431\u0430\u0439\u0434\u0436\u0430\u043d",
  "AX": "\u0410\u043b\u0430\u043d\u0434\u0441\u043a\u0456\u044f \u0430\u0441\u0442\u0440\u0430\u0432\u044b",
  "AL": "\u0410\u043b\u0431\u0430\u043d\u0456\u044f",
  "DZ": "\u0410\u043b\u0436\u044b\u0440",
  "OM": "\u0410\u043c\u0430\u043d",
  "AS": "\u0410\u043c\u0435\u0440\u044b\u043a\u0430\u043d\u0441\u043a\u0430\u0435 \u0421\u0430\u043c\u043e\u0430",
  "VI": "\u0410\u043c\u0435\u0440\u044b\u043a\u0430\u043d\u0441\u043a\u0456\u044f \u0412\u0456\u0440\u0433\u0456\u043d\u0441\u043a\u0456\u044f \u0430\u0441\u0442\u0440\u0430\u0432\u044b",
  "AI": "\u0410\u043d\u0433\u0456\u043b\u044c\u044f",
  "AO": "\u0410\u043d\u0433\u043e\u043b\u0430",
  "AD": "\u0410\u043d\u0434\u043e\u0440\u0430",
  "AQ": "\u0410\u043d\u0442\u0430\u0440\u043a\u0442\u044b\u043a\u0430",
  "AG": "\u0410\u043d\u0442\u044b\u0433\u0443\u0430 \u0456 \u0411\u0430\u0440\u0431\u0443\u0434\u0430",
  "AR": "\u0410\u0440\u0433\u0435\u043d\u0446\u0456\u043d\u0430",
  "AM": "\u0410\u0440\u043c\u0435\u043d\u0456\u044f",
  "AW": "\u0410\u0440\u0443\u0431\u0430",
  "CK": "\u0410\u0441\u0442\u0440\u0430\u0432\u044b \u041a\u0443\u043a\u0430",
  "PN": "\u0410\u0441\u0442\u0440\u0430\u0432\u044b \u041f\u0456\u0442\u043a\u044d\u0440\u043d",
  "HM": "\u0410\u0441\u0442\u0440\u0430\u0432\u044b \u0425\u0435\u0440\u0434 \u0456 \u041c\u0430\u043a\u0434\u043e\u043d\u0430\u043b\u044c\u0434",
  "TC": "\u0410\u0441\u0442\u0440\u0430\u0432\u044b \u0426\u0451\u0440\u043a\u0441 \u0456 \u041a\u0430\u0439\u043a\u0430\u0441",
  "AU": "\u0410\u045e\u0441\u0442\u0440\u0430\u043b\u0456\u044f",
  "AT": "\u0410\u045e\u0441\u0442\u0440\u044b\u044f",
  "AF": "\u0410\u0444\u0433\u0430\u043d\u0456\u0441\u0442\u0430\u043d",
  "BS": "\u0411\u0430\u0433\u0430\u043c\u0441\u043a\u0456\u044f \u0430\u0441\u0442\u0440\u0430\u0432\u044b",
  "BG": "\u0411\u0430\u043b\u0433\u0430\u0440\u044b\u044f",
  "BO": "\u0411\u0430\u043b\u0456\u0432\u0456\u044f",
  "BD": "\u0411\u0430\u043d\u0433\u043b\u0430\u0434\u044d\u0448",
  "BB": "\u0411\u0430\u0440\u0431\u0430\u0434\u0430\u0441",
  "BW": "\u0411\u0430\u0442\u0441\u0432\u0430\u043d\u0430",
  "BH": "\u0411\u0430\u0445\u0440\u044d\u0439\u043d",
  "BY": "\u0411\u0435\u043b\u0430\u0440\u0443\u0441\u044c",
  "BZ": "\u0411\u0435\u043b\u0456\u0437",
  "BE": "\u0411\u0435\u043b\u044c\u0433\u0456\u044f",
  "BJ": "\u0411\u0435\u043d\u0456\u043d",
  "BM": "\u0411\u0435\u0440\u043c\u0443\u0434\u0441\u043a\u0456\u044f \u0430\u0441\u0442\u0440\u0430\u0432\u044b",
  "BA": "\u0411\u043e\u0441\u043d\u0456\u044f \u0456 \u0413\u0435\u0440\u0446\u0430\u0433\u0430\u0432\u0456\u043d\u0430",
  "BR": "\u0411\u0440\u0430\u0437\u0456\u043b\u0456\u044f",
  "BN": "\u0411\u0440\u0443\u043d\u0435\u0439",
  "IO": "\u0411\u0440\u044b\u0442\u0430\u043d\u0441\u043a\u0430\u044f \u0442\u044d\u0440\u044b\u0442\u043e\u0440\u044b\u044f \u045e \u0406\u043d\u0434\u044b\u0439\u0441\u043a\u0456\u043c \u0430\u043a\u0456\u044f\u043d\u0435",
  "VG": "\u0411\u0440\u044b\u0442\u0430\u043d\u0441\u043a\u0456\u044f \u0412\u0456\u0440\u0433\u0456\u043d\u0441\u043a\u0456\u044f \u0430\u0441\u0442\u0440\u0430\u0432\u044b",
  "BF": "\u0411\u0443\u0440\u043a\u0456\u043d\u0430-\u0424\u0430\u0441\u043e",
  "BI": "\u0411\u0443\u0440\u0443\u043d\u0434\u0437\u0456",
  "BT": "\u0411\u0443\u0442\u0430\u043d",
  "VN": "\u0412\u2019\u0435\u0442\u043d\u0430\u043c",
  "VU": "\u0412\u0430\u043d\u0443\u0430\u0442\u0443",
  "VA": "\u0412\u0430\u0442\u044b\u043a\u0430\u043d",
  "HU": "\u0412\u0435\u043d\u0433\u0440\u044b\u044f",
  "VE": "\u0412\u0435\u043d\u0435\u0441\u0443\u044d\u043b\u0430",
  "BV": "\u0412\u043e\u0441\u0442\u0440\u0430\u045e \u0411\u0443\u0432\u044d",
  "CX": "\u0412\u043e\u0441\u0442\u0440\u0430\u045e \u041a\u0430\u043b\u044f\u0434",
  "IM": "\u0412\u043e\u0441\u0442\u0440\u0430\u045e \u041c\u044d\u043d",
  "NF": "\u0412\u043e\u0441\u0442\u0440\u0430\u045e \u041d\u043e\u0440\u0444\u0430\u043b\u043a",
  "SH": "\u0412\u043e\u0441\u0442\u0440\u0430\u045e \u0421\u0432\u044f\u0442\u043e\u0439 \u0410\u043b\u0435\u043d\u044b",
  "GB": "\u0412\u044f\u043b\u0456\u043a\u0430\u0431\u0440\u044b\u0442\u0430\u043d\u0456\u044f",
  "GA": "\u0413\u0430\u0431\u043e\u043d",
  "HT": "\u0413\u0430\u0456\u0446\u0456",
  "GM": "\u0413\u0430\u043c\u0431\u0456\u044f",
  "GH": "\u0413\u0430\u043d\u0430",
  "HN": "\u0413\u0430\u043d\u0434\u0443\u0440\u0430\u0441",
  "HK": "\u0413\u0430\u043d\u043a\u043e\u043d\u0433, \u0421\u0410\u0420 (\u041a\u0456\u0442\u0430\u0439)",
  "GY": "\u0413\u0430\u044f\u043d\u0430",
  "GP": "\u0413\u0432\u0430\u0434\u044d\u043b\u0443\u043f\u0430",
  "GT": "\u0413\u0432\u0430\u0442\u044d\u043c\u0430\u043b\u0430",
  "GN": "\u0413\u0432\u0456\u043d\u0435\u044f",
  "GW": "\u0413\u0432\u0456\u043d\u0435\u044f-\u0411\u0456\u0441\u0430\u0443",
  "DE": "\u0413\u0435\u0440\u043c\u0430\u043d\u0456\u044f",
  "GG": "\u0413\u0435\u0440\u043d\u0441\u0456",
  "GI": "\u0413\u0456\u0431\u0440\u0430\u043b\u0442\u0430\u0440",
  "GE": "\u0413\u0440\u0443\u0437\u0456\u044f",
  "GD": "\u0413\u0440\u044d\u043d\u0430\u0434\u0430",
  "GL": "\u0413\u0440\u044d\u043d\u043b\u0430\u043d\u0434\u044b\u044f",
  "GR": "\u0413\u0440\u044d\u0446\u044b\u044f",
  "GU": "\u0413\u0443\u0430\u043c",
  "DM": "\u0414\u0430\u043c\u0456\u043d\u0456\u043a\u0430",
  "DO": "\u0414\u0430\u043c\u0456\u043d\u0456\u043a\u0430\u043d\u0441\u043a\u0430\u044f \u0420\u044d\u0441\u043f\u0443\u0431\u043b\u0456\u043a\u0430",
  "DK": "\u0414\u0430\u043d\u0456\u044f",
  "DJ": "\u0414\u0436\u044b\u0431\u0443\u0446\u0456",
  "JE": "\u0414\u0436\u044d\u0440\u0441\u0456",
  "EG": "\u0415\u0433\u0456\u043f\u0435\u0442",
  "YE": "\u0415\u043c\u0435\u043d",
  "ZM": "\u0417\u0430\u043c\u0431\u0456\u044f",
  "EH": "\u0417\u0430\u0445\u043e\u0434\u043d\u044f\u044f \u0421\u0430\u0445\u0430\u0440\u0430",
  "ZW": "\u0417\u0456\u043c\u0431\u0430\u0431\u0432\u044d",
  "US": "\u0417\u043b\u0443\u0447\u0430\u043d\u044b\u044f \u0428\u0442\u0430\u0442\u044b",
  "JO": "\u0406\u0430\u0440\u0434\u0430\u043d\u0456\u044f",
  "IL": "\u0406\u0437\u0440\u0430\u0456\u043b\u044c",
  "ID": "\u0406\u043d\u0434\u0430\u043d\u0435\u0437\u0456\u044f",
  "IN": "\u0406\u043d\u0434\u044b\u044f",
  "IQ": "\u0406\u0440\u0430\u043a",
  "IR": "\u0406\u0440\u0430\u043d",
  "IE": "\u0406\u0440\u043b\u0430\u043d\u0434\u044b\u044f",
  "IS": "\u0406\u0441\u043b\u0430\u043d\u0434\u044b\u044f",
  "ES": "\u0406\u0441\u043f\u0430\u043d\u0456\u044f",
  "IT": "\u0406\u0442\u0430\u043b\u0456\u044f",
  "CV": "\u041a\u0430\u0431\u0430-\u0412\u0435\u0440\u0434\u044d",
  "KZ": "\u041a\u0430\u0437\u0430\u0445\u0441\u0442\u0430\u043d",
  "KY": "\u041a\u0430\u0439\u043c\u0430\u043d\u0430\u0432\u044b \u0430\u0441\u0442\u0440\u0430\u0432\u044b",
  "CC": "\u041a\u0430\u043a\u043e\u0441\u0430\u0432\u044b\u044f (\u041a\u0456\u043b\u0456\u043d\u0433) \u0430\u0441\u0442\u0440\u0430\u0432\u044b",
  "CO": "\u041a\u0430\u043b\u0443\u043c\u0431\u0456\u044f",
  "KH": "\u041a\u0430\u043c\u0431\u043e\u0434\u0436\u0430",
  "CM": "\u041a\u0430\u043c\u0435\u0440\u0443\u043d",
  "KM": "\u041a\u0430\u043c\u043e\u0440\u0441\u043a\u0456\u044f \u0430\u0441\u0442\u0440\u0430\u0432\u044b",
  "CA": "\u041a\u0430\u043d\u0430\u0434\u0430",
  "BQ": "\u041a\u0430\u0440\u044b\u0431\u0441\u043a\u0456\u044f \u041d\u0456\u0434\u044d\u0440\u043b\u0430\u043d\u0434\u044b",
  "QA": "\u041a\u0430\u0442\u0430\u0440",
  "KE": "\u041a\u0435\u043d\u0456\u044f",
  "CY": "\u041a\u0456\u043f\u0440",
  "KI": "\u041a\u0456\u0440\u044b\u0431\u0430\u0446\u0456",
  "CN": "\u041a\u0456\u0442\u0430\u0439",
  "CG": "\u041a\u043e\u043d\u0433\u0430 - \u0411\u0440\u0430\u0437\u0430\u0432\u0456\u043b\u044c",
  "CD": "\u041a\u043e\u043d\u0433\u0430 (\u041a\u0456\u043d\u0448\u0430\u0441\u0430)",
  "XK": "\u041a\u043e\u0441\u0430\u0432\u0430",
  "CR": "\u041a\u043e\u0441\u0442\u0430-\u0420\u044b\u043a\u0430",
  "CI": "\u041a\u043e\u0442-\u0434\u2019\u0406\u0432\u0443\u0430\u0440",
  "CU": "\u041a\u0443\u0431\u0430",
  "KW": "\u041a\u0443\u0432\u0435\u0439\u0442",
  "KG": "\u041a\u044b\u0440\u0433\u044b\u0437\u0441\u0442\u0430\u043d",
  "CW": "\u041a\u044e\u0440\u0430\u0441\u0430\u0430",
  "LA": "\u041b\u0430\u043e\u0441",
  "LV": "\u041b\u0430\u0442\u0432\u0456\u044f",
  "LS": "\u041b\u0435\u0441\u043e\u0442\u0430",
  "LR": "\u041b\u0456\u0431\u0435\u0440\u044b\u044f",
  "LB": "\u041b\u0456\u0432\u0430\u043d",
  "LY": "\u041b\u0456\u0432\u0456\u044f",
  "LT": "\u041b\u0456\u0442\u0432\u0430",
  "LI": "\u041b\u0456\u0445\u0442\u044d\u043d\u0448\u0442\u044d\u0439\u043d",
  "LU": "\u041b\u044e\u043a\u0441\u0435\u043c\u0431\u0443\u0440\u0433",
  "MM": "\u041c\u2019\u044f\u043d\u043c\u0430 (\u0411\u0456\u0440\u043c\u0430)",
  "MG": "\u041c\u0430\u0434\u0430\u0433\u0430\u0441\u043a\u0430\u0440",
  "YT": "\u041c\u0430\u0451\u0442\u0430",
  "MZ": "\u041c\u0430\u0437\u0430\u043c\u0431\u0456\u043a",
  "MO": "\u041c\u0430\u043a\u0430\u0430, \u0421\u0410\u0420 (\u041a\u0456\u0442\u0430\u0439)",
  "MW": "\u041c\u0430\u043b\u0430\u0432\u0456",
  "MY": "\u041c\u0430\u043b\u0430\u0439\u0437\u0456\u044f",
  "MD": "\u041c\u0430\u043b\u0434\u043e\u0432\u0430",
  "ML": "\u041c\u0430\u043b\u0456",
  "UM": "\u041c\u0430\u043b\u044b\u044f \u0410\u0434\u0434\u0430\u043b\u0435\u043d\u044b\u044f \u0430\u0441\u0442\u0440\u0430\u0432\u044b \u0417\u0428\u0410",
  "MV": "\u041c\u0430\u043b\u044c\u0434\u044b\u0432\u044b",
  "MT": "\u041c\u0430\u043b\u044c\u0442\u0430",
  "MC": "\u041c\u0430\u043d\u0430\u043a\u0430",
  "MN": "\u041c\u0430\u043d\u0433\u043e\u043b\u0456\u044f",
  "MS": "\u041c\u0430\u043d\u0442\u0441\u0435\u0440\u0430\u0442",
  "MA": "\u041c\u0430\u0440\u043e\u043a\u0430",
  "MQ": "\u041c\u0430\u0440\u0446\u0456\u043d\u0456\u043a\u0430",
  "MH": "\u041c\u0430\u0440\u0448\u0430\u043b\u0430\u0432\u044b \u0430\u0441\u0442\u0440\u0430\u0432\u044b",
  "MU": "\u041c\u0430\u045e\u0440\u044b\u043a\u0456\u0439",
  "MR": "\u041c\u0430\u045e\u0440\u044b\u0442\u0430\u043d\u0456\u044f",
  "MX": "\u041c\u0435\u043a\u0441\u0456\u043a\u0430",
  "FM": "\u041c\u0456\u043a\u0440\u0430\u043d\u0435\u0437\u0456\u044f",
  "NA": "\u041d\u0430\u043c\u0456\u0431\u0456\u044f",
  "NO": "\u041d\u0430\u0440\u0432\u0435\u0433\u0456\u044f",
  "NR": "\u041d\u0430\u0443\u0440\u0443",
  "NP": "\u041d\u0435\u043f\u0430\u043b",
  "NE": "\u041d\u0456\u0433\u0435\u0440",
  "NG": "\u041d\u0456\u0433\u0435\u0440\u044b\u044f",
  "NL": "\u041d\u0456\u0434\u044d\u0440\u043b\u0430\u043d\u0434\u044b",
  "NI": "\u041d\u0456\u043a\u0430\u0440\u0430\u0433\u0443\u0430",
  "NU": "\u041d\u0456\u0443\u044d",
  "NZ": "\u041d\u043e\u0432\u0430\u044f \u0417\u0435\u043b\u0430\u043d\u0434\u044b\u044f",
  "NC": "\u041d\u043e\u0432\u0430\u044f \u041a\u0430\u043b\u0435\u0434\u043e\u043d\u0456\u044f",
  "PK": "\u041f\u0430\u043a\u0456\u0441\u0442\u0430\u043d",
  "PW": "\u041f\u0430\u043b\u0430\u0443",
  "PS": "\u041f\u0430\u043b\u0435\u0441\u0446\u0456\u043d\u0441\u043a\u0456\u044f \u0422\u044d\u0440\u044b\u0442\u043e\u0440\u044b\u0456",
  "PA": "\u041f\u0430\u043d\u0430\u043c\u0430",
  "PG": "\u041f\u0430\u043f\u0443\u0430-\u041d\u043e\u0432\u0430\u044f \u0413\u0432\u0456\u043d\u0435\u044f",
  "PY": "\u041f\u0430\u0440\u0430\u0433\u0432\u0430\u0439",
  "PT": "\u041f\u0430\u0440\u0442\u0443\u0433\u0430\u043b\u0456\u044f",
  "ZA": "\u041f\u0430\u045e\u0434\u043d\u0451\u0432\u0430-\u0410\u0444\u0440\u044b\u043a\u0430\u043d\u0441\u043a\u0430\u044f \u0420\u044d\u0441\u043f\u0443\u0431\u043b\u0456\u043a\u0430",
  "GS": "\u041f\u0430\u045e\u0434\u043d\u0451\u0432\u0430\u044f \u0413\u0435\u043e\u0440\u0433\u0456\u044f \u0456 \u041f\u0430\u045e\u0434\u043d\u0451\u0432\u044b\u044f \u0421\u0430\u043d\u0434\u0432\u0456\u0447\u0430\u0432\u044b \u0430\u0441\u0442\u0440\u0430\u0432\u044b",
  "KR": "\u041f\u0430\u045e\u0434\u043d\u0451\u0432\u0430\u044f \u041a\u0430\u0440\u044d\u044f",
  "SS": "\u041f\u0430\u045e\u0434\u043d\u0451\u0432\u044b \u0421\u0443\u0434\u0430\u043d",
  "KP": "\u041f\u0430\u045e\u043d\u043e\u0447\u043d\u0430\u044f \u041a\u0430\u0440\u044d\u044f",
  "MK": "\u041f\u0430\u045e\u043d\u043e\u0447\u043d\u0430\u044f \u041c\u0430\u043a\u0435\u0434\u043e\u043d\u0456\u044f",
  "MP": "\u041f\u0430\u045e\u043d\u043e\u0447\u043d\u044b\u044f \u041c\u0430\u0440\u044b\u044f\u043d\u0441\u043a\u0456\u044f \u0430\u0441\u0442\u0440\u0430\u0432\u044b",
  "PE": "\u041f\u0435\u0440\u0443",
  "PL": "\u041f\u043e\u043b\u044c\u0448\u0447\u0430",
  "PR": "\u041f\u0443\u044d\u0440\u0442\u0430-\u0420\u044b\u043a\u0430",
  "RU": "\u0420\u0430\u0441\u0456\u044f",
  "RW": "\u0420\u0443\u0430\u043d\u0434\u0430",
  "RO": "\u0420\u0443\u043c\u044b\u043d\u0456\u044f",
  "RE": "\u0420\u044d\u044e\u043d\u044c\u0451\u043d",
  "SB": "\u0421\u0430\u043b\u0430\u043c\u043e\u043d\u0430\u0432\u044b \u0430\u0441\u0442\u0440\u0430\u0432\u044b",
  "SV": "\u0421\u0430\u043b\u044c\u0432\u0430\u0434\u043e\u0440",
  "SO": "\u0421\u0430\u043c\u0430\u043b\u0456",
  "WS": "\u0421\u0430\u043c\u043e\u0430",
  "SM": "\u0421\u0430\u043d-\u041c\u0430\u0440\u044b\u043d\u0430",
  "ST": "\u0421\u0430\u043d-\u0422\u0430\u043c\u044d \u0456 \u041f\u0440\u044b\u043d\u0441\u0456\u043f\u0456",
  "SA": "\u0421\u0430\u0443\u0434\u0430\u045e\u0441\u043a\u0430\u044f \u0410\u0440\u0430\u0432\u0456\u044f",
  "SC": "\u0421\u0435\u0439\u0448\u044d\u043b\u044c\u0441\u043a\u0456\u044f \u0430\u0441\u0442\u0440\u0430\u0432\u044b",
  "BL": "\u0421\u0435\u043d-\u0411\u0430\u0440\u0442\u044d\u043b\u044c\u043c\u0456",
  "MF": "\u0421\u0435\u043d-\u041c\u0430\u0440\u0442\u044d\u043d",
  "PM": "\u0421\u0435\u043d-\u041f\u2019\u0435\u0440 \u0456 \u041c\u0456\u043a\u0435\u043b\u043e\u043d",
  "SN": "\u0421\u0435\u043d\u0435\u0433\u0430\u043b",
  "VC": "\u0421\u0435\u043d\u0442-\u0412\u0456\u043d\u0441\u0435\u043d\u0442 \u0456 \u0413\u0440\u044d\u043d\u0430\u0434\u0437\u0456\u043d\u044b",
  "KN": "\u0421\u0435\u043d\u0442-\u041a\u0456\u0442\u0441 \u0456 \u041d\u0435\u0432\u0456\u0441",
  "LC": "\u0421\u0435\u043d\u0442-\u041b\u044e\u0441\u0456\u044f",
  "RS": "\u0421\u0435\u0440\u0431\u0456\u044f",
  "SG": "\u0421\u0456\u043d\u0433\u0430\u043f\u0443\u0440",
  "SX": "\u0421\u0456\u043d\u0442-\u041c\u0430\u0440\u0442\u044d\u043d",
  "SY": "\u0421\u0456\u0440\u044b\u044f",
  "SK": "\u0421\u043b\u0430\u0432\u0430\u043a\u0456\u044f",
  "SI": "\u0421\u043b\u0430\u0432\u0435\u043d\u0456\u044f",
  "SD": "\u0421\u0443\u0434\u0430\u043d",
  "SR": "\u0421\u0443\u0440\u044b\u043d\u0430\u043c",
  "SL": "\u0421\u044c\u0435\u0440\u0430-\u041b\u0435\u043e\u043d\u044d",
  "TJ": "\u0422\u0430\u0434\u0436\u044b\u043a\u0456\u0441\u0442\u0430\u043d",
  "TW": "\u0422\u0430\u0439\u0432\u0430\u043d\u044c",
  "TH": "\u0422\u0430\u0439\u043b\u0430\u043d\u0434",
  "TK": "\u0422\u0430\u043a\u0435\u043b\u0430\u0443",
  "TZ": "\u0422\u0430\u043d\u0437\u0430\u043d\u0456\u044f",
  "TG": "\u0422\u043e\u0433\u0430",
  "TO": "\u0422\u043e\u043d\u0433\u0430",
  "TT": "\u0422\u0440\u044b\u043d\u0456\u0434\u0430\u0434 \u0456 \u0422\u0430\u0431\u0430\u0433\u0430",
  "TV": "\u0422\u0443\u0432\u0430\u043b\u0443",
  "TN": "\u0422\u0443\u043d\u0456\u0441",
  "TM": "\u0422\u0443\u0440\u043a\u043c\u0435\u043d\u0456\u0441\u0442\u0430\u043d",
  "TR": "\u0422\u0443\u0440\u0446\u044b\u044f",
  "TL": "\u0422\u044b\u043c\u043e\u0440-\u041b\u0435\u0448\u0446\u0456",
  "UG": "\u0423\u0433\u0430\u043d\u0434\u0430",
  "UZ": "\u0423\u0437\u0431\u0435\u043a\u0456\u0441\u0442\u0430\u043d",
  "UA": "\u0423\u043a\u0440\u0430\u0456\u043d\u0430",
  "WF": "\u0423\u043e\u043b\u0456\u0441 \u0456 \u0424\u0443\u0442\u0443\u043d\u0430",
  "UY": "\u0423\u0440\u0443\u0433\u0432\u0430\u0439",
  "FK": "\u0424\u0430\u043b\u043a\u043b\u0435\u043d\u0434\u0441\u043a\u0456\u044f \u0430\u0441\u0442\u0440\u0430\u0432\u044b",
  "FO": "\u0424\u0430\u0440\u044d\u0440\u0441\u043a\u0456\u044f \u0430\u0441\u0442\u0440\u0430\u0432\u044b",
  "FJ": "\u0424\u0456\u0434\u0436\u044b",
  "PH": "\u0424\u0456\u043b\u0456\u043f\u0456\u043d\u044b",
  "FI": "\u0424\u0456\u043d\u043b\u044f\u043d\u0434\u044b\u044f",
  "GF": "\u0424\u0440\u0430\u043d\u0446\u0443\u0437\u0441\u043a\u0430\u044f \u0413\u0432\u0456\u044f\u043d\u0430",
  "PF": "\u0424\u0440\u0430\u043d\u0446\u0443\u0437\u0441\u043a\u0430\u044f \u041f\u0430\u043b\u0456\u043d\u0435\u0437\u0456\u044f",
  "TF": "\u0424\u0440\u0430\u043d\u0446\u0443\u0437\u0441\u043a\u0456\u044f \u043f\u0430\u045e\u0434\u043d\u0451\u0432\u044b\u044f \u0442\u044d\u0440\u044b\u0442\u043e\u0440\u044b\u0456",
  "FR": "\u0424\u0440\u0430\u043d\u0446\u044b\u044f",
  "HR": "\u0425\u0430\u0440\u0432\u0430\u0442\u044b\u044f",
  "CF": "\u0426\u044d\u043d\u0442\u0440\u0430\u043b\u044c\u043d\u0430-\u0410\u0444\u0440\u044b\u043a\u0430\u043d\u0441\u043a\u0430\u044f \u0420\u044d\u0441\u043f\u0443\u0431\u043b\u0456\u043a\u0430",
  "TD": "\u0427\u0430\u0434",
  "ME": "\u0427\u0430\u0440\u043d\u0430\u0433\u043e\u0440\u044b\u044f",
  "CL": "\u0427\u044b\u043b\u0456",
  "CZ": "\u0427\u044d\u0445\u0456\u044f",
  "CH": "\u0428\u0432\u0435\u0439\u0446\u0430\u0440\u044b\u044f",
  "SE": "\u0428\u0432\u0435\u0446\u044b\u044f",
  "SJ": "\u0428\u043f\u0456\u0446\u0431\u0435\u0440\u0433\u0435\u043d \u0456 \u042f\u043d-\u041c\u0430\u0435\u043d",
  "LK": "\u0428\u0440\u044b-\u041b\u0430\u043d\u043a\u0430",
  "EC": "\u042d\u043a\u0432\u0430\u0434\u043e\u0440",
  "GQ": "\u042d\u043a\u0432\u0430\u0442\u0430\u0440\u044b\u044f\u043b\u044c\u043d\u0430\u044f \u0413\u0432\u0456\u043d\u0435\u044f",
  "ER": "\u042d\u0440\u044b\u0442\u0440\u044d\u044f",
  "SZ": "\u042d\u0441\u0432\u0430\u0442\u044b\u043d\u0456",
  "EE": "\u042d\u0441\u0442\u043e\u043d\u0456\u044f",
  "ET": "\u042d\u0444\u0456\u043e\u043f\u0456\u044f",
  "JM": "\u042f\u043c\u0430\u0439\u043a\u0430",
  "JP": "\u042f\u043f\u043e\u043d\u0456\u044f"
}



================================================
FILE: public/intl/country/bg-BG.json
================================================
{
  "AU": "\u0410\u0432\u0441\u0442\u0440\u0430\u043b\u0438\u044f",
  "AT": "\u0410\u0432\u0441\u0442\u0440\u0438\u044f",
  "AZ": "\u0410\u0437\u0435\u0440\u0431\u0430\u0439\u0434\u0436\u0430\u043d",
  "AL": "\u0410\u043b\u0431\u0430\u043d\u0438\u044f",
  "DZ": "\u0410\u043b\u0436\u0438\u0440",
  "AS": "\u0410\u043c\u0435\u0440\u0438\u043a\u0430\u043d\u0441\u043a\u0430 \u0421\u0430\u043c\u043e\u0430",
  "VI": "\u0410\u043c\u0435\u0440\u0438\u043a\u0430\u043d\u0441\u043a\u0438 \u0412\u0438\u0440\u0434\u0436\u0438\u043d\u0441\u043a\u0438 \u043e\u0441\u0442\u0440\u043e\u0432\u0438",
  "AO": "\u0410\u043d\u0433\u043e\u043b\u0430",
  "AI": "\u0410\u043d\u0433\u0443\u0438\u043b\u0430",
  "AD": "\u0410\u043d\u0434\u043e\u0440\u0430",
  "AQ": "\u0410\u043d\u0442\u0430\u0440\u043a\u0442\u0438\u043a\u0430",
  "AG": "\u0410\u043d\u0442\u0438\u0433\u0443\u0430 \u0438 \u0411\u0430\u0440\u0431\u0443\u0434\u0430",
  "AR": "\u0410\u0440\u0436\u0435\u043d\u0442\u0438\u043d\u0430",
  "AM": "\u0410\u0440\u043c\u0435\u043d\u0438\u044f",
  "AW": "\u0410\u0440\u0443\u0431\u0430",
  "AF": "\u0410\u0444\u0433\u0430\u043d\u0438\u0441\u0442\u0430\u043d",
  "BD": "\u0411\u0430\u043d\u0433\u043b\u0430\u0434\u0435\u0448",
  "BB": "\u0411\u0430\u0440\u0431\u0430\u0434\u043e\u0441",
  "BS": "\u0411\u0430\u0445\u0430\u043c\u0441\u043a\u0438 \u043e\u0441\u0442\u0440\u043e\u0432\u0438",
  "BH": "\u0411\u0430\u0445\u0440\u0435\u0439\u043d",
  "BY": "\u0411\u0435\u043b\u0430\u0440\u0443\u0441",
  "BE": "\u0411\u0435\u043b\u0433\u0438\u044f",
  "BZ": "\u0411\u0435\u043b\u0438\u0437",
  "BJ": "\u0411\u0435\u043d\u0438\u043d",
  "BM": "\u0411\u0435\u0440\u043c\u0443\u0434\u0441\u043a\u0438 \u043e\u0441\u0442\u0440\u043e\u0432\u0438",
  "BO": "\u0411\u043e\u043b\u0438\u0432\u0438\u044f",
  "BA": "\u0411\u043e\u0441\u043d\u0430 \u0438 \u0425\u0435\u0440\u0446\u0435\u0433\u043e\u0432\u0438\u043d\u0430",
  "BW": "\u0411\u043e\u0442\u0441\u0432\u0430\u043d\u0430",
  "BR": "\u0411\u0440\u0430\u0437\u0438\u043b\u0438\u044f",
  "IO": "\u0411\u0440\u0438\u0442\u0430\u043d\u0441\u043a\u0430 \u0442\u0435\u0440\u0438\u0442\u043e\u0440\u0438\u044f \u0432 \u0418\u043d\u0434\u0438\u0439\u0441\u043a\u0438\u044f \u043e\u043a\u0435\u0430\u043d",
  "VG": "\u0411\u0440\u0438\u0442\u0430\u043d\u0441\u043a\u0438 \u0412\u0438\u0440\u0434\u0436\u0438\u043d\u0441\u043a\u0438 \u043e\u0441\u0442\u0440\u043e\u0432\u0438",
  "BN": "\u0411\u0440\u0443\u043d\u0435\u0439 \u0414\u0430\u0440\u0443\u0441\u0441\u0430\u043b\u0430\u043c",
  "BF": "\u0411\u0443\u0440\u043a\u0438\u043d\u0430 \u0424\u0430\u0441\u043e",
  "BI": "\u0411\u0443\u0440\u0443\u043d\u0434\u0438",
  "BT": "\u0411\u0443\u0442\u0430\u043d",
  "BG": "\u0411\u044a\u043b\u0433\u0430\u0440\u0438\u044f",
  "VU": "\u0412\u0430\u043d\u0443\u0430\u0442\u0443",
  "VA": "\u0412\u0430\u0442\u0438\u043a\u0430\u043d",
  "VE": "\u0412\u0435\u043d\u0435\u0446\u0443\u0435\u043b\u0430",
  "VN": "\u0412\u0438\u0435\u0442\u043d\u0430\u043c",
  "GA": "\u0413\u0430\u0431\u043e\u043d",
  "GM": "\u0413\u0430\u043c\u0431\u0438\u044f",
  "GH": "\u0413\u0430\u043d\u0430",
  "GY": "\u0413\u0430\u044f\u043d\u0430",
  "GP": "\u0413\u0432\u0430\u0434\u0435\u043b\u0443\u043f\u0430",
  "GT": "\u0413\u0432\u0430\u0442\u0435\u043c\u0430\u043b\u0430",
  "GN": "\u0413\u0432\u0438\u043d\u0435\u044f",
  "GW": "\u0413\u0432\u0438\u043d\u0435\u044f-\u0411\u0438\u0441\u0430\u0443",
  "DE": "\u0413\u0435\u0440\u043c\u0430\u043d\u0438\u044f",
  "GI": "\u0413\u0438\u0431\u0440\u0430\u043b\u0442\u0430\u0440",
  "GD": "\u0413\u0440\u0435\u043d\u0430\u0434\u0430",
  "GL": "\u0413\u0440\u0435\u043d\u043b\u0430\u043d\u0434\u0438\u044f",
  "GE": "\u0413\u0440\u0443\u0437\u0438\u044f",
  "GU": "\u0413\u0443\u0430\u043c",
  "GG": "\u0413\u044a\u0440\u043d\u0437\u0438",
  "GR": "\u0413\u044a\u0440\u0446\u0438\u044f",
  "DK": "\u0414\u0430\u043d\u0438\u044f",
  "DJ": "\u0414\u0436\u0438\u0431\u0443\u0442\u0438",
  "JE": "\u0414\u0436\u044a\u0440\u0441\u0438",
  "DM": "\u0414\u043e\u043c\u0438\u043d\u0438\u043a\u0430",
  "DO": "\u0414\u043e\u043c\u0438\u043d\u0438\u043a\u0430\u043d\u0441\u043a\u0430 \u0440\u0435\u043f\u0443\u0431\u043b\u0438\u043a\u0430",
  "EG": "\u0415\u0433\u0438\u043f\u0435\u0442",
  "EC": "\u0415\u043a\u0432\u0430\u0434\u043e\u0440",
  "GQ": "\u0415\u043a\u0432\u0430\u0442\u043e\u0440\u0438\u0430\u043b\u043d\u0430 \u0413\u0432\u0438\u043d\u0435\u044f",
  "ER": "\u0415\u0440\u0438\u0442\u0440\u0435\u044f",
  "SZ": "\u0415\u0441\u0432\u0430\u0442\u0438\u043d\u0438",
  "EE": "\u0415\u0441\u0442\u043e\u043d\u0438\u044f",
  "ET": "\u0415\u0442\u0438\u043e\u043f\u0438\u044f",
  "ZM": "\u0417\u0430\u043c\u0431\u0438\u044f",
  "EH": "\u0417\u0430\u043f\u0430\u0434\u043d\u0430 \u0421\u0430\u0445\u0430\u0440\u0430",
  "ZW": "\u0417\u0438\u043c\u0431\u0430\u0431\u0432\u0435",
  "IL": "\u0418\u0437\u0440\u0430\u0435\u043b",
  "TL": "\u0418\u0437\u0442\u043e\u0447\u0435\u043d \u0422\u0438\u043c\u043e\u0440",
  "IN": "\u0418\u043d\u0434\u0438\u044f",
  "ID": "\u0418\u043d\u0434\u043e\u043d\u0435\u0437\u0438\u044f",
  "IQ": "\u0418\u0440\u0430\u043a",
  "IR": "\u0418\u0440\u0430\u043d",
  "IE": "\u0418\u0440\u043b\u0430\u043d\u0434\u0438\u044f",
  "IS": "\u0418\u0441\u043b\u0430\u043d\u0434\u0438\u044f",
  "ES": "\u0418\u0441\u043f\u0430\u043d\u0438\u044f",
  "IT": "\u0418\u0442\u0430\u043b\u0438\u044f",
  "YE": "\u0419\u0435\u043c\u0435\u043d",
  "JO": "\u0419\u043e\u0440\u0434\u0430\u043d\u0438\u044f",
  "CV": "\u041a\u0430\u0431\u043e \u0412\u0435\u0440\u0434\u0435",
  "KZ": "\u041a\u0430\u0437\u0430\u0445\u0441\u0442\u0430\u043d",
  "KY": "\u041a\u0430\u0439\u043c\u0430\u043d\u043e\u0432\u0438 \u043e\u0441\u0442\u0440\u043e\u0432\u0438",
  "KH": "\u041a\u0430\u043c\u0431\u043e\u0434\u0436\u0430",
  "CM": "\u041a\u0430\u043c\u0435\u0440\u0443\u043d",
  "CA": "\u041a\u0430\u043d\u0430\u0434\u0430",
  "BQ": "\u041a\u0430\u0440\u0438\u0431\u0441\u043a\u0430 \u041d\u0438\u0434\u0435\u0440\u043b\u0430\u043d\u0434\u0438\u044f",
  "QA": "\u041a\u0430\u0442\u0430\u0440",
  "KE": "\u041a\u0435\u043d\u0438\u044f",
  "CY": "\u041a\u0438\u043f\u044a\u0440",
  "KG": "\u041a\u0438\u0440\u0433\u0438\u0437\u0441\u0442\u0430\u043d",
  "KI": "\u041a\u0438\u0440\u0438\u0431\u0430\u0442\u0438",
  "CN": "\u041a\u0438\u0442\u0430\u0439",
  "CC": "\u041a\u043e\u043a\u043e\u0441\u043e\u0432\u0438 \u043e\u0441\u0442\u0440\u043e\u0432\u0438 (\u043e\u0441\u0442\u0440\u043e\u0432\u0438 \u041a\u0438\u0439\u043b\u0438\u043d\u0433)",
  "CO": "\u041a\u043e\u043b\u0443\u043c\u0431\u0438\u044f",
  "XK": "\u041a\u043e\u0441\u043e\u0432\u043e",
  "KM": "\u041a\u043e\u043c\u043e\u0440\u0441\u043a\u0438 \u043e\u0441\u0442\u0440\u043e\u0432\u0438",
  "CG": "\u041a\u043e\u043d\u0433\u043e (\u0411\u0440\u0430\u0437\u0430\u0432\u0438\u043b)",
  "CD": "\u041a\u043e\u043d\u0433\u043e (\u041a\u0438\u043d\u0448\u0430\u0441\u0430)",
  "CR": "\u041a\u043e\u0441\u0442\u0430 \u0420\u0438\u043a\u0430",
  "CI": "\u041a\u043e\u0442 \u0434\u2019\u0418\u0432\u043e\u0430\u0440",
  "CU": "\u041a\u0443\u0431\u0430",
  "KW": "\u041a\u0443\u0432\u0435\u0439\u0442",
  "CW": "\u041a\u044e\u0440\u0430\u0441\u0430\u043e",
  "LA": "\u041b\u0430\u043e\u0441",
  "LV": "\u041b\u0430\u0442\u0432\u0438\u044f",
  "LS": "\u041b\u0435\u0441\u043e\u0442\u043e",
  "LR": "\u041b\u0438\u0431\u0435\u0440\u0438\u044f",
  "LY": "\u041b\u0438\u0431\u0438\u044f",
  "LB": "\u041b\u0438\u0432\u0430\u043d",
  "LT": "\u041b\u0438\u0442\u0432\u0430",
  "LI": "\u041b\u0438\u0445\u0442\u0435\u043d\u0449\u0430\u0439\u043d",
  "LU": "\u041b\u044e\u043a\u0441\u0435\u043c\u0431\u0443\u0440\u0433",
  "MR": "\u041c\u0430\u0432\u0440\u0438\u0442\u0430\u043d\u0438\u044f",
  "MU": "\u041c\u0430\u0432\u0440\u0438\u0446\u0438\u0439",
  "MG": "\u041c\u0430\u0434\u0430\u0433\u0430\u0441\u043a\u0430\u0440",
  "YT": "\u041c\u0430\u0439\u043e\u0442",
  "MO": "\u041c\u0430\u043a\u0430\u043e, \u0421\u0410\u0420 \u043d\u0430 \u041a\u0438\u0442\u0430\u0439",
  "MW": "\u041c\u0430\u043b\u0430\u0432\u0438",
  "MY": "\u041c\u0430\u043b\u0430\u0439\u0437\u0438\u044f",
  "MV": "\u041c\u0430\u043b\u0434\u0438\u0432\u0438",
  "ML": "\u041c\u0430\u043b\u0438",
  "MT": "\u041c\u0430\u043b\u0442\u0430",
  "MA": "\u041c\u0430\u0440\u043e\u043a\u043e",
  "MQ": "\u041c\u0430\u0440\u0442\u0438\u043d\u0438\u043a\u0430",
  "MH": "\u041c\u0430\u0440\u0448\u0430\u043b\u043e\u0432\u0438 \u043e\u0441\u0442\u0440\u043e\u0432\u0438",
  "MX": "\u041c\u0435\u043a\u0441\u0438\u043a\u043e",
  "MM": "\u041c\u0438\u0430\u043d\u043c\u0430\u0440 (\u0411\u0438\u0440\u043c\u0430)",
  "FM": "\u041c\u0438\u043a\u0440\u043e\u043d\u0435\u0437\u0438\u044f",
  "MZ": "\u041c\u043e\u0437\u0430\u043c\u0431\u0438\u043a",
  "MD": "\u041c\u043e\u043b\u0434\u043e\u0432\u0430",
  "MC": "\u041c\u043e\u043d\u0430\u043a\u043e",
  "MN": "\u041c\u043e\u043d\u0433\u043e\u043b\u0438\u044f",
  "MS": "\u041c\u043e\u043d\u0442\u0441\u0435\u0440\u0430\u0442",
  "NA": "\u041d\u0430\u043c\u0438\u0431\u0438\u044f",
  "NR": "\u041d\u0430\u0443\u0440\u0443",
  "NP": "\u041d\u0435\u043f\u0430\u043b",
  "NE": "\u041d\u0438\u0433\u0435\u0440",
  "NG": "\u041d\u0438\u0433\u0435\u0440\u0438\u044f",
  "NL": "\u041d\u0438\u0434\u0435\u0440\u043b\u0430\u043d\u0434\u0438\u044f",
  "NI": "\u041d\u0438\u043a\u0430\u0440\u0430\u0433\u0443\u0430",
  "NU": "\u041d\u0438\u0443\u0435",
  "NZ": "\u041d\u043e\u0432\u0430 \u0417\u0435\u043b\u0430\u043d\u0434\u0438\u044f",
  "NC": "\u041d\u043e\u0432\u0430 \u041a\u0430\u043b\u0435\u0434\u043e\u043d\u0438\u044f",
  "NO": "\u041d\u043e\u0440\u0432\u0435\u0433\u0438\u044f",
  "AE": "\u041e\u0431\u0435\u0434\u0438\u043d\u0435\u043d\u0438 \u0430\u0440\u0430\u0431\u0441\u043a\u0438 \u0435\u043c\u0438\u0440\u0441\u0442\u0432\u0430",
  "GB": "\u041e\u0431\u0435\u0434\u0438\u043d\u0435\u043d\u043e\u0442\u043e \u043a\u0440\u0430\u043b\u0441\u0442\u0432\u043e",
  "AX": "\u041e\u043b\u0430\u043d\u0434\u0441\u043a\u0438 \u043e\u0441\u0442\u0440\u043e\u0432\u0438",
  "OM": "\u041e\u043c\u0430\u043d",
  "BV": "\u043e\u0441\u0442\u0440\u043e\u0432 \u0411\u0443\u0432\u0435",
  "IM": "\u043e\u0441\u0442\u0440\u043e\u0432 \u041c\u0430\u043d",
  "NF": "\u043e\u0441\u0442\u0440\u043e\u0432 \u041d\u043e\u0440\u0444\u043e\u043b\u043a",
  "CX": "\u043e\u0441\u0442\u0440\u043e\u0432 \u0420\u043e\u0436\u0434\u0435\u0441\u0442\u0432\u043e",
  "CK": "\u043e\u0441\u0442\u0440\u043e\u0432\u0438 \u041a\u0443\u043a",
  "PN": "\u041e\u0441\u0442\u0440\u043e\u0432\u0438 \u041f\u0438\u0442\u043a\u0435\u0440\u043d",
  "TC": "\u043e\u0441\u0442\u0440\u043e\u0432\u0438 \u0422\u044a\u0440\u043a\u0441 \u0438 \u041a\u0430\u0439\u043a\u043e\u0441",
  "HM": "\u043e\u0441\u0442\u0440\u043e\u0432\u0438 \u0425\u044a\u0440\u0434 \u0438 \u041c\u0430\u043a\u0434\u043e\u043d\u0430\u043b\u0434",
  "UM": "\u041e\u0442\u0434\u0430\u043b\u0435\u0447\u0435\u043d\u0438 \u043e\u0441\u0442\u0440\u043e\u0432\u0438 \u043d\u0430 \u0421\u0410\u0429",
  "PK": "\u041f\u0430\u043a\u0438\u0441\u0442\u0430\u043d",
  "PW": "\u041f\u0430\u043b\u0430\u0443",
  "PS": "\u041f\u0430\u043b\u0435\u0441\u0442\u0438\u043d\u0441\u043a\u0438 \u0442\u0435\u0440\u0438\u0442\u043e\u0440\u0438\u0438",
  "PA": "\u041f\u0430\u043d\u0430\u043c\u0430",
  "PG": "\u041f\u0430\u043f\u0443\u0430-\u041d\u043e\u0432\u0430 \u0413\u0432\u0438\u043d\u0435\u044f",
  "PY": "\u041f\u0430\u0440\u0430\u0433\u0432\u0430\u0439",
  "PE": "\u041f\u0435\u0440\u0443",
  "PL": "\u041f\u043e\u043b\u0448\u0430",
  "PT": "\u041f\u043e\u0440\u0442\u0443\u0433\u0430\u043b\u0438\u044f",
  "PR": "\u041f\u0443\u0435\u0440\u0442\u043e \u0420\u0438\u043a\u043e",
  "RE": "\u0420\u0435\u044e\u043d\u0438\u043e\u043d",
  "RW": "\u0420\u0443\u0430\u043d\u0434\u0430",
  "RO": "\u0420\u0443\u043c\u044a\u043d\u0438\u044f",
  "RU": "\u0420\u0443\u0441\u0438\u044f",
  "SV": "\u0421\u0430\u043b\u0432\u0430\u0434\u043e\u0440",
  "WS": "\u0421\u0430\u043c\u043e\u0430",
  "SM": "\u0421\u0430\u043d \u041c\u0430\u0440\u0438\u043d\u043e",
  "ST": "\u0421\u0430\u043e \u0422\u043e\u043c\u0435 \u0438 \u041f\u0440\u0438\u043d\u0441\u0438\u043f\u0438",
  "SA": "\u0421\u0430\u0443\u0434\u0438\u0442\u0441\u043a\u0430 \u0410\u0440\u0430\u0431\u0438\u044f",
  "SJ": "\u0421\u0432\u0430\u043b\u0431\u0430\u0440\u0434 \u0438 \u042f\u043d \u041c\u0430\u0439\u0435\u043d",
  "SH": "\u0421\u0432\u0435\u0442\u0430 \u0415\u043b\u0435\u043d\u0430",
  "KP": "\u0421\u0435\u0432\u0435\u0440\u043d\u0430 \u041a\u043e\u0440\u0435\u044f",
  "MK": "\u0421\u0435\u0432\u0435\u0440\u043d\u0430 \u041c\u0430\u043a\u0435\u0434\u043e\u043d\u0438\u044f",
  "MP": "\u0421\u0435\u0432\u0435\u0440\u043d\u0438 \u041c\u0430\u0440\u0438\u0430\u043d\u0441\u043a\u0438 \u043e\u0441\u0442\u0440\u043e\u0432\u0438",
  "VC": "\u0421\u0435\u0439\u043d\u0442 \u0412\u0438\u043d\u0441\u044a\u043d\u0442 \u0438 \u0413\u0440\u0435\u043d\u0430\u0434\u0438\u043d\u0438",
  "KN": "\u0421\u0435\u0439\u043d\u0442 \u041a\u0438\u0442\u0441 \u0438 \u041d\u0435\u0432\u0438\u0441",
  "LC": "\u0421\u0435\u0439\u043d\u0442 \u041b\u0443\u0441\u0438\u044f",
  "SC": "\u0421\u0435\u0439\u0448\u0435\u043b\u0438",
  "BL": "\u0421\u0435\u043d \u0411\u0430\u0440\u0442\u0435\u043b\u0435\u043c\u0438",
  "MF": "\u0421\u0435\u043d \u041c\u0430\u0440\u0442\u0435\u043d",
  "PM": "\u0421\u0435\u043d \u041f\u0438\u0435\u0440 \u0438 \u041c\u0438\u043a\u0435\u043b\u043e\u043d",
  "SN": "\u0421\u0435\u043d\u0435\u0433\u0430\u043b",
  "SL": "\u0421\u0438\u0435\u0440\u0430 \u041b\u0435\u043e\u043d\u0435",
  "SG": "\u0421\u0438\u043d\u0433\u0430\u043f\u0443\u0440",
  "SX": "\u0421\u0438\u043d\u0442 \u041c\u0430\u0440\u0442\u0435\u043d",
  "SY": "\u0421\u0438\u0440\u0438\u044f",
  "SK": "\u0421\u043b\u043e\u0432\u0430\u043a\u0438\u044f",
  "SI": "\u0421\u043b\u043e\u0432\u0435\u043d\u0438\u044f",
  "SB": "\u0421\u043e\u043b\u043e\u043c\u043e\u043d\u043e\u0432\u0438 \u043e\u0441\u0442\u0440\u043e\u0432\u0438",
  "SO": "\u0421\u043e\u043c\u0430\u043b\u0438\u044f",
  "SD": "\u0421\u0443\u0434\u0430\u043d",
  "SR": "\u0421\u0443\u0440\u0438\u043d\u0430\u043c",
  "US": "\u0421\u044a\u0435\u0434\u0438\u043d\u0435\u043d\u0438 \u0449\u0430\u0442\u0438",
  "RS": "\u0421\u044a\u0440\u0431\u0438\u044f",
  "TJ": "\u0422\u0430\u0434\u0436\u0438\u043a\u0438\u0441\u0442\u0430\u043d",
  "TW": "\u0422\u0430\u0439\u0432\u0430\u043d",
  "TH": "\u0422\u0430\u0439\u043b\u0430\u043d\u0434",
  "TZ": "\u0422\u0430\u043d\u0437\u0430\u043d\u0438\u044f",
  "TG": "\u0422\u043e\u0433\u043e",
  "TK": "\u0422\u043e\u043a\u0435\u043b\u0430\u0443",
  "TO": "\u0422\u043e\u043d\u0433\u0430",
  "TT": "\u0422\u0440\u0438\u043d\u0438\u0434\u0430\u0434 \u0438 \u0422\u043e\u0431\u0430\u0433\u043e",
  "TV": "\u0422\u0443\u0432\u0430\u043b\u0443",
  "TN": "\u0422\u0443\u043d\u0438\u0441",
  "TM": "\u0422\u0443\u0440\u043a\u043c\u0435\u043d\u0438\u0441\u0442\u0430\u043d",
  "TR": "\u0422\u0443\u0440\u0446\u0438\u044f",
  "UG": "\u0423\u0433\u0430\u043d\u0434\u0430",
  "UZ": "\u0423\u0437\u0431\u0435\u043a\u0438\u0441\u0442\u0430\u043d",
  "UA": "\u0423\u043a\u0440\u0430\u0439\u043d\u0430",
  "HU": "\u0423\u043d\u0433\u0430\u0440\u0438\u044f",
  "WF": "\u0423\u043e\u043b\u0438\u0441 \u0438 \u0424\u0443\u0442\u0443\u043d\u0430",
  "UY": "\u0423\u0440\u0443\u0433\u0432\u0430\u0439",
  "FO": "\u0424\u0430\u0440\u044c\u043e\u0440\u0441\u043a\u0438 \u043e\u0441\u0442\u0440\u043e\u0432\u0438",
  "FJ": "\u0424\u0438\u0434\u0436\u0438",
  "PH": "\u0424\u0438\u043b\u0438\u043f\u0438\u043d\u0438",
  "FI": "\u0424\u0438\u043d\u043b\u0430\u043d\u0434\u0438\u044f",
  "FK": "\u0424\u043e\u043b\u043a\u043b\u0430\u043d\u0434\u0441\u043a\u0438 \u043e\u0441\u0442\u0440\u043e\u0432\u0438",
  "FR": "\u0424\u0440\u0430\u043d\u0446\u0438\u044f",
  "GF": "\u0424\u0440\u0435\u043d\u0441\u043a\u0430 \u0413\u0432\u0438\u0430\u043d\u0430",
  "PF": "\u0424\u0440\u0435\u043d\u0441\u043a\u0430 \u041f\u043e\u043b\u0438\u043d\u0435\u0437\u0438\u044f",
  "TF": "\u0424\u0440\u0435\u043d\u0441\u043a\u0438 \u044e\u0436\u043d\u0438 \u0442\u0435\u0440\u0438\u0442\u043e\u0440\u0438\u0438",
  "HT": "\u0425\u0430\u0438\u0442\u0438",
  "HN": "\u0425\u043e\u043d\u0434\u0443\u0440\u0430\u0441",
  "HK": "\u0425\u043e\u043d\u043a\u043e\u043d\u0433, \u0421\u0410\u0420 \u043d\u0430 \u041a\u0438\u0442\u0430\u0439",
  "HR": "\u0425\u044a\u0440\u0432\u0430\u0442\u0438\u044f",
  "CF": "\u0426\u0435\u043d\u0442\u0440\u0430\u043b\u043d\u043e\u0430\u0444\u0440\u0438\u043a\u0430\u043d\u0441\u043a\u0430 \u0440\u0435\u043f\u0443\u0431\u043b\u0438\u043a\u0430",
  "TD": "\u0427\u0430\u0434",
  "ME": "\u0427\u0435\u0440\u043d\u0430 \u0433\u043e\u0440\u0430",
  "CZ": "\u0427\u0435\u0445\u0438\u044f",
  "CL": "\u0427\u0438\u043b\u0438",
  "CH": "\u0428\u0432\u0435\u0439\u0446\u0430\u0440\u0438\u044f",
  "SE": "\u0428\u0432\u0435\u0446\u0438\u044f",
  "LK": "\u0428\u0440\u0438 \u041b\u0430\u043d\u043a\u0430",
  "SS": "\u042e\u0436\u0435\u043d \u0421\u0443\u0434\u0430\u043d",
  "ZA": "\u042e\u0436\u043d\u0430 \u0410\u0444\u0440\u0438\u043a\u0430",
  "GS": "\u042e\u0436\u043d\u0430 \u0414\u0436\u043e\u0440\u0434\u0436\u0438\u044f \u0438 \u042e\u0436\u043d\u0438 \u0421\u0430\u043d\u0434\u0432\u0438\u0447\u0435\u0432\u0438 \u043e\u0441\u0442\u0440\u043e\u0432\u0438",
  "KR": "\u042e\u0436\u043d\u0430 \u041a\u043e\u0440\u0435\u044f",
  "JM": "\u042f\u043c\u0430\u0439\u043a\u0430",
  "JP": "\u042f\u043f\u043e\u043d\u0438\u044f"
}



================================================
FILE: public/intl/country/bn-BD.json
================================================
{
  "AT": "\u0985\u09b8\u09cd\u099f\u09cd\u09b0\u09bf\u09af\u09bc\u09be",
  "AU": "\u0985\u09b8\u09cd\u099f\u09cd\u09b0\u09c7\u09b2\u09bf\u09af\u09bc\u09be",
  "AO": "\u0985\u09cd\u09af\u09be\u0999\u09cd\u0997\u09cb\u09b2\u09be",
  "AQ": "\u0985\u09cd\u09af\u09be\u09a8\u09cd\u099f\u09be\u09b0\u09cd\u0995\u099f\u09bf\u0995\u09be",
  "AG": "\u0985\u09cd\u09af\u09be\u09a8\u09cd\u099f\u09bf\u0997\u09c1\u09af\u09bc\u09be \u0993 \u09ac\u09be\u09b0\u09ac\u09c1\u09a1\u09be",
  "IM": "\u0986\u0987\u09b2 \u0985\u09ab \u09ae\u09cd\u09af\u09be\u09a8",
  "IS": "\u0986\u0987\u09b8\u09b2\u09cd\u09af\u09be\u09a8\u09cd\u09a1",
  "AZ": "\u0986\u099c\u09be\u09b0\u09ac\u09be\u0987\u099c\u09be\u09a8",
  "AD": "\u0986\u09a8\u09cd\u09a1\u09cb\u09b0\u09be",
  "AF": "\u0986\u09ab\u0997\u09be\u09a8\u09bf\u09b8\u09cd\u09a4\u09be\u09a8",
  "AS": "\u0986\u09ae\u09c7\u09b0\u09bf\u0995\u09be\u09a8 \u09b8\u09be\u09ae\u09cb\u09af\u09bc\u09be",
  "IE": "\u0986\u09af\u09bc\u09be\u09b0\u09b2\u09cd\u09af\u09be\u09a8\u09cd\u09a1",
  "AW": "\u0986\u09b0\u09c1\u09ac\u09be",
  "AR": "\u0986\u09b0\u09cd\u099c\u09c7\u09a8\u09cd\u099f\u09bf\u09a8\u09be",
  "AM": "\u0986\u09b0\u09cd\u09ae\u09c7\u09a8\u09bf\u09af\u09bc\u09be",
  "DZ": "\u0986\u09b2\u099c\u09c7\u09b0\u09bf\u09af\u09bc\u09be",
  "AL": "\u0986\u09b2\u09ac\u09c7\u09a8\u09bf\u09af\u09bc\u09be",
  "AX": "\u0986\u09b2\u09be\u09a8\u09cd\u09a1 \u09a6\u09cd\u09ac\u09c0\u09aa\u09aa\u09c1\u099e\u09cd\u099c",
  "UA": "\u0987\u0989\u0995\u09cd\u09b0\u09c7\u09a8",
  "EC": "\u0987\u0995\u09c1\u09af\u09bc\u09c7\u09a1\u09b0",
  "IL": "\u0987\u099c\u09b0\u09be\u09af\u09bc\u09c7\u09b2",
  "IT": "\u0987\u09a4\u09be\u09b2\u09bf",
  "ET": "\u0987\u09a5\u09bf\u0993\u09aa\u09bf\u09af\u09bc\u09be",
  "ID": "\u0987\u09a8\u09cd\u09a6\u09cb\u09a8\u09c7\u09b6\u09bf\u09af\u09bc\u09be",
  "YE": "\u0987\u09af\u09bc\u09c7\u09ae\u09c7\u09a8",
  "IQ": "\u0987\u09b0\u09be\u0995",
  "IR": "\u0987\u09b0\u09be\u09a8",
  "ER": "\u0987\u09b0\u09bf\u09a4\u09cd\u09b0\u09bf\u09af\u09bc\u09be",
  "SZ": "\u0987\u09b8\u0993\u09af\u09bc\u09be\u09a4\u09bf\u09a8\u09bf",
  "UG": "\u0989\u0997\u09be\u09a8\u09cd\u09a1\u09be",
  "UZ": "\u0989\u099c\u09ac\u09c7\u0995\u09bf\u09b8\u09cd\u09a4\u09be\u09a8",
  "KP": "\u0989\u09a4\u09cd\u09a4\u09b0 \u0995\u09cb\u09b0\u09bf\u09af\u09bc\u09be",
  "MK": "\u0989\u09a4\u09cd\u09a4\u09b0 \u09ae\u09cd\u09af\u09be\u09b8\u09c7\u09a1\u09cb\u09a8\u09bf\u09af\u09bc\u09be",
  "MP": "\u0989\u09a4\u09cd\u09a4\u09b0\u09be\u099e\u09cd\u099a\u09b2\u09c0\u09af\u09bc \u09ae\u09be\u09b0\u09bf\u09af\u09bc\u09be\u09a8\u09be \u09a6\u09cd\u09ac\u09c0\u09aa\u09aa\u09c1\u099e\u09cd\u099c",
  "UY": "\u0989\u09b0\u09c1\u0997\u09c1\u09af\u09bc\u09c7",
  "SV": "\u098f\u09b2 \u09b8\u09be\u09b2\u09ad\u09c7\u09a6\u09b0",
  "EE": "\u098f\u09b8\u09cd\u09a4\u09cb\u09a8\u09bf\u09af\u09bc\u09be",
  "AI": "\u098f\u09cd\u09af\u09be\u0999\u09cd\u0997\u09c1\u0987\u09b2\u09be",
  "OM": "\u0993\u09ae\u09be\u09a8",
  "WF": "\u0993\u09af\u09bc\u09be\u09b2\u09bf\u09b8 \u0993 \u09ab\u09c1\u099f\u09c1\u09a8\u09be",
  "CG": "\u0995\u0999\u09cd\u0997\u09cb - \u09ac\u09cd\u09b0\u09be\u099c\u09be\u09ad\u09bf\u09b2",
  "CD": "\u0995\u0999\u09cd\u0997\u09cb-\u0995\u09bf\u09a8\u09b6\u09be\u09b8\u09be",
  "KM": "\u0995\u09ae\u09cb\u09b0\u09cb\u09b8",
  "KH": "\u0995\u09ae\u09cd\u09ac\u09cb\u09a1\u09bf\u09af\u09bc\u09be",
  "CO": "\u0995\u09b2\u09ae\u09cd\u09ac\u09bf\u09af\u09bc\u09be",
  "KZ": "\u0995\u09be\u099c\u09be\u0996\u09b8\u09cd\u09a4\u09be\u09a8",
  "QA": "\u0995\u09be\u09a4\u09be\u09b0",
  "CA": "\u0995\u09be\u09a8\u09be\u09a1\u09be",
  "CU": "\u0995\u09bf\u0989\u09ac\u09be",
  "KG": "\u0995\u09bf\u09b0\u0997\u09bf\u099c\u09bf\u09b8\u09cd\u09a4\u09be\u09a8",
  "KI": "\u0995\u09bf\u09b0\u09bf\u09ac\u09be\u09a4\u09bf",
  "XK": "\u0995\u09b8\u09cb\u09ad\u09cb",
  "CK": "\u0995\u09c1\u0995 \u09a6\u09cd\u09ac\u09c0\u09aa\u09aa\u09c1\u099e\u09cd\u099c",
  "KW": "\u0995\u09c1\u09af\u09bc\u09c7\u09a4",
  "CW": "\u0995\u09c1\u09b0\u09be\u09b8\u09be\u0993",
  "KE": "\u0995\u09c7\u09a8\u09bf\u09af\u09bc\u09be",
  "CV": "\u0995\u09c7\u09aa\u09ad\u09be\u09b0\u09cd\u09a6\u09c7",
  "KY": "\u0995\u09c7\u09ae\u09cd\u09af\u09be\u09a8 \u09a6\u09cd\u09ac\u09c0\u09aa\u09aa\u09c1\u099e\u09cd\u099c",
  "CC": "\u0995\u09cb\u0995\u09cb\u09b8 (\u0995\u09bf\u09b2\u09bf\u0982) \u09a6\u09cd\u09ac\u09c0\u09aa\u09aa\u09c1\u099e\u09cd\u099c",
  "CI": "\u0995\u09cb\u09a4 \u09a6\u09bf\u09ad\u09cb\u09af\u09bc\u09be\u09b0",
  "CR": "\u0995\u09cb\u09b8\u09cd\u099f\u09be\u09b0\u09bf\u0995\u09be",
  "CM": "\u0995\u09cd\u09af\u09be\u09ae\u09c7\u09b0\u09c1\u09a8",
  "BQ": "\u0995\u09cd\u09af\u09be\u09b0\u09bf\u09ac\u09bf\u09af\u09bc\u09be\u09a8 \u09a8\u09c7\u09a6\u09be\u09b0\u09b2\u09cd\u09af\u09be\u09a8\u09cd\u09a1\u09b8",
  "CX": "\u0995\u09cd\u09b0\u09bf\u09b8\u09ae\u09be\u09b8 \u09a6\u09cd\u09ac\u09c0\u09aa",
  "HR": "\u0995\u09cd\u09b0\u09cb\u09af\u09bc\u09c7\u09b6\u09bf\u09af\u09bc\u09be",
  "GM": "\u0997\u09be\u09ae\u09cd\u09ac\u09bf\u09af\u09bc\u09be",
  "GN": "\u0997\u09bf\u09a8\u09bf",
  "GW": "\u0997\u09bf\u09a8\u09bf-\u09ac\u09bf\u09b8\u09be\u0989",
  "GY": "\u0997\u09bf\u09af\u09bc\u09be\u09a8\u09be",
  "GT": "\u0997\u09c1\u09af\u09bc\u09be\u09a4\u09c7\u09ae\u09be\u09b2\u09be",
  "GP": "\u0997\u09c1\u09af\u09bc\u09be\u09a6\u09c7\u09b2\u09cc\u09aa",
  "GU": "\u0997\u09c1\u09af\u09bc\u09be\u09ae",
  "GG": "\u0997\u09c1\u09af\u09bc\u09be\u09b0\u09cd\u09a8\u09b8\u09bf",
  "GA": "\u0997\u09cd\u09af\u09be\u09ac\u09a8",
  "GL": "\u0997\u09cd\u09b0\u09c0\u09a8\u09b2\u09cd\u09af\u09be\u09a8\u09cd\u09a1",
  "GR": "\u0997\u09cd\u09b0\u09c0\u09b8",
  "GD": "\u0997\u09cd\u09b0\u09c7\u09a8\u09be\u09a1\u09be",
  "GH": "\u0998\u09be\u09a8\u09be",
  "TD": "\u099a\u09be\u09a6",
  "CL": "\u099a\u09bf\u09b2\u09bf",
  "CN": "\u099a\u09c0\u09a8",
  "CZ": "\u099a\u09c7\u099a\u09bf\u09af\u09bc\u09be",
  "GE": "\u099c\u09b0\u09cd\u099c\u09bf\u09af\u09bc\u09be",
  "JO": "\u099c\u09b0\u09cd\u09a1\u09a8",
  "JP": "\u099c\u09be\u09aa\u09be\u09a8",
  "JM": "\u099c\u09be\u09ae\u09be\u0987\u0995\u09be",
  "ZM": "\u099c\u09be\u09ae\u09cd\u09ac\u09bf\u09af\u09bc\u09be",
  "DE": "\u099c\u09be\u09b0\u09cd\u09ae\u09be\u09a8\u09bf",
  "JE": "\u099c\u09be\u09b0\u09cd\u09b8\u09bf",
  "DJ": "\u099c\u09bf\u09ac\u09c1\u09a4\u09bf",
  "GI": "\u099c\u09bf\u09ac\u09cd\u09b0\u09be\u09b2\u09cd\u099f\u09be\u09b0",
  "ZW": "\u099c\u09bf\u09ae\u09cd\u09ac\u09be\u09ac\u09cb\u09af\u09bc\u09c7",
  "TV": "\u099f\u09c1\u09ad\u09be\u09b2\u09c1",
  "TK": "\u099f\u09cb\u0995\u09c7\u09b2\u09be\u0989",
  "TG": "\u099f\u09cb\u0997\u09cb",
  "TO": "\u099f\u09cb\u0999\u09cd\u0997\u09be",
  "DK": "\u09a1\u09c7\u09a8\u09ae\u09be\u09b0\u09cd\u0995",
  "DM": "\u09a1\u09cb\u09ae\u09bf\u09a8\u09bf\u0995\u09be",
  "DO": "\u09a1\u09cb\u09ae\u09c7\u09a8\u09bf\u0995\u09be\u09a8 \u09aa\u09cd\u09b0\u099c\u09be\u09a4\u09a8\u09cd\u09a4\u09cd\u09b0",
  "TW": "\u09a4\u09be\u0987\u0993\u09af\u09bc\u09be\u09a8",
  "TJ": "\u09a4\u09be\u099c\u09bf\u0995\u09bf\u09b8\u09cd\u09a4\u09be\u09a8",
  "TZ": "\u09a4\u09be\u099e\u09cd\u099c\u09be\u09a8\u09bf\u09af\u09bc\u09be",
  "TN": "\u09a4\u09bf\u0989\u09a8\u09bf\u09b8\u09bf\u09af\u09bc\u09be",
  "TL": "\u09a4\u09bf\u09ae\u09c1\u09b0-\u09b2\u09c7\u09b8\u09cd\u09a4\u09c7",
  "TR": "\u09a4\u09c1\u09b0\u09b8\u09cd\u0995",
  "TM": "\u09a4\u09c1\u09b0\u09cd\u0995\u09ae\u09c7\u09a8\u09bf\u09b8\u09cd\u09a4\u09be\u09a8",
  "TC": "\u09a4\u09c1\u09b0\u09cd\u0995\u09b8 \u0993 \u0995\u09be\u0987\u0995\u09cb\u09b8 \u09a6\u09cd\u09ac\u09c0\u09aa\u09aa\u09c1\u099e\u09cd\u099c",
  "TT": "\u09a4\u09cd\u09b0\u09bf\u09a8\u09bf\u09a8\u09be\u09a6 \u0993 \u099f\u09cb\u09ac\u09cd\u09af\u09be\u0997\u09cb",
  "TH": "\u09a5\u09be\u0987\u09b2\u09cd\u09af\u09be\u09a8\u09cd\u09a1",
  "ZA": "\u09a6\u0995\u09cd\u09b7\u09bf\u09a3 \u0986\u09ab\u09cd\u09b0\u09bf\u0995\u09be",
  "KR": "\u09a6\u0995\u09cd\u09b7\u09bf\u09a3 \u0995\u09cb\u09b0\u09bf\u09af\u09bc\u09be",
  "GS": "\u09a6\u0995\u09cd\u09b7\u09bf\u09a3 \u099c\u09b0\u09cd\u099c\u09bf\u09af\u09bc\u09be \u0993 \u09a6\u0995\u09cd\u09b7\u09bf\u09a3 \u09b8\u09cd\u09af\u09be\u09a8\u09cd\u09a1\u0989\u0987\u099a \u09a6\u09cd\u09ac\u09c0\u09aa\u09aa\u09c1\u099e\u09cd\u099c",
  "SS": "\u09a6\u0995\u09cd\u09b7\u09bf\u09a3 \u09b8\u09c1\u09a6\u09be\u09a8",
  "NO": "\u09a8\u09b0\u0993\u09af\u09bc\u09c7",
  "NF": "\u09a8\u09b0\u09ab\u09cb\u0995 \u09a6\u09cd\u09ac\u09c0\u09aa",
  "NE": "\u09a8\u09be\u0987\u099c\u09be\u09b0",
  "NG": "\u09a8\u09be\u0987\u099c\u09c7\u09b0\u09bf\u09af\u09bc\u09be",
  "NR": "\u09a8\u09be\u0989\u09b0\u09c1",
  "NA": "\u09a8\u09be\u09ae\u09bf\u09ac\u09bf\u09af\u09bc\u09be",
  "NC": "\u09a8\u09bf\u0989 \u0995\u09cd\u09af\u09be\u09b2\u09c7\u09a1\u09cb\u09a8\u09bf\u09af\u09bc\u09be",
  "NZ": "\u09a8\u09bf\u0989\u099c\u09bf\u09b2\u09cd\u09af\u09be\u09a8\u09cd\u09a1",
  "NU": "\u09a8\u09bf\u0989\u09af\u09bc\u09c7",
  "NI": "\u09a8\u09bf\u0995\u09be\u09b0\u09be\u0997\u09c1\u09af\u09bc\u09be",
  "GQ": "\u09a8\u09bf\u09b0\u0995\u09cd\u09b7\u09c0\u09af\u09bc \u0997\u09bf\u09a8\u09bf",
  "NL": "\u09a8\u09c7\u09a6\u09be\u09b0\u09b2\u09cd\u09af\u09be\u09a8\u09cd\u09a1\u09b8",
  "NP": "\u09a8\u09c7\u09aa\u09be\u09b2",
  "PT": "\u09aa\u09b0\u09cd\u09a4\u09c1\u0997\u09be\u09b2",
  "EH": "\u09aa\u09b6\u09cd\u099a\u09bf\u09ae \u09b8\u09be\u09b9\u09be\u09b0\u09be",
  "PK": "\u09aa\u09be\u0995\u09bf\u09b8\u09cd\u09a4\u09be\u09a8",
  "PA": "\u09aa\u09be\u09a8\u09be\u09ae\u09be",
  "PG": "\u09aa\u09be\u09aa\u09c1\u09af\u09bc\u09be \u09a8\u09bf\u0989 \u0997\u09bf\u09a8\u09bf",
  "PW": "\u09aa\u09be\u09b2\u09be\u0989",
  "PN": "\u09aa\u09bf\u099f\u0995\u09c7\u09af\u09bc\u09be\u09b0\u09cd\u09a8 \u09a6\u09cd\u09ac\u09c0\u09aa\u09aa\u09c1\u099e\u09cd\u099c",
  "PR": "\u09aa\u09c1\u09af\u09bc\u09c7\u09b0\u09cd\u09a4\u09cb \u09b0\u09bf\u0995\u09cb",
  "PE": "\u09aa\u09c7\u09b0\u09c1",
  "PL": "\u09aa\u09cb\u09b2\u09cd\u09af\u09be\u09a8\u09cd\u09a1",
  "PY": "\u09aa\u09cd\u09af\u09be\u09b0\u09be\u0997\u09c1\u09af\u09bc\u09c7",
  "PS": "\u09aa\u09cd\u09af\u09be\u09b2\u09c7\u09b8\u09cd\u099f\u09be\u0987\u09a8\u09c7\u09b0 \u0985\u099e\u09cd\u099a\u09b2\u09b8\u09ae\u09c2\u09b9",
  "FK": "\u09ab\u0995\u09b2\u09cd\u09af\u09be\u09a8\u09cd\u09a1 \u09a6\u09cd\u09ac\u09c0\u09aa\u09aa\u09c1\u099e\u09cd\u099c",
  "GF": "\u09ab\u09b0\u09be\u09b8\u09c0 \u0997\u09be\u09af\u09bc\u09be\u09a8\u09be",
  "TF": "\u09ab\u09b0\u09be\u09b8\u09c0 \u09a6\u0995\u09cd\u09b7\u09bf\u09a3\u09be\u099e\u09cd\u099a\u09b2",
  "PF": "\u09ab\u09b0\u09be\u09b8\u09c0 \u09aa\u09b2\u09bf\u09a8\u09c7\u09b6\u09bf\u09af\u09bc\u09be",
  "FJ": "\u09ab\u09bf\u099c\u09bf",
  "FI": "\u09ab\u09bf\u09a8\u09b2\u09cd\u09af\u09be\u09a8\u09cd\u09a1",
  "PH": "\u09ab\u09bf\u09b2\u09bf\u09aa\u09be\u0987\u09a8",
  "FO": "\u09ab\u09cd\u09af\u09be\u09b0\u0993 \u09a6\u09cd\u09ac\u09c0\u09aa\u09aa\u09c1\u099e\u09cd\u099c",
  "FR": "\u09ab\u09cd\u09b0\u09be\u09a8\u09cd\u09b8",
  "BW": "\u09ac\u09a4\u09b8\u09cb\u09af\u09bc\u09be\u09a8\u09be",
  "BO": "\u09ac\u09b2\u09bf\u09ad\u09bf\u09af\u09bc\u09be",
  "BA": "\u09ac\u09b8\u09a8\u09bf\u09af\u09bc\u09be \u0993 \u09b9\u09be\u09b0\u09cd\u099c\u09c7\u0997\u09cb\u09ad\u09bf\u09a8\u09be",
  "BD": "\u09ac\u09be\u0982\u09b2\u09be\u09a6\u09c7\u09b6",
  "BB": "\u09ac\u09be\u09b0\u09ac\u09be\u09a6\u09cb\u09b8",
  "BM": "\u09ac\u09be\u09b0\u09ae\u09c1\u09a1\u09be",
  "BH": "\u09ac\u09be\u09b9\u09b0\u09be\u0987\u09a8",
  "BS": "\u09ac\u09be\u09b9\u09be\u09ae\u09be \u09a6\u09cd\u09ac\u09c0\u09aa\u09aa\u09c1\u099e\u09cd\u099c",
  "BF": "\u09ac\u09c1\u09b0\u0995\u09bf\u09a8\u09be \u09ab\u09be\u09b8\u09cb",
  "BI": "\u09ac\u09c1\u09b0\u09c1\u09a8\u09cd\u09a1\u09bf",
  "BG": "\u09ac\u09c1\u09b2\u0997\u09c7\u09b0\u09bf\u09af\u09bc\u09be",
  "BJ": "\u09ac\u09c7\u09a8\u09bf\u09a8",
  "BE": "\u09ac\u09c7\u09b2\u099c\u09bf\u09af\u09bc\u09be\u09ae",
  "BY": "\u09ac\u09c7\u09b2\u09be\u09b0\u09c1\u09b6",
  "BZ": "\u09ac\u09c7\u09b2\u09bf\u099c",
  "BV": "\u09ac\u09cb\u09ad\u09c7\u099f \u09a6\u09cd\u09ac\u09c0\u09aa",
  "BR": "\u09ac\u09cd\u09b0\u09be\u099c\u09bf\u09b2",
  "IO": "\u09ac\u09cd\u09b0\u09bf\u099f\u09bf\u09b6 \u09ad\u09be\u09b0\u09a4 \u09ae\u09b9\u09be\u09b8\u09be\u0997\u09b0\u09c0\u09af\u09bc \u0985\u099e\u09cd\u099a\u09b2",
  "VG": "\u09ac\u09cd\u09b0\u09bf\u099f\u09bf\u09b6 \u09ad\u09be\u09b0\u09cd\u099c\u09bf\u09a8 \u09a6\u09cd\u09ac\u09c0\u09aa\u09aa\u09c1\u099e\u09cd\u099c",
  "BN": "\u09ac\u09cd\u09b0\u09c1\u09a8\u09c7\u0987",
  "VU": "\u09ad\u09be\u09a8\u09c1\u09af\u09bc\u09be\u099f\u09c1",
  "IN": "\u09ad\u09be\u09b0\u09a4",
  "VN": "\u09ad\u09bf\u09af\u09bc\u09c7\u09a4\u09a8\u09be\u09ae",
  "BT": "\u09ad\u09c1\u099f\u09be\u09a8",
  "VE": "\u09ad\u09c7\u09a8\u09c7\u099c\u09c1\u09af\u09bc\u09c7\u09b2\u09be",
  "VA": "\u09ad\u09cd\u09af\u09be\u099f\u09bf\u0995\u09be\u09a8 \u09b8\u09bf\u099f\u09bf",
  "MN": "\u09ae\u0999\u09cd\u0997\u09cb\u09b2\u09bf\u09af\u09bc\u09be",
  "CF": "\u09ae\u09a7\u09cd\u09af \u0986\u09ab\u09cd\u09b0\u09bf\u0995\u09be\u09b0 \u09aa\u09cd\u09b0\u099c\u09be\u09a4\u09a8\u09cd\u09a4\u09cd\u09b0",
  "MS": "\u09ae\u09a8\u09cd\u099f\u09b8\u09c7\u09b0\u09be\u099f",
  "ME": "\u09ae\u09a8\u09cd\u099f\u09bf\u09a8\u09bf\u0997\u09cd\u09b0\u09cb",
  "MR": "\u09ae\u09b0\u09bf\u09a4\u09be\u09a8\u09bf\u09af\u09bc\u09be",
  "MU": "\u09ae\u09b0\u09bf\u09b6\u09be\u09b8",
  "MD": "\u09ae\u09b2\u09a1\u09cb\u09ad\u09be",
  "FM": "\u09ae\u09be\u0987\u0995\u09cd\u09b0\u09cb\u09a8\u09c7\u09b6\u09bf\u09af\u09bc\u09be",
  "MG": "\u09ae\u09be\u09a6\u09be\u0997\u09be\u09b8\u09cd\u0995\u09be\u09b0",
  "MM": "\u09ae\u09be\u09af\u09bc\u09be\u09a8\u09ae\u09be\u09b0 (\u09ac\u09be\u09b0\u09cd\u09ae\u09be)",
  "YT": "\u09ae\u09be\u09af\u09bc\u09cb\u09a4\u09cd\u09a4\u09c7",
  "US": "\u09ae\u09be\u09b0\u09cd\u0995\u09bf\u09a8 \u09af\u09c1\u0995\u09cd\u09a4\u09b0\u09be\u09b7\u09cd\u099f\u09cd\u09b0",
  "VI": "\u09ae\u09be\u09b0\u09cd\u0995\u09bf\u09a8 \u09af\u09c1\u0995\u09cd\u09a4\u09b0\u09be\u09b7\u09cd\u099f\u09cd\u09b0\u09c7\u09b0 \u09ad\u09be\u09b0\u09cd\u099c\u09bf\u09a8 \u09a6\u09cd\u09ac\u09c0\u09aa\u09aa\u09c1\u099e\u09cd\u099c",
  "MQ": "\u09ae\u09be\u09b0\u09cd\u099f\u09bf\u09a8\u09bf\u0995",
  "MH": "\u09ae\u09be\u09b0\u09cd\u09b6\u09be\u09b2 \u09a6\u09cd\u09ac\u09c0\u09aa\u09aa\u09c1\u099e\u09cd\u099c",
  "MV": "\u09ae\u09be\u09b2\u09a6\u09cd\u09ac\u09c0\u09aa",
  "MY": "\u09ae\u09be\u09b2\u09af\u09bc\u09c7\u09b6\u09bf\u09af\u09bc\u09be",
  "MW": "\u09ae\u09be\u09b2\u09be\u0989\u0987",
  "ML": "\u09ae\u09be\u09b2\u09bf",
  "MT": "\u09ae\u09be\u09b2\u09cd\u099f\u09be",
  "EG": "\u09ae\u09bf\u09b6\u09b0",
  "MX": "\u09ae\u09c7\u0995\u09cd\u09b8\u09bf\u0995\u09cb",
  "MZ": "\u09ae\u09cb\u099c\u09be\u09ae\u09cd\u09ac\u09bf\u0995",
  "MC": "\u09ae\u09cb\u09a8\u09be\u0995\u09cb",
  "MA": "\u09ae\u09cb\u09b0\u0995\u09cd\u0995\u09cb",
  "MO": "\u09ae\u09cd\u09af\u09be\u0995\u09be\u0993 \u098f\u09b8\u098f\u0986\u09b0 \u099a\u09c0\u09a8\u09be",
  "GB": "\u09af\u09c1\u0995\u09cd\u09a4\u09b0\u09be\u099c\u09cd\u09af",
  "UM": "\u09af\u09c1\u0995\u09cd\u09a4\u09b0\u09be\u09b7\u09cd\u099f\u09cd\u09b0\u09c7\u09b0 \u09aa\u09be\u09b0\u09cd\u09b6\u09cd\u09ac\u09ac\u09b0\u09cd\u09a4\u09c0 \u09a6\u09cd\u09ac\u09c0\u09aa\u09aa\u09c1\u099e\u09cd\u099c",
  "RU": "\u09b0\u09be\u09b6\u09bf\u09af\u09bc\u09be",
  "RE": "\u09b0\u09bf\u0987\u0989\u09a8\u09bf\u09af\u09bc\u09a8",
  "RW": "\u09b0\u09c1\u09af\u09bc\u09be\u09a8\u09cd\u09a1\u09be",
  "RO": "\u09b0\u09cb\u09ae\u09be\u09a8\u09bf\u09af\u09bc\u09be",
  "LR": "\u09b2\u09be\u0987\u09ac\u09c7\u09b0\u09bf\u09af\u09bc\u09be",
  "LA": "\u09b2\u09be\u0993\u09b8",
  "LU": "\u09b2\u09be\u0995\u09cd\u09b8\u09c7\u09ae\u09ac\u09be\u09b0\u09cd\u0997",
  "LV": "\u09b2\u09be\u09a4\u09cd\u09ad\u09bf\u09af\u09bc\u09be",
  "LI": "\u09b2\u09bf\u099a\u09c7\u09a8\u09b8\u09cd\u099f\u09c7\u0987\u09a8",
  "LT": "\u09b2\u09bf\u09a5\u09c1\u09af\u09bc\u09be\u09a8\u09bf\u09af\u09bc\u09be",
  "LY": "\u09b2\u09bf\u09ac\u09bf\u09af\u09bc\u09be",
  "LB": "\u09b2\u09c7\u09ac\u09be\u09a8\u09a8",
  "LS": "\u09b2\u09c7\u09b8\u09cb\u09a5\u09cb",
  "LK": "\u09b6\u09cd\u09b0\u09c0\u09b2\u0999\u09cd\u0995\u09be",
  "AE": "\u09b8\u0982\u09af\u09c1\u0995\u09cd\u09a4 \u0986\u09b0\u09ac \u0986\u09ae\u09bf\u09b0\u09be\u09a4",
  "SB": "\u09b8\u09b2\u09cb\u09ae\u09a8 \u09a6\u09cd\u09ac\u09c0\u09aa\u09aa\u09c1\u099e\u09cd\u099c",
  "CY": "\u09b8\u09be\u0987\u09aa\u09cd\u09b0\u09be\u09b8",
  "ST": "\u09b8\u09be\u0993\u099f\u09cb\u09ae\u09be \u0993 \u09aa\u09cd\u09b0\u09bf\u09a8\u09cd\u09b8\u09bf\u09aa\u09bf",
  "SM": "\u09b8\u09be\u09a8 \u09ae\u09be\u09b0\u09bf\u09a8\u09cb",
  "WS": "\u09b8\u09be\u09ae\u09cb\u09af\u09bc\u09be",
  "RS": "\u09b8\u09be\u09b0\u09cd\u09ac\u09bf\u09af\u09bc\u09be",
  "SG": "\u09b8\u09bf\u0999\u09cd\u0997\u09be\u09aa\u09c1\u09b0",
  "SX": "\u09b8\u09bf\u09a8\u09cd\u099f \u09ae\u09be\u09b0\u09cd\u099f\u09c7\u09a8",
  "SL": "\u09b8\u09bf\u09af\u09bc\u09c7\u09b0\u09be \u09b2\u09bf\u0993\u09a8",
  "SY": "\u09b8\u09bf\u09b0\u09bf\u09af\u09bc\u09be",
  "SC": "\u09b8\u09bf\u09b8\u09bf\u09b2\u09bf",
  "CH": "\u09b8\u09c1\u0987\u099c\u09be\u09b0\u09b2\u09cd\u09af\u09be\u09a8\u09cd\u09a1",
  "SE": "\u09b8\u09c1\u0987\u09a1\u09c7\u09a8",
  "SD": "\u09b8\u09c1\u09a6\u09be\u09a8",
  "SR": "\u09b8\u09c1\u09b0\u09bf\u09a8\u09be\u09ae",
  "SN": "\u09b8\u09c7\u09a8\u09c7\u0997\u09be\u09b2",
  "KN": "\u09b8\u09c7\u09a8\u09cd\u099f \u0995\u09bf\u099f\u09b8 \u0993 \u09a8\u09c7\u09ad\u09bf\u09b8",
  "PM": "\u09b8\u09c7\u09a8\u09cd\u099f \u09aa\u09bf\u09af\u09bc\u09c7\u09b0 \u0993 \u09ae\u09bf\u0995\u09c1\u09af\u09bc\u09c7\u09b2\u09a8",
  "BL": "\u09b8\u09c7\u09a8\u09cd\u099f \u09ac\u09be\u09b0\u09a5\u09c7\u09b2\u09bf\u09ae\u09bf",
  "VC": "\u09b8\u09c7\u09a8\u09cd\u099f \u09ad\u09bf\u09a8\u09b8\u09c7\u09a8\u09cd\u099f \u0993 \u0997\u09cd\u09b0\u09c7\u09a8\u09be\u09a1\u09bf\u09a8\u09b8",
  "MF": "\u09b8\u09c7\u09a8\u09cd\u099f \u09ae\u09be\u09b0\u09cd\u099f\u09bf\u09a8",
  "LC": "\u09b8\u09c7\u09a8\u09cd\u099f \u09b2\u09c1\u09b8\u09bf\u09af\u09bc\u09be",
  "SH": "\u09b8\u09c7\u09a8\u09cd\u099f \u09b9\u09c7\u09b2\u09c7\u09a8\u09be",
  "SO": "\u09b8\u09cb\u09ae\u09be\u09b2\u09bf\u09af\u09bc\u09be",
  "SA": "\u09b8\u09cc\u09a6\u09bf \u0986\u09b0\u09ac",
  "ES": "\u09b8\u09cd\u09aa\u09c7\u09a8",
  "SJ": "\u09b8\u09cd\u09ac\u09be\u09b2\u09ac\u09be\u09b0\u09cd\u09a1 \u0993 \u099c\u09be\u09a8 \u09ae\u09c7\u09af\u09bc\u09c7\u09a8",
  "SK": "\u09b8\u09cd\u09b2\u09cb\u09ad\u09be\u0995\u09bf\u09af\u09bc\u09be",
  "SI": "\u09b8\u09cd\u09b2\u09cb\u09ad\u09be\u09a8\u09bf\u09af\u09bc\u09be",
  "HK": "\u09b9\u0982\u0995\u0982 \u098f\u09b8\u098f\u0986\u09b0 \u099a\u09c0\u09a8\u09be",
  "HN": "\u09b9\u09a8\u09cd\u09a1\u09c1\u09b0\u09be\u09b8",
  "HT": "\u09b9\u09be\u0987\u09a4\u09bf",
  "HU": "\u09b9\u09be\u0999\u09cd\u0997\u09c7\u09b0\u09bf",
  "HM": "\u09b9\u09be\u09b0\u09cd\u09a1 \u098f\u09ac\u0982 \u09ae\u09cd\u09af\u09be\u0995\u09a1\u09cb\u09a8\u09be\u09b2\u09cd\u09a1 \u09a6\u09cd\u09ac\u09c0\u09aa\u09aa\u09c1\u099e\u09cd\u099c"
}



================================================
FILE: public/intl/country/bs-BA.json
================================================
{
  "AF": "Afganistan",
  "AL": "Albanija",
  "DZ": "Al\u017eir",
  "VI": "Ameri\u010dka Djevi\u010danska ostrva",
  "AS": "Ameri\u010dka Samoa",
  "UM": "Ameri\u010dka Vanjska Ostrva",
  "AD": "Andora",
  "AO": "Angola",
  "AI": "Angvila",
  "AQ": "Antarktika",
  "AG": "Antigva i Barbuda",
  "AR": "Argentina",
  "AM": "Armenija",
  "AW": "Aruba",
  "AU": "Australija",
  "AT": "Austrija",
  "AZ": "Azerbejd\u017ean",
  "BS": "Bahami",
  "BH": "Bahrein",
  "BD": "Banglade\u0161",
  "BB": "Barbados",
  "BE": "Belgija",
  "BZ": "Belize",
  "BJ": "Benin",
  "BM": "Bermuda",
  "BY": "Bjelorusija",
  "BW": "Bocvana",
  "BO": "Bolivija",
  "BA": "Bosna i Hercegovina",
  "CX": "Bo\u017ei\u0107no ostrvo",
  "BR": "Brazil",
  "VG": "Britanska Djevi\u010danska ostrva",
  "IO": "Britanska Teritorija u Indijskom Okeanu",
  "BN": "Brunej",
  "BG": "Bugarska",
  "BF": "Burkina Faso",
  "BI": "Burundi",
  "BT": "Butan",
  "CF": "Centralnoafri\u010dka Republika",
  "ME": "Crna Gora",
  "TD": "\u010cad",
  "CZ": "\u010ce\u0161ka",
  "CL": "\u010cile",
  "DK": "Danska",
  "CD": "Demokratska Republika Kongo",
  "DM": "Dominika",
  "DO": "Dominikanska Republika",
  "DJ": "D\u017eibuti",
  "EG": "Egipat",
  "EC": "Ekvador",
  "GQ": "Ekvatorijalna Gvineja",
  "ER": "Eritreja",
  "EE": "Estonija",
  "SZ": "Esvatini",
  "ET": "Etiopija",
  "FO": "Farska ostrva",
  "FJ": "Fid\u017ei",
  "PH": "Filipini",
  "FI": "Finska",
  "FK": "Folklandska ostrva",
  "FR": "Francuska",
  "GF": "Francuska Gvajana",
  "PF": "Francuska Polinezija",
  "TF": "Francuske Ju\u017ene Teritorije",
  "GA": "Gabon",
  "GM": "Gambija",
  "GH": "Gana",
  "GG": "Gernzi",
  "GI": "Gibraltar",
  "GR": "Gr\u010dka",
  "GD": "Grenada",
  "GL": "Grenland",
  "GE": "Gruzija",
  "GU": "Guam",
  "GP": "Gvadalupe",
  "GY": "Gvajana",
  "GT": "Gvatemala",
  "GN": "Gvineja",
  "GW": "Gvineja-Bisao",
  "HT": "Haiti",
  "HM": "Herd i arhipelag MekDonald",
  "NL": "Holandija",
  "HN": "Honduras",
  "HK": "Hong Kong (SAR Kina)",
  "HR": "Hrvatska",
  "IN": "Indija",
  "ID": "Indonezija",
  "IQ": "Irak",
  "IR": "Iran",
  "IE": "Irska",
  "IS": "Island",
  "TL": "Isto\u010dni Timor",
  "IT": "Italija",
  "IL": "Izrael",
  "JM": "Jamajka",
  "JP": "Japan",
  "YE": "Jemen",
  "JE": "Jersey",
  "JO": "Jordan",
  "GS": "Ju\u017ena D\u017eord\u017eija i Ju\u017ena Sendvi\u010d ostrva",
  "KR": "Ju\u017ena Koreja",
  "SS": "Ju\u017eni Sudan",
  "ZA": "Ju\u017enoafri\u010dka Republika",
  "KY": "Kajmanska ostrva",
  "KH": "Kambod\u017ea",
  "CM": "Kamerun",
  "CA": "Kanada",
  "CV": "Kape Verde",
  "BQ": "Karipska Holandija",
  "QA": "Katar",
  "KZ": "Kazahstan",
  "KE": "Kenija",
  "CN": "Kina",
  "CY": "Kipar",
  "KG": "Kirgistan",
  "KI": "Kiribati",
  "CC": "Kokosova (Keelingova) ostrva",
  "CO": "Kolumbija",
  "KM": "Komori",
  "CG": "Kongo",
  "XK": "Kosovo",
  "CR": "Kostarika",
  "CU": "Kuba",
  "CK": "Kukova ostrva",
  "CW": "Kurasao",
  "KW": "Kuvajt",
  "LA": "Laos",
  "LV": "Latvija",
  "LS": "Lesoto",
  "LB": "Liban",
  "LR": "Liberija",
  "LY": "Libija",
  "LI": "Lihten\u0161tajn",
  "LT": "Litvanija",
  "LU": "Luksemburg",
  "MG": "Madagaskar",
  "HU": "Ma\u0111arska",
  "YT": "Majote",
  "MO": "Makao (SAR Kina)",
  "MW": "Malavi",
  "MV": "Maldivi",
  "MY": "Malezija",
  "ML": "Mali",
  "MT": "Malta",
  "MA": "Maroko",
  "MH": "Mar\u0161alova ostrva",
  "MQ": "Martinik",
  "MU": "Mauricijus",
  "MR": "Mauritanija",
  "MX": "Meksiko",
  "FM": "Mikronezija",
  "MM": "Mjanmar",
  "MD": "Moldavija",
  "MC": "Monako",
  "MN": "Mongolija",
  "MS": "Monserat",
  "MZ": "Mozambik",
  "NA": "Namibija",
  "NR": "Nauru",
  "NP": "Nepal",
  "NE": "Niger",
  "NG": "Nigerija",
  "NI": "Nikaragva",
  "NU": "Niue",
  "NO": "Norve\u0161ka",
  "NC": "Nova Kaledonija",
  "NZ": "Novi Zeland",
  "DE": "Njema\u010dka",
  "CI": "Obala Slonova\u010de",
  "AX": "Olandska ostrva",
  "OM": "Oman",
  "TC": "Ostrva Turks i Kaikos",
  "WF": "Ostrva Valis i Futuna",
  "BV": "Ostrvo Buve",
  "IM": "Ostrvo Man",
  "NF": "Ostrvo Norfolk",
  "PK": "Pakistan",
  "PW": "Palau",
  "PS": "Palestinska Teritorija",
  "PA": "Panama",
  "PG": "Papua Nova Gvineja",
  "PY": "Paragvaj",
  "PE": "Peru",
  "PN": "Pitkernska Ostrva",
  "PL": "Poljska",
  "PR": "Porto Riko",
  "PT": "Portugal",
  "RE": "Reunion",
  "RW": "Ruanda",
  "RO": "Rumunija",
  "RU": "Rusija",
  "SV": "Salvador",
  "WS": "Samoa",
  "SM": "San Marino",
  "ST": "Sao Tome i Principe",
  "SA": "Saudijska Arabija",
  "SC": "Sej\u0161eli",
  "SN": "Senegal",
  "SL": "Sijera Leone",
  "SG": "Singapur",
  "SX": "Sint Marten",
  "SY": "Sirija",
  "US": "Sjedinjene Dr\u017eave",
  "KP": "Sjeverna Koreja",
  "MK": "Sjeverna Makedonija",
  "MP": "Sjeverna Marijanska ostrva",
  "SK": "Slova\u010dka",
  "SI": "Slovenija",
  "SB": "Solomonska Ostrva",
  "SO": "Somalija",
  "RS": "Srbija",
  "SD": "Sudan",
  "SR": "Surinam",
  "SJ": "Svalbard i Jan Majen",
  "SH": "Sveta Helena",
  "LC": "Sveta Lucija",
  "BL": "Sveti Bartolomej",
  "KN": "Sveti Kits i Nevis",
  "MF": "Sveti Martin",
  "PM": "Sveti Petar i Mikelon",
  "VC": "Sveti Vinsent i Grenadin",
  "ES": "\u0160panija",
  "LK": "\u0160ri Lanka",
  "SE": "\u0160vedska",
  "CH": "\u0160vicarska",
  "TJ": "Tad\u017eikistan",
  "TH": "Tajland",
  "TW": "Tajvan",
  "TZ": "Tanzanija",
  "TG": "Togo",
  "TK": "Tokelau",
  "TO": "Tonga",
  "TT": "Trinidad i Tobago",
  "TN": "Tunis",
  "TM": "Turkmenistan",
  "TR": "Turska",
  "TV": "Tuvalu",
  "UG": "Uganda",
  "AE": "Ujedinjeni Arapski Emirati",
  "GB": "Ujedinjeno Kraljevstvo",
  "UA": "Ukrajina",
  "UY": "Urugvaj",
  "UZ": "Uzbekistan",
  "VU": "Vanuatu",
  "VA": "Vatikan",
  "VE": "Venecuela",
  "VN": "Vijetnam",
  "ZM": "Zambija",
  "EH": "Zapadna Sahara",
  "ZW": "Zimbabve"
}



================================================
FILE: public/intl/country/ca-ES.json
================================================
{
  "AF": "Afganistan",
  "AL": "Alb\u00e0nia",
  "DE": "Alemanya",
  "DZ": "Alg\u00e8ria",
  "AD": "Andorra",
  "AO": "Angola",
  "AI": "Anguilla",
  "AQ": "Ant\u00e0rtida",
  "AG": "Antigua i Barbuda",
  "SA": "Ar\u00e0bia Saudita",
  "AR": "Argentina",
  "AM": "Arm\u00e8nia",
  "AW": "Aruba",
  "AU": "Austr\u00e0lia",
  "AT": "\u00c0ustria",
  "AZ": "Azerbaidjan",
  "BS": "Bahames",
  "BH": "Bahrain",
  "BD": "Bangladesh",
  "BB": "Barbados",
  "BY": "Belar\u00fas",
  "BE": "B\u00e8lgica",
  "BZ": "Belize",
  "BJ": "Ben\u00edn",
  "BM": "Bermudes",
  "BT": "Bhutan",
  "BO": "Bol\u00edvia",
  "BA": "B\u00f2snia i Hercegovina",
  "BW": "Botswana",
  "BV": "Bouvet",
  "BR": "Brasil",
  "BN": "Brunei",
  "BG": "Bulg\u00e0ria",
  "BF": "Burkina Faso",
  "BI": "Burundi",
  "KH": "Cambodja",
  "CM": "Camerun",
  "CA": "Canad\u00e0",
  "CV": "Cap Verd",
  "BQ": "Carib Neerland\u00e8s",
  "VA": "Ciutat del Vatic\u00e0",
  "CO": "Col\u00f2mbia",
  "KM": "Comores",
  "CG": "Congo - Brazzaville",
  "CD": "Congo - Kinshasa",
  "KP": "Corea del Nord",
  "KR": "Corea del Sud",
  "CR": "Costa Rica",
  "CI": "C\u00f4te d\u2019Ivoire",
  "HR": "Cro\u00e0cia",
  "CU": "Cuba",
  "CW": "Cura\u00e7ao",
  "DK": "Dinamarca",
  "DJ": "Djibouti",
  "DM": "Dominica",
  "EG": "Egipte",
  "SV": "El Salvador",
  "AE": "Emirats \u00c0rabs Units",
  "EC": "Equador",
  "ER": "Eritrea",
  "SK": "Eslov\u00e0quia",
  "SI": "Eslov\u00e8nia",
  "ES": "Espanya",
  "US": "Estats Units",
  "EE": "Est\u00f2nia",
  "SZ": "eSwatini",
  "ET": "Eti\u00f2pia",
  "FJ": "Fiji",
  "PH": "Filipines",
  "FI": "Finl\u00e0ndia",
  "FR": "Fran\u00e7a",
  "GA": "Gabon",
  "GM": "G\u00e0mbia",
  "GE": "Ge\u00f2rgia",
  "GH": "Ghana",
  "GI": "Gibraltar",
  "GR": "Gr\u00e8cia",
  "GD": "Grenada",
  "GL": "Groenl\u00e0ndia",
  "GP": "Guadeloupe",
  "GF": "Guaiana Francesa",
  "GU": "Guam",
  "GT": "Guatemala",
  "GG": "Guernsey",
  "GN": "Guinea",
  "GW": "Guinea Bissau",
  "GQ": "Guinea Equatorial",
  "GY": "Guyana",
  "HT": "Hait\u00ed",
  "HN": "Hondures",
  "HK": "Hong Kong (RAE Xina)",
  "HU": "Hongria",
  "YE": "Iemen",
  "CX": "Illa Christmas",
  "RE": "Illa de la Reuni\u00f3",
  "IM": "Illa de Man",
  "HM": "Illa Heard i Illes McDonald",
  "AX": "Illes \u00c5land",
  "KY": "Illes Caiman",
  "CC": "Illes Cocos",
  "CK": "Illes Cook",
  "FO": "Illes F\u00e8roe",
  "GS": "Illes Ge\u00f2rgia del Sud i Sandwich del Sud",
  "FK": "Illes Malvines",
  "MP": "Illes Mariannes del Nord",
  "MH": "Illes Marshall",
  "UM": "Illes Perif\u00e8riques Menors dels EUA",
  "PN": "Illes Pitcairn",
  "SB": "Illes Salom\u00f3",
  "TC": "Illes Turks i Caicos",
  "VG": "Illes Verges Brit\u00e0niques",
  "VI": "Illes Verges Nord-americanes",
  "IN": "\u00cdndia",
  "ID": "Indon\u00e8sia",
  "IR": "Iran",
  "IQ": "Iraq",
  "IE": "Irlanda",
  "IS": "Isl\u00e0ndia",
  "IL": "Israel",
  "IT": "It\u00e0lia",
  "JM": "Jamaica",
  "JP": "Jap\u00f3",
  "JE": "Jersey",
  "JO": "Jord\u00e0nia",
  "KZ": "Kazakhstan",
  "KE": "Kenya",
  "KG": "Kirguizistan",
  "KI": "Kiribati",
  "XK": "Kosovo",
  "KW": "Kuwait",
  "LA": "Laos",
  "LS": "Lesotho",
  "LV": "Let\u00f2nia",
  "LB": "L\u00edban",
  "LR": "Lib\u00e8ria",
  "LY": "L\u00edbia",
  "LI": "Liechtenstein",
  "LT": "Litu\u00e0nia",
  "LU": "Luxemburg",
  "MO": "Macau (RAE Xina)",
  "MK": "Maced\u00f2nia del Nord",
  "MG": "Madagascar",
  "MY": "Mal\u00e0isia",
  "MW": "Malawi",
  "MV": "Maldives",
  "ML": "Mali",
  "MT": "Malta",
  "MA": "Marroc",
  "MQ": "Martinica",
  "MU": "Maurici",
  "MR": "Maurit\u00e0nia",
  "YT": "Mayotte",
  "MX": "M\u00e8xic",
  "FM": "Micron\u00e8sia",
  "MZ": "Mo\u00e7ambic",
  "MD": "Mold\u00e0via",
  "MC": "M\u00f2naco",
  "MN": "Mong\u00f2lia",
  "ME": "Montenegro",
  "MS": "Montserrat",
  "MM": "Myanmar (Birm\u00e0nia)",
  "NA": "Nam\u00edbia",
  "NR": "Nauru",
  "NP": "Nepal",
  "NI": "Nicaragua",
  "NE": "N\u00edger",
  "NG": "Nig\u00e8ria",
  "NU": "Niue",
  "NF": "Norfolk",
  "NO": "Noruega",
  "NC": "Nova Caled\u00f2nia",
  "NZ": "Nova Zelanda",
  "OM": "Oman",
  "NL": "Pa\u00efsos Baixos",
  "PK": "Pakistan",
  "PW": "Palau",
  "PA": "Panam\u00e0",
  "PG": "Papua Nova Guinea",
  "PY": "Paraguai",
  "PE": "Per\u00fa",
  "PF": "Polin\u00e8sia Francesa",
  "PL": "Pol\u00f2nia",
  "PT": "Portugal",
  "PR": "Puerto Rico",
  "QA": "Qatar",
  "GB": "Regne Unit",
  "CF": "Rep\u00fablica Centreafricana",
  "ZA": "Rep\u00fablica de Sud-\u00e0frica",
  "DO": "Rep\u00fablica Dominicana",
  "RO": "Romania",
  "RW": "Ruanda",
  "RU": "R\u00fassia",
  "EH": "S\u00e0hara Occidental",
  "BL": "Saint Barth\u00e9lemy",
  "KN": "Saint Christopher i Nevis",
  "SH": "Saint Helena",
  "LC": "Saint Lucia",
  "MF": "Saint Martin",
  "VC": "Saint Vincent i les Grenadines",
  "PM": "Saint-Pierre-et-Miquelon",
  "WS": "Samoa",
  "AS": "Samoa Nord-americana",
  "SM": "San Marino",
  "ST": "S\u00e3o Tom\u00e9 i Pr\u00edncipe",
  "SN": "Senegal",
  "RS": "S\u00e8rbia",
  "SC": "Seychelles",
  "SL": "Sierra Leone",
  "SG": "Singapur",
  "SX": "Sint Maarten",
  "SY": "S\u00edria",
  "SO": "Som\u00e0lia",
  "LK": "Sri Lanka",
  "SD": "Sudan",
  "SS": "Sudan del Sud",
  "SE": "Su\u00e8cia",
  "CH": "Su\u00efssa",
  "SR": "Surinam",
  "SJ": "Svalbard i Jan Mayen",
  "TJ": "Tadjikistan",
  "TH": "Tail\u00e0ndia",
  "TW": "Taiwan",
  "TZ": "Tanz\u00e0nia",
  "IO": "Territori Brit\u00e0nic de l\u2019Oce\u00e0 \u00cdndic",
  "TF": "Territoris Australs Francesos",
  "PS": "Territoris palestins",
  "TL": "Timor Oriental",
  "TG": "Togo",
  "TK": "Tokelau",
  "TO": "Tonga",
  "TT": "Trinitat i Tobago",
  "TN": "Tun\u00edsia",
  "TM": "Turkmenistan",
  "TR": "Turquia",
  "TV": "Tuvalu",
  "TD": "Txad",
  "CZ": "Tx\u00e8quia",
  "UA": "Ucra\u00efna",
  "UG": "Uganda",
  "UY": "Uruguai",
  "UZ": "Uzbekistan",
  "VU": "Vanuatu",
  "VE": "Vene\u00e7uela",
  "VN": "Vietnam",
  "WF": "Wallis i Futuna",
  "CL": "Xile",
  "CN": "Xina",
  "CY": "Xipre",
  "ZM": "Z\u00e0mbia",
  "ZW": "Zimb\u00e0bue"
}



================================================
FILE: public/intl/country/cs-CZ.json
================================================
{
  "AF": "Afgh\u00e1nist\u00e1n",
  "AX": "\u00c5landy",
  "AL": "Alb\u00e1nie",
  "DZ": "Al\u017e\u00edrsko",
  "AS": "Americk\u00e1 Samoa",
  "VI": "Americk\u00e9 Panensk\u00e9 ostrovy",
  "AD": "Andorra",
  "AO": "Angola",
  "AI": "Anguilla",
  "AQ": "Antarktida",
  "AG": "Antigua a Barbuda",
  "AR": "Argentina",
  "AM": "Arm\u00e9nie",
  "AW": "Aruba",
  "AU": "Austr\u00e1lie",
  "AZ": "\u00c1zerb\u00e1jd\u017e\u00e1n",
  "BS": "Bahamy",
  "BH": "Bahrajn",
  "BD": "Banglad\u00e9\u0161",
  "BB": "Barbados",
  "BE": "Belgie",
  "BZ": "Belize",
  "BY": "B\u011blorusko",
  "BJ": "Benin",
  "BM": "Bermudy",
  "BT": "Bh\u00fat\u00e1n",
  "BO": "Bol\u00edvie",
  "BA": "Bosna a Hercegovina",
  "BW": "Botswana",
  "BV": "Bouvet\u016fv ostrov",
  "BR": "Braz\u00edlie",
  "IO": "Britsk\u00e9 indickooce\u00e1nsk\u00e9 \u00fazem\u00ed",
  "VG": "Britsk\u00e9 Panensk\u00e9 ostrovy",
  "BN": "Brunej",
  "BG": "Bulharsko",
  "BF": "Burkina Faso",
  "BI": "Burundi",
  "CK": "Cookovy ostrovy",
  "CW": "Cura\u00e7ao",
  "TD": "\u010cad",
  "ME": "\u010cern\u00e1 Hora",
  "CZ": "\u010cesko",
  "CN": "\u010c\u00edna",
  "DK": "D\u00e1nsko",
  "DM": "Dominika",
  "DO": "Dominik\u00e1nsk\u00e1 republika",
  "DJ": "D\u017eibutsko",
  "EG": "Egypt",
  "EC": "Ekv\u00e1dor",
  "ER": "Eritrea",
  "EE": "Estonsko",
  "ET": "Etiopie",
  "FO": "Faersk\u00e9 ostrovy",
  "FK": "Falklandsk\u00e9 ostrovy",
  "FJ": "Fid\u017ei",
  "PH": "Filip\u00edny",
  "FI": "Finsko",
  "FR": "Francie",
  "GF": "Francouzsk\u00e1 Guyana",
  "TF": "Francouzsk\u00e1 ji\u017en\u00ed \u00fazem\u00ed",
  "PF": "Francouzsk\u00e1 Polyn\u00e9sie",
  "GA": "Gabon",
  "GM": "Gambie",
  "GH": "Ghana",
  "GI": "Gibraltar",
  "GD": "Grenada",
  "GL": "Gr\u00f3nsko",
  "GE": "Gruzie",
  "GP": "Guadeloupe",
  "GU": "Guam",
  "GT": "Guatemala",
  "GG": "Guernsey",
  "GN": "Guinea",
  "GW": "Guinea-Bissau",
  "GY": "Guyana",
  "HT": "Haiti",
  "HM": "Heard\u016fv ostrov a McDonaldovy ostrovy",
  "HN": "Honduras",
  "HK": "Hongkong \u2013 ZAO \u010c\u00edny",
  "CL": "Chile",
  "HR": "Chorvatsko",
  "IN": "Indie",
  "ID": "Indon\u00e9sie",
  "IQ": "Ir\u00e1k",
  "IR": "\u00cdr\u00e1n",
  "IE": "Irsko",
  "IS": "Island",
  "IT": "It\u00e1lie",
  "IL": "Izrael",
  "JM": "Jamajka",
  "JP": "Japonsko",
  "YE": "Jemen",
  "JE": "Jersey",
  "ZA": "Jihoafrick\u00e1 republika",
  "GS": "Ji\u017en\u00ed Georgie a Ji\u017en\u00ed Sandwichovy ostrovy",
  "KR": "Ji\u017en\u00ed Korea",
  "SS": "Ji\u017en\u00ed S\u00fad\u00e1n",
  "JO": "Jord\u00e1nsko",
  "KY": "Kajmansk\u00e9 ostrovy",
  "KH": "Kambod\u017ea",
  "CM": "Kamerun",
  "CA": "Kanada",
  "CV": "Kapverdy",
  "BQ": "Karibsk\u00e9 Nizozemsko",
  "QA": "Katar",
  "KZ": "Kazachst\u00e1n",
  "KE": "Ke\u0148a",
  "KI": "Kiribati",
  "CC": "Kokosov\u00e9 ostrovy",
  "CO": "Kolumbie",
  "KM": "Komory",
  "CG": "Kongo \u2013 Brazzaville",
  "CD": "Kongo \u2013 Kinshasa",
  "CR": "Kostarika",
  "XK": "Kosovo",
  "CU": "Kuba",
  "KW": "Kuvajt",
  "CY": "Kypr",
  "KG": "Kyrgyzst\u00e1n",
  "LA": "Laos",
  "LS": "Lesotho",
  "LB": "Libanon",
  "LR": "Lib\u00e9rie",
  "LY": "Libye",
  "LI": "Lichten\u0161tejnsko",
  "LT": "Litva",
  "LV": "Loty\u0161sko",
  "LU": "Lucembursko",
  "MO": "Macao \u2013 ZAO \u010c\u00edny",
  "MG": "Madagaskar",
  "HU": "Ma\u010farsko",
  "MY": "Malajsie",
  "MW": "Malawi",
  "MV": "Maledivy",
  "ML": "Mali",
  "MT": "Malta",
  "MA": "Maroko",
  "MH": "Marshallovy ostrovy",
  "MQ": "Martinik",
  "MU": "Mauricius",
  "MR": "Maurit\u00e1nie",
  "YT": "Mayotte",
  "UM": "Men\u0161\u00ed odlehl\u00e9 ostrovy USA",
  "MX": "Mexiko",
  "FM": "Mikron\u00e9sie",
  "MD": "Moldavsko",
  "MC": "Monako",
  "MN": "Mongolsko",
  "MS": "Montserrat",
  "MZ": "Mosambik",
  "MM": "Myanmar (Barma)",
  "NA": "Namibie",
  "NR": "Nauru",
  "DE": "N\u011bmecko",
  "NP": "Nep\u00e1l",
  "NE": "Niger",
  "NG": "Nig\u00e9rie",
  "NI": "Nikaragua",
  "NU": "Niue",
  "NL": "Nizozemsko",
  "NF": "Norfolk",
  "NO": "Norsko",
  "NC": "Nov\u00e1 Kaledonie",
  "NZ": "Nov\u00fd Z\u00e9land",
  "OM": "Om\u00e1n",
  "IM": "Ostrov Man",
  "PK": "P\u00e1kist\u00e1n",
  "PW": "Palau",
  "PS": "Palestinsk\u00e1 \u00fazem\u00ed",
  "PA": "Panama",
  "PG": "Papua-Nov\u00e1 Guinea",
  "PY": "Paraguay",
  "PE": "Peru",
  "PN": "Pitcairnovy ostrovy",
  "CI": "Pob\u0159e\u017e\u00ed slonoviny",
  "PL": "Polsko",
  "PR": "Portoriko",
  "PT": "Portugalsko",
  "AT": "Rakousko",
  "RE": "R\u00e9union",
  "GQ": "Rovn\u00edkov\u00e1 Guinea",
  "RO": "Rumunsko",
  "RU": "Rusko",
  "RW": "Rwanda",
  "GR": "\u0158ecko",
  "PM": "Saint-Pierre a Miquelon",
  "SV": "Salvador",
  "WS": "Samoa",
  "SM": "San Marino",
  "SA": "Sa\u00fadsk\u00e1 Ar\u00e1bie",
  "SN": "Senegal",
  "KP": "Severn\u00ed Korea",
  "MK": "Severn\u00ed Makedonie",
  "MP": "Severn\u00ed Mariany",
  "SC": "Seychely",
  "SL": "Sierra Leone",
  "SG": "Singapur",
  "SK": "Slovensko",
  "SI": "Slovinsko",
  "SO": "Som\u00e1lsko",
  "AE": "Spojen\u00e9 arabsk\u00e9 emir\u00e1ty",
  "GB": "Spojen\u00e9 kr\u00e1lovstv\u00ed",
  "US": "Spojen\u00e9 st\u00e1ty",
  "RS": "Srbsko",
  "LK": "Sr\u00ed Lanka",
  "CF": "St\u0159edoafrick\u00e1 republika",
  "SD": "S\u00fad\u00e1n",
  "SR": "Surinam",
  "SH": "Svat\u00e1 Helena",
  "LC": "Svat\u00e1 Lucie",
  "BL": "Svat\u00fd Bartolom\u011bj",
  "KN": "Svat\u00fd Kry\u0161tof a Nevis",
  "MF": "Svat\u00fd Martin (Francie)",
  "SX": "Svat\u00fd Martin (Nizozemsko)",
  "ST": "Svat\u00fd Tom\u00e1\u0161 a Princ\u016fv ostrov",
  "VC": "Svat\u00fd Vincenc a Grenadiny",
  "SZ": "Svazijsko",
  "SY": "S\u00fdrie",
  "SB": "\u0160alamounovy ostrovy",
  "ES": "\u0160pan\u011blsko",
  "SJ": "\u0160picberky a Jan Mayen",
  "SE": "\u0160v\u00e9dsko",
  "CH": "\u0160v\u00fdcarsko",
  "TJ": "T\u00e1d\u017eikist\u00e1n",
  "TZ": "Tanzanie",
  "TH": "Thajsko",
  "TW": "Tchaj-wan",
  "TG": "Togo",
  "TK": "Tokelau",
  "TO": "Tonga",
  "TT": "Trinidad a Tobago",
  "TN": "Tunisko",
  "TR": "Turecko",
  "TM": "Turkmenist\u00e1n",
  "TC": "Turks a Caicos",
  "TV": "Tuvalu",
  "UG": "Uganda",
  "UA": "Ukrajina",
  "UY": "Uruguay",
  "UZ": "Uzbekist\u00e1n",
  "CX": "V\u00e1no\u010dn\u00ed ostrov",
  "VU": "Vanuatu",
  "VA": "Vatik\u00e1n",
  "VE": "Venezuela",
  "VN": "Vietnam",
  "TL": "V\u00fdchodn\u00ed Timor",
  "WF": "Wallis a Futuna",
  "ZM": "Zambie",
  "EH": "Z\u00e1padn\u00ed Sahara",
  "ZW": "Zimbabwe"
}



================================================
FILE: public/intl/country/da-DK.json
================================================
{
  "AF": "Afghanistan",
  "AL": "Albanien",
  "DZ": "Algeriet",
  "AS": "Amerikansk Samoa",
  "UM": "Amerikanske overs\u00f8iske \u00f8er",
  "AD": "Andorra",
  "AO": "Angola",
  "AI": "Anguilla",
  "AQ": "Antarktis",
  "AG": "Antigua og Barbuda",
  "AR": "Argentina",
  "AM": "Armenien",
  "AW": "Aruba",
  "AZ": "Aserbajdsjan",
  "AU": "Australien",
  "BS": "Bahamas",
  "BH": "Bahrain",
  "BD": "Bangladesh",
  "BB": "Barbados",
  "BE": "Belgien",
  "BZ": "Belize",
  "BJ": "Benin",
  "BM": "Bermuda",
  "BT": "Bhutan",
  "BO": "Bolivia",
  "BA": "Bosnien-Hercegovina",
  "BW": "Botswana",
  "BV": "Bouvet\u00f8en",
  "BR": "Brasilien",
  "BN": "Brunei",
  "BG": "Bulgarien",
  "BF": "Burkina Faso",
  "BI": "Burundi",
  "KH": "Cambodja",
  "CM": "Cameroun",
  "CA": "Canada",
  "KY": "Cayman\u00f8erne",
  "CL": "Chile",
  "CC": "Cocos\u00f8erne",
  "CO": "Colombia",
  "KM": "Comorerne",
  "CG": "Congo-Brazzaville",
  "CD": "Congo-Kinshasa",
  "CK": "Cook\u00f8erne",
  "CR": "Costa Rica",
  "CU": "Cuba",
  "CW": "Cura\u00e7ao",
  "CY": "Cypern",
  "DK": "Danmark",
  "VI": "De Amerikanske Jomfru\u00f8er",
  "VG": "De Britiske Jomfru\u00f8er",
  "AE": "De Forenede Arabiske Emirater",
  "TF": "De Franske Besiddelser i Det Sydlige Indiske Ocean og Antarktis",
  "PS": "De pal\u00e6stinensiske omr\u00e5der",
  "BQ": "De tidligere Nederlandske Antiller",
  "CF": "Den Centralafrikanske Republik",
  "DO": "Den Dominikanske Republik",
  "IO": "Det Britiske Territorium i Det Indiske Ocean",
  "DJ": "Djibouti",
  "DM": "Dominica",
  "EC": "Ecuador",
  "EG": "Egypten",
  "SV": "El Salvador",
  "CI": "Elfenbenskysten",
  "ER": "Eritrea",
  "EE": "Estland",
  "SZ": "Eswatini",
  "ET": "Etiopien",
  "FK": "Falklands\u00f8erne",
  "FJ": "Fiji",
  "PH": "Filippinerne",
  "FI": "Finland",
  "FR": "Frankrig",
  "GF": "Fransk Guyana",
  "PF": "Fransk Polynesien",
  "FO": "F\u00e6r\u00f8erne",
  "GA": "Gabon",
  "GM": "Gambia",
  "GE": "Georgien",
  "GH": "Ghana",
  "GI": "Gibraltar",
  "GD": "Grenada",
  "GR": "Gr\u00e6kenland",
  "GL": "Gr\u00f8nland",
  "GP": "Guadeloupe",
  "GU": "Guam",
  "GT": "Guatemala",
  "GG": "Guernsey",
  "GN": "Guinea",
  "GW": "Guinea-Bissau",
  "GY": "Guyana",
  "HT": "Haiti",
  "HM": "Heard Island og McDonald Islands",
  "NL": "Holland",
  "HN": "Honduras",
  "BY": "Hviderusland",
  "IN": "Indien",
  "ID": "Indonesien",
  "IQ": "Irak",
  "IR": "Iran",
  "IE": "Irland",
  "IS": "Island",
  "IM": "Isle of Man",
  "IL": "Israel",
  "IT": "Italien",
  "JM": "Jamaica",
  "JP": "Japan",
  "JE": "Jersey",
  "JO": "Jordan",
  "CX": "Jule\u00f8en",
  "CV": "Kap Verde",
  "KZ": "Kasakhstan",
  "KE": "Kenya",
  "CN": "Kina",
  "KG": "Kirgisistan",
  "KI": "Kiribati",
  "XK": "Kosovo",
  "HR": "Kroatien",
  "KW": "Kuwait",
  "LA": "Laos",
  "LS": "Lesotho",
  "LV": "Letland",
  "LB": "Libanon",
  "LR": "Liberia",
  "LY": "Libyen",
  "LI": "Liechtenstein",
  "LT": "Litauen",
  "LU": "Luxembourg",
  "MG": "Madagaskar",
  "MW": "Malawi",
  "MY": "Malaysia",
  "MV": "Maldiverne",
  "ML": "Mali",
  "MT": "Malta",
  "MA": "Marokko",
  "MH": "Marshall\u00f8erne",
  "MQ": "Martinique",
  "MR": "Mauretanien",
  "MU": "Mauritius",
  "YT": "Mayotte",
  "MX": "Mexico",
  "FM": "Mikronesien",
  "MD": "Moldova",
  "MC": "Monaco",
  "MN": "Mongoliet",
  "ME": "Montenegro",
  "MS": "Montserrat",
  "MZ": "Mozambique",
  "MM": "Myanmar (Burma)",
  "NA": "Namibia",
  "NR": "Nauru",
  "NP": "Nepal",
  "NZ": "New Zealand",
  "NI": "Nicaragua",
  "NE": "Niger",
  "NG": "Nigeria",
  "NU": "Niue",
  "KP": "Nordkorea",
  "MK": "Nordmakedonien",
  "MP": "Nordmarianerne",
  "NF": "Norfolk Island",
  "NO": "Norge",
  "NC": "Ny Kaledonien",
  "OM": "Oman",
  "PK": "Pakistan",
  "PW": "Palau",
  "PA": "Panama",
  "PG": "Papua Ny Guinea",
  "PY": "Paraguay",
  "PE": "Peru",
  "PN": "Pitcairn",
  "PL": "Polen",
  "PT": "Portugal",
  "PR": "Puerto Rico",
  "QA": "Qatar",
  "RE": "R\u00e9union",
  "RO": "Rum\u00e6nien",
  "RU": "Rusland",
  "RW": "Rwanda",
  "BL": "Saint Barth\u00e9lemy",
  "KN": "Saint Kitts og Nevis",
  "LC": "Saint Lucia",
  "MF": "Saint Martin",
  "PM": "Saint Pierre og Miquelon",
  "VC": "Saint Vincent og Grenadinerne",
  "SB": "Salomon\u00f8erne",
  "WS": "Samoa",
  "SM": "San Marino",
  "ST": "S\u00e3o Tom\u00e9 og Pr\u00edncipe",
  "HK": "SAR Hongkong",
  "MO": "SAR Macao",
  "SA": "Saudi-Arabien",
  "CH": "Schweiz",
  "SN": "Senegal",
  "RS": "Serbien",
  "SC": "Seychellerne",
  "SL": "Sierra Leone",
  "SG": "Singapore",
  "SX": "Sint Maarten",
  "SK": "Slovakiet",
  "SI": "Slovenien",
  "SO": "Somalia",
  "GS": "South Georgia og De Sydlige Sandwich\u00f8er",
  "ES": "Spanien",
  "LK": "Sri Lanka",
  "SH": "St. Helena",
  "GB": "Storbritannien",
  "SD": "Sudan",
  "SR": "Surinam",
  "SJ": "Svalbard og Jan Mayen",
  "SE": "Sverige",
  "ZA": "Sydafrika",
  "KR": "Sydkorea",
  "SS": "Sydsudan",
  "SY": "Syrien",
  "TJ": "Tadsjikistan",
  "TW": "Taiwan",
  "TZ": "Tanzania",
  "TD": "Tchad",
  "TH": "Thailand",
  "TL": "Timor-Leste",
  "CZ": "Tjekkiet",
  "TG": "Togo",
  "TK": "Tokelau",
  "TO": "Tonga",
  "TT": "Trinidad og Tobago",
  "TN": "Tunesien",
  "TM": "Turkmenistan",
  "TC": "Turks- og Caicos\u00f8erne",
  "TV": "Tuvalu",
  "TR": "Tyrkiet",
  "DE": "Tyskland",
  "UG": "Uganda",
  "UA": "Ukraine",
  "HU": "Ungarn",
  "UY": "Uruguay",
  "US": "USA",
  "UZ": "Usbekistan",
  "VU": "Vanuatu",
  "VA": "Vatikanstaten",
  "VE": "Venezuela",
  "EH": "Vestsahara",
  "VN": "Vietnam",
  "WF": "Wallis og Futuna",
  "YE": "Yemen",
  "ZM": "Zambia",
  "ZW": "Zimbabwe",
  "GQ": "\u00c6kvatorialguinea",
  "AT": "\u00d8strig",
  "AX": "\u00c5land"
}



================================================
FILE: public/intl/country/de-CH.json
================================================
{
  "AF": "Afghanistan",
  "EG": "\u00c4gypten",
  "AX": "\u00c5landinseln",
  "AL": "Albanien",
  "DZ": "Algerien",
  "AS": "Amerikanisch-Samoa",
  "VI": "Amerikanische Jungferninseln",
  "UM": "Amerikanische \u00dcberseeinseln",
  "AD": "Andorra",
  "AO": "Angola",
  "AI": "Anguilla",
  "AQ": "Antarktis",
  "AG": "Antigua und Barbuda",
  "GQ": "\u00c4quatorialguinea",
  "AR": "Argentinien",
  "AM": "Armenien",
  "AW": "Aruba",
  "AZ": "Aserbaidschan",
  "ET": "\u00c4thiopien",
  "AU": "Australien",
  "BS": "Bahamas",
  "BH": "Bahrain",
  "BD": "Bangladesch",
  "BB": "Barbados",
  "BE": "Belgien",
  "BZ": "Belize",
  "BJ": "Benin",
  "BM": "Bermuda",
  "BT": "Bhutan",
  "BO": "Bolivien",
  "BQ": "Bonaire, Sint Eustatius und Saba",
  "BA": "Bosnien und Herzegowina",
  "BW": "Botswana",
  "BV": "Bouvetinsel",
  "BR": "Brasilien",
  "VG": "Britische Jungferninseln",
  "IO": "Britisches Territorium im Indischen Ozean",
  "BN": "Brunei",
  "BG": "Bulgarien",
  "BF": "Burkina Faso",
  "BI": "Burundi",
  "CL": "Chile",
  "CN": "China",
  "CK": "Cookinseln",
  "CR": "Costa Rica",
  "CI": "C\u00f4te d\u2019Ivoire",
  "CW": "Cura\u00e7ao",
  "DK": "D\u00e4nemark",
  "DE": "Deutschland",
  "DM": "Dominica",
  "DO": "Dominikanische Republik",
  "DJ": "Dschibuti",
  "EC": "Ecuador",
  "SV": "El Salvador",
  "ER": "Eritrea",
  "EE": "Estland",
  "SZ": "Eswatini",
  "FK": "Falklandinseln",
  "FO": "F\u00e4r\u00f6er",
  "FJ": "Fidschi",
  "FI": "Finnland",
  "FR": "Frankreich",
  "GF": "Franz\u00f6sisch-Guayana",
  "PF": "Franz\u00f6sisch-Polynesien",
  "TF": "Franz\u00f6sische S\u00fcd- und Antarktisgebiete",
  "GA": "Gabun",
  "GM": "Gambia",
  "GE": "Georgien",
  "GH": "Ghana",
  "GI": "Gibraltar",
  "GD": "Grenada",
  "GR": "Griechenland",
  "GL": "Gr\u00f6nland",
  "GB": "Grossbritannien",
  "GP": "Guadeloupe",
  "GU": "Guam",
  "GT": "Guatemala",
  "GG": "Guernsey",
  "GN": "Guinea",
  "GW": "Guinea-Bissau",
  "GY": "Guyana",
  "HT": "Haiti",
  "HM": "Heard und McDonaldinseln",
  "HN": "Honduras",
  "IN": "Indien",
  "ID": "Indonesien",
  "IQ": "Irak",
  "IR": "Iran",
  "IE": "Irland",
  "IS": "Island",
  "IM": "Isle of Man",
  "IL": "Israel",
  "IT": "Italien",
  "JM": "Jamaika",
  "JP": "Japan",
  "YE": "Jemen",
  "JE": "Jersey",
  "JO": "Jordanien",
  "KY": "Kaimaninseln",
  "KH": "Kambodscha",
  "CM": "Kamerun",
  "CA": "Kanada",
  "CV": "Kapverden",
  "KZ": "Kasachstan",
  "QA": "Katar",
  "KE": "Kenia",
  "KG": "Kirgisistan",
  "KI": "Kiribati",
  "CC": "Kokosinseln",
  "CO": "Kolumbien",
  "KM": "Komoren",
  "CG": "Kongo-Brazzaville",
  "CD": "Kongo-Kinshasa",
  "XK": "Kosovo",
  "HR": "Kroatien",
  "CU": "Kuba",
  "KW": "Kuwait",
  "LA": "Laos",
  "LS": "Lesotho",
  "LV": "Lettland",
  "LB": "Libanon",
  "LR": "Liberia",
  "LY": "Libyen",
  "LI": "Liechtenstein",
  "LT": "Litauen",
  "LU": "Luxemburg",
  "MG": "Madagaskar",
  "MW": "Malawi",
  "MY": "Malaysia",
  "MV": "Malediven",
  "ML": "Mali",
  "MT": "Malta",
  "MA": "Marokko",
  "MH": "Marshallinseln",
  "MQ": "Martinique",
  "MR": "Mauretanien",
  "MU": "Mauritius",
  "YT": "Mayotte",
  "MX": "Mexiko",
  "FM": "Mikronesien",
  "MC": "Monaco",
  "MN": "Mongolei",
  "ME": "Montenegro",
  "MS": "Montserrat",
  "MZ": "Mosambik",
  "MM": "Myanmar",
  "NA": "Namibia",
  "NR": "Nauru",
  "NP": "Nepal",
  "NC": "Neukaledonien",
  "NZ": "Neuseeland",
  "NI": "Nicaragua",
  "NL": "Niederlande",
  "NE": "Niger",
  "NG": "Nigeria",
  "NU": "Niue",
  "KP": "Nordkorea",
  "MP": "N\u00f6rdliche Marianen",
  "MK": "Nordmazedonien",
  "NF": "Norfolkinsel",
  "NO": "Norwegen",
  "OM": "Oman",
  "AT": "\u00d6sterreich",
  "TL": "Osttimor",
  "PK": "Pakistan",
  "PS": "Pal\u00e4stinensische Autonomiegebiete",
  "PW": "Palau",
  "PA": "Panama",
  "PG": "Papua-Neuguinea",
  "PY": "Paraguay",
  "PE": "Peru",
  "PH": "Philippinen",
  "PN": "Pitcairninseln",
  "PL": "Polen",
  "PT": "Portugal",
  "PR": "Puerto Rico",
  "MD": "Republik Moldau",
  "RE": "R\u00e9union",
  "RW": "Ruanda",
  "RO": "Rum\u00e4nien",
  "RU": "Russland",
  "SB": "Salomon-Inseln",
  "ZM": "Sambia",
  "WS": "Samoa",
  "SM": "San Marino",
  "ST": "S\u00e3o Tom\u00e9 und Pr\u00edncipe",
  "SA": "Saudi-Arabien",
  "SE": "Schweden",
  "CH": "Schweiz",
  "SN": "Senegal",
  "RS": "Serbien",
  "SC": "Seychellen",
  "SL": "Sierra Leone",
  "SG": "Singapur",
  "SX": "Sint Maarten",
  "SK": "Slowakei",
  "SI": "Slowenien",
  "SO": "Somalia",
  "HK": "Sonderverwaltungsregion Hongkong",
  "MO": "Sonderverwaltungsregion Macau",
  "ES": "Spanien",
  "SJ": "Spitzbergen und Jan Mayen",
  "LK": "Sri Lanka",
  "BL": "St. Barth\u00e9lemy",
  "SH": "St. Helena",
  "KN": "St. Kitts und Nevis",
  "LC": "St. Lucia",
  "MF": "St. Martin",
  "PM": "St. Pierre und Miquelon",
  "VC": "St. Vincent und die Grenadinen",
  "ZA": "S\u00fcdafrika",
  "SD": "Sudan",
  "GS": "S\u00fcdgeorgien und die S\u00fcdlichen Sandwichinseln",
  "KR": "S\u00fcdkorea",
  "SS": "S\u00fcdsudan",
  "SR": "Suriname",
  "SY": "Syrien",
  "TJ": "Tadschikistan",
  "TW": "Taiwan",
  "TZ": "Tansania",
  "TH": "Thailand",
  "TG": "Togo",
  "TK": "Tokelau",
  "TO": "Tonga",
  "TT": "Trinidad und Tobago",
  "TD": "Tschad",
  "CZ": "Tschechien",
  "TN": "Tunesien",
  "TR": "T\u00fcrkei",
  "TM": "Turkmenistan",
  "TC": "Turks- und Caicosinseln",
  "TV": "Tuvalu",
  "UG": "Uganda",
  "UA": "Ukraine",
  "HU": "Ungarn",
  "UY": "Uruguay",
  "UZ": "Usbekistan",
  "VU": "Vanuatu",
  "VA": "Vatikanstadt",
  "VE": "Venezuela",
  "AE": "Vereinigte Arabische Emirate",
  "US": "Vereinigte Staaten",
  "VN": "Vietnam",
  "WF": "Wallis und Futuna",
  "CX": "Weihnachtsinsel",
  "BY": "Weissrussland",
  "EH": "Westsahara",
  "CF": "Zentralafrikanische Republik",
  "ZW": "Zimbabwe",
  "CY": "Zypern"
}



================================================
FILE: public/intl/country/de-DE.json
================================================
{
  "AF": "Afghanistan",
  "EG": "\u00c4gypten",
  "AX": "\u00c5landinseln",
  "AL": "Albanien",
  "DZ": "Algerien",
  "AS": "Amerikanisch-Samoa",
  "VI": "Amerikanische Jungferninseln",
  "UM": "Amerikanische \u00dcberseeinseln",
  "AD": "Andorra",
  "AO": "Angola",
  "AI": "Anguilla",
  "AQ": "Antarktis",
  "AG": "Antigua und Barbuda",
  "GQ": "\u00c4quatorialguinea",
  "AR": "Argentinien",
  "AM": "Armenien",
  "AW": "Aruba",
  "AZ": "Aserbaidschan",
  "ET": "\u00c4thiopien",
  "AU": "Australien",
  "BS": "Bahamas",
  "BH": "Bahrain",
  "BD": "Bangladesch",
  "BB": "Barbados",
  "BY": "Belarus",
  "BE": "Belgien",
  "BZ": "Belize",
  "BJ": "Benin",
  "BM": "Bermuda",
  "BT": "Bhutan",
  "BO": "Bolivien",
  "BQ": "Bonaire, Sint Eustatius und Saba",
  "BA": "Bosnien und Herzegowina",
  "BW": "Botsuana",
  "BV": "Bouvetinsel",
  "BR": "Brasilien",
  "VG": "Britische Jungferninseln",
  "IO": "Britisches Territorium im Indischen Ozean",
  "BN": "Brunei Darussalam",
  "BG": "Bulgarien",
  "BF": "Burkina Faso",
  "BI": "Burundi",
  "CV": "Cabo Verde",
  "CL": "Chile",
  "CN": "China",
  "CK": "Cookinseln",
  "CR": "Costa Rica",
  "CI": "C\u00f4te d\u2019Ivoire",
  "CW": "Cura\u00e7ao",
  "DK": "D\u00e4nemark",
  "DE": "Deutschland",
  "DM": "Dominica",
  "DO": "Dominikanische Republik",
  "DJ": "Dschibuti",
  "EC": "Ecuador",
  "SV": "El Salvador",
  "ER": "Eritrea",
  "EE": "Estland",
  "SZ": "Eswatini",
  "FK": "Falklandinseln",
  "FO": "F\u00e4r\u00f6er",
  "FJ": "Fidschi",
  "FI": "Finnland",
  "FR": "Frankreich",
  "GF": "Franz\u00f6sisch-Guayana",
  "PF": "Franz\u00f6sisch-Polynesien",
  "TF": "Franz\u00f6sische S\u00fcd- und Antarktisgebiete",
  "GA": "Gabun",
  "GM": "Gambia",
  "GE": "Georgien",
  "GH": "Ghana",
  "GI": "Gibraltar",
  "GD": "Grenada",
  "GR": "Griechenland",
  "GL": "Gr\u00f6nland",
  "GP": "Guadeloupe",
  "GU": "Guam",
  "GT": "Guatemala",
  "GG": "Guernsey",
  "GN": "Guinea",
  "GW": "Guinea-Bissau",
  "GY": "Guyana",
  "HT": "Haiti",
  "HM": "Heard und McDonaldinseln",
  "HN": "Honduras",
  "IN": "Indien",
  "ID": "Indonesien",
  "IQ": "Irak",
  "IR": "Iran",
  "IE": "Irland",
  "IS": "Island",
  "IM": "Isle of Man",
  "IL": "Israel",
  "IT": "Italien",
  "JM": "Jamaika",
  "JP": "Japan",
  "YE": "Jemen",
  "JE": "Jersey",
  "JO": "Jordanien",
  "KY": "Kaimaninseln",
  "KH": "Kambodscha",
  "CM": "Kamerun",
  "CA": "Kanada",
  "KZ": "Kasachstan",
  "QA": "Katar",
  "KE": "Kenia",
  "KG": "Kirgisistan",
  "KI": "Kiribati",
  "CC": "Kokosinseln",
  "CO": "Kolumbien",
  "KM": "Komoren",
  "CG": "Kongo-Brazzaville",
  "CD": "Kongo-Kinshasa",
  "XK": "Kosovo",
  "HR": "Kroatien",
  "CU": "Kuba",
  "KW": "Kuwait",
  "LA": "Laos",
  "LS": "Lesotho",
  "LV": "Lettland",
  "LB": "Libanon",
  "LR": "Liberia",
  "LY": "Libyen",
  "LI": "Liechtenstein",
  "LT": "Litauen",
  "LU": "Luxemburg",
  "MG": "Madagaskar",
  "MW": "Malawi",
  "MY": "Malaysia",
  "MV": "Malediven",
  "ML": "Mali",
  "MT": "Malta",
  "MA": "Marokko",
  "MH": "Marshallinseln",
  "MQ": "Martinique",
  "MR": "Mauretanien",
  "MU": "Mauritius",
  "YT": "Mayotte",
  "MX": "Mexiko",
  "FM": "Mikronesien",
  "MC": "Monaco",
  "MN": "Mongolei",
  "ME": "Montenegro",
  "MS": "Montserrat",
  "MZ": "Mosambik",
  "MM": "Myanmar",
  "NA": "Namibia",
  "NR": "Nauru",
  "NP": "Nepal",
  "NC": "Neukaledonien",
  "NZ": "Neuseeland",
  "NI": "Nicaragua",
  "NL": "Niederlande",
  "NE": "Niger",
  "NG": "Nigeria",
  "NU": "Niue",
  "KP": "Nordkorea",
  "MP": "N\u00f6rdliche Marianen",
  "MK": "Nordmazedonien",
  "NF": "Norfolkinsel",
  "NO": "Norwegen",
  "OM": "Oman",
  "AT": "\u00d6sterreich",
  "PK": "Pakistan",
  "PS": "Pal\u00e4stinensische Autonomiegebiete",
  "PW": "Palau",
  "PA": "Panama",
  "PG": "Papua-Neuguinea",
  "PY": "Paraguay",
  "PE": "Peru",
  "PH": "Philippinen",
  "PN": "Pitcairninseln",
  "PL": "Polen",
  "PT": "Portugal",
  "PR": "Puerto Rico",
  "MD": "Republik Moldau",
  "RE": "R\u00e9union",
  "RW": "Ruanda",
  "RO": "Rum\u00e4nien",
  "RU": "Russland",
  "SB": "Salomonen",
  "ZM": "Sambia",
  "WS": "Samoa",
  "SM": "San Marino",
  "ST": "S\u00e3o Tom\u00e9 und Pr\u00edncipe",
  "SA": "Saudi-Arabien",
  "SE": "Schweden",
  "CH": "Schweiz",
  "SN": "Senegal",
  "RS": "Serbien",
  "SC": "Seychellen",
  "SL": "Sierra Leone",
  "ZW": "Simbabwe",
  "SG": "Singapur",
  "SX": "Sint Maarten",
  "SK": "Slowakei",
  "SI": "Slowenien",
  "SO": "Somalia",
  "HK": "Sonderverwaltungsregion Hongkong",
  "MO": "Sonderverwaltungsregion Macau",
  "ES": "Spanien",
  "SJ": "Spitzbergen und Jan Mayen",
  "LK": "Sri Lanka",
  "BL": "St. Barth\u00e9lemy",
  "SH": "St. Helena",
  "KN": "St. Kitts und Nevis",
  "LC": "St. Lucia",
  "MF": "St. Martin",
  "PM": "St. Pierre und Miquelon",
  "VC": "St. Vincent und die Grenadinen",
  "ZA": "S\u00fcdafrika",
  "SD": "Sudan",
  "GS": "S\u00fcdgeorgien und die S\u00fcdlichen Sandwichinseln",
  "KR": "S\u00fcdkorea",
  "SS": "S\u00fcdsudan",
  "SR": "Suriname",
  "SY": "Syrien",
  "TJ": "Tadschikistan",
  "TW": "Taiwan",
  "TZ": "Tansania",
  "TH": "Thailand",
  "TL": "Timor-Leste",
  "TG": "Togo",
  "TK": "Tokelau",
  "TO": "Tonga",
  "TT": "Trinidad und Tobago",
  "TD": "Tschad",
  "CZ": "Tschechien",
  "TN": "Tunesien",
  "TR": "T\u00fcrkei",
  "TM": "Turkmenistan",
  "TC": "Turks- und Caicosinseln",
  "TV": "Tuvalu",
  "UG": "Uganda",
  "UA": "Ukraine",
  "HU": "Ungarn",
  "UY": "Uruguay",
  "UZ": "Usbekistan",
  "VU": "Vanuatu",
  "VA": "Vatikanstadt",
  "VE": "Venezuela",
  "AE": "Vereinigte Arabische Emirate",
  "US": "Vereinigte Staaten",
  "GB": "Vereinigtes K\u00f6nigreich",
  "VN": "Vietnam",
  "WF": "Wallis und Futuna",
  "CX": "Weihnachtsinsel",
  "EH": "Westsahara",
  "CF": "Zentralafrikanische Republik",
  "CY": "Zypern"
}



================================================
FILE: public/intl/country/el-GR.json
================================================
{
  "SH": "\u0391\u03b3\u03af\u03b1 \u0395\u03bb\u03ad\u03bd\u03b7",
  "LC": "\u0391\u03b3\u03af\u03b1 \u039b\u03bf\u03c5\u03ba\u03af\u03b1",
  "BL": "\u0386\u03b3\u03b9\u03bf\u03c2 \u0392\u03b1\u03c1\u03b8\u03bf\u03bb\u03bf\u03bc\u03b1\u03af\u03bf\u03c2",
  "VC": "\u0386\u03b3\u03b9\u03bf\u03c2 \u0392\u03b9\u03ba\u03ad\u03bd\u03c4\u03b9\u03bf\u03c2 \u03ba\u03b1\u03b9 \u0393\u03c1\u03b5\u03bd\u03b1\u03b4\u03af\u03bd\u03b5\u03c2",
  "SM": "\u0386\u03b3\u03b9\u03bf\u03c2 \u039c\u03b1\u03c1\u03af\u03bd\u03bf\u03c2",
  "MF": "\u0386\u03b3\u03b9\u03bf\u03c2 \u039c\u03b1\u03c1\u03c4\u03af\u03bd\u03bf\u03c2 (\u0393\u03b1\u03bb\u03bb\u03b9\u03ba\u03cc \u03c4\u03bc\u03ae\u03bc\u03b1)",
  "SX": "\u0386\u03b3\u03b9\u03bf\u03c2 \u039c\u03b1\u03c1\u03c4\u03af\u03bd\u03bf\u03c2 (\u039f\u03bb\u03bb\u03b1\u03bd\u03b4\u03b9\u03ba\u03cc \u03c4\u03bc\u03ae\u03bc\u03b1)",
  "AO": "\u0391\u03b3\u03ba\u03cc\u03bb\u03b1",
  "AZ": "\u0391\u03b6\u03b5\u03c1\u03bc\u03c0\u03b1\u03ca\u03c4\u03b6\u03ac\u03bd",
  "EG": "\u0391\u03af\u03b3\u03c5\u03c0\u03c4\u03bf\u03c2",
  "ET": "\u0391\u03b9\u03b8\u03b9\u03bf\u03c0\u03af\u03b1",
  "HT": "\u0391\u03ca\u03c4\u03ae",
  "CI": "\u0391\u03ba\u03c4\u03ae \u0395\u03bb\u03b5\u03c6\u03b1\u03bd\u03c4\u03bf\u03c3\u03c4\u03bf\u03cd",
  "AL": "\u0391\u03bb\u03b2\u03b1\u03bd\u03af\u03b1",
  "DZ": "\u0391\u03bb\u03b3\u03b5\u03c1\u03af\u03b1",
  "VI": "\u0391\u03bc\u03b5\u03c1\u03b9\u03ba\u03b1\u03bd\u03b9\u03ba\u03ad\u03c2 \u03a0\u03b1\u03c1\u03b8\u03ad\u03bd\u03b5\u03c2 \u039d\u03ae\u03c3\u03bf\u03b9",
  "AS": "\u0391\u03bc\u03b5\u03c1\u03b9\u03ba\u03b1\u03bd\u03b9\u03ba\u03ae \u03a3\u03b1\u03bc\u03cc\u03b1",
  "AI": "\u0391\u03bd\u03b3\u03ba\u03bf\u03c5\u03af\u03bb\u03b1",
  "AD": "\u0391\u03bd\u03b4\u03cc\u03c1\u03b1",
  "AQ": "\u0391\u03bd\u03c4\u03b1\u03c1\u03ba\u03c4\u03b9\u03ba\u03ae",
  "AG": "\u0391\u03bd\u03c4\u03af\u03b3\u03ba\u03bf\u03c5\u03b1 \u03ba\u03b1\u03b9 \u039c\u03c0\u03b1\u03c1\u03bc\u03c0\u03bf\u03cd\u03bd\u03c4\u03b1",
  "UM": "\u0391\u03c0\u03bf\u03bc\u03b1\u03ba\u03c1\u03c5\u03c3\u03bc\u03ad\u03bd\u03b5\u03c2 \u039d\u03b7\u03c3\u03af\u03b4\u03b5\u03c2 \u0397\u03a0\u0391",
  "AR": "\u0391\u03c1\u03b3\u03b5\u03bd\u03c4\u03b9\u03bd\u03ae",
  "AM": "\u0391\u03c1\u03bc\u03b5\u03bd\u03af\u03b1",
  "AW": "\u0391\u03c1\u03bf\u03cd\u03bc\u03c0\u03b1",
  "AU": "\u0391\u03c5\u03c3\u03c4\u03c1\u03b1\u03bb\u03af\u03b1",
  "AT": "\u0391\u03c5\u03c3\u03c4\u03c1\u03af\u03b1",
  "AF": "\u0391\u03c6\u03b3\u03b1\u03bd\u03b9\u03c3\u03c4\u03ac\u03bd",
  "VU": "\u0392\u03b1\u03bd\u03bf\u03c5\u03ac\u03c4\u03bf\u03c5",
  "VA": "\u0392\u03b1\u03c4\u03b9\u03ba\u03b1\u03bd\u03cc",
  "BE": "\u0392\u03ad\u03bb\u03b3\u03b9\u03bf",
  "VE": "\u0392\u03b5\u03bd\u03b5\u03b6\u03bf\u03c5\u03ad\u03bb\u03b1",
  "BM": "\u0392\u03b5\u03c1\u03bc\u03bf\u03cd\u03b4\u03b5\u03c2",
  "VN": "\u0392\u03b9\u03b5\u03c4\u03bd\u03ac\u03bc",
  "BO": "\u0392\u03bf\u03bb\u03b9\u03b2\u03af\u03b1",
  "KP": "\u0392\u03cc\u03c1\u03b5\u03b9\u03b1 \u039a\u03bf\u03c1\u03ad\u03b1",
  "MK": "\u0392\u03cc\u03c1\u03b5\u03b9\u03b1 \u039c\u03b1\u03ba\u03b5\u03b4\u03bf\u03bd\u03af\u03b1",
  "BA": "\u0392\u03bf\u03c3\u03bd\u03af\u03b1 - \u0395\u03c1\u03b6\u03b5\u03b3\u03bf\u03b2\u03af\u03bd\u03b7",
  "BG": "\u0392\u03bf\u03c5\u03bb\u03b3\u03b1\u03c1\u03af\u03b1",
  "BR": "\u0392\u03c1\u03b1\u03b6\u03b9\u03bb\u03af\u03b1",
  "IO": "\u0392\u03c1\u03b5\u03c4\u03b1\u03bd\u03b9\u03ba\u03ac \u0395\u03b4\u03ac\u03c6\u03b7 \u0399\u03bd\u03b4\u03b9\u03ba\u03bf\u03cd \u03a9\u03ba\u03b5\u03b1\u03bd\u03bf\u03cd",
  "VG": "\u0392\u03c1\u03b5\u03c4\u03b1\u03bd\u03b9\u03ba\u03ad\u03c2 \u03a0\u03b1\u03c1\u03b8\u03ad\u03bd\u03b5\u03c2 \u039d\u03ae\u03c3\u03bf\u03b9",
  "FR": "\u0393\u03b1\u03bb\u03bb\u03af\u03b1",
  "TF": "\u0393\u03b1\u03bb\u03bb\u03b9\u03ba\u03ac \u039d\u03cc\u03c4\u03b9\u03b1 \u0395\u03b4\u03ac\u03c6\u03b7",
  "GF": "\u0393\u03b1\u03bb\u03bb\u03b9\u03ba\u03ae \u0393\u03bf\u03c5\u03b9\u03ac\u03bd\u03b1",
  "PF": "\u0393\u03b1\u03bb\u03bb\u03b9\u03ba\u03ae \u03a0\u03bf\u03bb\u03c5\u03bd\u03b7\u03c3\u03af\u03b1",
  "DE": "\u0393\u03b5\u03c1\u03bc\u03b1\u03bd\u03af\u03b1",
  "GE": "\u0393\u03b5\u03c9\u03c1\u03b3\u03af\u03b1",
  "GI": "\u0393\u03b9\u03b2\u03c1\u03b1\u03bb\u03c4\u03ac\u03c1",
  "GM": "\u0393\u03ba\u03ac\u03bc\u03c0\u03b9\u03b1",
  "GA": "\u0393\u03ba\u03b1\u03bc\u03c0\u03cc\u03bd",
  "GH": "\u0393\u03ba\u03ac\u03bd\u03b1",
  "GG": "\u0393\u03ba\u03ad\u03c1\u03bd\u03b6\u03b9",
  "GU": "\u0393\u03ba\u03bf\u03c5\u03ac\u03bc",
  "GP": "\u0393\u03bf\u03c5\u03b1\u03b4\u03b5\u03bb\u03bf\u03cd\u03c0\u03b7",
  "WF": "\u0393\u03bf\u03c5\u03ac\u03bb\u03b9\u03c2 \u03ba\u03b1\u03b9 \u03a6\u03bf\u03c5\u03c4\u03bf\u03cd\u03bd\u03b1",
  "GT": "\u0393\u03bf\u03c5\u03b1\u03c4\u03b5\u03bc\u03ac\u03bb\u03b1",
  "GY": "\u0393\u03bf\u03c5\u03b9\u03ac\u03bd\u03b1",
  "GN": "\u0393\u03bf\u03c5\u03b9\u03bd\u03ad\u03b1",
  "GW": "\u0393\u03bf\u03c5\u03b9\u03bd\u03ad\u03b1 \u039c\u03c0\u03b9\u03c3\u03ac\u03bf\u03c5",
  "GD": "\u0393\u03c1\u03b5\u03bd\u03ac\u03b4\u03b1",
  "GL": "\u0393\u03c1\u03bf\u03b9\u03bb\u03b1\u03bd\u03b4\u03af\u03b1",
  "DK": "\u0394\u03b1\u03bd\u03af\u03b1",
  "DO": "\u0394\u03bf\u03bc\u03b9\u03bd\u03b9\u03ba\u03b1\u03bd\u03ae \u0394\u03b7\u03bc\u03bf\u03ba\u03c1\u03b1\u03c4\u03af\u03b1",
  "EH": "\u0394\u03c5\u03c4\u03b9\u03ba\u03ae \u03a3\u03b1\u03c7\u03ac\u03c1\u03b1",
  "SV": "\u0395\u03bb \u03a3\u03b1\u03bb\u03b2\u03b1\u03b4\u03cc\u03c1",
  "CH": "\u0395\u03bb\u03b2\u03b5\u03c4\u03af\u03b1",
  "GR": "\u0395\u03bb\u03bb\u03ac\u03b4\u03b1",
  "ER": "\u0395\u03c1\u03c5\u03b8\u03c1\u03b1\u03af\u03b1",
  "EE": "\u0395\u03c3\u03b8\u03bf\u03bd\u03af\u03b1",
  "ZM": "\u0396\u03ac\u03bc\u03c0\u03b9\u03b1",
  "ZW": "\u0396\u03b9\u03bc\u03c0\u03ac\u03bc\u03c0\u03bf\u03c5\u03b5",
  "AE": "\u0397\u03bd\u03c9\u03bc\u03ad\u03bd\u03b1 \u0391\u03c1\u03b1\u03b2\u03b9\u03ba\u03ac \u0395\u03bc\u03b9\u03c1\u03ac\u03c4\u03b1",
  "US": "\u0397\u03bd\u03c9\u03bc\u03ad\u03bd\u03b5\u03c2 \u03a0\u03bf\u03bb\u03b9\u03c4\u03b5\u03af\u03b5\u03c2",
  "GB": "\u0397\u03bd\u03c9\u03bc\u03ad\u03bd\u03bf \u0392\u03b1\u03c3\u03af\u03bb\u03b5\u03b9\u03bf",
  "JP": "\u0399\u03b1\u03c0\u03c9\u03bd\u03af\u03b1",
  "IN": "\u0399\u03bd\u03b4\u03af\u03b1",
  "ID": "\u0399\u03bd\u03b4\u03bf\u03bd\u03b7\u03c3\u03af\u03b1",
  "JO": "\u0399\u03bf\u03c1\u03b4\u03b1\u03bd\u03af\u03b1",
  "IQ": "\u0399\u03c1\u03ac\u03ba",
  "IR": "\u0399\u03c1\u03ac\u03bd",
  "IE": "\u0399\u03c1\u03bb\u03b1\u03bd\u03b4\u03af\u03b1",
  "GQ": "\u0399\u03c3\u03b7\u03bc\u03b5\u03c1\u03b9\u03bd\u03ae \u0393\u03bf\u03c5\u03b9\u03bd\u03ad\u03b1",
  "EC": "\u0399\u03c3\u03b7\u03bc\u03b5\u03c1\u03b9\u03bd\u03cc\u03c2",
  "IS": "\u0399\u03c3\u03bb\u03b1\u03bd\u03b4\u03af\u03b1",
  "ES": "\u0399\u03c3\u03c0\u03b1\u03bd\u03af\u03b1",
  "IL": "\u0399\u03c3\u03c1\u03b1\u03ae\u03bb",
  "IT": "\u0399\u03c4\u03b1\u03bb\u03af\u03b1",
  "KZ": "\u039a\u03b1\u03b6\u03b1\u03ba\u03c3\u03c4\u03ac\u03bd",
  "CM": "\u039a\u03b1\u03bc\u03b5\u03c1\u03bf\u03cd\u03bd",
  "KH": "\u039a\u03b1\u03bc\u03c0\u03cc\u03c4\u03b6\u03b7",
  "CA": "\u039a\u03b1\u03bd\u03b1\u03b4\u03ac\u03c2",
  "QA": "\u039a\u03b1\u03c4\u03ac\u03c1",
  "CF": "\u039a\u03b5\u03bd\u03c4\u03c1\u03bf\u03b1\u03c6\u03c1\u03b9\u03ba\u03b1\u03bd\u03b9\u03ba\u03ae \u0394\u03b7\u03bc\u03bf\u03ba\u03c1\u03b1\u03c4\u03af\u03b1",
  "KE": "\u039a\u03ad\u03bd\u03c5\u03b1",
  "CN": "\u039a\u03af\u03bd\u03b1",
  "KG": "\u039a\u03b9\u03c1\u03b3\u03b9\u03c3\u03c4\u03ac\u03bd",
  "KI": "\u039a\u03b9\u03c1\u03b9\u03bc\u03c0\u03ac\u03c4\u03b9",
  "CO": "\u039a\u03bf\u03bb\u03bf\u03bc\u03b2\u03af\u03b1",
  "KM": "\u039a\u03bf\u03bc\u03cc\u03c1\u03b5\u03c2",
  "CD": "\u039a\u03bf\u03bd\u03b3\u03ba\u03cc - \u039a\u03b9\u03bd\u03c3\u03ac\u03c3\u03b1",
  "CG": "\u039a\u03bf\u03bd\u03b3\u03ba\u03cc - \u039c\u03c0\u03c1\u03b1\u03b6\u03b1\u03b2\u03af\u03bb",
  "CR": "\u039a\u03cc\u03c3\u03c4\u03b1 \u03a1\u03af\u03ba\u03b1",
  "XK": "\u039a\u03cc\u03c3\u03bf\u03b2\u03bf",
  "CU": "\u039a\u03bf\u03cd\u03b2\u03b1",
  "KW": "\u039a\u03bf\u03c5\u03b2\u03ad\u03b9\u03c4",
  "CW": "\u039a\u03bf\u03c5\u03c1\u03b1\u03c3\u03ac\u03bf",
  "HR": "\u039a\u03c1\u03bf\u03b1\u03c4\u03af\u03b1",
  "CY": "\u039a\u03cd\u03c0\u03c1\u03bf\u03c2",
  "LA": "\u039b\u03ac\u03bf\u03c2",
  "LS": "\u039b\u03b5\u03c3\u03cc\u03c4\u03bf",
  "LV": "\u039b\u03b5\u03c4\u03bf\u03bd\u03af\u03b1",
  "BY": "\u039b\u03b5\u03c5\u03ba\u03bf\u03c1\u03c9\u03c3\u03af\u03b1",
  "LB": "\u039b\u03af\u03b2\u03b1\u03bd\u03bf\u03c2",
  "LR": "\u039b\u03b9\u03b2\u03b5\u03c1\u03af\u03b1",
  "LY": "\u039b\u03b9\u03b2\u03cd\u03b7",
  "LT": "\u039b\u03b9\u03b8\u03bf\u03c5\u03b1\u03bd\u03af\u03b1",
  "LI": "\u039b\u03b9\u03c7\u03c4\u03b5\u03bd\u03c3\u03c4\u03ac\u03b9\u03bd",
  "LU": "\u039b\u03bf\u03c5\u03be\u03b5\u03bc\u03b2\u03bf\u03cd\u03c1\u03b3\u03bf",
  "YT": "\u039c\u03b1\u03b3\u03b9\u03cc\u03c4",
  "MG": "\u039c\u03b1\u03b4\u03b1\u03b3\u03b1\u03c3\u03ba\u03ac\u03c1\u03b7",
  "MO": "\u039c\u03b1\u03ba\u03ac\u03bf \u0395\u0394\u03a0 \u039a\u03af\u03bd\u03b1\u03c2",
  "MY": "\u039c\u03b1\u03bb\u03b1\u03b9\u03c3\u03af\u03b1",
  "MW": "\u039c\u03b1\u03bb\u03ac\u03bf\u03c5\u03b9",
  "MV": "\u039c\u03b1\u03bb\u03b4\u03af\u03b2\u03b5\u03c2",
  "ML": "\u039c\u03ac\u03bb\u03b9",
  "MT": "\u039c\u03ac\u03bb\u03c4\u03b1",
  "MA": "\u039c\u03b1\u03c1\u03cc\u03ba\u03bf",
  "MQ": "\u039c\u03b1\u03c1\u03c4\u03b9\u03bd\u03af\u03ba\u03b1",
  "MU": "\u039c\u03b1\u03c5\u03c1\u03af\u03ba\u03b9\u03bf\u03c2",
  "MR": "\u039c\u03b1\u03c5\u03c1\u03b9\u03c4\u03b1\u03bd\u03af\u03b1",
  "ME": "\u039c\u03b1\u03c5\u03c1\u03bf\u03b2\u03bf\u03cd\u03bd\u03b9\u03bf",
  "MX": "\u039c\u03b5\u03be\u03b9\u03ba\u03cc",
  "MM": "\u039c\u03b9\u03b1\u03bd\u03bc\u03ac\u03c1 (\u0392\u03b9\u03c1\u03bc\u03b1\u03bd\u03af\u03b1)",
  "FM": "\u039c\u03b9\u03ba\u03c1\u03bf\u03bd\u03b7\u03c3\u03af\u03b1",
  "MN": "\u039c\u03bf\u03b3\u03b3\u03bf\u03bb\u03af\u03b1",
  "MZ": "\u039c\u03bf\u03b6\u03b1\u03bc\u03b2\u03af\u03ba\u03b7",
  "MD": "\u039c\u03bf\u03bb\u03b4\u03b1\u03b2\u03af\u03b1",
  "MC": "\u039c\u03bf\u03bd\u03b1\u03ba\u03cc",
  "MS": "\u039c\u03bf\u03bd\u03c3\u03b5\u03c1\u03ac\u03c4",
  "BD": "\u039c\u03c0\u03b1\u03bd\u03b3\u03ba\u03bb\u03b1\u03bd\u03c4\u03ad\u03c2",
  "BB": "\u039c\u03c0\u03b1\u03c1\u03bc\u03c0\u03ad\u03b9\u03bd\u03c4\u03bf\u03c2",
  "BS": "\u039c\u03c0\u03b1\u03c7\u03ac\u03bc\u03b5\u03c2",
  "BH": "\u039c\u03c0\u03b1\u03c7\u03c1\u03ad\u03b9\u03bd",
  "BZ": "\u039c\u03c0\u03b5\u03bb\u03af\u03b6",
  "BJ": "\u039c\u03c0\u03b5\u03bd\u03af\u03bd",
  "BW": "\u039c\u03c0\u03bf\u03c4\u03c3\u03bf\u03c5\u03ac\u03bd\u03b1",
  "BF": "\u039c\u03c0\u03bf\u03c5\u03c1\u03ba\u03af\u03bd\u03b1 \u03a6\u03ac\u03c3\u03bf",
  "BI": "\u039c\u03c0\u03bf\u03c5\u03c1\u03bf\u03cd\u03bd\u03c4\u03b9",
  "BT": "\u039c\u03c0\u03bf\u03c5\u03c4\u03ac\u03bd",
  "BN": "\u039c\u03c0\u03c1\u03bf\u03c5\u03bd\u03ad\u03b9",
  "NA": "\u039d\u03b1\u03bc\u03af\u03bc\u03c0\u03b9\u03b1",
  "NR": "\u039d\u03b1\u03bf\u03c5\u03c1\u03bf\u03cd",
  "NZ": "\u039d\u03ad\u03b1 \u0396\u03b7\u03bb\u03b1\u03bd\u03b4\u03af\u03b1",
  "NC": "\u039d\u03ad\u03b1 \u039a\u03b1\u03bb\u03b7\u03b4\u03bf\u03bd\u03af\u03b1",
  "NP": "\u039d\u03b5\u03c0\u03ac\u03bb",
  "MP": "\u039d\u03ae\u03c3\u03bf\u03b9 \u0392\u03cc\u03c1\u03b5\u03b9\u03b5\u03c2 \u039c\u03b1\u03c1\u03b9\u03ac\u03bd\u03b5\u03c2",
  "KY": "\u039d\u03ae\u03c3\u03bf\u03b9 \u039a\u03ad\u03b9\u03bc\u03b1\u03bd",
  "CC": "\u039d\u03ae\u03c3\u03bf\u03b9 \u039a\u03cc\u03ba\u03bf\u03c2 (\u039a\u03af\u03bb\u03b9\u03bd\u03b3\u03ba)",
  "CK": "\u039d\u03ae\u03c3\u03bf\u03b9 \u039a\u03bf\u03c5\u03ba",
  "MH": "\u039d\u03ae\u03c3\u03bf\u03b9 \u039c\u03ac\u03c1\u03c3\u03b1\u03bb",
  "GS": "\u039d\u03ae\u03c3\u03bf\u03b9 \u039d\u03cc\u03c4\u03b9\u03b1 \u0393\u03b5\u03c9\u03c1\u03b3\u03af\u03b1 \u03ba\u03b1\u03b9 \u039d\u03cc\u03c4\u03b9\u03b5\u03c2 \u03a3\u03ac\u03bd\u03c4\u03bf\u03c5\u03b9\u03c4\u03c2",
  "AX": "\u039d\u03ae\u03c3\u03bf\u03b9 \u038c\u03bb\u03b1\u03bd\u03c4",
  "PN": "\u039d\u03ae\u03c3\u03bf\u03b9 \u03a0\u03af\u03c4\u03ba\u03b5\u03c1\u03bd",
  "SB": "\u039d\u03ae\u03c3\u03bf\u03b9 \u03a3\u03bf\u03bb\u03bf\u03bc\u03ce\u03bd\u03c4\u03bf\u03c2",
  "TC": "\u039d\u03ae\u03c3\u03bf\u03b9 \u03a4\u03b5\u03c1\u03ba\u03c2 \u03ba\u03b1\u03b9 \u039a\u03ac\u03b9\u03ba\u03bf\u03c2",
  "FO": "\u039d\u03ae\u03c3\u03bf\u03b9 \u03a6\u03b5\u03c1\u03cc\u03b5\u03c2",
  "FK": "\u039d\u03ae\u03c3\u03bf\u03b9 \u03a6\u03cc\u03ba\u03bb\u03b1\u03bd\u03c4",
  "HM": "\u039d\u03ae\u03c3\u03bf\u03b9 \u03a7\u03b5\u03c1\u03bd\u03c4 \u03ba\u03b1\u03b9 \u039c\u03b1\u03ba\u03bd\u03c4\u03cc\u03bd\u03b1\u03bb\u03bd\u03c4",
  "BV": "\u039d\u03ae\u03c3\u03bf\u03c2 \u039c\u03c0\u03bf\u03c5\u03b2\u03ad",
  "NF": "\u039d\u03ae\u03c3\u03bf\u03c2 \u039d\u03cc\u03c1\u03c6\u03bf\u03bb\u03ba",
  "IM": "\u039d\u03ae\u03c3\u03bf\u03c2 \u03c4\u03bf\u03c5 \u039c\u03b1\u03bd",
  "CX": "\u039d\u03ae\u03c3\u03bf\u03c2 \u03c4\u03c9\u03bd \u03a7\u03c1\u03b9\u03c3\u03c4\u03bf\u03c5\u03b3\u03ad\u03bd\u03bd\u03c9\u03bd",
  "NE": "\u039d\u03af\u03b3\u03b7\u03c1\u03b1\u03c2",
  "NG": "\u039d\u03b9\u03b3\u03b7\u03c1\u03af\u03b1",
  "NI": "\u039d\u03b9\u03ba\u03b1\u03c1\u03ac\u03b3\u03bf\u03c5\u03b1",
  "NU": "\u039d\u03b9\u03bf\u03cd\u03b5",
  "NO": "\u039d\u03bf\u03c1\u03b2\u03b7\u03b3\u03af\u03b1",
  "ZA": "\u039d\u03cc\u03c4\u03b9\u03b1 \u0391\u03c6\u03c1\u03b9\u03ba\u03ae",
  "KR": "\u039d\u03cc\u03c4\u03b9\u03b1 \u039a\u03bf\u03c1\u03ad\u03b1",
  "SS": "\u039d\u03cc\u03c4\u03b9\u03bf \u03a3\u03bf\u03c5\u03b4\u03ac\u03bd",
  "DM": "\u039d\u03c4\u03bf\u03bc\u03af\u03bd\u03b9\u03ba\u03b1",
  "NL": "\u039f\u03bb\u03bb\u03b1\u03bd\u03b4\u03af\u03b1",
  "BQ": "\u039f\u03bb\u03bb\u03b1\u03bd\u03b4\u03af\u03b1 \u039a\u03b1\u03c1\u03b1\u03ca\u03b2\u03b9\u03ba\u03ae\u03c2",
  "OM": "\u039f\u03bc\u03ac\u03bd",
  "HN": "\u039f\u03bd\u03b4\u03bf\u03cd\u03c1\u03b1",
  "HU": "\u039f\u03c5\u03b3\u03b3\u03b1\u03c1\u03af\u03b1",
  "UG": "\u039f\u03c5\u03b3\u03ba\u03ac\u03bd\u03c4\u03b1",
  "UZ": "\u039f\u03c5\u03b6\u03bc\u03c0\u03b5\u03ba\u03b9\u03c3\u03c4\u03ac\u03bd",
  "UA": "\u039f\u03c5\u03ba\u03c1\u03b1\u03bd\u03af\u03b1",
  "UY": "\u039f\u03c5\u03c1\u03bf\u03c5\u03b3\u03bf\u03c5\u03ac\u03b7",
  "PK": "\u03a0\u03b1\u03ba\u03b9\u03c3\u03c4\u03ac\u03bd",
  "PS": "\u03a0\u03b1\u03bb\u03b1\u03b9\u03c3\u03c4\u03b9\u03bd\u03b9\u03b1\u03ba\u03ac \u0395\u03b4\u03ac\u03c6\u03b7",
  "PW": "\u03a0\u03b1\u03bb\u03ac\u03bf\u03c5",
  "PA": "\u03a0\u03b1\u03bd\u03b1\u03bc\u03ac\u03c2",
  "PG": "\u03a0\u03b1\u03c0\u03bf\u03cd\u03b1 \u039d\u03ad\u03b1 \u0393\u03bf\u03c5\u03b9\u03bd\u03ad\u03b1",
  "PY": "\u03a0\u03b1\u03c1\u03b1\u03b3\u03bf\u03c5\u03ac\u03b7",
  "PE": "\u03a0\u03b5\u03c1\u03bf\u03cd",
  "PL": "\u03a0\u03bf\u03bb\u03c9\u03bd\u03af\u03b1",
  "PT": "\u03a0\u03bf\u03c1\u03c4\u03bf\u03b3\u03b1\u03bb\u03af\u03b1",
  "PR": "\u03a0\u03bf\u03c5\u03ad\u03c1\u03c4\u03bf \u03a1\u03af\u03ba\u03bf",
  "CV": "\u03a0\u03c1\u03ac\u03c3\u03b9\u03bd\u03bf \u0391\u03ba\u03c1\u03c9\u03c4\u03ae\u03c1\u03b9\u03bf",
  "RE": "\u03a1\u03b5\u03ca\u03bd\u03b9\u03cc\u03bd",
  "RW": "\u03a1\u03bf\u03c5\u03ac\u03bd\u03c4\u03b1",
  "RO": "\u03a1\u03bf\u03c5\u03bc\u03b1\u03bd\u03af\u03b1",
  "RU": "\u03a1\u03c9\u03c3\u03af\u03b1",
  "WS": "\u03a3\u03b1\u03bc\u03cc\u03b1",
  "ST": "\u03a3\u03ac\u03bf \u03a4\u03bf\u03bc\u03ad \u03ba\u03b1\u03b9 \u03a0\u03c1\u03af\u03bd\u03c3\u03b9\u03c0\u03b5",
  "SA": "\u03a3\u03b1\u03bf\u03c5\u03b4\u03b9\u03ba\u03ae \u0391\u03c1\u03b1\u03b2\u03af\u03b1",
  "SJ": "\u03a3\u03b2\u03ac\u03bb\u03bc\u03c0\u03b1\u03c1\u03bd\u03c4 \u03ba\u03b1\u03b9 \u0393\u03b9\u03b1\u03bd \u039c\u03b1\u03b3\u03b9\u03ad\u03bd",
  "KN": "\u03a3\u03b5\u03bd \u039a\u03b9\u03c4\u03c2 \u03ba\u03b1\u03b9 \u039d\u03ad\u03b2\u03b9\u03c2",
  "PM": "\u03a3\u03b5\u03bd \u03a0\u03b9\u03b5\u03c1 \u03ba\u03b1\u03b9 \u039c\u03b9\u03ba\u03b5\u03bb\u03cc\u03bd",
  "SN": "\u03a3\u03b5\u03bd\u03b5\u03b3\u03ac\u03bb\u03b7",
  "RS": "\u03a3\u03b5\u03c1\u03b2\u03af\u03b1",
  "SC": "\u03a3\u03b5\u03cb\u03c7\u03ad\u03bb\u03bb\u03b5\u03c2",
  "SG": "\u03a3\u03b9\u03b3\u03ba\u03b1\u03c0\u03bf\u03cd\u03c1\u03b7",
  "SL": "\u03a3\u03b9\u03ad\u03c1\u03b1 \u039b\u03b5\u03cc\u03bd\u03b5",
  "SK": "\u03a3\u03bb\u03bf\u03b2\u03b1\u03ba\u03af\u03b1",
  "SI": "\u03a3\u03bb\u03bf\u03b2\u03b5\u03bd\u03af\u03b1",
  "SO": "\u03a3\u03bf\u03bc\u03b1\u03bb\u03af\u03b1",
  "SZ": "\u03a3\u03bf\u03c5\u03b1\u03b6\u03b9\u03bb\u03ac\u03bd\u03b4\u03b7",
  "SD": "\u03a3\u03bf\u03c5\u03b4\u03ac\u03bd",
  "SE": "\u03a3\u03bf\u03c5\u03b7\u03b4\u03af\u03b1",
  "SR": "\u03a3\u03bf\u03c5\u03c1\u03b9\u03bd\u03ac\u03bc",
  "LK": "\u03a3\u03c1\u03b9 \u039b\u03ac\u03bd\u03ba\u03b1",
  "SY": "\u03a3\u03c5\u03c1\u03af\u03b1",
  "TW": "\u03a4\u03b1\u03ca\u03b2\u03ac\u03bd",
  "TH": "\u03a4\u03b1\u03ca\u03bb\u03ac\u03bd\u03b4\u03b7",
  "TZ": "\u03a4\u03b1\u03bd\u03b6\u03b1\u03bd\u03af\u03b1",
  "TJ": "\u03a4\u03b1\u03c4\u03b6\u03b9\u03ba\u03b9\u03c3\u03c4\u03ac\u03bd",
  "JM": "\u03a4\u03b6\u03b1\u03bc\u03ac\u03b9\u03ba\u03b1",
  "JE": "\u03a4\u03b6\u03ad\u03c1\u03b6\u03b9",
  "DJ": "\u03a4\u03b6\u03b9\u03bc\u03c0\u03bf\u03c5\u03c4\u03af",
  "TL": "\u03a4\u03b9\u03bc\u03cc\u03c1-\u039b\u03ad\u03c3\u03c4\u03b5",
  "TG": "\u03a4\u03cc\u03b3\u03ba\u03bf",
  "TK": "\u03a4\u03bf\u03ba\u03b5\u03bb\u03ac\u03bf\u03c5",
  "TO": "\u03a4\u03cc\u03bd\u03b3\u03ba\u03b1",
  "TV": "\u03a4\u03bf\u03c5\u03b2\u03b1\u03bb\u03bf\u03cd",
  "TR": "\u03a4\u03bf\u03c5\u03c1\u03ba\u03af\u03b1",
  "TM": "\u03a4\u03bf\u03c5\u03c1\u03ba\u03bc\u03b5\u03bd\u03b9\u03c3\u03c4\u03ac\u03bd",
  "TT": "\u03a4\u03c1\u03b9\u03bd\u03b9\u03bd\u03c4\u03ac\u03bd\u03c4 \u03ba\u03b1\u03b9 \u03a4\u03bf\u03bc\u03c0\u03ac\u03b3\u03ba\u03bf",
  "TD": "\u03a4\u03c3\u03b1\u03bd\u03c4",
  "CZ": "\u03a4\u03c3\u03b5\u03c7\u03af\u03b1",
  "TN": "\u03a4\u03c5\u03bd\u03b7\u03c3\u03af\u03b1",
  "YE": "\u03a5\u03b5\u03bc\u03ad\u03bd\u03b7",
  "PH": "\u03a6\u03b9\u03bb\u03b9\u03c0\u03c0\u03af\u03bd\u03b5\u03c2",
  "FI": "\u03a6\u03b9\u03bd\u03bb\u03b1\u03bd\u03b4\u03af\u03b1",
  "FJ": "\u03a6\u03af\u03c4\u03b6\u03b9",
  "CL": "\u03a7\u03b9\u03bb\u03ae",
  "HK": "\u03a7\u03bf\u03bd\u03b3\u03ba \u039a\u03bf\u03bd\u03b3\u03ba \u0395\u0394\u03a0 \u039a\u03af\u03bd\u03b1\u03c2"
}



================================================
FILE: public/intl/country/en-GB.json
================================================
{
  "AF": "Afghanistan",
  "AX": "\u00c5land Islands",
  "AL": "Albania",
  "DZ": "Algeria",
  "AS": "American Samoa",
  "AD": "Andorra",
  "AO": "Angola",
  "AI": "Anguilla",
  "AQ": "Antarctica",
  "AG": "Antigua & Barbuda",
  "AR": "Argentina",
  "AM": "Armenia",
  "AW": "Aruba",
  "AU": "Australia",
  "AT": "Austria",
  "AZ": "Azerbaijan",
  "BS": "Bahamas",
  "BH": "Bahrain",
  "BD": "Bangladesh",
  "BB": "Barbados",
  "BY": "Belarus",
  "BE": "Belgium",
  "BZ": "Belize",
  "BJ": "Benin",
  "BM": "Bermuda",
  "BT": "Bhutan",
  "BO": "Bolivia",
  "BA": "Bosnia & Herzegovina",
  "BW": "Botswana",
  "BV": "Bouvet Island",
  "BR": "Brazil",
  "IO": "British Indian Ocean Territory",
  "VG": "British Virgin Islands",
  "BN": "Brunei",
  "BG": "Bulgaria",
  "BF": "Burkina Faso",
  "BI": "Burundi",
  "KH": "Cambodia",
  "CM": "Cameroon",
  "CA": "Canada",
  "CV": "Cape Verde",
  "BQ": "Caribbean Netherlands",
  "KY": "Cayman Islands",
  "CF": "Central African Republic",
  "TD": "Chad",
  "CL": "Chile",
  "CN": "China",
  "CX": "Christmas Island",
  "CC": "Cocos (Keeling) Islands",
  "CO": "Colombia",
  "KM": "Comoros",
  "CG": "Congo - Brazzaville",
  "CD": "Congo - Kinshasa",
  "CK": "Cook Islands",
  "CR": "Costa Rica",
  "CI": "C\u00f4te d\u2019Ivoire",
  "HR": "Croatia",
  "CU": "Cuba",
  "CW": "Cura\u00e7ao",
  "CY": "Cyprus",
  "CZ": "Czechia",
  "DK": "Denmark",
  "DJ": "Djibouti",
  "DM": "Dominica",
  "DO": "Dominican Republic",
  "EC": "Ecuador",
  "EG": "Egypt",
  "SV": "El Salvador",
  "GQ": "Equatorial Guinea",
  "ER": "Eritrea",
  "EE": "Estonia",
  "SZ": "Eswatini",
  "ET": "Ethiopia",
  "FK": "Falkland Islands",
  "FO": "Faroe Islands",
  "FJ": "Fiji",
  "FI": "Finland",
  "FR": "France",
  "GF": "French Guiana",
  "PF": "French Polynesia",
  "TF": "French Southern Territories",
  "GA": "Gabon",
  "GM": "Gambia",
  "GE": "Georgia",
  "DE": "Germany",
  "GH": "Ghana",
  "GI": "Gibraltar",
  "GR": "Greece",
  "GL": "Greenland",
  "GD": "Grenada",
  "GP": "Guadeloupe",
  "GU": "Guam",
  "GT": "Guatemala",
  "GG": "Guernsey",
  "GN": "Guinea",
  "GW": "Guinea-Bissau",
  "GY": "Guyana",
  "HT": "Haiti",
  "HM": "Heard & McDonald Islands",
  "HN": "Honduras",
  "HK": "Hong Kong SAR China",
  "HU": "Hungary",
  "IS": "Iceland",
  "IN": "India",
  "ID": "Indonesia",
  "IR": "Iran",
  "IQ": "Iraq",
  "IE": "Ireland",
  "IM": "Isle of Man",
  "IL": "Israel",
  "IT": "Italy",
  "JM": "Jamaica",
  "JP": "Japan",
  "JE": "Jersey",
  "JO": "Jordan",
  "KZ": "Kazakhstan",
  "KE": "Kenya",
  "KI": "Kiribati",
  "XK": "Kosovo",
  "KW": "Kuwait",
  "KG": "Kyrgyzstan",
  "LA": "Laos",
  "LV": "Latvia",
  "LB": "Lebanon",
  "LS": "Lesotho",
  "LR": "Liberia",
  "LY": "Libya",
  "LI": "Liechtenstein",
  "LT": "Lithuania",
  "LU": "Luxembourg",
  "MO": "Macao SAR China",
  "MG": "Madagascar",
  "MW": "Malawi",
  "MY": "Malaysia",
  "MV": "Maldives",
  "ML": "Mali",
  "MT": "Malta",
  "MH": "Marshall Islands",
  "MQ": "Martinique",
  "MR": "Mauritania",
  "MU": "Mauritius",
  "YT": "Mayotte",
  "MX": "Mexico",
  "FM": "Micronesia",
  "MD": "Moldova",
  "MC": "Monaco",
  "MN": "Mongolia",
  "ME": "Montenegro",
  "MS": "Montserrat",
  "MA": "Morocco",
  "MZ": "Mozambique",
  "MM": "Myanmar (Burma)",
  "NA": "Namibia",
  "NR": "Nauru",
  "NP": "Nepal",
  "NL": "Netherlands",
  "NC": "New Caledonia",
  "NZ": "New Zealand",
  "NI": "Nicaragua",
  "NE": "Niger",
  "NG": "Nigeria",
  "NU": "Niue",
  "NF": "Norfolk Island",
  "KP": "North Korea",
  "MK": "North Macedonia",
  "MP": "Northern Mariana Islands",
  "NO": "Norway",
  "OM": "Oman",
  "PK": "Pakistan",
  "PW": "Palau",
  "PS": "Palestinian Territories",
  "PA": "Panama",
  "PG": "Papua New Guinea",
  "PY": "Paraguay",
  "PE": "Peru",
  "PH": "Philippines",
  "PN": "Pitcairn Islands",
  "PL": "Poland",
  "PT": "Portugal",
  "PR": "Puerto Rico",
  "QA": "Qatar",
  "RE": "R\u00e9union",
  "RO": "Romania",
  "RU": "Russia",
  "RW": "Rwanda",
  "WS": "Samoa",
  "SM": "San Marino",
  "ST": "S\u00e3o Tom\u00e9 & Pr\u00edncipe",
  "SA": "Saudi Arabia",
  "SN": "Senegal",
  "RS": "Serbia",
  "SC": "Seychelles",
  "SL": "Sierra Leone",
  "SG": "Singapore",
  "SX": "Sint Maarten",
  "SK": "Slovakia",
  "SI": "Slovenia",
  "SB": "Solomon Islands",
  "SO": "Somalia",
  "ZA": "South Africa",
  "GS": "South Georgia & South Sandwich Islands",
  "KR": "South Korea",
  "SS": "South Sudan",
  "ES": "Spain",
  "LK": "Sri Lanka",
  "BL": "St. Barth\u00e9lemy",
  "SH": "St. Helena",
  "KN": "St. Kitts & Nevis",
  "LC": "St. Lucia",
  "MF": "St. Martin",
  "PM": "St. Pierre & Miquelon",
  "VC": "St. Vincent & Grenadines",
  "SD": "Sudan",
  "SR": "Suriname",
  "SJ": "Svalbard & Jan Mayen",
  "SE": "Sweden",
  "CH": "Switzerland",
  "SY": "Syria",
  "TW": "Taiwan",
  "TJ": "Tajikistan",
  "TZ": "Tanzania",
  "TH": "Thailand",
  "TL": "Timor-Leste",
  "TG": "Togo",
  "TK": "Tokelau",
  "TO": "Tonga",
  "TT": "Trinidad & Tobago",
  "TN": "Tunisia",
  "TR": "Turkey",
  "TM": "Turkmenistan",
  "TC": "Turks & Caicos Islands",
  "TV": "Tuvalu",
  "UM": "U.S. Outlying Islands",
  "VI": "U.S. Virgin Islands",
  "UG": "Uganda",
  "UA": "Ukraine",
  "AE": "United Arab Emirates",
  "GB": "United Kingdom",
  "US": "United States",
  "UY": "Uruguay",
  "UZ": "Uzbekistan",
  "VU": "Vanuatu",
  "VA": "Vatican City",
  "VE": "Venezuela",
  "VN": "Vietnam",
  "WF": "Wallis & Futuna",
  "EH": "Western Sahara",
  "YE": "Yemen",
  "ZM": "Zambia",
  "ZW": "Zimbabwe"
}



================================================
FILE: public/intl/country/en-US.json
================================================
{
  "AF": "Afghanistan",
  "AX": "\u00c5land Islands",
  "AL": "Albania",
  "DZ": "Algeria",
  "AS": "American Samoa",
  "AD": "Andorra",
  "AO": "Angola",
  "AI": "Anguilla",
  "AQ": "Antarctica",
  "AG": "Antigua & Barbuda",
  "AR": "Argentina",
  "AM": "Armenia",
  "AW": "Aruba",
  "AU": "Australia",
  "AT": "Austria",
  "AZ": "Azerbaijan",
  "BS": "Bahamas",
  "BH": "Bahrain",
  "BD": "Bangladesh",
  "BB": "Barbados",
  "BY": "Belarus",
  "BE": "Belgium",
  "BZ": "Belize",
  "BJ": "Benin",
  "BM": "Bermuda",
  "BT": "Bhutan",
  "BO": "Bolivia",
  "BA": "Bosnia & Herzegovina",
  "BW": "Botswana",
  "BV": "Bouvet Island",
  "BR": "Brazil",
  "IO": "British Indian Ocean Territory",
  "VG": "British Virgin Islands",
  "BN": "Brunei",
  "BG": "Bulgaria",
  "BF": "Burkina Faso",
  "BI": "Burundi",
  "KH": "Cambodia",
  "CM": "Cameroon",
  "CA": "Canada",
  "CV": "Cape Verde",
  "BQ": "Caribbean Netherlands",
  "KY": "Cayman Islands",
  "CF": "Central African Republic",
  "TD": "Chad",
  "CL": "Chile",
  "CN": "China",
  "CX": "Christmas Island",
  "CC": "Cocos (Keeling) Islands",
  "CO": "Colombia",
  "KM": "Comoros",
  "CG": "Congo - Brazzaville",
  "CD": "Congo - Kinshasa",
  "CK": "Cook Islands",
  "CR": "Costa Rica",
  "CI": "C\u00f4te d\u2019Ivoire",
  "HR": "Croatia",
  "CU": "Cuba",
  "CW": "Cura\u00e7ao",
  "CY": "Cyprus",
  "CZ": "Czechia",
  "DK": "Denmark",
  "DJ": "Djibouti",
  "DM": "Dominica",
  "DO": "Dominican Republic",
  "EC": "Ecuador",
  "EG": "Egypt",
  "SV": "El Salvador",
  "GQ": "Equatorial Guinea",
  "ER": "Eritrea",
  "EE": "Estonia",
  "SZ": "Eswatini",
  "ET": "Ethiopia",
  "FK": "Falkland Islands",
  "FO": "Faroe Islands",
  "FJ": "Fiji",
  "FI": "Finland",
  "FR": "France",
  "GF": "French Guiana",
  "PF": "French Polynesia",
  "TF": "French Southern Territories",
  "GA": "Gabon",
  "GM": "Gambia",
  "GE": "Georgia",
  "DE": "Germany",
  "GH": "Ghana",
  "GI": "Gibraltar",
  "GR": "Greece",
  "GL": "Greenland",
  "GD": "Grenada",
  "GP": "Guadeloupe",
  "GU": "Guam",
  "GT": "Guatemala",
  "GG": "Guernsey",
  "GN": "Guinea",
  "GW": "Guinea-Bissau",
  "GY": "Guyana",
  "HT": "Haiti",
  "HM": "Heard & McDonald Islands",
  "HN": "Honduras",
  "HK": "Hong Kong SAR China",
  "HU": "Hungary",
  "IS": "Iceland",
  "IN": "India",
  "ID": "Indonesia",
  "IR": "Iran",
  "IQ": "Iraq",
  "IE": "Ireland",
  "IM": "Isle of Man",
  "IL": "Israel",
  "IT": "Italy",
  "JM": "Jamaica",
  "JP": "Japan",
  "JE": "Jersey",
  "JO": "Jordan",
  "KZ": "Kazakhstan",
  "KE": "Kenya",
  "KI": "Kiribati",
  "XK": "Kosovo",
  "KW": "Kuwait",
  "KG": "Kyrgyzstan",
  "LA": "Laos",
  "LV": "Latvia",
  "LB": "Lebanon",
  "LS": "Lesotho",
  "LR": "Liberia",
  "LY": "Libya",
  "LI": "Liechtenstein",
  "LT": "Lithuania",
  "LU": "Luxembourg",
  "MO": "Macao SAR China",
  "MG": "Madagascar",
  "MW": "Malawi",
  "MY": "Malaysia",
  "MV": "Maldives",
  "ML": "Mali",
  "MT": "Malta",
  "MH": "Marshall Islands",
  "MQ": "Martinique",
  "MR": "Mauritania",
  "MU": "Mauritius",
  "YT": "Mayotte",
  "MX": "Mexico",
  "FM": "Micronesia",
  "MD": "Moldova",
  "MC": "Monaco",
  "MN": "Mongolia",
  "ME": "Montenegro",
  "MS": "Montserrat",
  "MA": "Morocco",
  "MZ": "Mozambique",
  "MM": "Myanmar (Burma)",
  "NA": "Namibia",
  "NR": "Nauru",
  "NP": "Nepal",
  "NL": "Netherlands",
  "NC": "New Caledonia",
  "NZ": "New Zealand",
  "NI": "Nicaragua",
  "NE": "Niger",
  "NG": "Nigeria",
  "NU": "Niue",
  "NF": "Norfolk Island",
  "KP": "North Korea",
  "MK": "North Macedonia",
  "MP": "Northern Mariana Islands",
  "NO": "Norway",
  "OM": "Oman",
  "PK": "Pakistan",
  "PW": "Palau",
  "PS": "Palestinian Territories",
  "PA": "Panama",
  "PG": "Papua New Guinea",
  "PY": "Paraguay",
  "PE": "Peru",
  "PH": "Philippines",
  "PN": "Pitcairn Islands",
  "PL": "Poland",
  "PT": "Portugal",
  "PR": "Puerto Rico",
  "QA": "Qatar",
  "RE": "R\u00e9union",
  "RO": "Romania",
  "RU": "Russia",
  "RW": "Rwanda",
  "WS": "Samoa",
  "SM": "San Marino",
  "ST": "S\u00e3o Tom\u00e9 & Pr\u00edncipe",
  "SA": "Saudi Arabia",
  "SN": "Senegal",
  "RS": "Serbia",
  "SC": "Seychelles",
  "SL": "Sierra Leone",
  "SG": "Singapore",
  "SX": "Sint Maarten",
  "SK": "Slovakia",
  "SI": "Slovenia",
  "SB": "Solomon Islands",
  "SO": "Somalia",
  "ZA": "South Africa",
  "GS": "South Georgia & South Sandwich Islands",
  "KR": "South Korea",
  "SS": "South Sudan",
  "ES": "Spain",
  "LK": "Sri Lanka",
  "BL": "St. Barth\u00e9lemy",
  "SH": "St. Helena",
  "KN": "St. Kitts & Nevis",
  "LC": "St. Lucia",
  "MF": "St. Martin",
  "PM": "St. Pierre & Miquelon",
  "VC": "St. Vincent & Grenadines",
  "SD": "Sudan",
  "SR": "Suriname",
  "SJ": "Svalbard & Jan Mayen",
  "SE": "Sweden",
  "CH": "Switzerland",
  "SY": "Syria",
  "TW": "Taiwan",
  "TJ": "Tajikistan",
  "TZ": "Tanzania",
  "TH": "Thailand",
  "TL": "Timor-Leste",
  "TG": "Togo",
  "TK": "Tokelau",
  "TO": "Tonga",
  "TT": "Trinidad & Tobago",
  "TN": "Tunisia",
  "TR": "Turkey",
  "TM": "Turkmenistan",
  "TC": "Turks & Caicos Islands",
  "TV": "Tuvalu",
  "UM": "U.S. Outlying Islands",
  "VI": "U.S. Virgin Islands",
  "UG": "Uganda",
  "UA": "Ukraine",
  "AE": "United Arab Emirates",
  "GB": "United Kingdom",
  "US": "United States",
  "UY": "Uruguay",
  "UZ": "Uzbekistan",
  "VU": "Vanuatu",
  "VA": "Vatican City",
  "VE": "Venezuela",
  "VN": "Vietnam",
  "WF": "Wallis & Futuna",
  "EH": "Western Sahara",
  "YE": "Yemen",
  "ZM": "Zambia",
  "ZW": "Zimbabwe"
}



================================================
FILE: public/intl/country/es-ES.json
================================================
{
  "AF": "Afganist\u00e1n",
  "AL": "Albania",
  "DE": "Alemania",
  "AD": "Andorra",
  "AO": "Angola",
  "AI": "Anguila",
  "AQ": "Ant\u00e1rtida",
  "AG": "Antigua y Barbuda",
  "SA": "Arabia Saud\u00ed",
  "DZ": "Argelia",
  "AR": "Argentina",
  "AM": "Armenia",
  "AW": "Aruba",
  "AU": "Australia",
  "AT": "Austria",
  "AZ": "Azerbaiy\u00e1n",
  "BS": "Bahamas",
  "BD": "Banglad\u00e9s",
  "BB": "Barbados",
  "BH": "Bar\u00e9in",
  "BE": "B\u00e9lgica",
  "BZ": "Belice",
  "BJ": "Ben\u00edn",
  "BM": "Bermudas",
  "BY": "Bielorrusia",
  "BO": "Bolivia",
  "BA": "Bosnia y Herzegovina",
  "BW": "Botsuana",
  "BR": "Brasil",
  "BN": "Brun\u00e9i",
  "BG": "Bulgaria",
  "BF": "Burkina Faso",
  "BI": "Burundi",
  "BT": "But\u00e1n",
  "CV": "Cabo Verde",
  "KH": "Camboya",
  "CM": "Camer\u00fan",
  "CA": "Canad\u00e1",
  "BQ": "Caribe neerland\u00e9s",
  "QA": "Catar",
  "TD": "Chad",
  "CZ": "Chequia",
  "CL": "Chile",
  "CN": "China",
  "CY": "Chipre",
  "VA": "Ciudad del Vaticano",
  "CO": "Colombia",
  "KM": "Comoras",
  "CG": "Congo",
  "KP": "Corea del Norte",
  "KR": "Corea del Sur",
  "CR": "Costa Rica",
  "CI": "C\u00f4te d\u2019Ivoire",
  "HR": "Croacia",
  "CU": "Cuba",
  "CW": "Curazao",
  "DK": "Dinamarca",
  "DM": "Dominica",
  "EC": "Ecuador",
  "EG": "Egipto",
  "SV": "El Salvador",
  "AE": "Emiratos \u00c1rabes Unidos",
  "ER": "Eritrea",
  "SK": "Eslovaquia",
  "SI": "Eslovenia",
  "ES": "Espa\u00f1a",
  "US": "Estados Unidos",
  "EE": "Estonia",
  "SZ": "Esuatini",
  "ET": "Etiop\u00eda",
  "PH": "Filipinas",
  "FI": "Finlandia",
  "FJ": "Fiyi",
  "FR": "Francia",
  "GA": "Gab\u00f3n",
  "GM": "Gambia",
  "GE": "Georgia",
  "GH": "Ghana",
  "GI": "Gibraltar",
  "GD": "Granada",
  "GR": "Grecia",
  "GL": "Groenlandia",
  "GP": "Guadalupe",
  "GU": "Guam",
  "GT": "Guatemala",
  "GF": "Guayana Francesa",
  "GG": "Guernsey",
  "GN": "Guinea",
  "GQ": "Guinea Ecuatorial",
  "GW": "Guinea-Bis\u00e1u",
  "GY": "Guyana",
  "HT": "Hait\u00ed",
  "HN": "Honduras",
  "HU": "Hungr\u00eda",
  "IN": "India",
  "ID": "Indonesia",
  "IQ": "Irak",
  "IR": "Ir\u00e1n",
  "IE": "Irlanda",
  "BV": "Isla Bouvet",
  "IM": "Isla de Man",
  "CX": "Isla de Navidad",
  "NF": "Isla Norfolk",
  "IS": "Islandia",
  "AX": "Islas \u00c5land",
  "KY": "Islas Caim\u00e1n",
  "CC": "Islas Cocos",
  "CK": "Islas Cook",
  "FO": "Islas Feroe",
  "GS": "Islas Georgia del Sur y Sandwich del Sur",
  "HM": "Islas Heard y McDonald",
  "FK": "Islas Malvinas",
  "MP": "Islas Marianas del Norte",
  "MH": "Islas Marshall",
  "UM": "Islas menores alejadas de EE. UU.",
  "PN": "Islas Pitcairn",
  "SB": "Islas Salom\u00f3n",
  "TC": "Islas Turcas y Caicos",
  "VG": "Islas V\u00edrgenes Brit\u00e1nicas",
  "VI": "Islas V\u00edrgenes de EE. UU.",
  "IL": "Israel",
  "IT": "Italia",
  "JM": "Jamaica",
  "JP": "Jap\u00f3n",
  "JE": "Jersey",
  "JO": "Jordania",
  "KZ": "Kazajist\u00e1n",
  "KE": "Kenia",
  "KG": "Kirguist\u00e1n",
  "KI": "Kiribati",
  "XK": "Kosovo",
  "KW": "Kuwait",
  "LA": "Laos",
  "LS": "Lesoto",
  "LV": "Letonia",
  "LB": "L\u00edbano",
  "LR": "Liberia",
  "LY": "Libia",
  "LI": "Liechtenstein",
  "LT": "Lituania",
  "LU": "Luxemburgo",
  "MK": "Macedonia del Norte",
  "MG": "Madagascar",
  "MY": "Malasia",
  "MW": "Malaui",
  "MV": "Maldivas",
  "ML": "Mali",
  "MT": "Malta",
  "MA": "Marruecos",
  "MQ": "Martinica",
  "MU": "Mauricio",
  "MR": "Mauritania",
  "YT": "Mayotte",
  "MX": "M\u00e9xico",
  "FM": "Micronesia",
  "MD": "Moldavia",
  "MC": "M\u00f3naco",
  "MN": "Mongolia",
  "ME": "Montenegro",
  "MS": "Montserrat",
  "MZ": "Mozambique",
  "MM": "Myanmar (Birmania)",
  "NA": "Namibia",
  "NR": "Nauru",
  "NP": "Nepal",
  "NI": "Nicaragua",
  "NE": "N\u00edger",
  "NG": "Nigeria",
  "NU": "Niue",
  "NO": "Noruega",
  "NC": "Nueva Caledonia",
  "NZ": "Nueva Zelanda",
  "OM": "Om\u00e1n",
  "NL": "Pa\u00edses Bajos",
  "PK": "Pakist\u00e1n",
  "PW": "Palaos",
  "PA": "Panam\u00e1",
  "PG": "Pap\u00faa Nueva Guinea",
  "PY": "Paraguay",
  "PE": "Per\u00fa",
  "PF": "Polinesia Francesa",
  "PL": "Polonia",
  "PT": "Portugal",
  "PR": "Puerto Rico",
  "HK": "RAE de Hong Kong (China)",
  "MO": "RAE de Macao (China)",
  "GB": "Reino Unido",
  "CF": "Rep\u00fablica Centroafricana",
  "CD": "Rep\u00fablica Democr\u00e1tica del Congo",
  "DO": "Rep\u00fablica Dominicana",
  "RE": "Reuni\u00f3n",
  "RW": "Ruanda",
  "RO": "Ruman\u00eda",
  "RU": "Rusia",
  "EH": "S\u00e1hara Occidental",
  "WS": "Samoa",
  "AS": "Samoa Americana",
  "BL": "San Bartolom\u00e9",
  "KN": "San Crist\u00f3bal y Nieves",
  "SM": "San Marino",
  "MF": "San Mart\u00edn",
  "PM": "San Pedro y Miquel\u00f3n",
  "VC": "San Vicente y las Granadinas",
  "SH": "Santa Elena",
  "LC": "Santa Luc\u00eda",
  "ST": "Santo Tom\u00e9 y Pr\u00edncipe",
  "SN": "Senegal",
  "RS": "Serbia",
  "SC": "Seychelles",
  "SL": "Sierra Leona",
  "SG": "Singapur",
  "SX": "Sint Maarten",
  "SY": "Siria",
  "SO": "Somalia",
  "LK": "Sri Lanka",
  "ZA": "Sud\u00e1frica",
  "SD": "Sud\u00e1n",
  "SS": "Sud\u00e1n del Sur",
  "SE": "Suecia",
  "CH": "Suiza",
  "SR": "Surinam",
  "SJ": "Svalbard y Jan Mayen",
  "TH": "Tailandia",
  "TW": "Taiw\u00e1n",
  "TZ": "Tanzania",
  "TJ": "Tayikist\u00e1n",
  "IO": "Territorio Brit\u00e1nico del Oc\u00e9ano \u00cdndico",
  "TF": "Territorios Australes Franceses",
  "PS": "Territorios Palestinos",
  "TL": "Timor-Leste",
  "TG": "Togo",
  "TK": "Tokelau",
  "TO": "Tonga",
  "TT": "Trinidad y Tobago",
  "TN": "T\u00fanez",
  "TM": "Turkmenist\u00e1n",
  "TR": "Turqu\u00eda",
  "TV": "Tuvalu",
  "UA": "Ucrania",
  "UG": "Uganda",
  "UY": "Uruguay",
  "UZ": "Uzbekist\u00e1n",
  "VU": "Vanuatu",
  "VE": "Venezuela",
  "VN": "Vietnam",
  "WF": "Wallis y Futuna",
  "YE": "Yemen",
  "DJ": "Yibuti",
  "ZM": "Zambia",
  "ZW": "Zimbabue"
}



================================================
FILE: public/intl/country/es-MX.json
================================================
{
  "AF": "Afganist\u00e1n",
  "AL": "Albania",
  "DE": "Alemania",
  "AD": "Andorra",
  "AO": "Angola",
  "AI": "Anguila",
  "AQ": "Ant\u00e1rtida",
  "AG": "Antigua y Barbuda",
  "SA": "Arabia Saudita",
  "DZ": "Argelia",
  "AR": "Argentina",
  "AM": "Armenia",
  "AW": "Aruba",
  "AU": "Australia",
  "AT": "Austria",
  "AZ": "Azerbaiy\u00e1n",
  "BS": "Bahamas",
  "BD": "Banglad\u00e9s",
  "BB": "Barbados",
  "BH": "Bar\u00e9in",
  "BE": "B\u00e9lgica",
  "BZ": "Belice",
  "BJ": "Ben\u00edn",
  "BM": "Bermudas",
  "BY": "Bielorrusia",
  "BO": "Bolivia",
  "BA": "Bosnia y Herzegovina",
  "BW": "Botsuana",
  "BR": "Brasil",
  "BN": "Brun\u00e9i",
  "BG": "Bulgaria",
  "BF": "Burkina Faso",
  "BI": "Burundi",
  "BT": "But\u00e1n",
  "CV": "Cabo Verde",
  "KH": "Camboya",
  "CM": "Camer\u00fan",
  "CA": "Canad\u00e1",
  "BQ": "Caribe neerland\u00e9s",
  "QA": "Catar",
  "TD": "Chad",
  "CZ": "