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

outputFile=access_log_`date +"%Y%m%d%H%M"`.log
while [ $start -le $end ]
do
    while read line
    do
        echo $line >> $outputFile
    done<inputSample.txt
    sleep $delay
((start++))
done
echo "Code is exiting"