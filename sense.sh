#!/bin/sh
#----------------------------------------
# Linux Logic Analyzer
#
# [GPIO-19]-  -_-_-_-_-_
# [GPIO-21]   --__--__--
# [GPIO-22]   ----____--
#
# use:
# sense --c1 <pin-1> --c2 <pin-2> --c3 <pin-3> [... --cn <pin-n>]
#       --tc <trig-pin> --tp <trig-pol> --tm <trig-mod>
#       --width <wid> --rate <rat>
#       --cl1 <lbl-1> --cl2 <lbl-2> --cl3 <lbl-3> ... --cln <lbl-n>
#       --help
# def:
# pin-x: BCM logical i/o numbers
# trig-pin: one of 1 ... n
# trig-pol: '+' or '-'
# trig-mod: "auto" or "norm"
# wid: screen size in chars
# rat: loop time in seconds
# ex:
# sense  --c1 4 --c2 3 --c3 2 --tc 4 --tp - --tm norm -w 50 -r 0.04 --cl1 GPIO-19
#
# 1.0  2020-02-04 pds   initial cut

#
# define signal input(s) as RPi GPIO numbers
#
PIN_ONE=4
PIN_ONE_LABEL=BCM-$PIN_ONE
#PIN_ONE_LABEL=GPIO-19

PIN_TWO=3
PIN_TWO_LABEL=BCM-$PIN_TWO
#PIN_TWO_LABEL=GPIO-21

PIN_THREE=2
PIN_THREE_LABEL=BCM-$PIN_THREE
#PIN_THREE_LABEL=GPIO-22

#
# define signal triggering
#
TRIG_PIN=$PIN_ONE
TRIG_POL=1
TRIG_MOD=NORM

#
# configure display settings
#
WIDTH=50
#RATE=0.075
RATE=0.02
#RATE=$2/1000

#
#
#

help()
{
  echo "use:"
  echo "  sense <pin-1> <pin-2> <pin-3> [... <pin-n>] <trig-pin> <trig-pol> <trig-mod> <wid> <rat>"
  echo "        [<lbl-1> <lbl-2> <lbl-3> ... <lbl-n>]"
  echo "def:"
  echo "  pin-x: BCM logical i/o numbers"
  echo "  trig-pin: one of 1 ... n"
  echo "  trig-pol: '+' or '-'"
  echo "  trig-mod: 'auto' or 'norm'"
  echo "  wid: screen size in chars"
  echo "  rat: loop time in seconds"
  echo "ex:"
  echo "  sense --c1 4 --c2 3 --c3 2 --tc 4 --tp - --tm norm -w 50 -r 0.04"
  echo "        --cl1 GPIO-19 --cl2 GPIO-21 --cl3 GPIO-22"
}

options=$(getopt -o w:r:h --long "c1:,c2:,c3:,cl1:,cl2:,cl3:,tc:,tp:,tm:,tq:,tl:,width:,rate:,help" -- "$@")
if [ $? -ne 0 ]; then
  echo "Unknown option(s):"
  help
  exit 2
fi
eval set -- "$options"
while true; do
  case "$1" in
  --c1 ) PIN_ONE=$2; shift;;
  --c2 ) PIN_TWO=$2; shift;;
  --c3 ) PIN_THREE=$2; shift;;
  --cl1 ) PIN_ONE_LABEL=$2; shift;;
  --cl2 ) PIN_TWO_LABEL=$2; shift;;
  --cl3 ) PIN_THREE_LABEL=$2; shift;;
  --tc ) TRIG_PIN=$2; shift;;
  --tp ) if [ "$2" = "+" ]; then TRIG_POL=1; else TRIG_POL=0; fi; shift;;
  --tm ) TRIG_MOD=$(echo $2 | tr [a-z] [A-Z]); shift;;
  --tq ) TRIG_QUAL_PIN=$2; shift;;
  --tl ) TRIG_QUAL_LVL=0; shift;;
  -w | --width ) WIDTH=$2; shift;;
  -r | --rate ) RATE=$2; shift;;
  -h | --help ) help; exit 1;;
  -- ) break;;
  * ) echo "Error processing input:"; help; exit 2;;
  esac
  shift
done
#echo $PIN_ONE $PIN_TWO $PIN_THREE
#echo $PIN_ONE_LABEL $PIN_TWO_LABEL $PIN_THREE_LABEL 
#echo $TRIG_PIN $TRIG_POL $TRIG_MOD $TRIG_QUAL $TRIG_LVL
#echo $WIDTH $RATE

