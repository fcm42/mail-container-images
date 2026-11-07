#!/usr/bin/env bash
set -euo pipefail
RUNTIME="${RUNTIME:-docker}"
BASE_IMAGE="${IMAGE:-local/saslauthd:test}"
TEST_IMAGE="local/saslauthd-pam-test:$$"
NAME="saslauthd-pam-test-$$"
VOL="saslauthd-pam-test-$$"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cleanup() {
  "$RUNTIME" rm -f "$NAME" >/dev/null 2>&1 || :
  "$RUNTIME" volume rm "$VOL" >/dev/null 2>&1 || :
  "$RUNTIME" image rm "$TEST_IMAGE" >/dev/null 2>&1 || :
}
trap cleanup EXIT
# Only the disposable test image contains a local user and test password.
"$RUNTIME" build --build-arg "BASE_IMAGE=$BASE_IMAGE" -t "$TEST_IMAGE" "$ROOT/tests/fixtures/pam"
"$RUNTIME" volume create "$VOL" >/dev/null
"$RUNTIME" run -d --name "$NAME" \
  -e SASLAUTHD_MECHANISM=pam -e SASLAUTHD_PAM_SERVICE=mail \
  -v "$VOL:/run/saslauthd" "$TEST_IMAGE" >/dev/null
for i in $(seq 1 25); do
  if "$RUNTIME" exec "$NAME" test -S /run/saslauthd/mux; then break; fi
  if [ "$("$RUNTIME" inspect -f '{{.State.Running}}' "$NAME")" != true ]; then
    "$RUNTIME" logs "$NAME"; echo 'FAIL: saslauthd stopped' >&2; exit 1
  fi
  sleep 1
done
"$RUNTIME" exec "$NAME" test -S /run/saslauthd/mux || { "$RUNTIME" logs "$NAME"; exit 1; }
# Run Python client in a disposable helper container sharing the same volume.
# The helper uses its own Python runtime, not the production saslauthd image.
client() {
  "$RUNTIME" run --rm -v "$VOL:/socket:ro" \
    -v "$ROOT/tests/saslauthd-auth-client.py:/auth-client.py:ro" \
    --entrypoint python3 docker.io/library/python:3.13-alpine \
    /auth-client.py /socket/mux testmail "$1" smtp ''
}
if client 'IntegrationTestOnly-7sK9!' >/dev/null; then
  echo 'PASS: valid PAM credentials accepted'
else
  "$RUNTIME" logs "$NAME"; echo 'FAIL: valid PAM credentials rejected' >&2; exit 1
fi
if client 'incorrect-password' >/dev/null; then
  echo 'FAIL: invalid PAM credentials accepted' >&2; exit 1
else
  echo 'PASS: invalid PAM credentials rejected'
fi
