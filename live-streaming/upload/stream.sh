#!/usr/bin/env bash

streamers='1'
upload_url='rtmp:localhost:1935/stream/'
template_name='video-%s'
file='video.mp4'

print_usage() {
  app_name=$(basename "${0}") || "${0}"
  printf "%s - HLS streamer/content creator stress test\n" "${app_name}"
  printf "\n"
  printf "%s [options]\n" "${app_name}"
  printf "\n"
  printf "options:\n"
  printf "\t-h\tshow usage\n"
  printf "\t-s\tspecify number of streamers/content creators (default: %s)\n" "${streamers}"
  printf "\t-u\tspecify rtmp upload url (default: %s)\n" "${upload_url}"
  printf "\t-t\tspecify stream template name (default: %s)\n" "${template_name}"
  printf "\t-f\tspecify file to stream (default: %s)\n" "${file}"
  exit 0
}

while getopts 'hs:u:t:f:' flag; do
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
    u)
      upload_url="${OPTARG}" ;;
    t)
      template_name="${OPTARG}" ;;
    f)
      file="${OPTARG}" ;;
    h)
      print_usage ;;
    :)
      echo "Error: -${OPTARG} requires an argument."
      exit 1 ;;
    *)
      exit 1 ;;
  esac
done

for stream in $(seq 1 "${streamers}")
do
  url=$(printf "%s${template_name}" "${upload_url}" "${stream}")

	ffmpeg -re \
		-i "${file}" \
		-vcodec copy \
		-loop -1 \
		-c:a aac \
		-b:a 160k \
		-ar 44100 \
		-strict \
		-2 \
		-f flv \
		"${url}" &
done

_term() { 
  echo "Caught SIGTERM signal!" 
  for job in $(jobs -p)
  do
    kill -9 "${job}" 2>/dev/null
  done
}

trap _term SIGTERM

for job in $(jobs -p)
do
	wait "${job}"
done
