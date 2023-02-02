#!/bin/bash

# Backup and Restore script for MySQL and PostgreSQL databases

# Define variables
DATE=`date +%Y-%m-%d`
MYSQL_BACKUP_DIR="/backups/mysql"
POSTGRES_BACKUP_DIR="/backups/postgres"

# Check if the backup directories exist, if not create them
if [ ! -d $MYSQL_BACKUP_DIR ]; then
  mkdir -p $MYSQL_BACKUP_DIR
fi

if [ ! -d $POSTGRES_BACKUP_DIR ]; then
  mkdir -p $POSTGRES_BACKUP_DIR
fi

# Function to backup MySQL databases
mysql_backup() {
  echo "Backing up MySQL databases..."
  read -p "Enter the name of the database to be backed up: " db_name
  mysqldump -u root -p $db_name > "$MYSQL_BACKUP_DIR/$db_name-$DATE.sql"
  echo "Database $db_name has been backed up successfully to $MYSQL_BACKUP_DIR/$db_name-$DATE.sql"
}

# Function to backup PostgreSQL databases
postgres_backup() {
  echo "Backing up PostgreSQL databases..."
  read -p "Enter the name of the database to be backed up: " db_name
  pg_dump -U postgres $db_name > "$POSTGRES_BACKUP_DIR/$db_name-$DATE.sql"
  echo "Database $db_name has been backed up successfully to $POSTGRES_BACKUP_DIR/$db_name-$DATE.sql"
}

# Function to restore MySQL databases
mysql_restore() {
  echo "Restoring MySQL databases..."
  read -p "Enter the name of the database to be restored: " db_name
  mysql -u root -p $db_name < "$MYSQL_BACKUP_DIR/$db_name-$DATE.sql"
  echo "Database $db_name has been restored successfully from $MYSQL_BACKUP_DIR/$db_name-$DATE.sql"
}

# Function to restore PostgreSQL databases
postgres_restore() {
  echo "Restoring PostgreSQL databases..."
  read -p "Enter the name of the database to be restored: " db_name
  psql -U postgres $db_name < "$POSTGRES_BACKUP_DIR/$db_name-$DATE.sql"
  echo "Database $db_name has been restored successfully from $POSTGRES_BACKUP_DIR/$db_name-$DATE.sql"
}

# Main function to display menu and handle user input
main() {
  echo "============================================================="
  echo "Backup and Restore script for MySQL and PostgreSQL databases"
  echo "============================================================="
  echo "1. Backup MySQL databases"
  echo "2. Backup PostgreSQL databases"
  echo "3. Restore MySQL databases"
  echo "4. Restore PostgreSQL databases"
  echo "5. Quit"
  read -p "Enter your choice [1-5]: " choice

  case
