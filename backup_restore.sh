#!/bin/bash
# Function to list available config files
list_db_config_files() {
    echo "=============================="
    echo "Available database config files:"
    cd config
    ls *.dbcfg
    cd ../
    read -p "Enter config file name [without extension]: " config_file_name
    db_config_file="config/$config_file_name.dbcfg"
    if [ -f "$db_config_file" ]; then
        echo "Loading config file..."
    else
        echo "Config file not found."
    fi
}
# Function to list available config files
list_remote_server_config_files() {
    echo "=============================="
    echo "Available remote server config files:"
    cd config
    ls config/*.rmcfg
    cd ../
    read -p "Enter config file name [without extension]: " config_file_name
    remote_config_file="config/$config_file_name.rmcfg"
    if [ -f "$remote_config_file" ]; then
        echo "Loading config file..."
    else
        echo "Config file not found."
    fi
}

get_config_value() {
    config_file=$1
    config_key=$2
    config_value=$(grep "$config_key" "$config_file" | cut -d "=" -f2)
    if [ -z "$config_value" ]; then
        read -p "Enter $config_key: " config_value
    fi
    echo "$config_value"
}

function initialize_db_config() {
    list_db_config_files
    db_type=$(get_config_value "$db_config_file" "db_type")
    db_name=$(get_config_value "$db_config_file" "db_name")
    db_username=$(get_config_value "$db_config_file" "db_username")
    db_password=$(get_config_value "$db_config_file" "db_password")
}

function initialize_remote_config() {
    list_remote_server_config_files
    remote_host=$(get_config_value "$remote_config_file" "remote_host")
    remote_username=$(get_config_value "$remote_config_file" "remote_username")
    remote_dir=$(get_config_value "$remote_config_file" "remote_dir")
}

# Functions for backup and restore of MySQL and PostgreSQL databases
function backup_mysql() {
    # Create backup directory if it doesn't exist
    if [ ! -d "mysql_backups" ]; then
        mkdir mysql_backups
    fi

    # Backup the database
    mysqldump -u "$db_username" -p"$db_password" "$db_name" >"mysql_backups/$db_name-$(date +%F).sql"
    echo "MySQL database $db_name has been backed up successfully."
}

function restore_mysql() {
    # Restore the database
    cd mysql_backups
    ls *.sql
    cd ../
    read -p "Enter backup file name: " db_filename
    mysql -u "$db_username" -p"$db_password" "$db_name" <"mysql_backups/$db_filename"
    if [ $? -eq 0 ]; then
        echo "MySQL database $db_name has been restored successfully."
    else
        echo "Error: MySQL database restore failed."
    fi
}

function backup_postgres() {
    # Create backup directory if it doesn't exist
    if [ ! -d "postgres_backups" ]; then
        mkdir postgres_backups
    fi

    # Backup the database
    export PGPASSWORD="$db_password"
    pg_dump -U "$db_username" "$db_name" >"postgres_backups/$db_name-$(date +%F).sql"
    if [ $? -eq 0 ]; then
        echo "PostgreSQL database $db_name has been backed up successfully."
    else
        echo "Error: PostgreSQL database backup failed."
    fi
    unset PGPASSWORD
}

function restore_postgres() {
    # Restore the database
    cd postgres_backups
    ls *.sql
    cd ../
    db_filename=$(get_config_value "$db_config_file" "db_filename")
    export PGPASSWORD="$db_password"
    psql -U "$db_username" "$db_name" <"postgres_backups/$db_filename"
}

# Function to restore backup from remote server
function restore_remote() {
    initialize_remote_config
    # Create directory named after the hostname inside remote_backups directory
    backup_dir="remote_backups/${remote_host}"
    mkdir -p "$backup_dir"
    backup_file="${backup_dir}/${remote_host}-$(date +%F).sql"

    # Download backup from remote server using scp
    echo "Downloading backup from remote server..."
    scp "${remote_username}@${remote_host}:${remote_path}" "${backup_file}"

    # Check if download was successful
    if [ $? -eq 0 ]; then
        echo "Backup downloaded successfully."
        # Ask for database information
        initialize_db_config
        if [ "$db_type" == "mysql" ]; then
            # Restore MySQL database
            echo "Restoring MySQL database..."
            mysql -u "$db_username" -p"$db_password" "$db_name" <"$backup_file"
        elif [ "$db_type" == "postgresql" ]; then
            # Restore PostgreSQL database
            echo "Restoring PostgreSQL database..."
            export PGPASSWORD="$db_password"
            psql -U "$db_username" -d "$db_name" <"$backup_file"
        else
            echo "Invalid database type, please try again."
        fi

    else
        echo "Backup download failed. Please try again."
    fi
}

# Function to pull updates from Git repository
function pull_updates() {
    echo "Pulling updates from Git repository..."

    # Check if the current directory is a Git repository
    if [ ! -d ".git" ]; then
        echo "Error: Not a Git repository."
        return
    fi

    # Fetch the latest changes from the remote repository
    git fetch origin

    # Checkout the specified branch
    git checkout main

    # Pull the latest changes for the specified branch
    git pull origin main
}

function backup_local() {
    initialize_db_config
    if [ "$db_type" == "mysql" ]; then
        backup_mysql
    elif [ "$db_type" == "postgresql" ]; then
        backup_postgres
    else
        echo "Invalid database type, please try again."
    fi
}

function restore_local() {
    initialize_db_config
    if [ "$db_type" == "mysql" ]; then
        restore_mysql
    elif [ "$db_type" == "postgresql" ]; then
        restore_postgres
    else
        echo "Invalid database type, please try again."
    fi
}

function backup_from_remote_db() {
    initialize_remote_config
    initialize_db_config

    file_name="${db_name}_${remote_host}-$(date +%F).sql"
    if [ "$db_type" == "mysql" ]; then
        # Create directory named after the hostname inside remote_backups directory
        backup_dir="mysql_backups/"
        mkdir -p "$backup_dir"
        local_backup_file_path="${backup_dir}/${file_name}"

        # Backup the database
        echo "Backing up database on remote server..."
        ssh "${remote_username}@${remote_host}" "mkdir -p ${remote_dir}; mysqldump -u ${db_username} -p'${db_password}' ${db_name} > ${remote_dir}/${file_name}"


    elif
        [ "$db_type" == "postgresql" ]
    then
        # Create directory named after the hostname inside remote_backups directory
        backup_dir="postgres_backups/"
        mkdir -p "$backup_dir"
        local_backup_file_path="${backup_dir}/${file_name}"

        # Backup the database
        echo "Backing up database on remote server..."
        ssh "${remote_username}@${remote_host}" mkdir -p $remote_dir
        ssh "${remote_username}@${remote_host}" "export PGPASSWORD=${db_password}; pg_dump -U ${db_username} ${db_name}" >"${remote_dir}/${file_name}"

    else
        echo "Invalid database type, please try again."
        exit 1
    fi

    # Download backup from remote server using scp
    echo "Downloading backup from remote server..."
    scp "${remote_username}@${remote_host}:${remote_dir}/${file_name}" "${local_backup_file_path}"

}
# Function to display menu
function display_menu() {
    echo "========================================"
    echo " SQL Database Backup Tools"
    echo " Version: 2.0"
    echo "========================================"
    echo " Created by: AHMED ELKHAYYAT"
    echo " Website: https://elkhayyat.me"
    echo " Github: https://github.com/elkhayyat/sql_database_backup_tools"
    echo "========================================"
    echo "1. Backup from a local database to a local file"
    echo "2. Restore from a local file to a local database"
    echo "3. Backup from a remote database to a local file"
#    echo "4. Restore from a remote file to a local database"
#    echo "5. Backup from a local database to a remote file"
#    echo "6. Restore from a local file to a remote database"
    echo "9. Exit"
}

# Function to get user selection
function get_selection() {
    read -p "Enter your selection [1-6]: " selection
    echo
}

# Function to process user selection
function process_selection() {
    case $selection in
    1)
        backup_local
        ;;
    2)
        restore_local
        ;;
    3)
        backup_from_remote_db
        ;;
    6)
        exit 0
        ;;
    7)
        exit 0
        ;;
    8)
        exit 0
        ;;
    9)
        exit 0
        ;;
    *)
        echo "Invalid selection, please try again."
        ;;
    esac
}

function main() {
#    pull_updates
#    list_config_files
    # Continuously display menu and process user selection until exit
    while true; do
        display_menu
        get_selection
        process_selection
    done
}

main
