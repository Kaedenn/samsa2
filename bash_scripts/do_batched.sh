#!/bin/bash
#SBATCH --mem=100000
#SBATCH --time=7-0:0:0

source bash_scripts/lib/common.sh
source bash_scripts/lib/master.sh

PROGNAME="$0"

usage() {
  echo "usage: $PROGNAME <config> <file-list>" >&2
  if [[ -n "$1" ]]; then
    exit $1
  else
    exit 0
  fi
}

get_config() {
  awk -F= "\$1==\"$2\"{ print \$2 }" "$1"
}

while getopts ":h" arg; do
  case "$arg" in
    h)
      usage 0
      ;;
    *)
      echo "invalid argument $arg" >&2
      usage 1
      ;;
  esac
done

if [[ -z "$1" ]] || [[ -z "$2" ]]; then
  usage 0
fi

CONFIG_FILE="$1"
FILELIST_FILE="$2"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "ERROR: config file $CONFIG_FILE not found" >&2
  exit 1
fi

if [[ ! -f "$FILELIST_FILE" ]]; then
  echo "ERROR: file list $FILELIST_FILE not found" >&2
  exit 1
fi

s_uri="$(get_config "$CONFIG_FILE" "SERVER_URI")"
num_files="$(wc -l "$FILELIST_FILE" | awk '{ print $1 }')"
logstr "Downloading $num_files files from $s_uri"
cat "$FILELIST_FILE" | while read fname; do
  echo "Downloading $s_uri/$fname to $INPUT_DIR/$fname" >&2
  download_file "$s_uri/$fname" "$INPUT_DIR/$fname"
  do_gunzip "$INPUT_DIR/$fname"
done

# By request: only run steps 1, 2, and 3
do_step_1
do_step_2
do_step_3

