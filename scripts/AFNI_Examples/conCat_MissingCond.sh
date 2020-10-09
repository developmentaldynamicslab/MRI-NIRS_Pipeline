#!/bin/bash


subjlist='06IND144B'

cd /Volumes/PegasusDDLab/ProjectINDIA/Y1/NeuroDOT_Output_MRIs_Group

for subj in $subjlist
do

3dTcat /Volumes/PegasusDDLab/ProjectINDIA/GroupAnalyses/concat/Empty_India_Unmasked_ND_To_Atlas_CliptoBrain.nii.gz \
  /Volumes/PegasusDDLab/ProjectINDIA/GroupAnalyses/concat/Empty_India_Unmasked_ND_To_Atlas_CliptoBrain.nii.gz \
  /Volumes/PegasusDDLab/ProjectINDIA/GroupAnalyses/concat/Empty_India_Unmasked_ND_To_Atlas_CliptoBrain.nii.gz \
  /Volumes/PegasusDDLab/ProjectINDIA/GroupAnalyses/concat/Empty_India_Unmasked_ND_To_Atlas_CliptoBrain.nii.gz \
  ${subj}_India_cond3_Unmasked_oxy_ND_To_Atlas_CliptoBrain.nii.gz \
  ${subj}_India_cond3_Unmasked_deoxy_ND_To_Atlas_CliptoBrain.nii.gz \
  -prefix /Volumes/PegasusDDLab/ProjectINDIA/GroupAnalyses/concat/Y1NeuroDOT_MRIs_${subj}.nii -verb

done

subjlist='06IND356G'

cd /Volumes/PegasusDDLab/ProjectINDIA/Y1/NeuroDOT_Output_MRIs_Group

for subj in $subjlist
do

3dTcat ${subj}_India_cond1_Unmasked_oxy_ND_To_Atlas_CliptoBrain.nii.gz \
  ${subj}_India_cond1_Unmasked_deoxy_ND_To_Atlas_CliptoBrain.nii.gz \
  ${subj}_India_cond2_Unmasked_oxy_ND_To_Atlas_CliptoBrain.nii.gz \
  ${subj}_India_cond2_Unmasked_deoxy_ND_To_Atlas_CliptoBrain.nii.gz \
  /Volumes/PegasusDDLab/ProjectINDIA/GroupAnalyses/concat/Empty_India_Unmasked_ND_To_Atlas_CliptoBrain.nii.gz \
  /Volumes/PegasusDDLab/ProjectINDIA/GroupAnalyses/concat/Empty_India_Unmasked_ND_To_Atlas_CliptoBrain.nii.gz \
  -prefix /Volumes/PegasusDDLab/ProjectINDIA/GroupAnalyses/concat/Y1NeuroDOT_MRIs_${subj}.nii -verb

done

subjlist='09IND216G'

cd /Volumes/PegasusDDLab/ProjectINDIA/Y1/NeuroDOT_Output_MRIs_Group

for subj in $subjlist
do

3dTcat /Volumes/PegasusDDLab/ProjectINDIA/GroupAnalyses/concat/Empty_India_Unmasked_ND_To_Atlas_CliptoBrain.nii.gz \
  /Volumes/PegasusDDLab/ProjectINDIA/GroupAnalyses/concat/Empty_India_Unmasked_ND_To_Atlas_CliptoBrain.nii.gz \
  ${subj}_India_cond2_Unmasked_oxy_ND_To_Atlas_CliptoBrain.nii.gz \
  ${subj}_India_cond2_Unmasked_deoxy_ND_To_Atlas_CliptoBrain.nii.gz \
  ${subj}_India_cond3_Unmasked_oxy_ND_To_Atlas_CliptoBrain.nii.gz \
  ${subj}_India_cond3_Unmasked_deoxy_ND_To_Atlas_CliptoBrain.nii.gz \
  -prefix /Volumes/PegasusDDLab/ProjectINDIA/GroupAnalyses/concat/Y1NeuroDOT_MRIs_${subj}.nii -verb

