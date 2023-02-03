# Backup and Restore script for MySQL and PostgreSQL databases

This script provides an easy and automated way to backup and restore MySQL and PostgreSQL databases. With this script,
you can backup or restore a database with just a few clicks, without having to run the commands manually.

## Features

- Saved Configs to instantly backup or restore a database
- Backups up MySQL and PostgreSQL databases from local or remote servers
- Restores MySQL and PostgreSQL databases to local or remote servers
- Download Backups from remote servers
- Saves the backup file with the date in the file name
- Creates the backup directories if they don't exist

## Requirements

- Linux or macOS
- MySQL or PostgreSQL
- Bash shell
- SCP (for remote backups/restore).

#### Installing SCP on macOS
`brew install openssh`
#### Installing SCP on Ubuntu/Debian based Linux
`sudo apt-get install openssh-client`
#### Installing SCP on CentOS/RedHat distros
`sudo yum install openssh-clients`


## How to use

1. Clone the repository to your local machine.
2. Make the script executable by running the following command: `chmod +x backup_restore.sh`
3. Run the script with the following command: `./backup_restore.sh`
4. Choose the desired option from the menu.
5. Follow the prompts to enter the name of the database to be backed up or restored.

## To Generate a config file
1. Run the script with the following command: `bash config_creator.sh`
2. Choose whether you want to create a database config file or remote server config file.
3. Follow the prompts to enter the name of the database or remote server data.
Note: You may need to modify the script to match your database credentials and backup directory paths.

## TODO
[]: # Test PostgreSQL Local Restore.

## License
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details