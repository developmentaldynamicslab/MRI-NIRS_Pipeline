#!/bin/bash

flipRL=0
flipAP=0
flipSI=0

# Parse Command line arguements
while getopts “d:rpi” OPTION
do
  case $OPTION in
    h)
      echo "Usage: $0 -d subjectDir"
      echo "   where"
      echo "   -d Directory to fix orientation"
      echo "   -r Flip R/L"
      echo "   -p Flip A/P"
      echo "   -i Flip S/I"
      echo "   -h Display help message"
      exit 1
      ;;
    d)
      subjectDir=$OPTARG
      ;;
    r)
      flipRL=1
      ;;
    p)
      flipAP=1
      ;;
    i)
      flipSI=1
      ;;
    ?)
      echo "ERROR: Invalid option"
      echo "Usage: $0 -s subjectDir"
      echo "   where"
      echo "   -d Directory to fix orientation"
      echo "   -r Flip R/L"
      echo "   -p Flip A/P"
      echo "   -i Flip S/I"
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



subjectT1=`ls $subjectDir/*headvol.nii`
echo $subjectT1


if [ ! -e $subjectDir/orig ]; then
  mkdir $subjectDir/orig
fi
if [ ! -e $subjectDir/orig2 ]; then
  mkdir $subjectDir/orig2
fi
t1name=`basename $subjectT1`
cp $subjectT1 $subjectDir/orig2/.
subjectT1Orig=$subjectDir/orig2/$t1name

srowX=( $(nifti_tool -disp_hdr -infiles $subjectT1Orig | grep srow_x) )
srowY=( $(nifti_tool -disp_hdr -infiles $subjectT1Orig | grep srow_y) )
srowZ=( $(nifti_tool -disp_hdr -infiles $subjectT1Orig | grep srow_z) )

if [ "$flipRL" == "1" ]; then
  srowX[3]=`echo ${srowX[3]} | awk '{print $1 * -1.0}'`
fi

if [ "$flipAP" == "1" ]; then
  srowY[4]=`echo ${srowY[4]} | awk '{print $1 * -1.0}'`
fi

if [ "$flipSI" == "1" ]; then
  srowZ[5]=`echo ${srowZ[5]} | awk '{print $1 * -1.0}'`
fi

rowX=`echo "'${srowX[3]} ${srowX[4]} ${srowX[5]} ${srowX[6]}'"`
rowY=`echo "'${srowY[3]} ${srowY[4]} ${srowY[5]} ${srowY[6]}'"`
rowZ=`echo "'${srowZ[3]} ${srowZ[4]} ${srowZ[5]} ${srowZ[6]}'"`
echo $rowX
echo $rowY
echo $rowZ

cmd=`echo "nifti_tool -mod_hdr -mod_field srow_x $rowX -mod_field srow_y $rowY -mod_field srow_z $rowZ -prefix $subjectT1 -infiles $subjectT1Orig"`
eval $cmd


#warpImages=`ls ${subjectDir}/*oxy*.nii`
warpImages=`ls ${subjectDir}/*.nii`
for i in $warpImages
do
  imageName=`basename $i`
  mv $i $subjectDir/orig/.
  
  origImage=$subjectDir/orig/$imageName

  srowX=( $(nifti_tool -disp_hdr -infiles $origImage | grep srow_x) )
  srowY=( $(nifti_tool -disp_hdr -infiles $origImage | grep srow_y) )
  srowZ=( $(nifti_tool -disp_hdr -infiles $origImage | grep srow_z) )

  if [ "$flipRL" == "1" ]; then
    srowX[3]=`echo ${srowX[3]} | awk '{print $1 * -1.0}'`
  fi

  if [ "$flipAP" == "1" ]; then
    srowY[4]=`echo ${srowY[4]} | awk '{print $1 * -1.0}'`
  fi

  if [ "$flipSI" == "1" ]; then
    srowZ[5]=`echo ${srowZ[5]} | awk '{print $1 * -1.0}'`
  fi

  rowX=`echo "'${srowX[3]} ${srowX[4]} ${srowX[5]} ${srowX[6]}'"`
  rowY=`echo "'${srowY[3]} ${srowY[4]} ${srowY[5]} ${srowY[6]}'"`
  rowZ=`echo "'${srowZ[3]} ${srowZ[4]} ${srowZ[5]} ${srowZ[6]}'"`
  echo $rowX
  echo $rowY
  echo $rowZ

  cmd=`echo "nifti_tool -mod_hdr -mod_field srow_x $rowX -mod_field srow_y $rowY -mod_field srow_z $rowZ -prefix $i -infiles $origImage"`
  eval $cmd
  
done