done

subjlist='06IND280B'

cd /Volumes/PegasusDDLab/ProjectINDIA/Y1/NeuroDOT_Output_Templates_Group

for subj in $subjlist
do

3dTcat ${subj}_India_cond1_Unmasked_oxy_ND_To_Atlas_CliptoBrain.nii.gz \
  ${subj}_India_cond1_Unmasked_deoxy_ND_To_Atlas_CliptoBrain.nii.gz \
  /Volumes/PegasusDDLab/ProjectINDIA/GroupAnalyses/concat/Empty_India_Unmasked_ND_To_Atlas_CliptoBrain.nii.gz \
  /Volumes/PegasusDDLab/ProjectINDIA/GroupAnalyses/concat/Empty_India_Unmasked_ND_To_Atlas_CliptoBrain.nii.gz \
  ${subj}_India_cond3_Unmasked_oxy_ND_To_Atlas_CliptoBrain.nii.gz \
  ${subj}_India_cond3_Unmasked_deoxy_ND_To_Atlas_CliptoBrain.nii.gz \
  -prefix /Volumes/PegasusDDLab/ProjectINDIA/GroupAnalyses/concat/Y1NeuroDOT_Templates_${subj}.nii -verb

done

subjlist='06IND330B'

cd /Volumes/PegasusDDLab/ProjectINDIA/Y1/NeuroDOT_Output_Templates_Group

for subj in $subjlist
do

3dTcat ${subj}_India_cond1_Unmasked_oxy_ND_To_Atlas_CliptoBrain.nii.gz \
  ${subj}_India_cond1_Unmasked_deoxy_ND_To_Atlas_CliptoBrain.nii.gz \
  /Volumes/PegasusDDLab/ProjectINDIA/GroupAnalyses/concat/Empty_India_Unmasked_ND_To_Atlas_CliptoBrain.nii.gz \
  /Volumes/PegasusDDLab/ProjectINDIA/GroupAnalyses/concat/Empty_India_Unmasked_ND_To_Atlas_CliptoBrain.nii.gz \
  /Volumes/PegasusDDLab/ProjectINDIA/GroupAnalyses/concat/Empty_India_Unmasked_ND_To_Atlas_CliptoBrain.nii.gz \
  /Volumes/PegasusDDLab/ProjectINDIA/GroupAnalyses/concat/Empty_India_Unmasked_ND_To_Atlas_CliptoBrain.nii.gz \
  -prefix /Volumes/PegasusDDLab/ProjectINDIA/GroupAnalyses/concat/Y1NeuroDOT_Templates_${subj}.nii -verb

done

subjlist='06IND166B'

cd /Volumes/PegasusDDLab/ProjectINDIA/Y2/NeuroDOT_Output_MRIs_Group

for subj in $subjlist
do

3dTcat ${subj}_India_cond1_Unmasked_oxy_ND_To_Atlas_CliptoBrain.nii.gz \
  ${subj}_India_cond1_Unmasked_deoxy_ND_To_Atlas_CliptoBrain.nii.gz \
  ${subj}_India_cond2_Unmasked_oxy_ND_To_Atlas_CliptoBrain.nii.gz \
  ${subj}_India_cond2_Unmasked_deoxy_ND_To_Atlas_CliptoBrain.nii.gz \
  /Volumes/PegasusDDLab/ProjectINDIA/GroupAnalyses/concat/Empty_India_Unmasked_ND_To_Atlas_CliptoBrain.nii.gz \
  /Volumes/PegasusDDLab/ProjectINDIA/GroupAnalyses/concat/Empty_India_Unmasked_ND_To_Atlas_CliptoBrain.nii.gz \
  -prefix /Volumes/PegasusDDLab/ProjectINDIA/GroupAnalyses/concat/Y2NeuroDOT_MRIs_${subj}.nii -verb

done
