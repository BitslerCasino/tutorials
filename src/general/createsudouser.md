
## Creating a Sudo User on Ubuntu 16.04

The  `sudo`  command provides a mechanism for granting administrator privileges, ordinarily only available to the root user, to normal users. This guide will show you the easiest way to create a new user with sudo access on Ubuntu, without having to modify your server's  `sudoers`  file. If you want to configure sudo for an existing user, simply skip to step 3.

#### 1. Log in to your server as the  `root`  user.
```bash
local$ ssh root@server_ip
```  
#### 2. Create a new user account using the  `adduser`  command. Don’t forget to replace  `username`  with the user name that you want to create.
```bash
server$ adduser username
```
You will be prompted to set and confirm the new user password. Make sure that the password for the new account is as strong as possible.

```output
Set password prompts:
Enter new UNIX password:
Retype new UNIX password:
passwd: password updated successfully
```
Follow the prompts to set the new user's information. It is fine to accept the defaults to leave all of this information blank.

```output
User information prompts:
Changing the user information for username
Enter the new value, or press ENTER for the default
    Full Name []:
    Room Number []:
    Work Phone []:
    Home Phone []:
    Other []:
Is the information correct? [Y/n]
```
#### 3. Use the usermod command to add the user to the sudo group.
```bash
server$ usermod -aG sudo username
```