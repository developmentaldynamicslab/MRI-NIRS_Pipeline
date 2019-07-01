#!/bin/bash

# ./runNIRS.sh -s /home/installer/Desktop/0104 -a /home/installer/Desktop/AtlasViewerTools/MNI -h /home/installer/Desktop/HOMER2 -t 100
# ./runNIRS.sh -s /Users/vince/images/Spencer/NIRS/0104 -a /Users/vince/images/Spencer/NIRS/MNI -h /Users/vince/development/AtlasViewer/HOMER2 -t 5

echo "ERROR: This scripot needs to be updated to include latest changes to the pipeline."
exit 1


haveMatlab=`which matlab`
threshold=1000
opticalDensity=0.001
roiSenstivity=1
slicerHome=/Applications/Slicer.app
platform=`uname`


while getopts ":s:a:h:t:o:r:x" opt;
do
  case $opt in
    s) subjectPath=$OPTARG ;;
    a) atlasPath=$OPTARG ;;
    h) homerPath=$OPTARG ;;
    t) threshold=$OPTARG ;;
    r) slicerHome=$OPTARG ;;
    o) opticalDensity=$OPTARG ;;
    x) roiSenstivity=0 ;;
    *) echo "Usage: $0 -s subjectDirectory -a atlasDirectory -h homerDir -t threshold [-o opticalDensity] [-r SlicerDir] [-x]"
       echo "          -s path to the subject to analyze"
       echo "          -a MNI atlas directory" 
       echo "          -h Path to the HOMER2 software" 
       echo "          -t sensititivity profile threshold" 
       echo "          -o optical density value [default 0.001]" 
       echo "          -r Path to the 3D Slicer software" 
       echo "          -x exclude the ROI senstivity profile estimates" 
       exit 1 
       ;;
  esac
done

if [ "$platform" == "Linux" ]; then
  export LD_LIBRARY_PATH=${slicerHome}/lib/Slicer-4.3:${slicerHome}/lib/Slicer-4.3/cli-modules:${slicerHome}/lib/Teem-1.10.0:${slicerHome}/lib/Python/lib
  export PATH=${PATH}:${slicerHome}/lib/Slicer-4.3/cli-modules:${slicerHome}/cli-modules
else
  export DYLD_LIBRARY_PATH=${slicerHome}/Contents/lib/Slicer-4.3:${slicerHome}/Contents/lib/Slicer-4.3/cli-modules:${slicerHome}/Contents/lib/Teem-1.10.0:${slicerHome}/Contents/lib/Python/lib
  export PATH=${PATH}:${slicerHome}/Contents/cli-modules
fi


if [ "$subjectPath" == "" ] || [ ! -e $subjectPath ]; then
  echo "ERROR: The -s option is required and must be a valid path"
  echo "Usage: $0 -s subjectDirectory -a atlasDirectory -h homerDir -t threshold" 
  exit 1
fi

if [ "$atlasPath" == "" ] || [ ! -e $atlasPath ]; then
  echo "ERROR: The -a option is required and must be a valid path"
  echo "Usage: $0 -s subjectDirectory -a atlasDirectory -h homerDir -t threshold" 
  exit 1
fi

if [ "$homerPath" == "" ] || [ ! -e $homerPath ]; then
  echo "ERROR: The -h option is required and must be a valid path"
  echo "Usage: $0 -s subjectDirectory -a atlasDirectory -h homerDir -t threshold" 
  exit 1
fi

if [ ! -e $subjectPath/viewer/Subject/ROIs ]; then
  mkdir -p $subjectPath/viewer/Subject/ROIs
fi


scriptFullPath=`perl -e 'use Cwd "abs_path";print abs_path(shift)' $0`
scriptDir=`dirname $scriptFullPath`
echo $scriptDir


### Map Atlas Data to the Subject

# First convert the headvol.vox file to a Nifti Image
cd $subjectPath/viewer/Subject
echo "addpath('$homerPath/PACKAGES/AtlasViewerGUI/Utils')" > formatVox.m
echo "addpath('$homerPath/PACKAGES/AtlasViewerGUI/Utils/nifti')" >> formatVox.m
echo "addpath('$homerPath/PACKAGES/AtlasViewerGUI/ForwardModel')" >> formatVox.m
echo "addpath('$scriptDir')" >> formatVox.m
echo ""  >> formatVox.m
echo "atlasviewerVol2nii('$subjectPath/fw/headvol.vox','$subjectPath/viewer/Subject/headvol.nii')" >> formatVox.m
echo "quit"  >> formatVox.m
echo "$haveMatlab"
if [ "$haveMatlab" == "" ]; then
	octave --no-window-system formatVox.m
else
  matlab -nodisplay -r "formatVox"
fi

exit

# Map images from Atlas to Subject Space
$scriptDir/AtlasViewerToNifti \
  -i $atlasPath/T1_head_only.nii \
  -e $subjectPath/viewer/Subject/headvol.nii \
  -t $subjectPath/fw/headvol2viewer.txt \
  -o $subjectPath/viewer/Subject/AtlasT1.nii.gz \
  -f $subjectPath/viewer/Subject/headvol_mask.nii.gz
  
