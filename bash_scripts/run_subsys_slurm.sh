#!/bin/bash

source bash_scripts/lib/common.sh
source bash_scripts/lib/master.sh

run_program()
{
  srun -p t1small --pty --exclusive "$@"
}

export PREFIX="srun -p t1small --pty --exclusive"

export DRY_RUN=1
do_diamond_subsys "$STEP_3" "$STEP_4"
