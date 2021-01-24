# IPsec VPN
Deb snippet for install [IPsec](https://en.wikipedia.org/wiki/IPsec) VPN.  

## Usage
```bash
In progress
```

## Example 

    wget -O ipsec.sh https://raw.githubusercontent.com/outdead/randomutils/master/vpn/ipsec/ipsec.sh
    chmod u+x ipsec.sh
    ./ipsec.sh install vpn.example.com example password
    rm ipsec.sh

    # Or in one command.
    wget -O ipsec.sh https://raw.githubusercontent.com/outdead/randomutils/master/vpn/ipsec/ipsec.sh && sudo bash ipsec.sh install vpn.example.com example password; rm ipsec.sh
    