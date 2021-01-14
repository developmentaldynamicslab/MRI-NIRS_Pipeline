#!/bin/bash
subjlist='06IND001B_R3 06IND003G_R3'
for subj in $subjlist
do

  cd  /Volumes/PegasusDDLab/IndiaY2Seg
  #
  # Extract a mask for the skull with no background pixels outside of the skull
  3dcalc -a ${subj}_neurologicalHighRes2.nii -prefix ${subj}_mask_400.nii -expr 'step(a-1500)'
  # Fill the mask to skull / brain
  3dinfill -blend SOLID -prefix ${subj}_mask_filled.nii -minhits 2 -input  ${subj}_mask_400.nii
  # Clip the image to just the region defined by the mask generated above
  3dcalc -a ${subj}_neurologicalHighRes2.nii  -b ${subj}_mask_filled.nii -prefix ${subj}_final_Masked.nii -expr '(a*b)'
  # Multiply by iteslf
  3dcalc -a ${subj}_final_Masked.nii -b ${subj}_final_Masked.nii -expr 'a*b' -prefix ${subj}_enhanced.nii

  #Then segment using vinces new script (April 28 2019) and should align to ACPC
  mkdir -p /Volumes/PegasusDDLab/IndiaY2Seg/${subj}/

  bash autoSegment20190428.sh -t /Volumes/PegasusDDLab/India_other_rounds/india_highRes/${subj}_neurologicalHighRes.nii.gz -o /Volumes/PegasusDDLab/IndiaY2Seg/${subj}/ -s 0.5 -c 3 -b -m

done