#-----------------------------------
#

GPIO=/sys/class/gpio

ON="1"
OFF="0"

addPin()
{
  if [ ! -e $GPIO/gpio$1 ]; then
    echo "$1" > $GPIO/export
  fi
}

removePin()
{
  if [ -e $GPIO/gpio$1 ]; then
    echo "$1" > $GPIO/unexport
  fi
}

setOutput()
{
  echo "out" > $GPIO/gpio$1/direction
}

setInput()
{
  echo "in" > $GPIO/gpio$1/direction
}

setPinState()
{
  echo $2 > $GPIO/gpio$1/value
}

#declare -i x=0
x=0

showPinState()
{
  if [ $1 -eq 1 ]; then
    echo "-"
  else
    echo "_"
  fi
}

getPinState()
{
  x=$( cat $GPIO/gpio$1/value )
}

startup()
{
  addPin $PIN_ONE
  setInput $PIN_ONE
  #setOutput $PIN_ONE

  addPin $PIN_TWO
  setInput $PIN_TWO
  #setOutput $PIN_TWO

  addPin $PIN_THREE
  setInput $PIN_THREE
  #setOutput $PIN_THREE
}

shutdown()
{
  #setPinState $PIN_THREE $OFF
  removePin $PIN_THREE

  #setPinState $PIN_TWO $OFF
  removePin $PIN_TWO

  #setPinState $PIN_ONE $OFF
  removePin $PIN_ONE
}

#declare -i is_running=1
is_running=1

please_stop()
{
  is_running=0
}

trap please_stop SIGINT

#
#-----------------------------------

startup

tput clear
tput cup 5 3
#tput setaf 3
echo "Linux Logic Analyzer"
tput sgr0
tput cup 6 5
tput rev
echo "Width=$WIDTH Rate=$RATE"
tput sgr0

#declare -i xorg=12
#declare -i yorg=10
xorg=12
yorg=10

#declare -i xpos=0
#declare -i ypos=0
xpos=0
ypos=0

xpos=0
ypos=$(expr $yorg + 0)
tput cup $ypos $xpos
tput setaf 1
printf "[$PIN_ONE_LABEL]"
if [ $TRIG_PIN -eq $PIN_ONE ]; then
  if [ $TRIG_POL -eq 1 ]; then
    printf "+"
  else
    printf "-"
  fi
fi

xpos=0
ypos=$(expr $yorg + 1)
tput cup $ypos $xpos
tput setaf 2
printf "[$PIN_TWO_LABEL]"
if [ $TRIG_PIN -eq $PIN_TWO ]; then
  if [ $TRIG_POL -eq 1 ]; then
    printf "+"
  else
    printf "-"
  fi
fi

xpos=0
ypos=$(expr $yorg + 2)
tput cup $ypos $xpos
tput setaf 3
printf "[$PIN_THREE_LABEL]"
if [ $TRIG_PIN -eq $PIN_THREE ]; then
  if [ $TRIG_POL -eq 1 ]; then
    printf "+"
  else
    printf "-"
  fi
fi

#declare -i var=0
var=0
while [ $is_running -eq 1 ]
do
  #
  # wait for trigger event
  #

  if [ "$TRIG_MOD" = "NORM" -a $var -eq 0 ]; then
    getPinState $TRIG_PIN
    a=$x
    sleep 0.01
    getPinState $TRIG_PIN
    b=$x
    if ! [ $a -ne $TRIG_POL -a $b -eq $TRIG_POL ]; then
      continue
    fi
  fi

  sleep $RATE

  #
  # sample
  #

  getPinState $PIN_ONE
  a=$x
  getPinState $PIN_TWO
  b=$x
  getPinState $PIN_THREE
  c=$x

  xpos=$(expr $xorg + $var)

  ypos=$(expr $yorg + 0)
  tput cup $ypos $xpos
  tput setaf 1
  showPinState $a

  ypos=$(expr $yorg + 1)
  tput cup $ypos $xpos
  tput setaf 2
  showPinState $b

  ypos=$(expr $yorg + 2)
  tput cup $ypos $xpos
  tput setaf 3
  showPinState $c

  #
  # escapement
  #

  var=$(expr $var + 1)
  if [ $var -eq $WIDTH ]; then
    #echo -e "\c"
    #printf '\r'
    var=0
  fi
done

xpos=0
ypos=$(expr $ypos + 1)
tput cup $ypos $xpos

shutdown
