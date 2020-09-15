#!/bin/bash

afniProg=`which 3dcalc`
if [[ $afniProg == "" ]]; then
  echo "Error:  Unable to find the AFNI commands. Update your path and rerun the command."
  exit 1
fi

if [ ! -e $subjectDir/orig ]; then
  mkdir $subjectDir/orig
fi

anatFile=`ls $subjectDir/headvol.nii`
if [ "$anatFile" == "" ]; then
  echo "ERROR: Failed to find the anatomical file"
  exit 1
fi

anatFile2=`ls $subjectDir/headvol_2mm.nii`
if [ "$anatFile2" == "" ]; then
  echo "ERROR: Failed to find the anatomical file"
  exit 1
fi

AdotFile=`ls $subjectDir/AdotVol_NeuroDOT2mm.nii`
if [ "$AdotFile" == "" ]; then
  echo "ERROR: Failed to find the Adot file"
  exit 1
fi

anatname=`basename $anatFile`
origImage=$subjectDir/orig/$anatname
anatname2=`basename $anatFile2`
origImage2=$subjectDir/orig/$anatname2
Adotname=`basename $AdotFile`
origImage3=$subjectDir/orig/$Adotname

# If the first time running the script copy images to orig directory
# otherwise copy original images back and fix orientation of the original
# images
if [ ! -e $origImage ]; then
  cp $anatFile $origImage
  cp $anatFile2 $origImage2
  cp $AdotFile $origImage3
else
  cp $origImage $anatFile
  cp $origImage2 $anatFile2
  cp $origImage3 $AdotFile
fi

# Correct Orientation for the Anatomical File
3dLRflip -AP -prefix ${anatFile%.nii}_tmp.nii ${anatFile}
rm ${anatFile}
3dLRflip -IS -prefix ${anatFile%.nii}.nii ${anatFile%.nii}_tmp.nii
rm ${anatFile%.nii}_tmp.nii

3dLRflip -AP -prefix ${anatFile2%.nii}_tmp.nii ${anatFile2}
rm ${anatFile2}
3dLRflip -IS -prefix ${anatFile2%.nii}.nii ${anatFile2%.nii}_tmp.nii
rm ${anatFile2%.nii}_tmp.nii

# Correct Orientation for the ADOT File
3dLRflip -AP -prefix ${AdotFile%.nii}_tmp.nii ${AdotFile}
rm ${AdotFile}
3dLRflip -IS -prefix ${AdotFile%.nii}.nii ${AdotFile%.nii}_tmp.nii
rm ${AdotFile%.nii}_tmp.nii

exit
