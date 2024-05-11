# script that will count failed login attempts and output them if they are more than 10

LIMIT=10
LOGFILE=${1}

if [[ ! -f ${LOGFILE} ]] ;then
  echo "The log file ${LOGFILE} is not accessible." >&2
  exit 1
fi

# check if no args passed
if [[ "${#}" -lt 1 ]] ;then
  echo "Please pass at least one file as argument!" >&2
  exit 1
fi

# checking if provided logfile is accessible
if [[ ! -f ${LOGFILE} ]] ;then
  echo "Log file not accessible." >&2
  exit 1
fi

echo 'Count,IP,Location'

grep Failed ${LOGFILE} | awk '{print $(NF - 3)}' | sort | uniq -c | sort -nr |  while read COUNT IP
do
  # If the number of failed attempts is greater than the limit, display count, IP, and location.
  if [[ "${COUNT}" -gt "${LIMIT}" ]]
  then
    LOCATION=$(geoiplookup ${IP} | awk -F ', ' '{print $2}')
    echo "${COUNT},${IP},${LOCATION}"
  fi
done
