ARG BASE_IMAGE=local/saslauthd:test
FROM ${BASE_IMAGE}
RUN dnf -y install shadow-utils && dnf clean all && rm -rf /var/cache/dnf \
 && useradd --create-home --shell /sbin/nologin testmail \
 && printf 'testmail:IntegrationTestOnly-7sK9!\n' | chpasswd
COPY mail /etc/pam.d/mail
