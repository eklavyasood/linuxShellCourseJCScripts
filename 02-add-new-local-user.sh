# enforcing superuser permission requirement
if [[ "${UID}" -ne 0 ]] ;then
  echo "You need to run this script as the root user!"
  exit 1
fi

# returning manpage-type usage statement if account name isn't supplied at execution
if [[ "${#}" -lt 1 ]] ;then
  echo "Usage: ${0} USER_NAME [COMMENT]..."
  echo "Create an account on the local system with the name USER_NAME and a comment field COMMENT"
  exit 1
fi

# reading username from the first argument
USER_NAME="${1}"

# reading the rest of the arguments as the comment
shift
COMMENT="${@}"

# automatically generating a password for the user
PASSWORD=$(date +%s%N | sha256sum | head -c12)

# creating the user
useradd -c "$COMMENT" "$USER_NAME"

# checking if the user couldn't be created
if [[ "${?}" -ne 0 ]] ;then
  echo "the user could not be created for some reason"
  exit 1
fi

# setting the password for the new user
echo $PASSWORD | passwd --stdin $USER_NAME

# checking if the password couldn't be set
if [[ "${?}" -ne 0 ]] ;then
  echo "the password could not be set for some reason"
  exit 1
fi

# forcing password change at first login
passwd -e $USER_NAME

# displaying the new username, hostname and password

echo -n "username:"
echo -n $USER_NAME
echo
echo -n "password:"
echo -n $PASSWORD
echo
echo -n "hostname:"
hostname

