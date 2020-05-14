#!/bin/bash

# VAM - Testing Paths
export PATH=${PATH}:/Users/magnottav/development/BRAINS/Oct2017/BRAINSTools-Build/bin:/opt/afni

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

afniProg=`which 3dcalc`
if [[ $afniProg == "" ]]; then
  echo "Error:  Unable to find the AFNI commands. Update your path and rerun the command."
  exit 1
fi

antsProg=`which antsRegistration`
if [[ $afniProg == "" ]]; then
  echo "Error:  Unable to find the ANTS commands. Update your path and rerun the command."
  exit 1
fi

subjects=`awk '{print $1}' $1`
let index=1

for i in $subjects
do
  subjectId=`cat $1 | tr -d '\r' | sed -n ${index}p | awk '{print $1}'`
  NIRSfile=`cat $1 | tr -d '\r' | sed -n ${index}p | awk '{print $2}'`
  subjectDir=`cat $1 | tr -d '\r' | sed -n ${index}p | awk '{print $3}'`
  betaDir=`cat $1 | tr -d '\r' | sed -n ${index}p | awk '{print $4}'`
  subjectResultDir=`cat $1 | tr -d '\r' | sed -n ${index}p | awk '{print $5}'`
  anatHeadVol=`cat $1 | tr -d '\r' | sed -n ${index}p | awk '{print $6}'`
  atlasImage=`cat $1 | tr -d '\r' | sed -n ${index}p | awk '{print $7}'`
  atlasMask=`cat $1 | tr -d '\r' | sed -n ${index}p | awk '{print $8}'`
  commonResultDir=`cat $1 | tr -d '\r' | sed -n ${index}p | awk '{print $9}'`
  atlasType=`cat $1 | tr -d '\r' | sed -n ${index}p | awk '{print $10}'`
  fNIRSAtlasLabel=`cat $1 | tr -d '\r' | sed -n ${index}p | awk '{print $11}'`
  subjectHsegMask=`cat $1 | tr -d '\r' | sed -n ${index}p | awk '{print $12}'`
  atlasHsegMask=`cat $1 | tr -d '\r' | sed -n ${index}p | awk '{print $13}'`
  subjectT1=`cat $1 | tr -d '\r' | sed -n ${index}p | awk '{print $14}'`
  subjectBrainMask=`cat $1 | tr -d '\r' | sed -n ${index}p | awk '{print $15}'`
  clustDir=`cat $1 | tr -d '\r' | sed -n ${index}p | awk '{print $16}'`

  echo "Subject Id: $subjectId"
  echo "NIRS File: $NIRSfile"
  echo "Subject Dir: $subjectDir"
  echo "Beta Dir: $betaDir"
  echo "Subject Results Dir: $subjectResultDir"
  echo "Anat Headvol: $anatHeadVol"
  echo "Atlas Image: $atlasImage"
  echo "Atlas Mask: $atlasMask"
  echo "Common Results Dir: $commonResultDir"
  echo "Atlas Type: $atlasType"
  echo "Atlas Label: $fNIRSAtlasLabel"
  echo "Subject Hseg: $subjectHsegMask"
  echo "Atlas Hseg: $atlasHsegMask"
  echo "Subject Image: $subjectT1"
  echo "Subject Mask: $subjectBrainMask"
  echo "Cluster Dir: $clustDir"

  #################################################################
  # NOTE: Files Needed for the subject have been added to the driver file
  # Get the T1 image for registration and Brain Mask
  #   This matching could be modified to support additional types
  #   of images and masks
  #subjectT1=`ls $subjectResultDir/*headvol.nii`
  #subjectBrainMask=`ls $subjectResultDir/*headvol.nii`
  #subjectT1=$subjectDir/T1_RAS_ACPC.nii
  #subjectBrainMask=$subjectDir/hseg.nii
  #echo "Subject T1: $subjectT1"
  #echo "Subject Mask: $subjectBrainMask"
  #################################################################

  cp $subjectDir'/viewer/Subject/headvol_2mm.nii' $clustDir/$i'_headvol2mm.nii'
  cp $subjectDir'/viewer/Subject/AdotVol_NeuroDOT2mm.nii' $clustDir/$i'_AdotVol_NeuroDOT2mm.nii'

  3dcalc -a $clustDir/$i'_headvol2mm.nii' \
      -prefix $clustDir/$i'_headvol2mm_BrainOnly.nii' \
      -expr 'step(a-1)'

  for j in {0..35}
  do
    3dcalc -a $clustDir/$i'_AdotVol_NeuroDOT2mm.nii'[$j] -b $clustDir/$i'_headvol2mm_BrainOnly.nii' -expr 'a*b' -prefix $clustDir/$i'_Temp.nii'
    3dExtrema -maxima -nbest 1 -quiet -volume $clustDir/$i'_Temp.nii' >> $clustDir/$i'_Mvalues.1D'
    rm $clustDir/$i'_Temp.nii'
  done

  MX=(`cat $clustDir/$i'_Mvalues.1D' | awk '{print $3}'`)
  MY=(`cat $clustDir/$i'_Mvalues.1D' | awk '{print $4}'`)
  MZ=(`cat $clustDir/$i'_Mvalues.1D' | awk '{print $5}'`)

  for j in {0..35}
  do
    let k=j+1
    basename=$clustDir/$i'_clust_order_Peaks'$k'.nii'
    basename2=$clustDir/$i'_clust_order_Peaks'$k'_BrainOnly.nii'
    3dcalc -a $clustDir/$i'_headvol2mm.nii' \
      -prefix $basename \
      -expr 'step(25-(x-'${MX[$j]}')*(x-'${MX[$j]}')-(y-'${MY[$j]}')*(y-'${MY[$j]}')-(z-'${MZ[$j]}')*(z-'${MZ[$j]}'))'

    #clip to brain
    3dcalc -a $basename -b $clustDir/$i'_headvol2mm_BrainOnly.nii' -expr 'a*b' -prefix $basename2
  done

  let index+=1
done

for j in {0..35}
do
  let k=j+1
  basename2=$clustDir/'clust_order_Peaks'$k'_BrainOnly.nii'
  touch $basename2
done