#for i in $atlasPath/ROIs/*.nii
#do
#  resultFile=`basename $i`
#  $scriptDir/AtlasViewerToNifti \
#    -i $i \
#    -e $subjectPath/viewer/Subject/headvol.nii \
#    -t $subjectPath/viewer/headvol2viewer.txt \
#    -o $subjectPath/viewer/Subject/ROIs/${resultFile}.gz \
#    -m 1
#done

### Create brain surface
haveModelMaker=`which ModelMaker`
if [ "$haveModelMaker" != "" ]; then
  ModelMaker --smooth 1000 --decimate 0.10 -s 1 -e 1 -n Skull $subjectPath/viewer/Subject/headvol_mask.nii.gz
fi


### Convert the Sensitivity Profile
echo "addpath('$homerPath/PACKAGES/AtlasViewerGUI/Utils')" > format3pt.m
echo "addpath('$homerPath/PACKAGES/AtlasViewerGUI/Utils/nifti')" >> format3pt.m
echo "addpath('$homerPath/PACKAGES/AtlasViewerGUI/ForwardModel')" >> format3pt.m
echo "addpath('$scriptDir')" >> format3pt.m
echo ""  >> format3pt.m
echo "AdotVol3pt2nii('$subjectPath','$threshold')" >> format3pt.m
echo "quit" >> format3pt.m
if [ "$haveMatlab" == "" ]; then
  octave --no-window-system format3pt.m
else
  matlab -nodisplay -r "format3pt"
fi


### Convert Optode Sensors to Slicer Fiducials
$scriptDir/DigiPtsToSlicer \
  -i $subjectPath/digpts.txt \
  -o $subjectPath/viewer/Subject/digpts.fcsv


if [ "$roiSenstivity" == "1" ]; then
  ### Estimate Sensitivity Profile
  if [ -e $subjectPath/viewer/Subject/SentivityMatrix.csv ]; then
    rm $subjectPath/viewer/Subject/SentivityMatrix.csv
  fi

  if [ -e $subjectPath/viewer/Subject/OpticalDensity.csv ]; then
    rm $subjectPath/viewer/Subject/OpticalDensity.csv
  fi


  debug=1
  writeOpticalDensity=1

  for i in $subjectPath/viewer/Subject/ROIs/*.nii.gz
  do
    if [ "$haveModelMaker" != "" ]; then
      tmpName=`basename $i`
      modelName=${i%.nii.gz}
      ModelMaker --smooth 200 --decimate 0.25 -s 1 -e 1 -n $modelName $i
    fi
    
    for j in $subjectPath/viewer/Subject/AdotVol_S*_D*_C*.nii
    do
      profileName=`basename $j`
      source=`echo $profileName | awk -F_ '{print $2}'`
      detector=`echo $profileName | awk -F_ '{print $3}'`
      channel=`echo $profileName | awk -F_ '{print $4}' | awk -F. '{print $1}'`
      if [ $writeOpticalDensity -eq 1 ]; then
        $scriptDir/SenstivityProfileMeasurements \
          -i $j $channel $source $detector \
          -m $i 1 \
          -t $threshold \
          -d $debug \
          -f $subjectPath/viewer/Subject/SentivityMatrix.csv \
          -o $subjectPath/viewer/Subject/OpticalDensity.csv \
          -a $opticalDensity \
          -b $subjectPath/viewer/Subject/AdotVolMask_${source}_${detector}_${channel}.nii.gz
          
        if [ "$haveModelMaker" != "" ]; then
          ModelMaker --smooth 1000 --decimate 0.10 -s 1 -e 1 -n ${source}_${detector}_${channel} \
            $subjectPath/viewer/Subject/AdotVolMask_${source}_${detector}_${channel}.nii.gz
        fi
      else
        $scriptDir/SenstivityProfileMeasurements \
          -i $j $channel $source $detector \
          -m $i 1 \
          -t $threshold \
          -d $debug \
          -f $subjectPath/viewer/Subject/SentivityMatrix.csv \
          -a $opticalDensity
      fi
      debug=0
    done
    writeOpticalDensity=0
  done

else
  for i in $subjectPath/viewer/Subject/ROIs/*.nii.gz
  do
    if [ "$haveModelMaker" != "" ]; then
      tmpName=`basename $i`
      modelName=${i%.nii.gz}
      ModelMaker --smooth 200 --decimate 0.25 -s 1 -e 1 -n $modelName $i
    fi
  done
  
  for j in $subjectPath/viewer/Subject/AdotVol_S*_D*_C*.nii
  do
    profileName=`basename $j`
    source=`echo $profileName | awk -F_ '{print $2}'`
    detector=`echo $profileName | awk -F_ '{print $3}'`
    channel=`echo $profileName | awk -F_ '{print $4}' | awk -F. '{print $1}'`
    
    $scriptDir/SenstivityProfileMeasurements \
      -i $j $channel $source $detector \
      -m $i 1 \
      -t $threshold \
      -d 1 \
      -f /tmp/SentivityMatrix_ignore.csv \
      -o /tmp/OpticalDensity_ignore.csv \
      -a $opticalDensity \
      -b $subjectPath/viewer/Subject/AdotVolMask_${source}_${detector}_${channel}.nii.gz
      
    if [ "$haveModelMaker" != "" ]; then
      ModelMaker --smooth 1000 --decimate 0.10 -s 1 -e 1 -n ${source}_${detector}_${channel} \
        $subjectPath/viewer/Subject/AdotVolMask_${source}_${detector}_${channel}.nii.gz
    fi
  done
  
fi


exit


