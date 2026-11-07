# Mail container images (initial scaffold)

AlmaLinux 10 images for Postfix, Cyrus IMAPd and saslauthd, targeting OCI-compatible Docker and Podman.

## Status: bootstrap / NOT production-ready

Dockerfiles are preliminary. They have **not** been built or tested in this environment. Package availability, Cyrus master binary path, daemon foreground behavior, UID/GID, SELinux, shared SASL sockets, persistent volumes, configuration, health checks and safe upgrades all require validation. The CI currently builds every image and publishes **nothing**. Grype and Grant are not yet installed or run. Do not deploy as a mail service.

## Build locally

```sh
docker build -t local/postfix:test images/postfix
docker build -t local/cyrus-imapd:test images/cyrus-imapd
docker build -t local/saslauthd:test images/saslauthd
```

Use `podman build` instead of `docker build` to validate Podman.

## Planned milestones

1. Validate AlmaLinux 10 RPM package availability and process commands.
2. Implement configuration mounts, data volumes, non-root permissions, socket integration and real integration tests.
3. Add version-pinned Syft, Grype and Grant reporting with artifact retention; scan findings informational.
4. Publish tested OCI images to GHCR with immutable digests and SBOM association.
5. Add selective change detection, RPM update checks, Renovate digest pinning, scheduled rescans.
6. Test RHEL 9, Ubuntu 24.04, Debian 13 with Docker and Podman; prepare optional Quadlets.

## Iteration 2: saslauthd runtime smoke test

The saslauthd image now has a configurable foreground entrypoint and a socket-creation smoke test. See `docs/saslauthd-integration.md`. This does not yet prove successful PAM/LDAP authentication or cross-container integration.

### Iteration 3: PAM integration test

The saslauthd image now uses `SASLAUTHD_PAM_SERVICE=mail` by default. A matching
`/etc/pam.d/mail` must be mounted at runtime. No local users, passwords, or LDAP
credentials are embedded in the production image. The `cyrus-sasl-utils` RPM is
intentionally **not** installed (unavailable on AlmaLinux 10).

```sh
docker build -t local/saslauthd:test images/saslauthd
./tests/saslauthd-runtime.sh
./tests/saslauthd-pam.sh
# Or: RUNTIME=podman ./tests/saslauthd-pam.sh
```

The PAM integration test creates a disposable test-only image containing a
local test account, mounts a disposable socket volume, tests correct and
incorrect passwords through the actual saslauthd mux protocol, and cleans up.
The test password is deliberately public and **must never be used outside CI**.
The helper client uses `python:3.13-alpine` and requires image pull access.

For production, mount the PAM stack at `/etc/pam.d/mail:ro`, install/configure
appropriate PAM/LDAP dependencies in a separately reviewed image extension,
and verify NSS user lookup and account checks. Mounting only `pam_ldap.so`
configuration is not sufficient unless the module and its dependencies exist.
Do not mount host `/etc/shadow` into this image.

On SELinux-enforcing Podman hosts, the test's file bind mount may require
appropriate labeling; avoid automatically relabeling system-owned PAM files.
