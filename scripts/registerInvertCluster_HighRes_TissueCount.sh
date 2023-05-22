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

  #first we need to resample the headvol.nii file
#  3dresample -dxyz 2 2 2 -prefix $clustDir/$i'_headvol2mm.nii' -input $subjectDir'/viewer/Subject/headvol.nii'
  cp $subjectDir'/viewer/Subject/headvol.nii' $clustDir/$i'_headvol.nii'

  aff=$commonResultDir/$fNIRSAtlasLabel'_T1_to_Atlas_0GenericAffine.mat'
  war=$commonResultDir/$fNIRSAtlasLabel'_T1_to_Atlas_1InverseWarp.nii.gz'
  m=$clustDir/$i'_headvol.nii'
  resultImageBase=$clustDir/$i

  #cp $clustDir/$i'_headvol2mm.nii' $clustDir/$i'_headvol2mm_unfix.nii'
  #3drefit -orient LPI $clustDir/$i'_headvol2mm_unfix.nii'

  warpImages=`ls ${clustDir}/clust_*.nii`
  #warpImages=`ls ${subjectResultDir}/${subjectId}_headvol.nii`
  for i in $warpImages
  do

    resultImage2=`basename $i`
    resultImage=$resultImageBase"_${resultImage2%.nii*}.nii"
    echo "Result Image: $resultImage"
    antsApplyTransforms -d 3 \
    -i $i \
    -r $m \
    -o ${resultImage}\
    -n GenericLabel \
    -t [$aff, 1] \
    -t $war

    #fix orientation issue
    #cp ${resultImage} $resultImageBase"_${resultImage2%.nii*}_unfix.nii"
	#3drefit -orient LPI $resultImageBase"_${resultImage2%.nii*}_unfix.nii"

#add path to output 1D name and add subject info and cluster number
    #g1=$clustDir/$subjectId'_GM.nii'
    g1=$resultImageBase"_${resultImage2%.nii*}_GM.nii"
    3dcalc -a ${resultImage} -b $m -expr 'equals(a*b,3)' -prefix $g1
    g=$clustDir/'CountGM.1D'
    3dBrickStat -count -non-zero ${resultImage} >> $g
    3dBrickStat -count -non-zero $g1 >> $g
    rm $g1

    #w1=$clustDir/$subjectId'_WM.nii'
    w1=$resultImageBase"_${resultImage2%.nii*}_WM.nii"
    3dcalc -a ${resultImage} -b $m -expr 'equals(a*b,4)' -prefix $w1
    w=$clustDir/'CountWM.1D'
    3dBrickStat -count -non-zero ${resultImage} >> $w
    3dBrickStat -count -non-zero $w1 >> $w
    rm $w1

    c1=$resultImageBase"_${resultImage2%.nii*}_CSF.nii"
    3dcalc -a ${resultImage} -b $m -expr 'equals(a*b,2)' -prefix $c1
    c=$clustDir/'CountCSF.1D'
    3dBrickStat -count -non-zero ${resultImage} >> $c
    3dBrickStat -count -non-zero $c1 >> $c
    rm $c1

    #w1=$clustDir/$subjectId'_WM.nii'
    s1=$resultImageBase"_${resultImage2%.nii*}_SKULL.nii"
    3dcalc -a ${resultImage} -b $m -expr 'equals(a*b,1)' -prefix $s1
    s=$clustDir/'CountSKULL.1D'
    3dBrickStat -count -non-zero ${resultImage} >> $s
    3dBrickStat -count -non-zero $s1 >> $s
    rm $s1

	#example that works...
    #antsApplyTransforms -d 3 \
    #-i clust_order_10LearnedxHb_l1_01.nii \
    #-r 32HWB036_headvol.nii \
    #-o 32HWB036_clust_order.nii.gz \
    #-n GenericLabel \
    #-t [32HWB036_T1_to_Atlas_0GenericAffine.mat, 1] \
    #-t 32HWB036_T1_to_Atlas_1InverseWarp.nii.gz

    #resultClipImage="${resultImage%.nii*}_ClipToBrain.nii.gz"
    #if [ "${atlasHsegMask}" == "1" ]; then
    #  3dcalc -a $resultImage -b $atlasMask -expr 'a*step(b-1)' -prefix $resultClipImage
    #else
    #  3dcalc -a $resultImage -b $atlasMask -expr 'a*step(b)' -prefix $resultClipImage
    #fi
  done
  let index+=1
done
