FROM ubuntu:20.04
# Default environment variables. Please overwrite!
LABEL org.opencontainers.image.source https://github.com/hayhaylonton/docker-samba-ad

ENV SAMBA_REALM="samba.dom"
ENV SAMBA_PASSWORD="UnsecurePassword!"
ENV SAMBA_HOST_IP="10.10.10.247"
ENV SAMBA_DNS_FORWARDER="10.10.10.254"

RUN apt-get update && \
	apt-get install -y \
       locales samba krb5-user krb5-config winbind smbclient libpam-winbind libnss-winbind lmdb-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configure timezone and locale
RUN echo "Asia/Ho_Chi_Minh" > /etc/timezone && \
	dpkg-reconfigure -f noninteractive tzdata
RUN locale-gen en_US.utf8 && \
	dpkg-reconfigure locales
	
# Add startup scripts
RUN mkdir -p /etc/my_init.d
COPY samba_setup.sh /etc/my_init.d/

VOLUME ["/var/lib/samba"]

#CMD ["/etc/my_init.d/samba_setup.sh"]
RUN apt-get update && \
	apt-get install -y supervisor ntp

COPY ntp/ntp.conf /etc/
RUN apt-get install -y bind9 bind9utils

COPY supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY bind/* /etc/bind/
COPY samba/named.conf /etc/my_init.d/

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ADD https://www.internic.net/zones/named.root /etc/bind/db.root

CMD ["/usr/bin/supervisord"]

# Expose AD DC Ports
EXPOSE 135/tcp \
    137/udp \
    138/udp \
    139/tcp \
    445/tcp \
    464/tcp \
    464/udp \
    389/tcp \
    389/udp \
    636/tcp \
    3268/tcp \
    3269/tcp \
    53/tcp \
    53/udp \
    88/tcp \
    88/udp \
    123/udp \
    53/udp