#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# STEP 1: Set Variables and the File Paths for storing logs and passwords
gab_USER_LOGS="/var/log/user_management.log"
gab_USER_PASSWORD="/var/secure/user_passwords.txt"

# STEP 2: Create a Log Function that stores a timestamp in gab_USER_LOGS variable
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $gab_USER_LOGS
}

# STEP 3: Checking for the input file
if [ -z "$1" ]; then
    echo "Usage: $0 <name-of-text-file>"
    exit 1
fi

# STEP 4: Ensuring permissions are set for log and password files
touch $gab_USER_LOGS
chmod 644 $gab_USER_LOGS

mkdir -p /var/secure
touch $gab_USER_PASSWORD
chmod 600 $gab_USER_PASSWORD

# Notify that the script has started
echo "Starting user creation process..."

# STEP 5: Read the input file
while IFS=";" read -r username groups; do
    # Remove whitespaces
    username=$(echo "$username" | xargs)
    groups=$(echo "$groups" | xargs)

    # Checking if the user exists
    if id "$username" &>/dev/null; then
        log_message "User $username already exists. Skipping creation."
        echo "User $username already exists. Skipping creation."
        continue
    fi

    # STEP 6: Create the users and the personal group
    useradd -m -s /bin/bash "$username"
    log_message "Created user $username."
    echo "Created user $username."

    # Set the user's primary group to match their username
    if ! id -Gn "$username" | grep -qw "$username"; then
        usermod -g "$username" "$username"
        log_message "Created and set primary group for $username."
        echo "Created and set primary group for $username."
    else
        log_message "Primary group for $username is already set. Skipping."
        echo "Primary group for $username is already set. Skipping."
    fi

    # Creating additional groups if specified
    if [ -n "$groups" ]; then
        IFS="," read -ra group_array <<< "$groups"
        for group in "${group_array[@]}"; do
            group=$(echo "$group" | xargs)
            if ! getent group "$group" &>/dev/null; then
                groupadd "$group"
                log_message "Created group $group."
                echo "Created group $group."
            fi
            if ! id -Gn "$username" | grep -qw "$group"; then
                usermod -aG "$group" "$username"
                log_message "Added user $username to group $group."
                echo "Added user $username to group $group."
            else
                log_message "User $username is already in group $group. Skipping."
                echo "User $username is already in group $group. Skipping."
            fi
        done
    fi

    # STEP 7: Generate random passwords for each user
    password=$(openssl rand -base64 12)
    echo "$username:$password" | chpasswd
    log_message "Set password for user $username."
    echo "Set password for user $username."

    # Saving the password
    echo "$username,$password" >> $gab_USER_PASSWORD
done < "$1"

log_message "User creation process completed."
echo "User creation process completed."

root@HNGvm:/home/azureuser# vi create_user.sh

    # STEP 6: Create the users and the personal group
    useradd -m -s /bin/bash "$username"
    log_message "Created user $username."
    echo "Created user $username."

    # Set the user's primary group to match their username
    if ! id -Gn "$username" | grep -qw "$username"; then
        usermod -g "$username" "$username"
        log_message "Created and set primary group for $username."
        echo "Created and set primary group for $username."
    else
        log_message "Primary group for $username is already set. Skipping."
        echo "Primary group for $username is already set. Skipping."
    fi

    # Creating additional groups if specified
    if [ -n "$groups" ]; then
        IFS="," read -ra group_array <<< "$groups"
        for group in "${group_array[@]}"; do
            group=$(echo "$group" | xargs)
            if ! getent group "$group" &>/dev/null; then
                groupadd "$group"
                log_message "Created group $group."
                echo "Created group $group."
            fi
            if ! id -Gn "$username" | grep -qw "$group"; then
                usermod -aG "$group" "$username"
                log_message "Added user $username to group $group."
                echo "Added user $username to group $group."
            else
                log_message "User $username is already in group $group. Skipping."
                echo "User $username is already in group $group. Skipping."
            fi
        done
    fi

    # STEP 7: Generate random passwords for each user
    password=$(openssl rand -base64 12)
    echo "$username:$password" | chpasswd
    log_message "Set password for user $username."
    echo "Set password for user $username."

    # Saving the password
    echo "$username,$password" >> $gab_USER_PASSWORD
done < "$1"

log_message "User creation process completed."
echo "Hi Gabriel!! User creation process is now completed."
