#!/bin/bash

if ! command -v toilet &> /dev/null; then
  echo "Need toilet for this script to work"
  echo "brew install toilet"
  exit 1
fi

# Displays a countdown with ascii text art
 hour=$1
 min=$2
 sec=$3
 while [ $hour -ge 0 ]; do
   while [ $min -ge 0 ]; do
     while [ $sec -ge 0 ]; do
       clear
       toilet -f smmono9 -w 1000 "Starting in $hour:$min:$sec"
       let "sec=sec-1"
       sleep 1
     done
     sec=59
     let "min=min-1"
   done
   min=59
   let "hour=hour-1"
 done
