# IPsec VPN
Deb cookbook for install [IPsec](https://en.wikipedia.org/wiki/IPsec) VPN.  

## Usage
```bash
NAME:
   ipsec.sh script allows you to install and configure IPsec VPN.

USAGE:
   ./ipsec.sh command [arguments...]

COMMANDS:
   help, h     Shows a list of commands or help for one command
   version, v  Prints ./ipsec.sh version
   install     Installs Strongswan VPN server

GLOBAL OPTIONS:
   --help, -h     show help
   --version, -v  print the version
```

## Example 

    wget -O ipsec.sh https://raw.githubusercontent.com/outdead/randomutils/master/scripts/vpn/ipsec/ipsec.sh
    chmod u+x ipsec.sh
    ./ipsec.sh install vpn.example.com example password
    rm ipsec.sh

    # Or in one command.
    wget -O ipsec.sh https://raw.githubusercontent.com/outdead/randomutils/master/scripts/vpn/ipsec/ipsec.sh && sudo bash ipsec.sh install vpn.example.com example password; rm ipsec.sh
    