FROM almalinux:10
RUN dnf -y upgrade --refresh && dnf -y install postfix cyrus-sasl cyrus-sasl-plain ca-certificates && dnf clean all && rm -rf /var/cache/dnf
EXPOSE 25 587
STOPSIGNAL SIGTERM
CMD ["/usr/sbin/postfix", "start-fg"]
