#!/bin/sh
set -eu
: "${SASLAUTHD_MECHANISM:=pam}"
: "${SASLAUTHD_SOCKET_DIR:=/run/saslauthd}"
: "${SASLAUTHD_THREADS:=5}"
case "$SASLAUTHD_MECHANISM" in *[!a-zA-Z0-9_-]*|'') echo "Invalid SASLAUTHD_MECHANISM" >&2; exit 2;; esac
case "$SASLAUTHD_THREADS" in *[!0-9]*|'') echo "Invalid SASLAUTHD_THREADS" >&2; exit 2;; esac
[ "$SASLAUTHD_THREADS" -ge 1 ] || exit 2
# A PAM service must be provided externally; never silently fall back to other stacks.
mkdir -p "$SASLAUTHD_SOCKET_DIR"
# The socket directory must be writable by saslauthd and accessible to consumers.
# Do not chmod a shared mount here: ownership is a deployment responsibility.
exec /usr/sbin/saslauthd \
     -a "$SASLAUTHD_MECHANISM" \
     -n "$SASLAUTHD_THREADS" \
     -m "$SASLAUTHD_SOCKET_DIR" \
     -d
