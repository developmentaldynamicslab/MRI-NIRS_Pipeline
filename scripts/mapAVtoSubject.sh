#!/bin/bash

scriptPath=`dirname $0`
scriptPath=$scriptPath/matlab

# Parse Command line arguements
while getopts “s:h” OPTION
do
  case $OPTION in
    h)
      echo "Usage: $0 -s subjectDir"
      echo "   where"
      echo "   -s AtlasViewer Analysis Directory for the subject"
      echo "   -h Display help message"
      exit 1
      ;;
    s)
      subjectDir=$OPTARG
      ;;
    ?)
      echo "ERROR: Invalid option"
      echo "Usage: $0 -s subjectDir"
      echo "   where"
      echo "   -s AtlasViewer Analysis Directory for the subject"
      echo "   -h Display help message"
      exit 1
      ;;
     esac
done

afniProg=`which 3dcalc`
if [[ $afniProg == "" ]]; then
  echo "Error:  Unable to find the AFNI commands. Update your path and rerun the command."
  exit 1
fi

matlabProg=`which matlab`
if [[ $matlabProg == "" ]]; then
  echo "Error:  Unable to find the Matlab executable. Update your path and rerun the command."
  exit 1
fi

if [ "$subjectDir" == "" ]; then
  echo "ERROR: Subject directory must be specified"
  exit 1
fi

if [ ! -e $subjectDir ]; then
  echo "ERROR: Subject directory does not exist"
  exit 1
fi

outputDir=$subjectDir/viewer/Subject
if [ ! -e $outputDir ]; then
  mkdir -p $outputDir
fi


nirsFile=`ls $subjectDir/*.nirs | head -1`
matlabScript=${outputDir}/transformAVdata.m
cat > $matlabScript << EOF
%
% MATLAB Script - Transform AV Data to Subject Space
%
close all;
clear all;
addpath(genpath('$scriptPath'));
subjectDir='$subjectDir';
fwHeadVol='$subjectDir/fw/headvol.vox';
anatHeadVol='$subjectDir/anatomical/headvol.vox';
resultHeadVol='$outputDir/headvol.nii';
nirsFileName='$nirsFile';
AVfwVol2AnatNii(fwHeadVol,anatHeadVol,resultHeadVol);
AVAdotVol3pt2nii(subjectDir, nirsFileName);
digPtsToAnatomical(subjectDir);
quit;
EOF

matlab -r "run('$matlabScript');"

