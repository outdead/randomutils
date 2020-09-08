TELNET
======
Runs command on remote server with TELNET protocol.

# Usage
```text
USAGE:
   ./telnet.sh [global options] command [arguments...]

VERSION:
   0.1.0

Description:
   You must set remote server ip, port and command to execute

COMMANDS:
   help, h     Shows a list of commands or help for one command
   version, v  Prints telnet/telnet.sh version

GLOBAL OPTIONS:
   -a value, --address value   set host and port to remote TELNET server.
                               Required flag if env IP and PORT are not set
   -p value, --password value  set password to remote TELNET server.
                               Required flag if env PASSWORD is not set
   -c value, --command value   command to execute on remote server.
                               Required flag if env COMMAND is not set
   --help, -h     show help
   --version, -v  print the version
```

# Example 

    PASSWORD="banana" IP=172.19.0.2 PORT=8081 COMMAND=version ./telnet.sh
    ./telnet.sh -c version -a 172.19.0.2:8081 -p banana
