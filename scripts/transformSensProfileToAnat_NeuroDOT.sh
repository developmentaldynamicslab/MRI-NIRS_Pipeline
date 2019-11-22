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

matlabProg=`which matlab`
if [[ $matlabProg == "" ]]; then
  echo "Error:  Unable to find the Matlab executable. Update your path and rerun the command."
  exit 1
fi

afniProg=`which 3dcalc`
if [[ $afniProg == "" ]]; then
  echo "Error:  Unable to find the AFNI commands. Update your path and rerun the command."
  exit 1
fi

subjects=`awk '{print $1}' $1`
let index=1

for i in $subjects
do
  NIRSfile=`cat $1 | tr -d '\r' | sed -n ${index}p | awk '{print $2}'`
  subjectDir=`cat $1 | tr -d '\r' | sed -n ${index}p | awk '{print $3}'`
  anatHeadVol=`cat $1 | tr -d '\r' | sed -n ${index}p | awk '{print $6}'`
  outputDir=$subjectDir/viewer/Subject

  if [ ! -e $outputDir ]; then
    mkdir -p $outputDir
  fi

  echo "addpath(genpath('$scriptPath'));" > $outputDir/mapToAnat.m
  echo -n "AVAdotVol3pt2nii_NeuroDOT('$subjectDir'," >> $outputDir/mapToAnat.m
  echo -n "'$anatHeadVol'," >> $outputDir/mapToAnat.m
  echo "'$NIRSfile');" >> $outputDir/mapToAnat.m

  echo -n "AVfwVol2AnatNii('$subjectDir/fw/headvol.vox'," >> $outputDir/mapToAnat.m
  echo -n "'$anatHeadVol'," >> $outputDir/mapToAnat.m
  echo "'$outputDir/headvol.nii');" >> $outputDir/mapToAnat.m
  echo "quit;" >> $outputDir/mapToAnat.m

  matlab -r "run('$outputDir/mapToAnat.m');"

  # Now threshold the images
  index2=1
  channelImages=`ls $outputDir/AdotVol_S*_D*_C*_temp.nii`
  for j in $channelImages
  do
    fName=`basename $j`
    channel=${fName%_temp.nii}
    3dcalc -a $j -expr 'a*astep(a,0.0001)' -prefix $outputDir/${channel}_ND.nii
    
    if [ $index2 == 1 ]; then
    	index2=2
    	3dTcat $outputDir/${channel}_ND.nii -prefix $outputDir/AdotVol_NeuroDOT.nii
    else
    	3dTcat $outputDir/AdotVol_NeuroDOT.nii $outputDir/${channel}.nii -prefix $outputDir/AdotVol_NeuroDOT_temp.nii
    	rm $outputDir/AdotVol_NeuroDOT.nii
    	mv $outputDir/AdotVol_NeuroDOT_temp.nii $outputDir/AdotVol_NeuroDOT.nii
    fi
  done
  
  3dresample -dxyz 2 2 2 -prefix $outputDir/AdotVol_NeuroDOT2mm.nii -input $outputDir/AdotVol_NeuroDOT.nii

  rm -f $outputDir/AdotVol_S*_D*_C*_temp.nii
  rm -f $outputDir/*_ND.nii

  let index+=1
done
