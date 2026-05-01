#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ENV_FILE:-$ROOT_DIR/.env}"
SPLIT_DEBUG_INFO_DIR="${SPLIT_DEBUG_INFO_DIR:-build/sentry-debug-info}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing $ENV_FILE. Copy .env.example to .env and fill in release values." >&2
  exit 1
fi

set -a
source "$ENV_FILE"
set +a

required_vars=(
  SENTRY_DSN
  SENTRY_ENVIRONMENT
  SENTRY_RELEASE
  PRIVACY_POLICY_URL
)

for var_name in "${required_vars[@]}"; do
  if [[ -z "${!var_name:-}" ]]; then
    echo "Missing required environment variable: $var_name" >&2
    exit 1
  fi
done

if [[ "$PRIVACY_POLICY_URL" == "YOUR_PUBLIC_GIST_URL" ]]; then
  echo "PRIVACY_POLICY_URL still points at the placeholder value." >&2
  echo "Publish docs/privacy-policy.md to a public URL, then update .env." >&2
  exit 1
fi

build_args=(
  appbundle
  --release
  --dart-define=SENTRY_DSN="$SENTRY_DSN"
  --dart-define=SENTRY_ENVIRONMENT="$SENTRY_ENVIRONMENT"
  --dart-define=SENTRY_RELEASE="$SENTRY_RELEASE"
  --dart-define=PRIVACY_POLICY_URL="$PRIVACY_POLICY_URL"
)

if [[ -n "${BUILD_NAME:-}" ]]; then
  build_args+=(--build-name="$BUILD_NAME")
fi

if [[ -n "${BUILD_NUMBER:-}" ]]; then
  build_args+=(--build-number="$BUILD_NUMBER")
fi

if [[ -n "$SPLIT_DEBUG_INFO_DIR" ]]; then
  mkdir -p "$ROOT_DIR/$SPLIT_DEBUG_INFO_DIR"
  build_args+=(--split-debug-info="$SPLIT_DEBUG_INFO_DIR")
fi

flutter build "${build_args[@]}"
