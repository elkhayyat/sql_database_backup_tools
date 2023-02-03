#!/bin/bash

#!/bin/bash
# Function to create config file
create_config_file() {
    echo "Creating config file..."
    # Prompt user for values
    read -p "Enter config file name [without extension]: " config_file_name
    config_file="config/$config_file_name.dbcfg"
    read -p "Enter database type [mysql or postgresql]: " db_type
    read -p "Enter database name: " db_name
    read -p "Enter database username: " db_username
    read -p "Enter database password: " db_password

    # Write values to config file
    {
        echo "# Database configuration"
        echo "db_type=$db_type"
        echo "db_name=$db_name"
        echo "db_username=$db_username"
        echo "db_password=$db_password"
    } >"$config_file"
    echo "Config file $config_file created successfully."
}

function create_remote_config_file(){
    echo "Creating remote config file..."
    # Prompt user for values
    read -p "Enter config file name [without extension]: " config_file_name
    config_file="config/$config_file_name.rmcfg"
    read -p "Enter remote host: " remote_host
    read -p "Enter remote username: " remote_username
    read -p "Enter remote full backup file directory [without trailing slash]: " remote_dir

    # Write values to config file
    {
        echo "# Remote server configuration"
        echo "remote_host=$remote_host"
        echo "remote_username=$remote_username"
        echo "remote_dir=remote_dir"
    } >"$config_file"
    echo "Config file $config_file created successfully."
}

function display_menu(){
    echo "========================================"
    echo " SQL Database Backup Tools - Config Creator"
    echo " Version: 2.0"
    echo "========================================"
    echo " Created by: AHMED ELKHAYYAT"
    echo " Website: https://elkhayyat.me"
    echo " Github: https://github.com/elkhayyat/sql_database_backup_tools"
    echo "========================================"
    echo "1. Create a new database config file"
    echo "2. Create a new remote server config file [used for remote server data]"
    echo "3. Exit"
}

function read_input(){
    local c
    read -p "Enter your choice [1-3] " c
    case $c in
        1) create_config_file ;;
        2) create_remote_config_file ;;
        3) exit 0 ;;
        *) echo "Please select between 1 to 3 choice only."
           read_input
    esac
}

function main(){
    if [ ! -d "config" ]; then
        mkdir config
    fi
    while true; do
        display_menu
        read_input
    done
}

main