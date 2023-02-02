#!/bin/bash

# Functions for backup and restore of MySQL and PostgreSQL databases
function backup_mysql() {
    # Get database name
    read -p "Enter the name of the MySQL database to backup: " db_name

    # Get MySQL credentials
    read -p "Enter the MySQL username: " mysql_user
    read -s -p "Enter the MySQL password: " mysql_password
    echo

    # Create backup directory if it doesn't exist
    if [ ! -d "mysql_backups" ]; then
        mkdir mysql_backups
    fi

    # Backup the database
    mysqldump -u "$mysql_user" -p"$mysql_password" "$db_name" > "mysql_backups/$db_name-$(date +%F).sql"
    echo "MySQL database $db_name has been backed up successfully."
}

function restore_mysql() {
    # Get database name
    read -p "Enter the name of the MySQL database to restore: " db_name

    # Get backup file name
    read -p "Enter the name of the backup file: " file_name

    # Get MySQL credentials
    read -p "Enter the MySQL username: " mysql_user
    read -s -p "Enter the MySQL password: " mysql_password
    echo

    # Restore the database
    mysql -u "$mysql_user" -p"$mysql_password" "$db_name" < "mysql_backups/$file_name"
    echo "MySQL database $db_name has been restored successfully."
}

function backup_postgres() {
    # Get database name
    read -p "Enter the name of the PostgreSQL database to backup: " db_name

    # Get PostgreSQL credentials
    read -p "Enter the PostgreSQL username: " pg_user
    read -s -p "Enter the PostgreSQL password: " pg_password
    echo

    # Create backup directory if it doesn't exist
    if [ ! -d "postgres_backups" ]; then
        mkdir postgres_backups
    fi

    # Backup the database
    export PGPASSWORD="$pg_password"
    pg_dump -U "$pg_user" "$db_name" > "postgres_backups/$db_name-$(date +%F).sql"
    unset PGPASSWORD
    echo "PostgreSQL database $db_name has been backed up successfully."
}

function restore_postgres() {
    # Get database name
    read -p "Enter the name of the PostgreSQL database to restore: " db_name

    # Get backup file name
    read -p "Enter the name of the backup file: " file_name

    # Get PostgreSQL credentials
    read -p "Enter the PostgreSQL username: " pg_user
    read -s -p "Enter the PostgreSQL password: " pg_password
    echo

    # Restore the database
    export PGPASSWORD="$pg_password"
    psql -U "$pg_user" "$db_name" < "postgres_backups/$file_name"
}

# Function to restore backup from remote server
function restore_remote() {
    # Ask for remote server information
    read -p "Enter remote server address: " server
    read -p "Enter username: " username
    read -p "Enter the path to the backup on the remote server: " backup_path

    # Check if the server can be accessed using key or password or preconfigured ssh configs
    echo "Checking access to remote server..."
    ssh -q $username@$server exit
    if [ $? -ne 0 ]; then
        # If access failed, ask for password
        read -sp "Password: " password
        echo
        scp -r $username:$backup_path .
    else
        scp -r $username@$server:$backup_path .
    fi

    # Ask for database information
    read -p "Enter database name: " database
    read -p "Enter database username: " db_username
    read -sp "Enter database password: " db_password
    echo

    # Check if database is MySQL or PostgreSQL
    read -p "Enter database type (mysql or postgres): " db_type
    if [ "$db_type" == "mysql" ]; then
        # Restore MySQL database
        echo "Restoring MySQL database..."
        mysql -u $db_username -p$db_password $database < $backup_path
    elif [ "$db_type" == "postgres" ]; then
        # Restore PostgreSQL database
        echo "Restoring PostgreSQL database..."
        psql -U $db_username -d $database -f $backup_path
    else
        echo "Invalid database type, please try again."
    fi
}


# Function to pull updates from Git repository
function pull_updates() {
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
    echo "1. Backup MySQL database"
    echo "2. Restore MySQL database"
    echo "3. Backup PostgreSQL database"
    echo "4. Restore PostgreSQL database"
    echo "5. Restore Backup from Remote Server"
    echo "6. Exit"
}

# Function to get user selection
function get_selection() {
    read -p "Enter your selection 1-6:" selection
    echo
}

# Function to process user selection
function process_selection() {
    case $selection in
        1)
            backup_mysql
            ;;
        2)
            restore_mysql
            ;;
        3)
            backup_postgres
            ;;
        4)
            restore_postgres
            ;;
        5)
            restore_remote
            ;;
        6)
            exit 0
            ;;
        *)
            echo "Invalid selection, please try again."
            ;;
    esac
}

# Continuously display menu and process user selection until exit
while true; do
    pull_updates
    display_menu
    get_selection
    process_selection
done
