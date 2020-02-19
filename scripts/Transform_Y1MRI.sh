#!/bin/bash

subjlist='06IND001B'


for subj in $subjlist
do

bash /Users/administrator/Documents/GitHub/MRI-NIRS_Pipeline/scripts/registerCommon.sh \
-t /Volumes/PegasusDDLab/ProjectINDIA/Y1/MCs-MRIs/${subj}/T1_RAS.nii \
-s /Volumes/PegasusDDLab/ProjectINDIA/Y1/MCs-MRIs/${subj}/hseg.nii \
-a /Volumes/PegasusDDLab/ProjectINDIA/GroupTemplate/indiaOveralltemplate_scale2mm.nii \
-b /Volumes/PegasusDDLab/ProjectINDIA/GroupTemplate/indiaOveralltemplate_BrainMask2mm.nii \
-c /Volumes/PegasusDDLab/ProjectINDIA/GroupTemplate/indiaOveralltemplate_scale2mm.nii \
-d /Volumes/PegasusDDLab/ProjectINDIA/GroupTemplate/indiaOveralltemplate_BrainMask2mm.nii \
-i ${subj} \
-o /Volumes/PegasusDDLab/ProjectINDIA/Y1/NeuroDOT_Output_MRIs/Transformed \
-w /Volumes/PegasusDDLab/ProjectINDIA/Y1/NeuroDOT_Output_MRIs/${subj}_India-Load_cond1_Unmasked_deoxy_ND.nii \
-w /Volumes/PegasusDDLab/ProjectINDIA/Y1/NeuroDOT_Output_MRIs/${subj}_India-Load_cond1_Unmasked_oxy_ND.nii \
-w /Volumes/PegasusDDLab/ProjectINDIA/Y1/NeuroDOT_Output_MRIs/${subj}_India-Load_cond2_Unmasked_deoxy_ND.nii \
-w /Volumes/PegasusDDLab/ProjectINDIA/Y1/NeuroDOT_Output_MRIs/${subj}_India-Load_cond2_Unmasked_oxy_ND.nii \
-w /Volumes/PegasusDDLab/ProjectINDIA/Y1/NeuroDOT_Output_MRIs/${subj}_India-Load_cond3_Unmasked_deoxy_ND.nii \
-w /Volumes/PegasusDDLab/ProjectINDIA/Y1/NeuroDOT_Output_MRIs/${subj}_India-Load_cond3_Unmasked_oxy_ND.nii \


done
