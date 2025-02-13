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

  # Get the T1 image for registration and Brain Mask
  #   This matching could be modified to support additional types
  #   of images and masks
  #subjectT1=`ls $subjectResultDir/*headvol.nii`
  #subjectBrainMask=`ls $subjectResultDir/*headvol.nii`

  #for Template INDIA
#  subjectT1=$subjectDir/T1_RAS_ACPC.nii
#  subjectBrainMask=$subjectDir/hseg.nii

  #for Y1 INDIA
#subjectT1=$subjectDir/T1_RAS.nii
#subjectBrainMask=$subjectDir/T1_Mask.nii

  #for Y2 INDIA
#  subjectT1=$subjectDir/T1_RAS_ACPC.nii
#  subjectBrainMask=$subjectDir/Brain_Mask_ACPC.nii

#  echo "Subject T1: $subjectT1"
#  echo "Subject Mask: $subjectBrainMask"

  if [ $atlasType != "AtlasW" ]; then

    subjectMovingImage=${commonResultDir}/${fNIRSAtlasLabel}_T1_ACPC_Brain.nii
    if [ "${subjectHsegMask}" == "1" ]; then
      3dcalc -a $subjectBrainMask -b $subjectT1 -expr 'step(a-1)*b' -prefix $subjectMovingImage
    else
      3dcalc -a $subjectBrainMask -b $subjectT1 -expr 'step(a)*b' -prefix $subjectMovingImage
    fi

    atlasFixedImage=${commonResultDir}/${fNIRSAtlasLabel}_T1_Atlas_Brain.nii
    if [ "${atlasHsegMask}" == "1" ]; then
      3dcalc -a $atlasMask -b $atlasImage -expr 'step(a-1)*b' -prefix $atlasFixedImage
    else
      3dcalc -a $atlasMask -b $atlasImage -expr 'step(a)*b' -prefix $atlasFixedImage
    fi

    antsRegistration --dimensionality 3 --float 0 \
    --output [${commonResultDir}/${fNIRSAtlasLabel}_T1_to_Atlas_,${commonResultDir}/${fNIRSAtlasLabel}_T1_to_Atlas.nii.gz] \
    --interpolation LanczosWindowedSinc \
    --winsorize-image-intensities [0.005,0.995] \
    --use-histogram-matching 1 \
    --initial-moving-transform [$atlasFixedImage,$subjectMovingImage,1] \
    --transform Rigid[0.1] \
    --metric MI[$atlasFixedImage,$subjectMovingImage,0.25] \
    --convergence [1000x500x250x100,1e-6,10] \
    --shrink-factors 8x4x2x1 \
    --smoothing-sigmas 3x2x1x0vox \
    --transform Affine[0.1] \
    --metric MI[$atlasFixedImage,$subjectMovingImage,1,32,Regular,0.25] \
    --convergence [1000x500x250x100,1e-6,10] \
    --shrink-factors 8x4x2x1 \
    --smoothing-sigmas 3x2x1x0vox \
    --transform SyN[0.1,3,0] \
    --metric CC[$atlasFixedImage,$subjectMovingImage,1,4] \
    --convergence [100x70x50x20,1e-6,10] \
    --shrink-factors 8x4x2x1 \
    --smoothing-sigmas 3x2x1x0vox
  fi
  
  # Fix the Output for AFNI. ANTs puts things in the proper physical space but
  # does not set the qform and sform codes for MNI or TALAIRACH space. This
  # will fix this if the Atlas image is in MNI or TALAIRACH space
  qform=`nifti_tool -disp_hdr -infiles $atlasFixedImage | grep qform_code | awk '{print $4}'`
  sform=`nifti_tool -disp_hdr -infiles $atlasFixedImage | grep sform_code | awk '{print $4}'`
  if [ $qform == 3 ] || [ $sform == 3 ]; then
    3drefit -view tlrc -space TLRC ${commonResultDir}/${fNIRSAtlasLabel}_T1_to_Atlas.nii.gz
  elif [ $qform == 4 ] || [ $sform == 4 ]; then
    3drefit -view tlrc -space MNI ${commonResultDir}/${fNIRSAtlasLabel}_T1_to_Atlas.nii.gz
  fi

  affineXfrm=`ls ${commonResultDir}/${fNIRSAtlasLabel}_T1_to_Atlas*Affine.mat`
  if [ "$affineXfrm" == "" ]; then
      echo "ERROR: Failed to find resulting Affine transform from ANTS registration."
      exit 1
  fi

  warpXfrm=`ls ${commonResultDir}/${fNIRSAtlasLabel}_T1_to_Atlas*1Warp.nii.gz`
  if [ "$warpXfrm" == "" ]; then
      echo "ERROR: Failed to find resulting Warp transform from ANTS registration."
      exit 1
  fi

  warpImages=`ls ${subjectResultDir}/${subjectId}*oxy*.nii`
  #warpImages=`ls ${subjectResultDir}/${subjectId}_headvol.nii`

  for i in $warpImages
  do
    resultImage=`basename $i`
    resultImage="${commonResultDir}/${resultImage%.nii*}_To_Atlas.nii.gz"
    echo "Result Image: $resultImage"
    antsApplyTransforms -d 3 \
    -i $i \
    -r $atlasImage \
    -o ${resultImage} \
    -n Linear \
    -t $warpXfrm \
    -t $affineXfrm
    
    if [ $qform == 3 ] || [ $sform == 3 ]; then
      3drefit -view tlrc -space TLRC ${resultImage}
    elif [ $qform == 4 ] || [ $sform == 4 ]; then
      3drefit -view tlrc -space MNI ${resultImage}
    fi

    resultClipImage="${resultImage%.nii*}_ClipToBrain.nii.gz"
    if [ "${atlasHsegMask}" == "1" ]; then
      3dcalc -a $resultImage -b $atlasMask -expr 'a*step(b-1)' -prefix $resultClipImage
    else
      3dcalc -a $resultImage -b $atlasMask -expr 'a*step(b)' -prefix $resultClipImage
    fi
  done
  let index+=1
done
