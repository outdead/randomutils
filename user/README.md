# OS User
Creates and deletes Linux user. You must have sudo privileges to call create and delete commands.

## Usage 

    ./user/user.sh command [arguments...]

## Commands 

    help, h     Shows a list of commands or help for one command
    version, v  Prints user/user.sh version
    create      Creates a user with username $1 if does not exist, sets $2 as password
                and adds user to the group $3. Usage: ./user/user.sh create {username} {password} [group]
    delete      removes user with username $1. Usage: ./user/user.sh delete {username}

## Global Options

    --help, -h     show help
    --version, -v  print the version

## Example

    wget -O user.sh https://raw.githubusercontent.com/outdead/randomutils/master/user/user.sh && sudo bash user.sh create username password group; rm user.sh
