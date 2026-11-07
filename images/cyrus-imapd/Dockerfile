FROM almalinux:10
RUN dnf -y upgrade --refresh && dnf -y install cyrus-imapd cyrus-imapd-utils cyrus-sasl ca-certificates && dnf clean all && rm -rf /var/cache/dnf
EXPOSE 143 993
STOPSIGNAL SIGTERM
CMD ["/usr/libexec/cyrus-imapd/master", "-D"]
