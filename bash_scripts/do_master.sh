#!/bin/bash

source bash_scripts/lib/common.sh
source bash_scripts/lib/master.sh

INPUT_DIR=$SAMSA/input_files
OUTPUT_DIR=$SAMSA

STEP_1="$OUTPUT_DIR/step_1_output"
STEP_2="$OUTPUT_DIR/step_2_output"
STEP_3="$OUTPUT_DIR/step_3_output"
STEP_4="$OUTPUT_DIR/step_4_output"
STEP_5="$OUTPUT_DIR/step_5_output"

do_step_1() {
    do_pear "$INPUT_DIR" "$STEP_1"
}

do_step_2() {
    do_trimmomatic "$STEP_1" "$STEP_2"
    do_read_counter "$STEP_2" "$STEP_2/raw_counts.txt"
}

do_step_3() {
    do_sortmerna "$STEP_2" "$STEP_3"
}

do_step_4() {
    do_diamond_refseq "$STEP_3" "$STEP_4"
    do_diamond_subsys "$STEP_3" "$STEP_4"
}

do_step_5() {
    do_refseq_analysis "$STEP_4" "$STEP_5"
    do_subsys_analysis "$STEP_4" "$STEP_5"
}

# Comment out one or more of the following lines to restrict which steps run
do_all() {
    do_step_1
    do_step_2
    do_step_3
    do_step_4
    do_step_5
}

export SAMSA_INTERACTIVE=1
export DRY_RUN=1
do_all
export DRY_RUN=
do_all
