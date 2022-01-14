#!/usr/bin/env bash

streamers='1'
clients='1'
download_url='http://localhost:80/live/'
template_name='video-%s'
sleep_window='0'

print_usage() {
  app_name=$(basename "${0}") || "${0}"
  printf "%s - watch m3u8 streams strees test\n" "${app_name}"
  printf "\n"
  printf "%s [options]\n" "${app_name}"
  printf "\n"
  printf "options:\n"
  printf "\t-h\tshow usage\n"
  printf "\t-s\tspecify number of streamers/content creators (default: %s)\n" "${streamers}"
  printf "\t-c\tspecify number of clients per stream (default: %s)\n" "${clients}"
  printf "\t-d\tspecify download url (default: %s)\n" "${download_url}"
  printf "\t-t\tspecify stream template name (default: %s)\n" "${template_name}"
  printf "\t-r\tspecify random sleep window in ms (default: %s)\n" "${sleep_window}"
  exit 0
}

while getopts 'hs:c:d:t:f:r:' flag; do
  case "${flag}" in
    s)
      streamers="${OPTARG}"
      re_isanum='^[0-9]+$'
      if ! [[ "${streamers}" =~ $re_isanum ]] ; then
        echo "Error: streamers must be a positive, whole number."
        exit 1
      elif [ "${streamers}" -eq "0" ]; then
        echo "Error: streamers must be greater than zero."
        exit 1
      fi ;;
    c)
      clients="${OPTARG}"
      re_isanum='^[0-9]+$'
      if ! [[ "${clients}" =~ $re_isanum ]] ; then
        echo "Error: clients must be a positive, whole number."
        exit 1
      elif [ "${clients}" -eq "0" ]; then
        echo "Error: clients must be greater than zero."
        exit 1
      fi ;;
    d)
      download_url="${OPTARG}" ;;
    t)
      template_name="${OPTARG}" ;;
    r)
      sleep_window="${OPTARG}" ;;
    h)
      print_usage ;;
    :)
      echo "Error: -${OPTARG} requires an argument."
      exit 1 ;;
    *)
      exit 1 ;;
  esac
done

_term() { 
  echo "Caught SIGTERM signal!" 
  for job in $(jobs -p)
  do
    kill -9 "${job}" 2>/dev/null
  done
}

trap _term SIGTERM

_stream() {
  sleep_ms=$(1 + "${RANDOM}" "${sleep_window}")
  sleep $(echo "${sleep_ms}/1000" | bc -l)
  hlsdl -b -o - "${1}" >/dev/null
}

for stream in $(seq 1 "${streamers}")
do
  url=$(printf "%s${template_name}.m3u8" "${download_url}" "${stream}")
  for _ in $(seq 1 "${clients}")
  do
    _stream "${url}"
  done
done

for job in $(jobs -p)
do
	wait "${job}"
done
