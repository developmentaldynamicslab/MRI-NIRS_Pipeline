#!/bin/bash

#export PATH=${PATH}:/Users/magnottav/development/BRAINS/Oct2017/BRAINSTools-Build/bin

subjectT1=""
subjectBrainMask=""
atlasT1=""
atlasBrainMask=""
resampleAtlas=""
resampleAtlasMask=""
outputDir=""
warpImages=""
scanId=""
skipRegistration=0

while getopts “t:s:o:a:b:c:d:i:w:hz” OPTION
do
    case $OPTION in
      h)
        echo "Usage: $0 -t subjectT1Image -s subjectBrainMask -a AtlasT1 -b AtlasBrainMask -c AtlasResImage -d AtlasResMask -o outputDir -w WarpImages"
        echo "   where"
        echo "   -t Subject T1 weighted Image"
        echo "   -s Subject Brain Mask"
        echo "   -a Atlas T1 Image"
        echo "   -b Atlas Brain Mask"
        echo "   -c Atlas Image to define resolution of Beta Maps (Default is AtlasT1)"
        echo "   -d Atlas Image Mask to clip Beta Maps (Default is Atlas Brain Mask)"
        echo "   -o OutputDirectory"
        echo "   -i Scan-Id (Used for naming outputs)"
        echo "   -w Additional Images to warp (Can be specified multiple times)"
        echo "   -z Skip Registration (Just apply transform to additional warp images)"
        echo "   -h Display help message"
        exit 1
        ;;
      t)
        subjectT1=$OPTARG
        ;;
      s)
        subjectBrainMask=$OPTARG
        ;;
      o)
        outputDir=$OPTARG
        ;;
      a)
        atlasT1=$OPTARG
        ;;
      b)
        atlasBrainMask=$OPTARG
        ;;
      c)
        resampleAtlas=$OPTARG
        ;;
      d)
        resampleAtlasMask=$OPTARG
        ;;
      i)
        scanId=$OPTARG
        ;;
      z)
        skipRegistration=1
        ;;
      w)
        warpImages="$warpImages $OPTARG"
        ;;
      ?)
        echo "Usage: $0 -t subjectT1Image -s subjectBrainMask -a AtlasT1 -b AtlasBrainMask -c AtlasResImage -d AtlasResMask -o outputDir -w WarpImages"
        echo "   where"
        echo "   -t Subject T1 weighted Image"
        echo "   -s Subject Brain Mask"
        echo "   -a Atlas T1 Image"
        echo "   -b Atlas Brain Mask"
        echo "   -c Atlas Image to define resolution of Beta Maps (Default is AtlasT1)"
        echo "   -d Atlas Image Mask to clip Beta Maps (Default is Atlas Brain Mask)"
        echo "   -o OutputDirectory"
        echo "   -i Scan-Id (Used for naming outputs)"
        echo "   -w Additional Images to warp (Can be specified multiple times)"
        echo "   -z Skip Registration (Just apply transform to additional warp images)"
        echo "   -h Display help message"
        exit 1
        ;;
    esac
done


if [ "$resampleAtlas" == "" ]; then
    resampleAtlas=$atlasT1
fi

if [ "$resampleAtlasMask" == "" ]; then
    resampleAtlasMask=$atlasBrainMask
fi

if [ ! -e $subjectT1 ]; then
    echo "ERROR: Subject T1 Image does not exist"
    exit 1
fi

if [ ! -e $subjectBrainMask ]; then
  echo "ERROR: Subject brain mask does not exist"
  exit 1
fi

if [ ! -e $atlasT1 ]; then
  echo "ERROR: Atlas T1 Image does not exist"
  exit 1
fi

if [ ! -e $atlasBrainMask ]; then
    echo "ERROR: Atlas Brain Mask does not exist"
    exit 1
fi

if [ ! -e $resampleAtlas ]; then
    echo "ERROR: Atlas Resample Image does not exist"
    exit 1
fi

if [ ! -e $resampleAtlasMask ]; then
    echo "ERROR: Atlas Resample Mask does not exist"
    exit 1
fi

if [ ! -e $outputDir ]; then
    echo "ERROR: Output directory does not exist"
    exit 1
fi

if [ "$scanId" == "" ]; then
    echo "ERROR: Scan-Id Not specified."
    exit 1
fi

echo "================Registration Parameters================"
echo "Subject T1:        $subjectT1"
echo "Subject Bran Mask: $subjectBrainMask"
echo "Atlas T1:          $atlasT1"
echo "Atlas Brain Mask:  $atlasBrainMask"
echo "Atlas Resample:    $resampleAtlas"
echo "Atlas Clip Mask:   $resampleAtlasMask"
echo "Scan Id:           $scanId"
echo "Output Dir:        $outputDir"
echo "Warp Images:       $warpImages"
echo "Skip registration: $skipRegistration"
echo "======================================================="


if [ "$skipRegistration" == "0" ]; then

subjectMovingImage=${outputDir}/T1_ACPC_Brain.nii
3dcalc -a $subjectBrainMask -b $subjectT1 -expr 'step(a-1)*b' -prefix $subjectMovingImage

