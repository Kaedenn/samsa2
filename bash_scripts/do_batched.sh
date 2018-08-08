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
  if [[ -f "$INPUT_DIR/${fname/.gz/}" ]]; then
    echo "Skipping downloaded file $INPUT_DIR/$fname" >&2
  else
    echo "Downloading $s_uri/$fname to $INPUT_DIR/$fname" >&2
    download_file "$s_uri/$fname" "$INPUT_DIR/$fname"
    do_gunzip "$INPUT_DIR/$fname"
  fi
done

# By request: only run steps 1, 2, and 3

# Step 1: PEAR
do_pear "$INPUT_DIR"

# Step 2: Trimmomatic (and read counter processing)
do_trimmomatic "$STEP_1" "$STEP_2"
do_read_counter "$STEP_2" "$STEP_2/raw_counts.txt"

# Step 3: SortMeRNA
do_sortmerna "$STEP_2" "$STEP_3"

