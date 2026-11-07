FROM almalinux:10
RUN dnf -y upgrade --refresh \
 && dnf -y install cyrus-sasl cyrus-sasl-plain cyrus-sasl-ldap cyrus-sasl-md5 ca-certificates \
 && dnf clean all && rm -rf /var/cache/dnf
COPY --chmod=0755 entrypoint.sh /usr/local/bin/saslauthd-entrypoint
RUN mkdir -p /run/saslauthd
STOPSIGNAL SIGTERM
ENTRYPOINT ["/usr/local/bin/saslauthd-entrypoint"]
