#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f package.json ]]; then
  echo "[next-build-debug] package.json not found. Skip (template script)."
  exit 0
fi

echo "[next-build-debug] Node: $(node -v 2>/dev/null || echo 'N/A')"
echo "[next-build-debug] npm: $(npm -v 2>/dev/null || echo 'N/A')"

package_manager="npm"
if grep -q '"packageManager"[[:space:]]*:[[:space:]]*"pnpm@' package.json; then
  package_manager="pnpm"
elif [[ -f pnpm-lock.yaml ]]; then
  package_manager="pnpm"
elif [[ -f yarn.lock ]]; then
  package_manager="yarn"
fi

echo "[next-build-debug] package manager: ${package_manager}"

if [[ "${package_manager}" == "pnpm" ]]; then
  corepack enable
  corepack prepare pnpm@latest --activate
  pnpm --version
  pnpm install --frozen-lockfile || pnpm install
  (npx next info || true)
  NODE_OPTIONS="--trace-uncaught --trace-warnings" pnpm run build
elif [[ "${package_manager}" == "yarn" ]]; then
  yarn --version
  yarn install --frozen-lockfile || yarn install
  (npx next info || true)
  NODE_OPTIONS="--trace-uncaught --trace-warnings" yarn build
else
  npm ci || npm install
  (npx next info || true)
  NODE_OPTIONS="--trace-uncaught --trace-warnings" npm run build
fi
