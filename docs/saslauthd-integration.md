# saslauthd runtime validation (iteration 2)

This milestone checks that the daemon starts and creates `/run/saslauthd/mux`. **It does not test successful authentication.** The default `pam` mechanism authenticates against the container's PAM setup, not automatically against host accounts or LDAP. Do not expose the socket to untrusted containers or users.

```bash
docker build -t local/saslauthd:test images/saslauthd
./tests/saslauthd-runtime.sh
RUNTIME=podman ./tests/saslauthd-runtime.sh
```

The test uses a named volume and removes it after completion. It assumes a working local container runtime. The smoke test does not verify rootless operation, SELinux labels, cross-container socket permissions or successful authentication.

## Next integration milestone

1. Choose a concrete authentication backend (e.g. LDAP, PAM with a deliberate configuration). Avoid treating the default PAM setup as production-ready.
2. Determine effective UID/GID, SELinux labels and socket permissions for Postfix and Cyrus IMAPd; verify access from each consumer. Shared bind mounts on SELinux systems generally require shared labeling (`:z`) or a dedicated policy, not private `:Z` labels on each container.
3. Validate with `testsaslauthd` (including a valid and invalid credential) using the selected backend.
4. Test Postfix SMTP AUTH and Cyrus IMAP authentication end-to-end. The two consumers may require distinct SASL configuration and socket paths.
5. Confirm SIGTERM shutdown, restart behavior and rootless Podman deployment. Do not mount the host `/etc/shadow` as a shortcut.

`SASLAUTHD_MECHANISM`, `SASLAUTHD_SOCKET_DIR` and `SASLAUTHD_THREADS` can be configured via environment variables. Only use trusted configuration values. The container does not modify permissions of externally mounted directories.
