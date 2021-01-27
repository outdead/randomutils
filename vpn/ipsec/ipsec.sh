#!/usr/bin/env bash

VERSION="0.1.0"
YEAR="2021"
AUTHOR="Pavel Korotkiy (outdead)"

PKI_FOLDER=~/pki
IPSECD_FOLDER=/etc/ipsec.d
IPSEC_CONF_FILE=/etc/ipsec.conf
IPSEC_SECRET_FILE=/etc/ipsec.secrets
BEFORE_RULES_FILE=/etc/ufw/before.rules
SYSCTL_CONF_FILE=/etc/ufw/sysctl.conf

function install() {
    local domain="$1"
    if [[ -z "${domain}" ]]; then echo "domain is not set"; return 1; fi;

    local username="$2"
    if [[ -z "${username}" ]]; then echo "username is not set"; return 1; fi;

    local password="$3"
    if [[ -z "${password}" ]]; then echo "password is not set"; return 1; fi;

    apt install -y strongswan strongswan-pki libcharon-extra-plugins libcharon-extauth-plugins \
        libstrongswan-extra-plugins libstrongswan-standard-plugins

    create_certificates "${domain}"
    replace_ipsec_conf "${domain}"
    replace_ipsec_secret "$2" "$3"

    systemctl restart strongswan-starter

    apt -y install ufw

    ufw allow OpenSSH
    echo "y" | ufw enable
    ufw allow 500,4500/udp

    replace_before_rules
    fill_sysctl

    sysctl -p

    ufw disable
    echo "y" | ufw enable

    cat "${IPSECD_FOLDER}/cacerts/ca-cert.pem"
}

function create_certificates() {
    local domain="$1"
    if [[ -z "${domain}" ]]; then echo "domain is not set"; return 1; fi;

    mkdir -p "${PKI_FOLDER}/"{cacerts,certs,private} && chmod 700 "${PKI_FOLDER}"
    pki --gen --type rsa --size 4096 --outform pem > "${PKI_FOLDER}/private/ca-key.pem"
    pki --self --ca --lifetime 3650 --in "${PKI_FOLDER}/private/ca-key.pem" \
        --type rsa --dn "CN=VPN root CA" --outform pem > "${PKI_FOLDER}/cacerts/ca-cert.pem"
    pki --gen --type rsa --size 4096 --outform pem > "${PKI_FOLDER}/private/server-key.pem"
    pki --pub --in "${PKI_FOLDER}/private/server-key.pem" --type rsa \
        | pki --issue --lifetime 1825 \
            --cacert "${PKI_FOLDER}/cacerts/ca-cert.pem" \
            --cakey "${PKI_FOLDER}/private/ca-key.pem" \
            --dn "CN=${domain}" --san "${domain}" \
            --flag serverAuth --flag ikeIntermediate --outform pem \
        >  "${PKI_FOLDER}/certs/server-cert.pem"
    cp -r "${PKI_FOLDER}/"* "${IPSECD_FOLDER}/"
}

function replace_ipsec_conf() {
    local domain="$1"
    if [[ -z "${domain}" ]]; then echo "domain is not set"; return 1; fi;

    cp "${IPSEC_CONF_FILE}"{,.original}

    cat >"${IPSEC_CONF_FILE}" <<EOF
config setup
    charondebug="ike 1, knl 1, cfg 0"
    uniqueids=no

conn ikev2-vpn
    auto=add
    compress=no
    type=tunnel
    keyexchange=ikev2
    fragmentation=yes
    forceencaps=yes
    dpdaction=clear
    dpddelay=300s
    rekey=no
    left=%any
    leftid=@${domain}
    leftcert=server-cert.pem
    leftsendcert=always
    leftsubnet=0.0.0.0/0
    right=%any
    rightid=%any
    rightauth=eap-mschapv2
    rightsourceip=10.10.10.0/24
    rightdns=8.8.8.8,8.8.4.4
    rightsendcert=never
    eap_identity=%identity
    ike=chacha20poly1305-sha512-curve25519-prfsha512,aes256gcm16-sha384-prfsha384-ecp384,aes256-sha1-modp1024,aes128-sha1-modp1024,3des-sha1-modp1024!
    esp=chacha20poly1305-sha512,aes256gcm16-ecp384,aes256-sha256,aes256-sha1,3des-sha1!
EOF
}

function replace_ipsec_secret() {
    local username="$1"
    if [[ -z "${username}" ]]; then echo "username is not set"; return 1; fi;

    local password="$2"
    if [[ -z "${password}" ]]; then echo "password is not set"; return 1; fi;

    cp "${IPSEC_SECRET_FILE}"{,.original}

    cat >"${IPSEC_SECRET_FILE}" <<EOF
# This file holds shared secrets or RSA private keys for authentication.

# RSA private key for this host, authenticating it to any other host
# which knows the public part.
: RSA "server-key.pem"
${username} : EAP "${password}"
EOF
}

