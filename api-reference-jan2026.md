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

