#!/usr/bin/env bash

VERSION="1.0.4"
YEAR="2020"

# create creates a user with username $1 if does not exist,
# sets $2 as password and adds user to the group $3.
# If the sudo group is specified, an entry is added to /etc/sudoers
# allowing the user to use sudo without a password.
function create() {
    local username="$1"
    local password="$2"
    local group="$3"

    if [ -z "${username}" ]; then
       echo "username is not set"
       return 1
    fi

    if [ -z "${password}" ]; then
       echo "password is not set"
       return 1
    fi

    egrep "(^${username}:)" /etc/passwd >/dev/null
    if [ $? -eq 0 ]; then
        echo "user ${username} already exists"
        return 1
    fi

    # useradd ${username} -s /bin/bash -U -m -G sudo
    useradd -d /home/${username} -m -s /bin/bash -c FullName,Phone,OtherInfo ${username} &&
    echo "${username}:${password}" | chpasswd

    if [ $? -eq 0  ] && [ "${group}" ]; then
        usermod -aG ${group} ${username}

        if [ $? -eq 0  ] && [ ${group} == 'sudo' ]; then
            echo -e "${username} ALL=(ALL) NOPASSWD:ALL\n" >> /etc/sudoers
        fi
    fi
}

# delete removes user with username $1.
function delete() {
    local username="$1"

    if [ -z "${username}" ]; then
       echo "username is not set"
       return 1
    fi

    grep "${username}:" /etc/passwd >/dev/null
    if [ $? -eq 0 ]; then
        sed -i "/${username} ALL=(ALL) NOPASSWD:ALL/d" "/etc/sudoers" && sed -i '$d' "/etc/sudoers"
        userdel ${username} && rm -r /home/${username}/
    fi
}

case "$1" in
    create)
        create "$2" "$3" "$4";;
    delete)
        delete "$2";;
    version|v|--version|-v)
        echo "$0 version $VERSION";;
    help|h|--help|-h)
        echo "NAME:"
        echo "   ${0##*/} script allows you to create or delete Linux user."
        echo
        echo "USAGE:"
        echo "   $0 command [arguments...]"
        echo
        echo "VERSION:"
        echo "   $VERSION"
        echo
        echo "Description:"
        echo "   You must have sudo privileges to call create and delete commands."
        echo
        echo "COMMANDS:"
        echo "   help, h     Shows a list of commands or help for one command"
        echo "   version, v  Prints $0 version"
        echo "   create      Creates a user with username \$1 if does not exist, sets \$2 as password"
        echo "               and adds user to the group \$3. Usage: $0 create {username} {password} [group]"
        echo "   delete      removes user with username \$1. Usage: $0 delete {username}"
        echo
        echo "GLOBAL OPTIONS:"
        echo "   --help, -h     show help"
        echo "   --version, -v  print the version"
        echo
        echo "COPYRIGHT:"
        echo "   Copyright (c) $YEAR Pavel Korotkiy (outdead)"
esac
