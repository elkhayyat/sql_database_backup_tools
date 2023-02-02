# Backup and Restore script for MySQL and PostgreSQL databases

This script provides an easy and automated way to backup and restore MySQL and PostgreSQL databases. With this script, you can backup or restore a database with just a few clicks, without having to run the commands manually.

## Features
- Backups up MySQL and PostgreSQL databases
- Restores MySQL and PostgreSQL databases
- Asks the user for the name of the database to be backed up or restored
- Saves the backup file with the date in the file name
- Creates the backup directories if they don't exist

## How to use
1. Clone the repository to your local machine.
2. Make the script executable by running the following command: `chmod +x backup_restore.sh`
3. Run the script with the following command: `./backup_restore.sh`
4. Choose the desired option from the menu:
    1. Backup MySQL databases
    2. Backup PostgreSQL databases
    3. Restore MySQL databases
    4. Restore PostgreSQL databases
    5. Quit
5. Follow the prompts to enter the name of the database to be backed up or restored.

Note: You may need to modify the script to match your database credentials and backup directory paths.
