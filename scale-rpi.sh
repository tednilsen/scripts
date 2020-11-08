#!/bin/bash

# scale-rpi.sh
#   a script to change the current scaling kernel of the RPi
#   https://github.com/tednilsen/scripts/raw/main/scale-rpi.sh

# -------------------------------------------------

# info: my bash script skills are terrible!

# to set skaling, just set the parameters:
# vcgencmd scaling_kernel 0 -2 -6 -8 -10 -8 -3 2 18 50 82 119 155 187 213 227 227 213 187 155 119 82 50 18 2 -3 -8 -10 -8 -6 -2 0   0

# SCALERLIB_KERNELS_TYPES_SINC=1,
# SCALERLIB_KERNELS_TYPES_SINC_BLACKMAN=2,
# SCALERLIB_KERNELS_TYPES_SINC_NO_SIDE_LOBES=3,
# SCALERLIB_KERNELS_TYPES_SINC_HALF_FIRST_SIDE_LOBE=4,
# SCALERLIB_KERNELS_TYPES_SINC_HAMMING=5,
# SCALERLIB_KERNELS_TYPES_SINC_HAMMING_3PI=6, (default)
# SCALERLIB_KERNELS_TYPES_SINC_HAMMING_2_5PI=7,
# SCALERLIB_KERNELS_TYPES_NEAREST_NEIGHBOUR=8,

# -------------------------------------------------

VCMAX=9

VCNAME=("SINC BLACKMAN NO_SIDE_LOBES HALF_FIRST_SIDE_LOBE HAMMING SINC_HAMMING_3PI HAMMING_2_5PI NEAREST_NEIGHBOUR NEAREST_2")

VCCMD=(	"23 22 21 18 13 8 2 -6 18 41 67 96 129 160 191 222 222 191 160 129 96 67 41 18 -6 2 8 13 18 21 22 23   0"
	"0 0 -1 -3 -5 -7 -8 -4 7 28 60 102 150 196 233 253 253 233 196 150 102 60 28 7 -4 -8 -7 -5 -3 -1 0 0   0"
	"0 0 0 0 3 8 17 30 47 67 89 111 132 150 163 170 170 163 150 132 111 89 67 47 30 17 8 3 0 0 0 0   0"
	"-22 -15 -7 3 15 28 42 56 70 84 97 109 118 126 131 134 134 131 126 118 109 97 84 70 56 42 28 15 3 -7 -15 -22   0"
	"0 1 3 6 12 20 30 43 59 76 93 111 127 139 149 154 154 149 139 127 111 93 76 59 43 30 20 12 6 3 1 0   0"
	"-2 -3 -4 -4 -3 1 9 22 40 64 90 118 145 169 186 196 196 186 169 145 118 90 64 40 22 9 1 -3 -4 -4 -3 -2   0"
	"-2 -2 -1 1 4 11 20 34 51 71 93 115 135 152 165 172 172 165 152 135 115 93 71 51 34 20 11 4 1 -1 -2 -2   0"
	"0 0 0 0 0 0 0 0 1 1 1 1 255 255 255 255 255 255 255 255 1 1 1 1 0 0 0 0 0 0 0 0   1"
	"0 0 0 0 0 0 0 0 1 8 16 224 248 248 255 255 255 255 248 248 224 16 8 1 0 0 0 0 0 0 0 0   0" )

QUIET=0
NUM=0
P=0
for ARG in $@; do
  # prev arg was p? we have launch parameter so grab it
  if [[ $P = 1 ]]; then
    LAUNCH=$ARG
    P=0
    PRG=1
  else
    # else check args
    [[ $ARG =~ ^[qQ] ]] && QUIET=1
    [[ $ARG =~ ^[1-$VCMAX]$ ]] && NUM=$ARG
    # p argument? then prepare that next arg is the launch
    [[ $ARG =~ ^[pP] ]] && P=1
  fi;
done;

if [[ $NUM =~ ^[1-$VCMAX]$ ]]; then
  # grab scaling_kernel if we shall launch
  if [[ $PRG -eq 1 ]]; then
    SCALE=$(vcgencmd scaling_kernel)
    SCALE=${SCALE#*=}
  fi;
  ARR=($VCNAME)
  NUM=$(( $NUM - 1 ))
  SEL=${ARR[$NUM]}
  [ $QUIET -eq 0 ] && echo "Selected $SEL scaling"
  vcgencmd "scaling_kernel ${VCCMD[$NUM]}" > /dev/null
  # launch program? ...then launch and resore scaling kernel
  if [[ $PRG -eq 1 ]]; then
    # launch program
    ./"${LAUNCH}"
    # restore scaling kernel
    vcgencmd "scaling_kernel ${SCALE}" > /dev/null
  fi;
else
  echo
  echo "RPi Scaling Kernel launcher..."
  echo
  echo "Please input a number between 1..$VCMAX to select scaling mode:"
  echo "----------------------------------------------------------"
  NUM=1
  for NAME in $VCNAME; do
    echo $NUM $NAME
    NUM=$(( $NUM + 1 ))
  done;
  echo "----------------------------------------------------------"
  echo
  echo "Argument:        Info:"
  echo "1-9              Select scaling kernel"
  echo "q                Quiet"
  echo 'p + "program"    Launch program'
  echo
  echo "----------------------------------------------------------"
  echo
  echo "example 1: Set scaling 8 (NEAREST_NEIGHBOUR):"
  echo "./scale-rpi.sh 2"
  echo
  echo "example 2: Quiet set scaling 4 (HALF_FIRST_SIDE_LOBE):"
  echo "./scale-rpi.sh q 4"
  echo
  echo " example 3: Quiet set scaling 2 (BLACKMAN), launch amiberry, restore scaling kernel when amiberry finnishes."
  echo "./scale-rpi.sh q 2 p amiberry"
  echo
fi

exit 0
