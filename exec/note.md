# To add a new user

## -m creates a home directory
## -G wheel adds them to the wheel group (so they can use sudo if enabled)
## -s /bin/bash sets their shell

`sudo useradd -m -G wheel -s /bin/bash <username>`
`sudo passwd <username>`

# To delete the user later

## -r deletes their home directory and files

`sudo userdel -r <username>`

# If the user has processes running then you can do

`sudo pkill -u <username>`
