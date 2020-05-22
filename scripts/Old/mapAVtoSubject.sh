#!/bin/bash

scriptPath=`dirname $0`
scriptPath=$scriptPath/matlab

# Parse Command line arguements
while getopts “s:a:h” OPTION
do
  case $OPTION in
    h)
      echo "Usage: $0 -s subjectDir"
      echo "   where"
      echo "   -s AtlasViewer Analysis Directory for the subject"
      echo "   -a AtlasViewer headvol.vox image for the subject"
      echo "   -h Display help message"
      exit 1
      ;;
    s)
      subjectDir=$OPTARG
      ;;
    a)
      anatHeadVol=$OPTARG
      ;;
    ?)
      echo "ERROR: Invalid option"
      echo "Usage: $0 -s subjectDir"
      echo "   where"
      echo "   -s AtlasViewer Analysis Directory for the subject"
      echo "   -a AtlasViewer headvol.vox image for the subject"
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

if [ ! -f $anatHeadVol ]; then
  echo "ERROR: Subject haedvol.vox does not exist"
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
anatHeadVol='$anatHeadVol';
resultHeadVol='$outputDir/headvol.nii';
nirsFileName='$nirsFile';
AVfwVol2AnatNii(fwHeadVol,anatHeadVol,resultHeadVol);
AVAdotVol3pt2nii(subjectDir, anatHeadVol, nirsFileName);
digPtsToAnatomical(subjectDir, anatHeadVol);
quit;
EOF

matlab -r "run('$matlabScript');"


# Now threshold the images
channelImages=`ls $outputDir/AdotVol_S*_D*_C*_temp.nii`
for i in $channelImages
do
  fName=`basename $i`
  channel=${fName%_temp.nii}
  3dcalc -a $i -expr 'a*astep(a,0.0001)' -prefix $outputDir/${channel}.nii
done

rm -f $outputDir/AdotVol_S*_D*_C*_temp.nii
