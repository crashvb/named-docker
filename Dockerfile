FROM crashvb/supervisord:latest
LABEL maintainer "Richard Davis <crashvb@gmail.com>"

# Install packages, download files ...
RUN docker-apt bind9 dnsutils

# Configure: bind9
ENV BIND_CONFIG=/etc/bind
ADD bind-* /usr/local/bin/
ADD db.* named.conf.* zones.* /usr/local/share/bind/
RUN install --directory --group=bind --mode=0775 --owner=root /var/lib/bind /var/run/named && \
	install --directory --group=adm --mode=0755 --owner=bind /var/log/bind && \
	sed --expression="/conf.options/ainclude \"${BIND_CONFIG}/named.conf.keys\";" --in-place ${BIND_CONFIG}/named.conf && \
	sed --expression="/rfc1918/s/\/\///" --in-place ${BIND_CONFIG}/named.conf.local && \
	sed --expression="/rfc1918/ainclude \"${BIND_CONFIG}/zones.rfc3171\";" --in-place ${BIND_CONFIG}/named.conf.local && \
	sed --expression="/rfc3171/ainclude \"${BIND_CONFIG}/zones.rfc4193\";" --in-place ${BIND_CONFIG}/named.conf.local && \
	install --group=bind --mode=0644 --owner=bind /dev/null ${BIND_CONFIG}/named.conf.keys && \
	install --group=bind --mode=0644 --owner=bind /dev/null ${BIND_CONFIG}/zones.rfc3171 && \
	install --group=bind --mode=0644 --owner=bind /dev/null ${BIND_CONFIG}/zones.rfc4193 && \
	mv ${BIND_CONFIG} /usr/local/share/bind/config && \
	mv /usr/local/share/bind/config/named.conf.options /usr/local/share/bind/config/named.conf.options.dist

# Configure: supervisor
ADD supervisord.bind.conf /etc/supervisor/conf.d/bind.conf

# Configure: entrypoint
ADD entrypoint.bind /etc/entrypoint.d/bind

# Configure: healthcheck
ADD healthcheck.bind /etc/healthcheck.d/bind

EXPOSE 53/udp

VOLUME ${BIND_CONFIG}
