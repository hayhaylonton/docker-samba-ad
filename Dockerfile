FROM ubuntu:20.04
# Default environment variables. Please overwrite!
LABEL org.opencontainers.image.source https://github.com/hayhaylonton/docker-samba-ad

ENV SAMBA_REALM="samba.dom"
ENV SAMBA_PASSWORD="UnsecurePassword!"
ENV SAMBA_HOST_IP="10.10.10.247"
ENV SAMBA_DNS_FORWARDER="10.10.10.254"

RUN apt-get update && \
	apt-get install -y \
       locales samba krb5-user krb5-config winbind smbclient libpam-winbind libnss-winbind \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configure timezone and locale
RUN echo "Asia/Ho_Chi_Minh" > /etc/timezone && \
	dpkg-reconfigure -f noninteractive tzdata
RUN locale-gen en_US.utf8 && \
	dpkg-reconfigure locales
	
# Add startup scripts
RUN mkdir -p /etc/my_init.d
#COPY samba_setup.sh samba_run.sh /etc/my_init.d/
COPY samba_setup.sh /etc/my_init.d/
#COPY samba_run.sh /etc/my_init.d/
#RUN chmod +x /etc/my_init.d/samba_setup.sh
#RUN chown root:root /etc/my_init.d/samba_setup.sh
#RUN chmod +x /etc/my_init.d/samba_run.sh
#RUN chown root:root /etc/my_init.d/samba_run.sh

VOLUME ["/var/lib/samba"]

CMD ["/etc/my_init.d/samba_setup.sh"]

# Clean up APT when done.
#RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Expose AD DC Ports
EXPOSE 135/tcp
EXPOSE 137/udp
EXPOSE 138/udp
EXPOSE 139/tcp
EXPOSE 445/tcp
EXPOSE 464/tcp
EXPOSE 464/udp
EXPOSE 389/tcp
EXPOSE 389/udp
EXPOSE 636/tcp
EXPOSE 3268/tcp
EXPOSE 3269/tcp
EXPOSE 53/tcp
EXPOSE 53/udp
EXPOSE 88/tcp
EXPOSE 88/udp