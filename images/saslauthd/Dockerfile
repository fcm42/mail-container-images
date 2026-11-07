FROM almalinux:10
RUN dnf -y upgrade --refresh && dnf -y install cyrus-sasl cyrus-sasl-plain ca-certificates && dnf clean all && rm -rf /var/cache/dnf
RUN mkdir -p /run/saslauthd
VOLUME ["/run/saslauthd"]
STOPSIGNAL SIGTERM
CMD ["/usr/sbin/saslauthd", "-a", "pam", "-m", "/run/saslauthd", "-n", "5", "-d"]
