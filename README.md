# Backup and Restore script for MySQL and PostgreSQL databases

This script provides an easy and automated way to backup and restore MySQL and PostgreSQL databases. With this script,
you can backup or restore a database with just a few clicks, without having to run the commands manually.

It also provides config creator tools to create pre-configured files to be re-used instead of writing your db_name,
db_server, and db_credentials each time you run the script.

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
##### Config Creator
1. Run the script with the following command: `bash config_creator.sh`
2. Choose whether you want to create a database config file or remote server config file.
3. Follow the prompts to enter the name of the database or remote server data.
   Note: You may need to modify the script to match your database credentials and backup directory paths.
##### Database backup/restore
1. Clone the repository to your local machine.
2. Make the script executable by running the following command: `chmod +x backup_restore.sh`
3. Run the script with the following command: `./backup_restore.sh`
4. Choose the desired option from the menu.
5. Follow the prompts and select the desired config file which includes your database information like database name and
   credentials.

## To Generate a config file


## TODO

1. [ ] Adding support to back-up from a local database to a remote file.
2. [ ] Adding support to Restore from a remote file to a local database.
3. [ ] Adding support to Restore from a local file to a remote database.

## TESTS

1. [X] Test back-up from local MySQL database to a local file.
2. [X] Test restore from a local file to MySQL local database.
3. [ ] Test back-up from local PostgreSQL database to a local file.
4. [ ] Test restore from a local file to PostgreSQL local database.
5. [X] Test back-up from remote MySQL database to a local file.

## Change Log

- 2023-02-03: [Version 2.0]
    - Added PostgreSQL support.
    - Added remote server backup support.
    - Added config_creator.sh script to generate config files.
- 2020-02-02: [Version 1.0] Initial release.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details