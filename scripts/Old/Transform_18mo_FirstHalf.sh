#!/bin/bash

subjlist='06IND012B 06IND014B 06IND016G 06IND045G 06IND047B 06IND066B 06IND067B 06IND073B 06IND108G 06IND118G 06IND120G 06IND121B 06IND131B 06IND132B 06IND137G 06IND142B 06IND144B 06IND156B 06IND160B 06IND161G 06IND166B 06IND168B 06IND170B 06IND172G 06IND203G 06IND204B 06IND206B 06IND211G 06IND215G 06IND217B 06IND227G 06IND256G 06IND262B 06IND267B 06IND271G 06IND277B 06IND278G 06IND279G 06IND301G 06IND303B 06IND306G 06IND309G 06IND311B 06IND318G 06IND321G 06IND322G 06IND327G 06IND328G 06IND334B 06IND335B 06IND336B 06IND337G 06IND354B 06IND355G 06IND356G 06IND361B 06IND374B 06IND387B'


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
