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

subjectT1=`ls -1 $subjectDir/*headvol*.nii | head -1`
if [ "$subjectT1" == "" ]; then
  echo "ERROR: Failed to find the subject T1 weighted scan"
  exit
fi

if [ ! -e $subjectDir/orig ]; then
  mkdir $subjectDir/orig
fi

t1name=`basename $subjectT1`
origImage=$subjectDir/orig/$t1name

# If the first time running the script copy images to orig directory
# otherwise copy original images back and fix orientation of the original
# images
if [ ! -e $origImage ]; then
  cp $subjectT1 $origImage
else
  cp $origImage $subjectT1
fi

apDir=`3dinfo $subjectT1 | grep Posterior | awk '{print $1}'`
apOrder=`3dinfo $subjectT1 | grep Posterior | awk '{print $4}'`
rlDir=`3dinfo $subjectT1 | grep Right | awk '{print $1}'`
rlOrder=`3dinfo $subjectT1 | grep Right | awk '{print $4}'`
siDir=`3dinfo $subjectT1 | grep Inferior | awk '{print $1}'`
siOrder=`3dinfo $subjectT1 | grep Inferior | awk '{print $4}'`


if [ "$apOrder" == "Posterior-to-Anterior" ]; then
  if [ "$flipAP" == "1" ]; then
    newAPorder="A"
  else
    newAPorder="P"
  fi
else
  if [ "$flipAP" == "1" ]; then
    newAPorder="P"
  else
    newAPorder="A"
  fi
fi

echo $apOrder
echo $flipAP
echo $newAPorder


if [ "$rlOrder" == "Left-to-Right" ]; then
  if [ "$flipRL" == "1" ]; then
    newRLorder="R"
  else
    newRLorder="L"
  fi
else
  if [ "$flipRL" == "1" ]; then
    newRLorder="L"
  else
    newRLorder="R"
  fi
fi

echo $rlOrder
echo $flipRL
echo $newRLorder


if [ "$siOrder" == "Inferior-to-Superior" ]; then
  if [ "$flipSI" == "1" ]; then
    newSIorder="S"
  else
    newSIorder="I"
  fi
else
  if [ "$flipSI" == "1" ]; then
    newSIorder="I"
  else
    newSIorder="S"
  fi
fi

if [ "$apDir" == "first" ]; then
  dir1=$newAPorder
elif [ "$apDir" == "second" ]; then
  dir2=$newAPorder
else
  dir3=$newAPorder
fi

if [ "$rlDir" == "first" ]; then
  dir1=$newRLorder
elif [ "$rlDir" == "second" ]; then
  dir2=$newRLorder
else
  dir3=$newRLorder
fi

if [ "$siDir" == "first" ]; then
  dir1=$newSIorder
elif [ "$siDir" == "second" ]; then
  dir2=$newSIorder
else
  dir3=$newSIorder
fi

echo "${dir1}${dir2}${dir3} $subjectT1"

for i in $subjectT1
do
    3drefit -orient ${dir1}${dir2}${dir3} $i
done



warpImages=`ls ${subjectDir}/AdotVol_NeuroDOT*.nii`
for i in $warpImages
do
  imageName=`basename $i`
  if [ ! -e $subjectDir/orig ]; then
    mkdir $subjectDir/orig
  fi
  
  origImage=$subjectDir/orig/$imageName
  
  # If the first time running the script copy images to orig directory
  # otherwise copy original images back and fix orientation of the original
  # images
  if [ ! -e $origImage ]; then
    cp $i $origImage
  else
    cp $origImage $i
  fi
  
  apDir=`3dinfo $i | grep Posterior | awk '{print $1}'`
  apOrder=`3dinfo $i | grep Posterior | awk '{print $4}'`
  rlDir=`3dinfo $i | grep Right | awk '{print $1}'`
  rlOrder=`3dinfo $i | grep Right | awk '{print $4}'`
  siDir=`3dinfo $i | grep Inferior | awk '{print $1}'`
  siOrder=`3dinfo $i | grep Inferior | awk '{print $4}'`

  if [ "$apOrder" == "Posterior-to-Anterior" ]; then
    if [ "$flipAP" == "1" ]; then
      newAPorder="A"
    else
      newAPorder="P"
    fi
  else
    if [ "$flipAP" == "1" ]; then
      newAPorder="P"
    else
      newAPorder="A"
    fi
  fi

  if [ "$rlOrder" == "Left-to-Right" ]; then
    if [ "$flipRL" == "1" ]; then
      newRLorder="R"
    else
      newRLorder="L"
    fi
  else
    if [ "$flipRL" == "1" ]; then
      newRLorder="L"
    else
      newRLorder="R"
    fi
  fi

  if [ "$siOrder" == "Inferior-to-Superior" ]; then
    if [ "$flipSI" == "1" ]; then
      newSIorder="S"
    else
      newSIorder="I"
    fi
  else
    if [ "$flipSI" == "1" ]; then
      newSIorder="I"
    else
      newSIorder="S"
    fi
  fi

  if [ "$apDir" == "first" ]; then
    dir1=$newAPorder
  elif [ "$apDir" == "second" ]; then
    dir2=$newAPorder
  else
    dir3=$newAPorder
  fi

  if [ "$rlDir" == "first" ]; then
    dir1=$newRLorder
  elif [ "$rlDir" == "second" ]; then
    dir2=$newRLorder
  else
    dir3=$newRLorder
  fi

  if [ "$siDir" == "first" ]; then
    dir1=$newSIorder
  elif [ "$siDir" == "second" ]; then
    dir2=$newSIorder
  else
    dir3=$newSIorder
  fi

  echo $dir1
  echo $dir2
  echo $dir3
  3drefit -orient ${dir1}${dir2}${dir3} $i
  
done


exit
