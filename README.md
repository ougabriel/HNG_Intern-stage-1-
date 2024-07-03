### HNG_Intern-stage-1-DevOps Engineer Task


### Technical Article: Automating User Creation and Management with a Bash Script
![Untitled design](https://github.com/ougabriel/HNG_Intern-stage-1-/assets/34310658/4fba30c7-5a1a-4822-b398-c64b1e642896)


As a DevOps engineer, efficiently managing user accounts is crucial for maintaining system security and operational efficiency. This article introduces a Bash script `create_users.sh` designed to automate the creation of users based on data from a text file, manage group assignments, generate random passwords, and maintain detailed logs of all actions performed.

### Script Overview

The `create_users.sh` script reads input from a specified text file formatted as `username, groups`. It processes each line to create users, set up their primary groups, add them to additional groups if specified, generate secure passwords, and log each step for auditability.

### Step-by-Step Explanation

#### 1. Setting Variables and File Paths

The script initializes variables and defines file paths for logging user management activities and securely storing passwords.

```bash
#!/bin/bash

set -e

gab-USER_LOGS="/var/log/user_management.log"
gab-USER_PASSWORD="/var/secure/user_passwords.txt"
```

These variables (`gab-USER_LOGS` and `gab-USER_PASSWORD`) store paths to log and password files respectively, ensuring organized data management.

#### 2. Creating a Logging Function

A logging function `log_message()` is defined to append timestamped messages to the log file (`gab-USER_LOGS`), aiding in tracking user creation activities.

```bash
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $gab-USER_LOGS
}
```

This function enhances the script's traceability by recording events such as user creation, group assignments, and password generation.

#### 3. Checking Input File Presence

The script verifies if an input file is provided when executing the script, ensuring proper usage.

```bash
if [-z "$1"]; then
    echo "Usage: $0 <name-of-text-file>"
    exit 1
fi
```

This validation prevents unintended execution errors by prompting users to specify a text file containing usernames and associated group memberships.

#### 4. Setting File Permissions

Permissions for the log and password files are configured to restrict access and ensure data security.

```bash
touch $gab-USER_LOGS
chmod 644 $gab-USER_LOGS

mkdir -p /var/secure
touch $gab-USER_PASSWORD
chmod 600 $gab-USER_PASSWORD
```

These commands (`touch` and `chmod`) create the log file if absent, set read and write permissions, create the password file directory (`/var/secure`), and secure password storage with restricted permissions.

#### 5. Reading and Processing Input File

The script iterates through each line of the input file, extracting usernames and groups while handling whitespace trimming.

```bash
while IFS=";" read -r username groups; do
    username=$(echo "$username" | xargs)
    groups=$(echo "$groups" | xargs)
```

This loop (`while` with `read` and `IFS`) parses each line from the input file, preparing data for user creation and group management.

#### 6. User and Group Management

For each user identified in the input file, the script verifies user existence and performs user creation tasks.

```bash
if id "$username" &>/dev/null; then
    log_message "User $username already exists. Skipping creation."
    continue
fi

useradd -m -s /bin/bash "$username"
log_message "Created user $username."

usermod -g "$username" "$username"
log_message "Created and set a group for $username."
```

These commands (`id`, `useradd`, `usermod`) validate user existence, create users with home directories and shell access (`/bin/bash`), and set primary groups based on usernames.

#### 7. Managing Additional Groups

If additional groups are specified in the input file, the script creates these groups and adds users accordingly.

```bash
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
```

This segment handles dynamic group creation (`groupadd`) and user group assignment (`usermod -aG`), ensuring users are adequately configured for team-based access and collaboration.

#### 8. Password Generation and Storage

The script generates secure passwords for each new user, updates user credentials, and logs password-related activities.

```bash
password=$(openssl rand -base64 12)
echo "$username:$password" | chpasswd
log_message "User password is set for $username."

echo "$username,$password" >> $gab-USER_PASSWORD
```

The `openssl rand -base64 12` command creates strong, base64-encoded passwords, enhancing system security. Passwords are updated (`chpasswd`) and securely stored in the password file (`gab-USER_PASSWORD`) for future reference.

#### 9. Script Completion

Upon completing user creation tasks, a final log entry signifies successful execution of the script.

```bash
log_message "Hi Gabriel Okom !! User creation is completely set-up and ready for use."
```

This message (`log_message`) serves as confirmation of script execution and readiness for operational use, aiding in post-execution review and audit.

#### 10. Script Testing and Verification
A random text file was called named `gab_users.txt` with the following details
```bash
cat <<EOL > gab_users.txt
ayodele; sudo,dev
chioma; dev,www-data
femi; sudo
uche; dev,finance
kunle; hr,www-data
kemi; finance,www-data
abiodun; sudo,marketing
adeola; sudo,hr
ifunanya; marketing,www-data
chinedu; dev,sales
amara; sales, finance
olabisi; hr,sales
kemi; finance,www-data
abiodun; sudo,marketing
sola; dev,www-data
amara; sales, finance
ebuka; dev,www-data
tosin; sudo,hr
Ifeanyi; dev,marketing
lola; sales, finance
chukwuemeka; hr,www-data
bolaji; finance, dev
nkechi; marketing, sales
EOL
EOF

```
![image](https://github.com/ougabriel/HNG_Intern-stage-1-/assets/34310658/9c239fba-6eb4-403e-80f8-318b75443d1b)

After running the script using the following command, logs and random password files were generated and stored as shown in the image below
```bash
sudo bash create_user.sh gab_users.txt
```

![image](https://github.com/ougabriel/HNG_Intern-stage-1-/assets/34310658/4adf6e62-392e-4d71-a0eb-24e6f3faaa6f)


** 10.1:    Confirming Error Handling and Logs Saved**

Logs saved with timestamps showing exact dates up to the time and seconds that it was created
```bash
cat /var/log/user_management.log
```

![image](https://github.com/ougabriel/HNG_Intern-stage-1-/assets/34310658/84c8f2b4-7048-4e31-b13e-cac971edbfbb)


** 10.2:    Confirming Password creation and storage**

Another set of random names was used for this purpose with the same file name `gab_users.txt`
A random text file was called named `gab_users.txt` with the following details
```bash
cat << EOF > gab_users.txt
joy; sales,finance
ugochi; IT
gabriel; IT
linda; finance,marketing
mine; graphics
john; chef,housekeep
mandy; welfare,finance
ruth; marketing
elsa; marketing,sales
peter; management,CTO
ugo; CEO
EOF

```

Command used to get the password details of the new users and group

```bash
cat /var/secure/user_passwords.txt
```
![image](https://github.com/ougabriel/HNG_Intern-stage-1-/assets/34310658/9f6d0126-db38-4944-ba3c-a99af7d033c8)

**10.3:    Verify Individual Users has been created**

We will use the `id` command

```bash
id <username>
```
![image](https://github.com/ougabriel/HNG_Intern-stage-1-/assets/34310658/f02e8461-93d9-4934-87c2-2e56fcfdfdca)


**10.4: Verify Individual Group**

```bash
getent group <username>
```
![image](https://github.com/ougabriel/HNG_Intern-stage-1-/assets/34310658/8d4ff77a-4cab-4765-86b8-f1e28fc61ab8)

** 10.5: Verify invidual users has a personal group with the same name as their username**

```bash
id <username>
getent passwd <username>
getent group <username>
```
![image](https://github.com/ougabriel/HNG_Intern-stage-1-/assets/34310658/130f51d9-96c2-407c-9ffc-a11838c50714)

This will be explained in detail as given below

```bash
As the task suggests, The image shows the output of a series of commands that check user and group information for a user named "gabriel".
I have made effort to explain each command and its output:

1. `id gabriel`:
   - This command displays user and group information for the user "gabriel".
   - Output:
     ```
     uid=1023(gabriel) gid=1048(gabriel) groups=1048(gabriel),1027(IT)
     ```
     - `uid=1023(gabriel)`: The user ID (UID) for "gabriel" is 1023.
     - `gid=1048(gabriel)`: The primary group ID (GID) for "gabriel" is 1048, which corresponds to a group also named "gabriel".
     - `groups=1048(gabriel),1027(IT)`: "gabriel" belongs to two groups: "gabriel" (GID 1048) and "IT" (GID 1027).

2. `getent group gabriel`:
   - This command retrieves the group entry for the group named "gabriel" from the system databases.
   - Output:
     ```
     gabriel:x:1048:
     ```
     - `gabriel`: The name of the group.
     - `x`: Placeholder indicating that the group password is stored in a shadow file (if used).
     - `1048`: The GID of the group "gabriel".
     - The absence of additional information indicates there are no other members in the "gabriel" group besides the user "gabriel".

3. `getent passwd gabriel`:
   - This command retrieves the passwd entry for the user "gabriel" from the system databases.
   - Output:
     ```
     gabriel:x:1023:1048::/home/gabriel:/bin/bash
     ```
     - `gabriel`: The username.
     - `x`: Placeholder indicating that the user password is stored in a shadow file.
     - `1023`: The UID of the user "gabriel".
     - `1048`: The GID of the user "gabriel".
     - The fields for the user’s full name and other info are empty.
     - `/home/gabriel`: The home directory for "gabriel".
     - `/bin/bash`: The default shell for "gabriel".

 Summary

The user "gabriel" has a UID of 1023 and belongs to the primary group "gabriel" with a GID of 1048.
Additionally, "gabriel" is part of the "IT" group with a GID of 1027.
The home directory for "gabriel" is `/home/gabriel`, and the default shell is `/bin/bash`.
There are no other members in the "gabriel" group.
```

It is important to note that the commands run on the user `gabriel` has also the same output as other user created using the `create_user.sh` script.

### Deleting Users
Since the txt files were used to test the users on this machine, it will be a good idea for all this users to be deleted when the script testins is done. Here is a simple script I made to achieve this purpose.
```bash

#!/bin/bash

# Set the path to the password file
PASSWORD_FILE="/var/secure/user_passwords.txt"

# Check if the password file exists
if [ ! -f "$PASSWORD_FILE" ]; then
    echo "Password file not found. No users to delete."
    exit 1
fi

# Read the password file and delete users
while IFS=',' read -r username password; do
    # Check if the user exists
    if id "$username" &>/dev/null; then
        echo "Deleting user: $username"
        # Delete the user and their home directory
        userdel -r "$username"
    else
        echo "User $username not found. Skipping."
    fi
done < "$PASSWORD_FILE"

# Remove the password file
echo "Removing password file"
rm -f "$PASSWORD_FILE"

# Remove the log file
LOG_FILE="/var/log/user_management.log"
if [ -f "$LOG_FILE" ]; then
    echo "Removing log file"
    rm -f "$LOG_FILE"
fi

echo "Hi Gabriel !! User deletion process is now completed."

```

### Conclusion

In conclusion, the `create_users.sh` Bash script provides a robust solution for automating user creation, group management, and password administration in Unix-like environments. By integrating this script into system administration workflows, organizations can streamline user onboarding processes, enforce security best practices, and maintain comprehensive audit trails of user management activities.

### Additional Resources

For further information on Bash scripting, system administration, and best practices in user management, explore the following resources:

- [HNG Internship](https://hng.tech/internship)
- [HNG Hire](https://hng.tech/hire)

By leveraging automation with `create_users.sh`, SysOps engineers and administrators can optimize resource allocation, enhance system security, and foster collaborative environments across development teams.
