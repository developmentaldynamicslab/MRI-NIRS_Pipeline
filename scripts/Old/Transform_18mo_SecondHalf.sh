#!/bin/bash

subjlist='09IND004G 09IND005G 09IND039G 09IND059G 09IND060B 09IND082G 09IND106B 09IND109B 09IND110G 09IND114B 09IND116B 09IND119B 09IND133G 09IND136B 09IND151G 09IND152G 09IND154G 09IND157G 09IND167G 09IND201B 09IND202B 09IND209B 09IND210B 09IND213B 09IND214B 09IND216G 09IND218G 09IND240G 09IND241B 09IND246B 09IND249G 09IND252G 09IND253B 09IND261B 09IND264B 09IND265G 09IND269B 09IND270G 09IND273G 09IND302B 09IND304B 09IND312B 09IND314G 09IND315B 09IND350G 09IND352B 09IND357B 09IND358G 09IND362B 09IND363B 09IND364B 09IND365B 09IND369B 09IND370G 09IND371G 09IND377B 09IND384B 09IND385B 09IND386G 09IND390B'


for subj in $subjlist
do

  bash /Users/administrator/Documents/GitHub/MRI-NIRS_Pipeline/scripts/registerCommon.sh \
  -t /Volumes/PegasusDDLab/IndiaY2Data/MCData/${subj}/T1_RAS_ACPC.nii \
  -s /Volumes/PegasusDDLab/IndiaY2Data/MCData/${subj}/hseg.nii \
  -a /Volumes/PegasusDDLab/IndiaY2Data/indiaOveralltemplate_scale2mm.nii \
  -b /Volumes/PegasusDDLab/IndiaY2Data/indiaOveralltemplate_BrainMask2mm.nii \
  -c /Volumes/PegasusDDLab/IndiaY2Data/indiaOveralltemplate_scale2mm.nii \
  -d /Volumes/PegasusDDLab/IndiaY2Data/indiaOveralltemplate_BrainMask2mm.nii \
  -i ${subj} \
  -o /Volumes/PegasusDDLab/IndiaY2Data/SobanaTesting/Th0.0001/Transformed \
  -w /Volumes/PegasusDDLab/IndiaY2Data/SobanaTesting/Th0.0001/Beta_${subj}_cond1_Unmasked_deoxy.nii \
  -w /Volumes/PegasusDDLab/IndiaY2Data/SobanaTesting/Th0.0001/Beta_${subj}_cond1_Unmasked_oxy.nii \
  -w /Volumes/PegasusDDLab/IndiaY2Data/SobanaTesting/Th0.0001/Beta_${subj}_cond2_Unmasked_deoxy.nii \
  -w /Volumes/PegasusDDLab/IndiaY2Data/SobanaTesting/Th0.0001/Beta_${subj}_cond2_Unmasked_oxy.nii \
  -w /Volumes/PegasusDDLab/IndiaY2Data/SobanaTesting/Th0.0001/Beta_${subj}_cond3_Unmasked_deoxy.nii \
  -w /Volumes/PegasusDDLab/IndiaY2Data/SobanaTesting/Th0.0001/Beta_${subj}_cond3_Unmasked_oxy.nii \
  -w /Volumes/PegasusDDLab/IndiaY2Data/SobanaTesting/Th0.0001/Beta_${subj}_cond4_Unmasked_deoxy.nii \
  -w /Volumes/PegasusDDLab/IndiaY2Data/SobanaTesting/Th0.0001/Beta_${subj}_cond4_Unmasked_oxy.nii \
  -w /Volumes/PegasusDDLab/IndiaY2Data/SobanaTesting/Th0.0001/Beta_${subj}_cond5_Unmasked_deoxy.nii \
  -w /Volumes/PegasusDDLab/IndiaY2Data/SobanaTesting/Th0.0001/Beta_${subj}_cond5_Unmasked_oxy.nii

  done
