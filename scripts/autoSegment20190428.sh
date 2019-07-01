#!/bin/bash

crop=10
thresholdScale=1.0
alternateSkullStrip=0
biasFieldCorrection=0
medianFilter=0
neonateScan=0

# Parse Command line arguements
while getopts “t:r:c:o:s:habmn” OPTION
do
  case $OPTION in
    h)
      echo "Usage: $0 -t t1Image -r classImage -o outputDir -c padSize -s threshold-scale"
      echo "   where"
      echo "   -t T1 Weighted image for analysis"
      echo "   -r Tissue classified image (if not specified, then this will be created)"
      echo "   -o OutputDirectory"
      echo "   -c Number of voxels to pad with 0 around the image (default is 10)"
      echo "   -s Threshold scale factor (default is 1 = off, value should between 0 and 1)"
      echo "   -a Flag to use alternate approach (A) to skull strip for scans"
      echo "   -b Flag to perform bias field correction in cases where image exhibit shading"
      echo "   -m Flag to perform median filtering where image has low SNR"
      echo "   -n Flag to use neonate pipeline options"
      echo "   -h Display help message"
      exit 1
      ;;
    t)
      T1Image=$OPTARG
      ;;
    r)
      segmentImage=$OPTARG
      ;;
    o)
      analysisDir=$OPTARG
      ;;
    c)
      crop=$OPTARG
      ;;
    s)
      thresholdScale=$OPTARG
      ;;
    b)
      biasFieldCorrection=1
      ;;
    m)
      medianFilter=1
      ;;
    n)
      neonateScan=1
      ;;
    a)
      alternateSkullStrip=1
      ;;
    ?)
      echo "ERROR: Invalid option"
      echo "Usage: $0 -t t1Image -o outputDir -c padSize -s threshold-scale"
      echo "   where"
      echo "   -t T1 Weighted image for analysis"
      echo "   -o OutputDirectory"
      echo "   -c Number of voxels to pad with 0 around the image (default is 10)"
      echo "   -s Threshold scale factor (default is 1 = off, value should between 0 and 1)"
      echo "   -a Flag to use alternate approach (A) to skull strip for neonate scans"
      echo "   -b Flag to perform bias field correction in cases where image exhibit shading"
      echo "   -m Flag to perform median filtering where image has low SNR"
      echo "   -n Flag to use neonate pipeline options"
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

if [ ! -e $T1Image ]; then
  echo "ERROR: T1 Image does not exist"
  exit 1
fi

if [ "$segmentImage" != "" ]; then
	if [ ! -e $segmentImage ]; then
	  echo "ERROR: Segment Image does not exist"
	  exit 1
	fi
fi

if [ ! -e $analysisDir ]; then
  echo "ERROR: Analysis Directory does not exist"
  exit 1
fi

if [ "$alternateSkullStrip" == "1" ]; then
	if [ "$neonateScan" == "1" ]; then
      alternateSkullStrip=1
	else
	  alternateSkullStrip=2
	fi
fi


######################################################################################
# STEP 1 - RAS Orientation
# Force Orientation to RAS - Based on Information from AtlasViewer (getOrientation.m)
# Then perform ACPC alignment of the brain and then resample to 1.0 mm resolution
######################################################################################
rasT1Image=$analysisDir/T1_RAS.nii
3dresample -prefix ${rasT1Image} -orient ras -rmode Li -inset $T1Image


######################################################################################
# STEP 2 - Clip T1 to the Brain
# Generate the brain mask and make binary - This was moved to the second step to
# allow the alignment with @auto_tlrc to work with the no_ss option. This was
# required to get neonate scans to work properly.
######################################################################################
T1Mask=$analysisDir/T1_Mask.nii
case $alternateSkullStrip in
  0)
    3dSkullStrip -prefix $T1Mask -mask_vol -input $rasT1Image
    ;;
  1)
    3dSkullStrip -prefix $T1Mask -mask_vol -avoid_eyes -init_radius 50 -use_skull -exp_frac 0.05 -input $rasT1Image
    rm skull_strip_out_hull.ply
    ;;
  2)
    3dSkullStrip -prefix $T1Mask -mask_vol -avoid_eyes -init_radius 50 -use_skull -input $rasT1Image
    rm skull_strip_out_hull.ply
    ;;
  *)
    echo "Error: Invalid skull stripping mode specified"
    exit 1
    ;;