atlasFixedImage=${outputDir}/T1_Atlas_Brain.nii
3dcalc -a $atlasBrainMask -b $atlasT1 -expr 'step(a)*b' -prefix $atlasFixedImage

antsRegistration --dimensionality 3 --float 0 \
--output [${outputDir}/${scanId}_T1_to_Atlas_,${outputDir}/${scanId}_T1_to_Atlas.nii.gz] \
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
--smoothing-sigmas 3x2x1x0vox \

# -x [$atlasBrainMask,$subjectBrainMask]
fi

affineXfrm=`ls ${outputDir}/${scanId}_T1_to_Atlas*Affine.mat`
if [ "$affineXfrm" == "" ]; then
    echo "ERROR: Failed to find resulting Affine transform from ANTS registration."
    exit 1
fi

warpXfrm=`ls ${outputDir}/${scanId}_T1_to_Atlas*Warp.nii.gz`
if [ "$warpXfrm" == "" ]; then
    echo "ERROR: Failed to find resulting Warp transform from ANTS registration."
    exit 1
fi


for i in $warpImages
do
  resultImage=`basename $i`
  resultImage="${outputDir}/${scanId}_${resultImage%.nii*}_To_Atlas.nii.gz"
  echo "Result Image: $resultImage"
  antsApplyTransforms -d 3 \
  -i $i \
  -r $resampleAtlas \
  -o ${resultImage} \
  -n Linear \
  -t $warpXfrm \
  -t $affineXfrm
  
  prefixImage=`basename $i`
  resultClipImage="${outputDir}/${scanId}_${prefixImage%.nii*}_To_Atlas_ClipToBrain.nii.gz"
  3dcalc -a $resultImage -b $resampleAtlasMask -prefix $resultClipImage -expr 'a*step(b)'
done






exit

ageAtlasT1=../india6Month_lin.nii
commonAtlasT1=../indiaOveralltemplate.nii.gz

antsRegistration --dimensionality 3 --float 0 \
--output [${outputDir}/india${age}Atlas2Common,${outputDir}/india${age}Atlas2Common.nii.gz] \
--interpolation LanczosWindowedSinc \
--winsorize-image-intensities [0.005,0.995] \
--use-histogram-matching 0 \
--initial-moving-transform [$commonAtlasT1,$ageAtlasT1,1] \
--transform Rigid[0.1] \
--metric MI[$commonAtlasT1,$ageAtlasT1,0.25] \
--convergence [1000x500x250x100,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox \
--transform Affine[0.1] \
--metric MI[$commonAtlasT1,$ageAtlasT1,1,32,Regular,0.25] \
--convergence [1000x500x250x100,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox \
--transform SyN[0.1,3,0] \
--metric CC[$commonAtlasT1,$ageAtlasT1,1,4] \
--convergence [100x70x50x20,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox
-x []



3dcalc -a indiaOveralltemplate.nii.gz -expr 'a*1000' -prefix indiaOveralltemplate_scale.nii.gz
3dSkullStrip -prefix indiaOveralltemplate_brain.nii.gz -mask_vol -input indiaOveralltemplate_scale.nii.gz -avoid_eyes -init_radius 50 -use_skull -exp_frac 0.05
rm skull_strip_out_hull.ply


outputDir=`pwd`
commonAtlasMask=../indiaTemplates/india_ageGroupTemplatesAndTransforms/indiaOveralltemplate_brain.nii.gz
commonAtlasT1=../indiaTemplates/india_ageGroupTemplatesAndTransforms/indiaOveralltemplate_scale.nii.gz
ageAtlasT1=../VINCE_030G/T1_RAS.nii
ageAtlasMask=../VINCE_030G/T1_Mask.nii

/Users/magnottav/development/BRAINS/Oct2017/BRAINSTools-Build/bin/antsRegistration --dimensionality 3 --float 0 --output [${outputDir}/india${age}Atlas2Common,${outputDir}/india${age}Atlas2Common.nii.gz] --interpolation LanczosWindowedSinc --winsorize-image-intensities [0.005,0.995] --use-histogram-matching 0 --initial-moving-transform [$commonAtlasT1,$ageAtlasT1,1] --transform Rigid[0.1] --metric MI[$commonAtlasT1,$ageAtlasT1,0.25] --convergence [1000x500x250x100,1e-6,10] --shrink-factors 8x4x2x1 --smoothing-sigmas 3x2x1x0vox --transform Affine[0.1] --metric MI[$commonAtlasT1,$ageAtlasT1,1,32,Regular,0.25] --convergence [1000x500x250x100,1e-6,10] --shrink-factors 8x4x2x1 --smoothing-sigmas 3x2x1x0vox --transform SyN[0.1,3,0] --metric CC[$commonAtlasT1,$ageAtlasT1,1,4] --convergence [100x70x50x20,1e-6,10] --shrink-factors 8x4x2x1 --smoothing-sigmas 3x2x1x0vox -x [${commonAtlasMask},${ageAtlasMask}]


Register to COmmon Atlas and resample Image
Resample all follower images


