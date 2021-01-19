#!/usr/bin/env bash

VERSION="0.0.0"
YEAR="2021"
AUTHOR="Pavel Korotkiy (outdead)"

function install() {
    local domain="$1"
    local username="$2"
    local password="$3"

    if [ -z "${domain}" ]; then
       echo "domain is not set"
       return 1
    fi

    if [ -z "${username}" ]; then
       echo "username is not set"
       return 1
    fi

    if [ -z "${password}" ]; then
       echo "password is not set"
       return 1
    fi

    apt install -y strongswan strongswan-pki libcharon-extra-plugins libcharon-extauth-plugins \
        libstrongswan-extra-plugins libstrongswan-standard-plugins

    mkdir -p ~/pki/{cacerts,certs,private} && chmod 700 ~/pki

    pki --gen --type rsa --size 4096 --outform pem > ~/pki/private/ca-key.pem

    pki --self --ca --lifetime 3650 --in ~/pki/private/ca-key.pem \
        --type rsa --dn "CN=VPN root CA" --outform pem > ~/pki/cacerts/ca-cert.pem

    pki --gen --type rsa --size 4096 --outform pem > ~/pki/private/server-key.pem

    pki --pub --in ~/pki/private/server-key.pem --type rsa \
        | pki --issue --lifetime 1825 \
            --cacert ~/pki/cacerts/ca-cert.pem \
            --cakey ~/pki/private/ca-key.pem \
            --dn "CN=${domain}" --san "${domain}" \
            --flag serverAuth --flag ikeIntermediate --outform pem \
        >  ~/pki/certs/server-cert.pem

    sudo cp -r ~/pki/* /etc/ipsec.d/

    sudo mv /etc/ipsec.conf{,.original}

    (
        echo "config setup"
        echo "    charondebug=\"ike 1, knl 1, cfg 0\""
        echo "    uniqueids=no"
        echo ""
        echo "conn ikev2-vpn"
        echo "    auto=add"
        echo "    compress=no"
        echo "    type=tunnel"
        echo "    keyexchange=ikev2"
        echo "    fragmentation=yes"
        echo "    forceencaps=yes"
        echo "    dpdaction=clear"
        echo "    dpddelay=300s"
        echo "    rekey=no"
        echo "    left=%any"
        echo "    leftid=@${domain}"
        echo "    leftcert=server-cert.pem"
        echo "    leftsendcert=always"
        echo "    leftsubnet=0.0.0.0/0"
        echo "    right=%any"
        echo "    rightid=%any"
        echo "    rightauth=eap-mschapv2"
        echo "    rightsourceip=10.10.10.0/24"
        echo "    rightdns=8.8.8.8,8.8.4.4"
        echo "    rightsendcert=never"
        echo "    eap_identity=%identity"
        echo "    ike=chacha20poly1305-sha512-curve25519-prfsha512,aes256gcm16-sha384-prfsha384-ecp384,aes256-sha1-modp1024,aes128-sha1-modp1024,3des-sha1-modp1024!"
        echo "    esp=chacha20poly1305-sha512,aes256gcm16-ecp384,aes256-sha256,aes256-sha1,3des-sha1!"
    ) | sudo tee /etc/ipsec.conf

    (
        echo
        echo ": RSA \"server-key.pem\""
        echo "${username} : EAP \"${password}\""
    ) | sudo tee -a /etc/ipsec.secrets

    sudo systemctl restart strongswan-starter

    sudo ufw allow OpenSSH

    echo "y" | sudo ufw enable

    sudo ufw allow 500,4500/udp

    local interface=$(ip route show default | grep -oP '(?<=dev).*?(?= *proto)' | xargs)

    local first_search="# Don't delete these required lines, otherwise there will be errors"
    local first_text=`(
        echo "*nat"
        echo "-A POSTROUTING -s 10.10.10.0/24 -o ${interface} -m policy --pol ipsec --dir out -j ACCEPT"
        echo "-A POSTROUTING -s 10.10.10.0/24 -o ${interface} -j MASQUERADE"
        echo "COMMIT"
        echo ""
        echo "*mangle"
        echo "-A FORWARD --match policy --pol ipsec --dir in -s 10.10.10.0/24 -o ${interface} -p tcp -m tcp --tcp-flags SYN,RST SYN -m tcpmss --mss 1361:1536 -j TCPMSS --set-mss 1360"
        echo "COMMIT"
    )`

    sed -i -r "s/${first_search}/${first_text}\n\n${first_search}/g" vpn/ipsec/testdata/before2.rules

}

function test() {
    cp vpn/ipsec/testdata/before.rules vpn/ipsec/testdata/before2.rules

    local interface=$(ip route show default | grep -oP '(?<=dev).*?(?= *proto)' | xargs)
    local first_search="# Don't delete these required lines, otherwise there will be errors"
    local first_text=`(
        echo "*nat"
        echo "-A POSTROUTING -s 10.10.10.0/24 -o ${interface} -m policy --pol ipsec --dir out -j ACCEPT"
        echo "-A POSTROUTING -s 10.10.10.0/24 -o ${interface} -j MASQUERADE"
        echo "COMMIT"
        echo ""
        echo "*mangle"
        echo "-A FORWARD --match policy --pol ipsec --dir in -s 10.10.10.0/24 -o ${interface} -p tcp -m tcp --tcp-flags SYN,RST SYN -m tcpmss --mss 1361:1536 -j TCPMSS --set-mss 1360"
        echo "COMMIT"
    )`

    sed -i "s/${first_search}/${first_text}\n\n${first_search}/g" vpn/ipsec/testdata/before2.rules
}

case "$1" in
    install)
        # install "$2" "$3" "$4";;
        echo "Not implemented";;
    test)
        test;;
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
