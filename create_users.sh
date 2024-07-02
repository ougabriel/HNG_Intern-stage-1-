##This script will help to automate user creation by reading a text file
##The text file MUST be in employee "username, groups" format

#!/bin/bash

set -e

##STEP 1: Set Variables and the File Paths for storing logs and password 

gab-USER_LOGS="/var/log/user_management.log"
gab-USER_PASSWORD="/var/secure/user_passwords.txt"

##STEP 2: Create a Log Function that stores a timestamp in gab-USER_LOGS variable

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $gab-USER_LOGS
}

##STEP 3: Checking for the input file

if [-z "$1"]; then
    echo "Usage: $0 <name-of-text-file>"
    exit 1
fi

##STEP 4: Ensuring permissions are set for log and password files
 touch $gab-USER_LOGS
 chmod 644 $gab-USER_LOGS

 mkdir -p /var/secure
 touch $gab-USER_PASSWORD
 chmod 600 $gab-USER_PASSWORD

 ##STEP 5: Read the input file

while IFS=";" read -r username groups; do
    #removing whitespaces
    username=$(echo "$username" | xargs)
    groups=$(echo "$groups" | xargs)

    #checking if the user exists
    if id "$username" &>/dev/null; then
        log_message "User $username already exists. Skipping creation."
        continue
    fi

    ##STEP 6: Create the users and the group
    useradd -m -s /bin/bash "$username"
    log_message "Created user $username."

    #setting the user group to match its username
    usermod -g "$username" "$username"
    log_message "Created and set a group for $username."

##STEP 6: Creating an additional group if specified
   if [ -n "$groups" ]; then
        IFS="," read -ra group_array <<< "$groups"
        for group in "${group_array[@]}"; do
            group=$(echo "$group" | xargs)
            if ! getent group "$group" &>/dev/null; then
                groupadd "$group"
                log_message "Created group $group."
            fi
            usermod -aG "$group" "$username"
            log_message "Added user $username to group $group."
        done
    fi

##STEP 7: Generate random passwords for each user
    password=$(openssl rand -base64 12)
    echo "$username:$password" | chpasswd
    log_message "User password is set for $username."

    #saving the password 
    echo "$username,$password" >> $gab-USER_PASSWORD
done < "$1"

log_message "Hi Gabriel Okom !! User creation is completely set-up and ready for use."
