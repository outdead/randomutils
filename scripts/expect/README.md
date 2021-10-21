# Expect
Deb snippet for automatically enter SSH password with using [Expect](https://en.wikipedia.org/wiki/Expect) utility.

## Install

    # Install Expect util
    apt-get install expect
     
    # Install helper
    sudo cp exp /usr/bin/exp
    sudo chmod 0644 /usr/bin/exp
    sudo chmod +x /usr/bin/exp

## Usage

    exp password ssh user@host
