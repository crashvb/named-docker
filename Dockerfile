FROM crashvb/supervisord:202201080446@sha256:8fe6a411bea68df4b4c6c611db63c22f32c4a455254fa322f381d72340ea7226
ARG org_opencontainers_image_created=undefined
ARG org_opencontainers_image_revision=undefined
LABEL \
	org.opencontainers.image.authors="Richard Davis <crashvb@gmail.com>" \
	org.opencontainers.image.base.digest="sha256:8fe6a411bea68df4b4c6c611db63c22f32c4a455254fa322f381d72340ea7226" \
	org.opencontainers.image.base.name="crashvb/supervisord:202201080446" \
	org.opencontainers.image.created="${org_opencontainers_image_created}" \
	org.opencontainers.image.description="Image containing named." \
	org.opencontainers.image.licenses="Apache-2.0" \
	org.opencontainers.image.source="https://github.com/crashvb/named-docker" \
	org.opencontainers.image.revision="${org_opencontainers_image_revision}" \
	org.opencontainers.image.title="crashvb/named" \
	org.opencontainers.image.url="https://github.com/crashvb/named-docker"

# Install packages, download files ...
RUN docker-apt bind9 dnsutils

# Configure: bind9
ENV BIND_CONFIG=/etc/bind
COPY bind-* /usr/local/bin/
COPY db.* named.conf.* zones.* /usr/local/share/bind/
RUN install --directory --group=bind --mode=0775 --owner=root /var/lib/bind /var/run/named && \
	install --directory --group=adm --mode=0755 --owner=bind /var/log/bind && \
	sed --expression="/conf.options/iinclude \"${BIND_CONFIG}/named.conf.rndc\";" --in-place ${BIND_CONFIG}/named.conf && \
	sed --expression="/conf.options/ainclude \"${BIND_CONFIG}/named.conf.keys\";" --in-place ${BIND_CONFIG}/named.conf && \
	sed --expression="/rfc1918/s/\/\///" --in-place ${BIND_CONFIG}/named.conf.local && \
	sed --expression="/rfc1918/ainclude \"${BIND_CONFIG}/zones.rfc3171\";" --in-place ${BIND_CONFIG}/named.conf.local && \
	sed --expression="/rfc3171/ainclude \"${BIND_CONFIG}/zones.rfc4193\";" --in-place ${BIND_CONFIG}/named.conf.local && \
	install --group=bind --mode=0644 --owner=bind /dev/null ${BIND_CONFIG}/named.conf.keys && \
	install --group=bind --mode=0644 --owner=bind /dev/null ${BIND_CONFIG}/zones.rfc3171 && \
	install --group=bind --mode=0644 --owner=bind /dev/null ${BIND_CONFIG}/zones.rfc4193 && \
	rm ${BIND_CONFIG}/rndc.key && \
	bind-update-root && \
	mv ${BIND_CONFIG} /usr/local/share/bind/config && \
	mv /usr/local/share/bind/config/named.conf.options /usr/local/share/bind/config/named.conf.options.dist

# Configure: supervisor
COPY supervisord.bind.conf /etc/supervisor/conf.d/bind.conf

# Configure: entrypoint
COPY entrypoint.bind /etc/entrypoint.d/bind

# Configure: healthcheck
COPY healthcheck.bind /etc/healthcheck.d/bind

EXPOSE 53/udp

VOLUME ${BIND_CONFIG}
