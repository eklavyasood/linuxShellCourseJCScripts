# creating local users script 3

# enforcing superuser privileges
if [[ "${UID}" -ne 0 ]] ;then
  echo "You must run this script as the root user! Exiting..." >&2
  exit 1
fi

# checking if arguments were passed or not
if [[ "${#}" -lt 1 ]] ;then
  echo "Usage: ${0} USER_NAME [COMMENT]..." >&2
  echo "Create a new account on the system with the name USER_NAME and an optional COMMENT"  >&2
  exit 1
fi

# reading first argument as username
USER_NAME="${1}"

# reading all other arguments as the comment field
shift
COMMENT="${@}"

# generating a password
PASSWORD=$(date +%s%N | sha256sum | head -c8)

# creating the account, and checking if it was created or not
useradd -c "$COMMENT" "$USER_NAME" &>/dev/null
if [[ "${?}" -ne 0 ]] ;then
  echo "The account could not be created! Exiting..." >&2
  exit 1
fi

# setting password, forcing change at first login, and checking if it was set or not
echo "$PASSWORD" | passwd --stdin "$USER_NAME" &> /dev/null
if [[ "${?}" -ne 0 ]] ;then
  echo "The password could not be set! Exiting..." >&2
  exit 1
fi
passwd -e $USER_NAME > /dev/null

# displaying the new user's username, hostname and password
echo "username:"
echo $USER_NAME
echo "password:"
echo $PASSWORD
echo "host:"
hostname
exit 0
