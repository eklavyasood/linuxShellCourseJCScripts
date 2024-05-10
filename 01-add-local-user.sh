#!/bin/bash

# check if the user is root or not
if [[ "$(id -u)" != 0 ]]
then
  echo "you are not the root user! you must run this script as root"
  exit 1
fi

# read username, full name, and initial password
read -pr "enter the username to create: " USER_NAME
read -pr "enter the full name: " FULL_NAME
read -pr "enter this user's password: " PASSWORD

# creating user
useradd -c "$FULL_NAME" "$USER_NAME"

# checking if the user was added successfully
if [[ "${?}" -ne 0 ]]
then
  echo "the user was unable to be added for some reason"
  echo "exiting"
  exit 1
fi

# creating initial password
echo "$PASSWORD" | passwd --stdin "$USER_NAME"

# checking if the password was set successfully
if [[ "${?}" -ne 0 ]]
then
  echo "the password was unable to be set"
  echo "exiting"
  exit 1
fi

# expiring the user's password on first login
passwd -e "$USER_NAME"

# displaying username, password and hostname
echo -e "\nusername:"
echo "$USER_NAME"
echo -e "\npassword:"
echo "$PASSWORD"
echo -e "\nhostname:"
hostname
