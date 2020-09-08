#!/usr/bin/env bash

VERSION="0.1.0"
YEAR="2020"
AUTHOR="Pavel Korotkiy (outdead)"

# execute runs command on remote server with TELNET protocol.
function execute() {
    local ip="$1"
    local port="$2"
    local password="$3"
    local command="$4"

    if [[ -z "${ip}" ]]; then
       echo "ip is not set"
       return 1
    fi

    if [[ -z "${port}" ]]; then
       echo "port is not set"
       return 1
    fi

    if [[ -z "${password}" ]]; then
       echo "password is not set"
       return 1
    fi

    if [[ -z "${command}" ]]; then
       echo "command is not set"
       return 1
    fi

    (
      sleep 1;  echo "${password}"; echo "${command}"; sleep 1; echo "quit"
    ) | telnet "${ip}" "${port}"
}

while [[ -n "$1" ]]; do
    case "$1" in
        version|v|--version|-v)
            echo "$0 version $VERSION"
            exit ;;
        help|h|--help|-h)
            echo "NAME:"
            echo "   ${0##*/} script allows you to run command on remote server with TELNET protocol"
            echo
            echo "USAGE:"
            echo "   $0 [global options] command [arguments...]"
            echo
            echo "VERSION:"
            echo "   $VERSION"
            echo
            echo "Description:"
            echo "   You must set remote server ip, port and command to execute"
            echo
            echo "COMMANDS:"
            echo "   help, h     Shows a list of commands or help for one command"
            echo "   version, v  Prints $0 version"
            echo
            echo "GLOBAL OPTIONS:"
            echo "   -a value, --address value   set host and port to remote TELNET server."
            echo "                               Required flag if env IP and PORT are not set"
            echo "   -p value, --password value  set password to remote TELNET server."
            echo "                               Required flag if env PASSWORD is not set"
            echo "   -c value, --command value   command to execute on remote server."
            echo "                               Required flag if env COMMAND is not set"
            echo "   --help, -h     show help"
            echo "   --version, -v  print the version"
            echo
            echo "COPYRIGHT:"
            echo "   Copyright (c) $YEAR $AUTHOR"
            exit;;
        --address|-a) param="$2"
            IFS=':' read -ra params <<< "$param"
            IP="${params[0]}"
            PORT="${params[1]}"
            shift ;;
        --password|-p) param="$2"
            PASSWORD="$param"
            shift ;;
        --command|-c) param="$2"
            COMMAND="$param"
            shift ;;
        --) shift
            break ;;
        *) echo "$1 is not an option";;
    esac

    shift
done

execute "$IP" "$PORT" "$PASSWORD" "$COMMAND";
