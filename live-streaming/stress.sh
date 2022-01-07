#!/usr/bin/env bash


streamers='1'
clients='1'
upload_url='rtmp:localhost:1935/stream/'
download_url='http://localhost:80/live/'
template_name='video-%s'
file='video.mp4'
image_name='hls'
container_name='hls'
keep='false'

print_usage() {
  app_name=$(basename "${0}") || "${0}"
  printf "%s - HLS online strees test\n" "${app_name}"
  printf "\n"
  printf "%s [options]\n" "${app_name}"
  printf "\n"
  printf "options:\n"
  printf "\t-h\tshow usage\n"
  printf "\t-s\tspecify number of streamers/content creators (default: %s)\n" "${streamers}"
  printf "\t-c\tspecify number of clients per stream (default: %s)\n" "${clients}"
  printf "\t-u\tspecify rtmp upload url (default: %s)\n" "${upload_url}"
  printf "\t-d\tspecify download url (default: %s)\n" "${download_url}"
  printf "\t-t\tspecify stream template name (default: %s)\n" "${template_name}"
  printf "\t-f\tspecify file to stream (default: %s)\n" "${file}"
  printf "\t-i\tspecify image name (default: %s)\n" "${image_name}"
  printf "\t-n\tspecify container name (default: %s)\n" "${container_name}"
  printf "\t-k\tkeep image (default: %s)\n" "${keep}"
  exit 0
}

while getopts 'hks:c:u:d:t:f:i:n:' flag; do
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
    u)
      upload_url="${OPTARG}" ;;
    d)
      download_url="${OPTARG}" ;;
    t)
      template_name="${OPTARG}" ;;
    f)
      file="${OPTARG}" ;;
    i)
      image_name="${OPTARG}" ;;
    n)
      container_name="${OPTARG}" ;;
    k)
      keep='true' ;;
    h)
      print_usage ;;
    :)
      echo "Error: -${OPTARG} requires an argument."
      exit 1 ;;
    *)
      exit 1 ;;
  esac
done

function _docker_build_image() {
  docker build -t "${image_name}" -f download/Dockerfile download
}

function _docker_remove_image() {
  docker rmi "${image_name}" -f
}

function _docker_stop_container() {
  docker stop "${container_name}"
}

_term() { 
  echo "Caught SIGTERM signal!" 
  _docker_stop_container
  for job in $(jobs -p)
  do
    kill -9 "${job}" 2>/dev/null
  done
  if [ "${keep}" = "false" ]; then
    _docker_remove_image
  fi
}

trap _term SIGTERM

_docker_build_image

./upload/stream.sh -s "${streamers}" \
  -u "${upload_url}" \
  -t "${template_name}" \
  -f "${file}" &

docker run --rm --name "${container_name}" "${image_name}" -- \
  -s "${streamers}" \
  -c "${clients}" \
  -d "${download_url}" \
  -t "${template_name}" &


for job in $(jobs -p)
do
	wait "${job}"
done