esac

brainMask=$analysisDir/brain.nii
3dcalc -a $T1Mask -expr 'ispositive(a-5)' -prefix $brainMask

# Clip the T1 to the brain for alignment
rasT1BrainOnly=$analysisDir/T1_RAS_BrainOnly.nii
3dcalc -a $brainMask -b $rasT1Image -expr '(a*b)' -prefix $rasT1BrainOnly



######################################################################################
# STEP 3 - ACPC Alignment
# Perform alignment with the Talairach Atlas. Use only the rigid portion of the
# transform, which will put the current subject data into ACPC alignment. This
# essentially removes scaling from the transform and keeps the data in subject space
######################################################################################
pushd `pwd`
cd $analysisDir

@auto_tlrc -base TT_avg152T1+tlrc -maxite 500 -dxyz 1.0 -rigid_equiv -init_xform AUTO_CENTER_CM -ok_notice -no_ss -input T1_RAS_BrainOnly.nii
# This next step is required since the command appears broken in @auto_tlrc
xfrmFile=`ls *_at.Xat.1D`
rigidFile=T1_RAS_at.Xat.rigid.1D
baseImage=`ls *_at.nii`
cat_matvec $xfrmFile -P > $rigidFile
# Now apply - Transforms T1 to ACPC alignment
acpcT1Image=$analysisDir/T1_RAS_ACPC.nii
acpcBrainMask=$analysisDir/Brain_Mask_ACPC.nii
3dAllineate -interp linear -1Dmatrix_apply $rigidFile -prefix ${acpcT1Image} -base ${baseImage} -input $rasT1Image
3dAllineate -interp linear -1Dmatrix_apply $rigidFile -prefix ${acpcBrainMask} -base ${baseImage} -input $brainMask
popd


# Bring along the classified image if provided by the user
if [ "$segmentImage" != "" ]; then
  rasSegment=$analysisDir/segment_RAS.nii
  3dresample -prefix ${rasSegment} -orient ras -rmode NN -inset $segmentImage

  acpcSegment=$analysisDir/segment_ACPC.nii
  3dAllineate -interp NN -1Dmatrix_apply $analysisDir/$rigidFile -prefix ${acpcSegment} -base $analysisDir/${baseImage} -input ${rasSegment}

  segmentImage=$acpcSegment
fi



######################################################################################
# STEP 4 - Pad the Image with 0's
# This step pads the image with 0's. This is needed to ensure that the surface
# created is closed. This is a requirement of AtlasViwer
######################################################################################
cropImage=$analysisDir/T1_crop.nii
expandImage=$analysisDir/T1_expand.nii
3dZeropad -prefix $cropImage -R -$crop -L -$crop -A -$crop -P -$crop -S -$crop -I -$crop $acpcT1Image
3dZeropad -prefix $expandImage -R $crop -L $crop -A $crop -P $crop -S $crop -I $crop $cropImage 

# Bring along the classified image
if [ "$segmentImage" != "" ]; then
  cropSegImage=$analysisDir/Segment_crop.nii
  expandSegImage=$analysisDir/Segment_expand.nii
  3dZeropad -prefix $cropSegImage -R -$crop -L -$crop -A -$crop -P -$crop -S -$crop -I -$crop $segmentImage
  3dZeropad -prefix $expandSegImage -R $crop -L $crop -A $crop -P $crop -S $crop -I $crop $cropSegImage 
  segmentImage=$expandSegImage
fi


