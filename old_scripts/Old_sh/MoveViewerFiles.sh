#!/bin/bash

##################################################################
# This script works off an input file with space seperated fields
# The file should have the following columns with one row per
# subject:
#
# SubjectId NIRSFile ImageDir BetaDir ResultDir AnatomicalHeadVox
#
##################################################################

# Setup Evironmental Variables
scriptPath=`dirname $0`
scriptPath=$scriptPath/matlab

if [ $# != 1 ]; then
  echo "ERROR: Inavlid usage."
  echo "$0 inputFile"
  exit
fi

if [ ! -e $1 ]; then
  echo "ERROR: Input file does not exist"
  exit 1
fi

subjects=`awk '{print $1}' $1`
let index=1

for i in $subjects
do
  NIRSfile=`cat $1 | tr -d '\r' | sed -n ${index}p | awk '{print $2}'`
  subjectDir=`cat $1 | tr -d '\r' | sed -n ${index}p | awk '{print $3}'`
  anatHeadVol=`cat $1 | tr -d '\r' | sed -n ${index}p | awk '{print $6}'`

  mv $subjectDir/viewer $subjectDir/viewer_0.01

  let index+=1
done