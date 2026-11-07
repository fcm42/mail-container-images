#!/usr/bin/env bash
set -euo pipefail
RUNTIME="${RUNTIME:-docker}"
IMAGE="${IMAGE:-local/saslauthd:test}"
NAME="saslauthd-smoke-$$"
VOL="saslauthd-smoke-$$"
cleanup() { "$RUNTIME" rm -f "$NAME" >/dev/null 2>&1 || :; "$RUNTIME" volume rm "$VOL" >/dev/null 2>&1 || :; }
trap cleanup EXIT
"$RUNTIME" volume create "$VOL" >/dev/null
"$RUNTIME" run -d --name "$NAME" -v "$VOL:/run/saslauthd" -v "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/fixtures/pam/mail:/etc/pam.d/mail:ro" "$IMAGE" >/dev/null
for i in $(seq 1 20); do
  if "$RUNTIME" exec "$NAME" test -S /run/saslauthd/mux; then
    echo 'PASS: saslauthd mux socket exists'; exit 0
  fi
  if [ "$("$RUNTIME" inspect -f '{{.State.Running}}' "$NAME")" != true ]; then
    "$RUNTIME" logs "$NAME"; echo 'FAIL: container stopped' >&2; exit 1
  fi
  sleep 1
done
"$RUNTIME" logs "$NAME"
echo 'FAIL: socket was not created' >&2
exit 1