######################################################################################
# STEP 5 - Background removal
# Threshold the T1 image to eliminate background noise. The resulting
# mask is filled to be used for the skull surface
######################################################################################
T1ThresholdImage=$analysisDir/T1_Tissue.nii
threshold=`3dClipLevel ${acpcT1Image}`
echo "T1 Threshold: $threshold"
threshold=`echo "$threshold $thresholdScale" | awk '{print $1 * $2}'`
echo "T1 Scaled Threshold: $threshold"
3dcalc -a $expandImage -expr "step(a-${threshold})" -prefix $T1ThresholdImage
T1SkullMask=$analysisDir/T1_Skull_Mask.nii
3dinfill -blend SOLID -prefix $T1SkullMask -minhits 2 -input $T1ThresholdImage


######################################################################################
# STEP 6 - Bias Field Correction (optional)
# Perform bias field correction if requested. Typically not needed but some
# datasets with large shading artifacts may need this step.
######################################################################################
if [ $biasFieldCorrection == 1 ]; then
  T1Brain=$analysisDir/T1_brain.nii
  3dcalc -a $acpcBrainMask -b $acpcT1Image -expr 'step(a)*b' -prefix $T1Brain
  
  T1BrainBFC=$analysisDir/T1_brain_BFC.nii
  3dUnifize -prefix $T1BrainBFC -input ${T1Brain} 
  
  classT1=$T1BrainBFC
else
  classT1=$acpcT1Image
fi


######################################################################################
# STEP 6 - Median Filtering (optional)
# Perform Median filtering to improve SNR if requested.
######################################################################################
if [ $medianFilter == 1 ]; then
  T1BrainBFC=$analysisDir/T1_smooth.nii
  3dmerge -dxyz=1 -1filter_winsor 2.5 19 -prefix ${T1BrainBFC} $classT1
  classT1=$T1BrainBFC
fi
 
classT1=`basename $classT1`
imageMask=`basename $acpcBrainMask`
T1SkullMask=`basename $T1SkullMask`


######################################################################################
# STEP 7 - Tissue classification (Optional)
# This step is typically required. It is only skipped in the case that the user
# has provided their own tissue classification for the image.
######################################################################################
if [  "$segmentImage" == "" ]; then
	#
	# Classify the image into GM, WM, and SCSF within the brain
	#          3dSeg Output stored in classDir as Classes+orig
	#          Tissue Types: CSF=1, GM=2, WM=3
	#
	#
	echo "Running Classification"
	echo "...Image: $classT1"
	echo "...Mask: $imageMask"
	cd $analysisDir
	classDir=classification 
	3dSeg -anat $classT1 -mask $imageMask -classes 'CSF ; GM ; WM' \
		  -bias_classes 'GM ; WM' -bias_fwhm 25.0 -mixfrac AVG152_BRAIN_MASK -main_N 5 \
		  -blur_meth BFT -prefix $classDir
	segmentImage=$classDir/Classes+tlrc
    pwd
fi
    

######################################################################################
# STEP 8 - Create hseg image
# Separate the tissue classes and recombine to form hseg image used by AtlasViewer.
# If the user provides their own segmentation, it must use the same labels for
# tissue types as used by AFNI's 3dSeg.
######################################################################################
pwd
csfImage=csf.nii
gmImage=gm.nii
wmImage=wm.nii
hsegImage=hseg.nii
hsegTissueType=hseg_tiss_type.txt
3dcalc -a $segmentImage -expr 'equals(a,1)' -prefix $csfImage
3dcalc -a $segmentImage -expr 'equals(a,2)' -prefix $gmImage
3dcalc -a $segmentImage -expr 'equals(a,3)' -prefix $wmImage
3dcalc -a $T1SkullMask -b $csfImage -c $gmImage -d $wmImage -expr 'max(max(max(a,b*2),c*3),d*4)' -prefix $hsegImage
echo "scalp" > $hsegTissueType
echo "csf" >> $hsegTissueType
echo "gm" >> $hsegTissueType
echo "wm" >> $hsegTissueType

exit

