#!/bin/bash
# Function to create config file
create_config_file() {
    echo "Creating config file..."
    # Prompt user for values
    read -p "Enter database type [mysql or postgresql]: " db_type
    read -p "Enter database username: " db_username
    read -p "Enter database password: " db_password
    read -p "Enter database name: " db_name
    read -p "Enter database backup file name to be restored: " db_filename

    read -p "Enter remote host: " remote_host
    read -p "Enter remote username: " remote_username
    read -p "Enter remote full backup file path: " remote_path

    # Write values to config file
    {
        echo "# Database configuration"
        echo "db_type=$db_type"
        echo "db_name=$db_name"
        echo "db_username=$db_username"
        echo "db_password=$db_password"
        echo"db_filename=db_filename"
        echo
        echo
        echo "# Remote server configuration"
        echo "remote_host=$remote_host"
        echo "remote_username=$remote_username"
        echo "remote_path=$remote_path"
    } >"$config_file"
    initialize_db_config
    initialize_remote_config
}

# Function to list available config files
list_config_files() {
    echo "=============================="
    echo "Available config files:"
    ls *.cfg
    read -p "Enter config file name [xxx.cfg]: " config_file
    if [ -f "$config_file" ]; then
        echo "Loading config file..."
    else
        echo "Config file not found."
        create_config_file "$config_file"
    fi
}

get_config_file() {
    # Check if config file is passed as an argument
    read -p "Enter config file name: " config_file
    if [ ! -f "$config_file" ]; then
        echo "Config file not found."
        read -p "Do you want to create a new config file? (y/n) " answer
        if [ "$answer" == "y" ]; then
            create_config_file
        else
            list_config_files
        fi
    fi
}

get_config_value() {
    config_key=$1
    config_value=$(grep "$config_key" "$config_file" | cut -d "=" -f2)
    if [ -z "$config_value" ]; then
        read -p "Enter $config_key: " config_value
    fi
    echo "$config_value"
}

function initialize_db_config() {
    db_type=$(get_config_value "db_type")
    db_name=$(get_config_value "db_name")
    db_username=$(get_config_value "db_username")
    db_password=$(get_config_value "db_password")
    db_filename=$(get_config_value "db_filename")
}

function initialize_remote_config() {
    remote_host=$(get_config_value "remote_host")
    remote_username=$(get_config_value "remote_username")
    remote_path=$(get_config_value "remote_path")
}

# Functions for backup and restore of MySQL and PostgreSQL databases
function backup_mysql() {
    initialize_db_config
    # Create backup directory if it doesn't exist
    if [ ! -d "mysql_backups" ]; then
        mkdir mysql_backups
    fi

    # Backup the database
    mysqldump -u "$db_username" -p"$db_password" "$db_name" >"mysql_backups/$db_name-$(date +%F).sql"
    echo "MySQL database $db_name has been backed up successfully."
}

function restore_mysql() {
    initialize_db_config
    # Restore the database
    mysql -u "$db_username" -p"$db_password" "$db_name" <"mysql_backups/$db_filename"
    echo "MySQL database $db_name has been restored successfully."
}

function backup_postgres() {
    initialize_db_config
    # Create backup directory if it doesn't exist
    if [ ! -d "postgres_backups" ]; then
        mkdir postgres_backups
    fi

    # Backup the database
    export PGPASSWORD="$db_password"
    pg_dump -U "$db_username" "$db_name" >"postgres_backups/$db_name-$(date +%F).sql"
    unset PGPASSWORD
    echo "PostgreSQL database $db_name has been backed up successfully."
}

function restore_postgres() {
    initialize_db_config
    # Restore the database
    export PGPASSWORD="$db_password"
    psql -U "$db_username" "$db_name" <"postgres_backups/$db_filename"
}

# Function to restore backup from remote server
function restore_remote() {
    initialize_remote_config
    # Create directory named after the hostname inside remote_backups directory
    backup_dir="remote_backups/${remote_host}"
    mkdir -p backup_dir
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

# Function to display menu
function display_menu() {
    echo "===================="
    echo " Database Backup/Restore"
    echo "===================="
    echo "1. Create Config File"
    echo "2. Load Config File"
    echo "3. Backup MySQL database"
    echo "4. Restore MySQL database"
    echo "5. Backup PostgreSQL database"
    echo "6. Restore PostgreSQL database"
    echo "7. Restore Backup from Remote Server"
    echo "8. Exit"
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
        create_config_file
        ;;
    2)
        list_config_files
        ;;
    3)
        backup_mysql
        ;;
    4)
        restore_mysql
        ;;
    5)
        backup_postgres
        ;;
    6)
        restore_postgres
        ;;
    7)
        restore_remote
        ;;
    8)
        exit 0
        ;;
    *)
        echo "Invalid selection, please try again."
        ;;
    esac
}

function main() {
    pull_updates
    list_config_files
    # Continuously display menu and process user selection until exit
    while true; do
        display_menu
        get_selection
        process_selection
    done
}

main
