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
    display_menu
    get_selection
    process_selection
done