######################################################################################
# STEP 9 - Create Matlab script
# This is section of code is no longer needed since AtlasViwer will now import
# the hseg image and generate these surfaces. It is left here for historical
# reference only.
######################################################################################
surfaceGenScript=surfaceGenerationScript.m;
cat > $surfaceGenScript << EOF
%
% MATLAB Script - Create the Surface using AtlasViewer Surface Tools
%
close all;
clear all;

% Create the Outer scalp/skull surface
tiss_type=struct([]);
tiss_type(1).name = 'scalp';
tiss_type(2).name = 'csf';
tiss_type(3).name = 'gm';
tiss_type(4).name = 'wm';

dirnameSubj='.';
hsegImage='$hsegImage';
hsegnii = load_untouch_nii(hsegImage);
headvol.img = hsegnii.img;
headvol.tiss_prop = tiss_type;
headvol.T_2mc = eye(4);
% Old Value [get_nii_vox2ras(hsegnii); 0 0 0 1];
headvol.T_2digpts = eye(4);
headvol.T_2ras = eye(4);
headvol.T_2ref = eye(4);
headvol.T_2viewer = eye(4);
% Should either of the following values be 'RAS'
headvol.orientation = '';
headvol.orientationOrig = '';

% Save the image data in AtlasViewe raw format
save_vox([dirnameSubj '/anatomical/headvol.vox'],headvol);

% Now create and save the head surface
headsurf=headvol2headsurf(headvol);
write_surf([dirnameSubj '/anatomical/headsurf.mesh'], headsurf.mesh.vertices, headsurf.mesh.faces);
headsurf2vol = eye(4);
save([dirnameSubj '/anatomical/headsurf2vol.txt'],'-ascii','headsurf2vol');

% Create the Inner pial/brain surface
brainImage='$T1Mask';
brainnii=load_untouch_nii(brainImage);
tiss_type=struct([]);
tiss_type(1).name = 'tissue';
brainvol.img = brainnii.img;
brainvol.tiss_prop = tiss_type;
brainvol.T_2mc = eye(4);
% Old value [get_nii_vox2ras(brainnii); 0 0 0 1];
brainvol.T_2digpts = eye(4);
brainvol.T_2ras = eye(4);
brainvol.T_2ref = eye(4);
brainvol.T_2viewer = eye(4);
% Should either of the following values be 'RAS'
brainvol.orientation = '';
brainvol.orientationOrig = '';

% Save the image data in AtlasViewe raw format
save_vox([dirnameSubj '/anatomical/brainvol.vox'],brainvol);

% Now create and save the pial surface
pialsurf=pialvol2pialsurf(brainvol);
write_surf([dirnameSubj '/anatomical/pialsurf.mesh'], pialsurf.mesh.vertices, pialsurf.mesh.faces);

% Create Ref Points Files
%fid = fopen([dirnameSubj '/anatomical/refpts_label.txt'],'wt');
%fprintf(fid,'Nz\nIz\nAr\nAl\nCz\n');    
%fclose(fid);
  
%refPts = [2.3488763e+02   8.1720793e+01   1.7471014e+02; 3.8417588e+01   1.3117768e+02   1.1464009e+02; 1.1717850e+02   5.4392249e+01   1.7878120e+02; 1.5507876e+02   1.7813529e+02   1.6909359e+02; 1.1219288e+02   8.8752879e+01   2.3713572e+01];
%save([dirnameSubj '/anatomical/refpts.txt'],'-ascii','refPts');
%T = brainvol.T_2mc;
%save([dirnameSubj '/anatomical/refpts2vol.txt'],'-ascii','T');

% Unclear if this is needed - Need to debug with help from Sobana
%T = [1 0 0 -x1+1; 0 1 0 -y1+1; 0 0 1 -z1+1; 0 0 0 1];
%save([FreeSurferSubjectDir '/anatomical/pialsurf2vol.txt'],'-ascii','T');
%save([FreeSurferSubjectDir '/anatomical/headsurf2vol.txt'],'-ascii','T');  
%quit;
EOF

if [ ! -e $analysisDir/anatomical ]; then
  mkdir $analysisDir/anatomical
fi




