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
