#!/bin/sh

set -e

samba_run () {
    # Fix nameserver
    echo nameserver 127.0.0.1 > /etc/resolv.conf
    echo domain $SAMBA_REALM >> /etc/resolv.conf
    echo search $SAMBA_REALM >> /etc/resolv.conf
    cat /etc/resolv.conf
    
    samba -i -s /etc/samba/smb.conf
}

# Check if samba is setup
if [ -f /var/lib/samba/.setup ]
then
    samba_run
fi

# Require $SAMBA_REALM to be set
: "${SAMBA_REALM:?SAMBA_REALM needs to be set}"

# If $SAMBA_PASSWORD is not set, generate a password
if [ ! "$SAMBA_PASSWORD" ]
then
    SAMBA_PASSWORD="UnsecurePassword!"
fi
echo "[INFO] Samba password set to: $SAMBA_PASSWORD"

# Populate $SAMBA_OPTIONS
SAMBA_OPTIONS=${SAMBA_OPTIONS:-}

if [ -n "$SAMBA_DOMAIN" ]
then
    SAMBA_OPTIONS="$SAMBA_OPTIONS --domain=$SAMBA_DOMAIN"
else
    SAMBA_OPTIONS="$SAMBA_OPTIONS --domain=${SAMBA_REALM%%.*}"
fi

if [ -n "$SAMBA_HOST_IP" ] 
then
    SAMBA_OPTIONS="$SAMBA_OPTIONS --host-ip=$SAMBA_HOST_IP"
fi

# Provision domain
rm -f /etc/samba/smb.conf
rm -rf /var/lib/samba/*
samba-tool domain provision \
    --use-rfc2307 \
    --realm=${SAMBA_REALM} \
    --adminpass=${SAMBA_PASSWORD} \
    --server-role=dc \
    --dns-backend=BIND9_DLZ \
    --backend-store=mdb \
    $SAMBA_OPTIONS \
    --option="bind interfaces only"=yes

# Update dns-forwarder if required
if [ -n "$SAMBA_DNS_FORWARDER" ]
then
    sed -i "s/dns forwarder = .*/dns forwarder = $SAMBA_DNS_FORWARDER/" /etc/samba/smb.conf
fi
#fix bug sysvol
sed -i 's/\[sysvol\]/\[sysvol\]\n\tpreserve case = yes\n\tpublic = no\n\tcase sensitive = no\n\tvfs objects = dfs_samba4 acl_xattr\n\tbrowseable = no/' /etc/samba/smb.conf
mv /etc/krb5.conf /etc/krb5.conf.original
cp /var/lib/samba/private/krb5.conf /etc/


sed -i "s/dns_lookup_realm = false/dns_lookup_realm = true/" /etc/krb5.conf

# Mark samba as setup
touch /var/lib/samba/.setup
cp -Rvaf /etc/my_init.d/named.conf /var/lib/samba/private/
samba_run