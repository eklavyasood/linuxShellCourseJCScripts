# enforcing no-superuser-running rule
if [[ "${UID}" -eq 0 ]]
then
  echo "Use the -s option if you want to run the ssh command as root!" >&2
  exit 1
fi

# global variables
SERVER_FILE='/vagrant/servers'

# usage function
function usage() {
  echo "Usage: ${0} [nsv] [-f FILE] COMMAND" >&2
  echo "    -f  Specify an alternate serverfile" >&2
  echo "    -n  Perform a dry run of the commands (list the commands instead of running them)" >&2
  echo "    -s  Run the commands as superuser on the remote machine" >&2
  echo "    -v  Run the script verbosely" >&2
  exit 1 >&2
}

# parsing options
while getopts f:nsv OPTION
do
  case ${OPTION} in
    f)  SERVER_FILE=${OPTARG} ;;
    n)  DRY_RUN='true' ;;
    s)  SUPER_FLAG='sudo' ;;
    v)  VERBOSITY='true' ;;
    *)  usage  ;;
  esac
done
shift "$(( OPTIND - 1 ))"

# confirm whether the server file exists
if [[ ! -f "${SERVER_FILE}" ]] ;then
  echo "Cannot access ${SERVER_FILE}." >&2
  exit 1
fi

# check for no commands to be passed
if [[ "${#}" -lt 1 ]] ;then
  usage
fi

COMMAND="${@}"

# run ssh command
for SERVER in $(cat ${SERVER_FILE})
do
  if [[ "${VERBOSITY}" = 'true' ]]
  then
    echo "${SERVER}"
  fi

  if [[ "${DRY_RUN}" = 'true' ]]
  then
    echo "DRY RUN: ssh -o ConnectTimeout=2 ${SERVER} "${SUPER_FLAG} ${COMMAND}" "
  else
    ssh -o ConnectTimeout=2 ${SERVER} "${SUPER_FLAG} ${@}"
    SSH_EXIT_STATUS="${?}"
  fi

  if [[ "${SSH_EXIT_STATUS}" -ne 0 ]] ;then
    EXIT_STATUS=${SSH_EXIT_STATUS}
    echo "Execution on ${SERVER} failed." >&2
  fi
done

exit ${EXIT_STATUS}
