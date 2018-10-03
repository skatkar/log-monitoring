#!/bin/bash
start=0
end=10
delay=5

while getopts ":d:i:" opt
do
  case ${opt} in
    d ) delay=$OPTARG
		echo "Delay of " $delay " is set"
      ;;
    i ) end=$OPTARG
		echo "Loop will iterate for " $end " times"
      ;;
    \? ) echo "Usage: cmd [-d] [-i]"
      ;;
  esac
done


while [ $start -le $end ]
do
    while read line
    do
        echo $line
    done<inputSample.txt
    sleep $delay
((start++))
done
echo "Code is exiting"