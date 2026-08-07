#!/usr/bin/env bash
# Smoke test for the Alibaba Cloud Token Plan endpoint.
#
# Reads the key from ALIBABA_TOKEN_PLAN_API_KEY (or DASHSCOPE_API_KEY as a
# fallback), then lists the models available on the Token Plan endpoint.
# Prints only status + model count — never the key.
#
# Usage: ALIBABA_TOKEN_PLAN_API_KEY=sk-sp-... ./scripts/smoke-test.sh

set -euo pipefail

KEY="${ALIBABA_TOKEN_PLAN_API_KEY:-${DASHSCOPE_API_KEY:-}}"
ENDPOINT="https://token-plan.ap-southeast-1.maas.aliyuncs.com/compatible-mode/v1"

# Fall back to ~/.hermes/.env if neither env var is set.
if [ -z "$KEY" ] && [ -f "${HOME}/.hermes/.env" ]; then
  KEY="$(grep -E '^(ALIBABA_TOKEN_PLAN_API_KEY|DASHSCOPE_API_KEY)=' "${HOME}/.hermes/.env" | head -1 | cut -d= -f2- | tr -d '"' || true)"
fi

if [ -z "$KEY" ]; then
  echo "ERROR: set ALIBABA_TOKEN_PLAN_API_KEY (or DASHSCOPE_API_KEY) first." >&2
  exit 1
fi

echo "Probing ${ENDPOINT} ..."
STATUS="$(curl -s -o /tmp/token-plan-models.json -w '%{http_code}' \
  -H "Authorization: Bearer ${KEY}" "${ENDPOINT}/models")"

if [ "$STATUS" = "200" ]; then
  COUNT="$(python3 -c "import json;print(len(json.load(open('/tmp/token-plan-models.json')).get('data',[])))")"
  echo "OK: HTTP 200 — ${COUNT} models available on the Token Plan endpoint."
  python3 -c "import json;[print('  ', m['id']) for m in json.load(open('/tmp/token-plan-models.json')).get('data',[])]"
else
  echo "FAILED: HTTP ${STATUS}"
  head -c 300 /tmp/token-plan-models.json
  echo
  exit 1
fi