function replace_before_rules() {
    local interface=$(ip route show default | grep -oP '(?<=dev).*?(?= *proto)' | xargs)

    cp "${BEFORE_RULES_FILE}"{,.original}

    cat >"${BEFORE_RULES_FILE}" <<EOF
#
# rules.before
#
# Rules that should be run before the ufw command line added rules. Custom
# rules should be added to one of these chains:
#   ufw-before-input
#   ufw-before-output
#   ufw-before-forward
#

*nat
-A POSTROUTING -s 10.10.10.0/24 -o ${interface} -m policy --pol ipsec --dir out -j ACCEPT
-A POSTROUTING -s 10.10.10.0/24 -o ${interface} -j MASQUERADE
COMMIT

*mangle
-A FORWARD --match policy --pol ipsec --dir in -s 10.10.10.0/24 -o ${interface} -p tcp -m tcp --tcp-flags SYN,RST SYN -m tcpmss --mss 1361:1536 -j TCPMSS --set-mss 1360
COMMIT

# Don't delete these required lines, otherwise there will be errors
*filter
:ufw-before-input - [0:0]
:ufw-before-output - [0:0]
:ufw-before-forward - [0:0]
:ufw-not-local - [0:0]
# End required lines

-A ufw-before-forward --match policy --pol ipsec --dir in --proto esp -s 10.10.10.0/24 -j ACCEPT
-A ufw-before-forward --match policy --pol ipsec --dir out --proto esp -d 10.10.10.0/24 -j ACCEPT

# allow all on loopback
-A ufw-before-input -i lo -j ACCEPT
-A ufw-before-output -o lo -j ACCEPT

# quickly process packets for which we already have a connection
-A ufw-before-input -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A ufw-before-output -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A ufw-before-forward -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# drop INVALID packets (logs these in loglevel medium and higher)
-A ufw-before-input -m conntrack --ctstate INVALID -j ufw-logging-deny
-A ufw-before-input -m conntrack --ctstate INVALID -j DROP

# ok icmp codes for INPUT
-A ufw-before-input -p icmp --icmp-type destination-unreachable -j ACCEPT
-A ufw-before-input -p icmp --icmp-type time-exceeded -j ACCEPT
-A ufw-before-input -p icmp --icmp-type parameter-problem -j ACCEPT
-A ufw-before-input -p icmp --icmp-type echo-request -j ACCEPT

# ok icmp code for FORWARD
-A ufw-before-forward -p icmp --icmp-type destination-unreachable -j ACCEPT
-A ufw-before-forward -p icmp --icmp-type time-exceeded -j ACCEPT
-A ufw-before-forward -p icmp --icmp-type parameter-problem -j ACCEPT
-A ufw-before-forward -p icmp --icmp-type echo-request -j ACCEPT

# allow dhcp client to work
-A ufw-before-input -p udp --sport 67 --dport 68 -j ACCEPT

#
# ufw-not-local
#
-A ufw-before-input -j ufw-not-local

# if LOCAL, RETURN
-A ufw-not-local -m addrtype --dst-type LOCAL -j RETURN

# if MULTICAST, RETURN
-A ufw-not-local -m addrtype --dst-type MULTICAST -j RETURN

# if BROADCAST, RETURN
-A ufw-not-local -m addrtype --dst-type BROADCAST -j RETURN

# all other non-local packets are dropped
-A ufw-not-local -m limit --limit 3/min --limit-burst 10 -j ufw-logging-deny
-A ufw-not-local -j DROP

# allow MULTICAST mDNS for service discovery (be sure the MULTICAST line above
# is uncommented)
-A ufw-before-input -p udp -d 224.0.0.251 --dport 5353 -j ACCEPT

# allow MULTICAST UPnP for service discovery (be sure the MULTICAST line above
# is uncommented)
-A ufw-before-input -p udp -d 239.255.255.250 --dport 1900 -j ACCEPT

# don't delete the 'COMMIT' line or these rules won't be processed
COMMIT
EOF
}

function fill_sysctl() {
    cat <<EOF >> "${SYSCTL_CONF_FILE}"

net/ipv4/ip_forward=1
net/ipv4/conf/all/accept_redirects=0
net/ipv4/conf/all/send_redirects=0
net/ipv4/ip_no_pmtu_disc=1
EOF
}

case "$1" in
    install)
        install "$2" "$3" "$4";;
    version|v|--version|-v)
        echo "$0 version $VERSION";;
    help|h|--help|-h)
        echo "NAME:"
        echo "   ${0##*/} script allows you to install and configure IPsec VPN."
        echo
        echo "USAGE:"
        echo "   $0 command [arguments...]"
        echo
        echo "VERSION:"
        echo "   $VERSION"
        echo
        echo "Description:"
        echo "   You must have sudo privileges to call install command."
        echo
        echo "COMMANDS:"
        echo "   help, h     Shows a list of commands or help for one command"
        echo "   version, v  Prints $0 version"
        echo "   install     Installs Strongswan VPN server"
        echo
        echo "GLOBAL OPTIONS:"
        echo "   --help, -h     show help"
        echo "   --version, -v  print the version"
        echo
        echo "COPYRIGHT:"
        echo "   Copyright (c) $YEAR $AUTHOR"
esac
