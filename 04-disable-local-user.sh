# delete local user without removing their home directory

ARCHIVE_DIR="/archive"

# enforcing superuser
if [[ "${UID}" -ne 0 ]] ;then
  echo "Please run this program as root or with superuser permissions." >&2
  exit 1
fi

# usage function
usage() {
  echo "Usage: ${0} [-dra] USER_NAME" >&2
  echo "Disable the account of the specified USER_NAME..." >&2
  echo "  -d  Delete the account instead of disabling it"
  echo "  -r  Remove the home directory of the user"
  echo "  -a  Archive the contents of the user's home directory to the /archives directory"
  exit 1
}

# parsing options
while getopts dra OPTION
do
  case ${OPTION} in
    a) ARCHIVE='true'     ;;
    r) REMOVE_OPT='-r'    ;;
    d) DELETE_USER='true'  ;;
    ?) usage  ;;
  esac
done

# remove getopts options while leaving username arguments
shift "$(( OPTIND - 1 ))"

# check if no arguments were passed
if [[ "${#}" -lt 1 ]] ;then
  usage
fi

# loop through all usernames supplied as arguments
for USERNAME in "${@}" ;do
  USERID=$(id -u ${USERNAME})
  if [[ "${USERID}" -lt 1000 ]] ;then
    echo "Cannot remove ${USERNAME} account with UID ${USERID}." >&2
    exit 1
  fi

  # archive creation
  if [[ "${ARCHIVE}" = 'true' ]] ;then
    if [[ ! -d "${ARCHIVE_DIR}" ]] ;then
      echo "CREATING ${ARCHIVE_DIR} directory."
      mkdir -p ${ARCHIVE_DIR}
      if [[ "${?}" -ne 0 ]] ;then
        echo "The archive directory ${ARCHIVE_DIR} could not be created." >&2
        exit 1
      fi
    fi

    # archiving home directory and moving the archive to ARCHIVE_DIR
    HOME_DIR="/home/${USERNAME}"
    ARCHIVE_FILE="${ARCHIVE_DIR}/${USERNAME}.tgz"
    if [[ -d "${HOME_DIR}" ]] ;then
      echo "Archiving ${HOME_DIR} to ${ARCHIVE_FILE}."
      tar -zcf ${ARCHIVE_FILE} ${HOME_DIR} &> /dev/null
      if [[ "${?}" -ne 0 ]] ;then
        echo "Could not create ${ARCHIVE_FILE}" >&2
        exit 1
      fi
    else 
      echo "${HOME_DIR} does not exist or is not a directory." >&2
      exit 1
    fi
  fi

  # delete logic
  if [[ "${DELETE_USER}" = 'true' ]] ;then
    userdel ${REMOVE_OPT} ${USERNAME}

    # check if userdel executed successfully
    if [[ "${?}" -ne 0 ]] ;then
      echo "The account ${USERNAME} was NOT be deleted." >&2
      exit 1
    fi
    echo "The account ${USERNAME} was deleted"
  else 
    chage -E 0 ${USERNAME}

    # check if the command was successful
    if [[ "${?}" -ne 0 ]] ;then
      echo "The account ${USERNAME} was NOT disabled." >&2
      exit 1
    fi
    echo "The account ${USERNAME} was disabled."
  fi
done

exit 0
