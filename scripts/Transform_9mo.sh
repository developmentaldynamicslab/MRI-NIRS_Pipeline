#!/bin/bash

subjlist='09IND127B	09IND133G	09IND136B	09IND138G	09IND141G	09IND151G	09IND152G	09IND154G	09IND157G	09IND159G	09IND167G	09IND175G	09IND201B	09IND202B	09IND209B	09IND210B	09IND213B	09IND216G	09IND218G	09IND240G	09IND241B	09IND247B	09IND249G	09IND252G	09IND253B	09IND261B	09IND265G	09IND269B	09IND270G	09IND272G	09IND273G	09IND275G	09IND302B	09IND304B	09IND312B	09IND314G	09IND315B	09IND350G	09IND357B	09IND358G	09IND363B	09IND365B	09IND369B	09IND370G	09IND371G	09IND372B	09IND377B	09IND382B	09IND384B	09IND385B	09IND386G	09IND390B'


## Sean's template

#3dcalc -a indiaOveralltemplate.nii.gz -expr 'a*1000' -prefix indiaOveralltemplate_scale.nii.gz

#3dSkullStrip -prefix indiaOveralltemplate_brain.nii.gz -mask_vol -input indiaOveralltemplate_scale.nii.gz -avoid_eyes -init_radius 50 -use_skull -exp_frac 0.05

# Transformation:

for subj in $subjlist
do

bash /media/sw57/DRIVE10/India_Gates/Scripts/registerCommon.sh \
-t /media/sw57/DRIVE10/India_Gates/MCs/9mo/${subj}/struc/T1_RAS.nii \
-s /media/sw57/DRIVE10/India_Gates/MCs/9mo/${subj}/struc/T1_Mask.nii \
-a /media/sw57/DRIVE10/India_Gates/indiaTemplates/india_ageGroupTemplatesAndTransforms/indiaOveralltemplate_scale.nii.gz \
-b /media/sw57/DRIVE10/India_Gates/indiaTemplates/india_ageGroupTemplatesAndTransforms/indiaOveralltemplate_brain.nii.gz \
-i ${subj} \
-o /media/sw57/MAXTOR/India-gates/ICs/9mo/Transformed \
-w /media/sw57/MAXTOR/India-gates/ICs/9mo/Load_${subj}_cond1_Unmasked_deoxy.nii \
-w /media/sw57/MAXTOR/India-gates/ICs/9mo/Load_${subj}_cond2_Unmasked_deoxy.nii \
-w /media/sw57/MAXTOR/India-gates/ICs/9mo/Load_${subj}_cond3_Unmasked_deoxy.nii \
-w /media/sw57/MAXTOR/India-gates/ICs/9mo/Load_${subj}_cond4_Unmasked_deoxy.nii \
-w /media/sw57/MAXTOR/India-gates/ICs/9mo/Load_${subj}_cond5_Unmasked_deoxy.nii \
-w /media/sw57/MAXTOR/India-gates/ICs/9mo/Load_${subj}_cond1_Unmasked_oxy.nii \
-w /media/sw57/MAXTOR/India-gates/ICs/9mo/Load_${subj}_cond2_Unmasked_oxy.nii \
-w /media/sw57/MAXTOR/India-gates/ICs/9mo/Load_${subj}_cond3_Unmasked_oxy.nii \
-w /media/sw57/MAXTOR/India-gates/ICs/9mo/Load_${subj}_cond4_Unmasked_oxy.nii \
-w /media/sw57/MAXTOR/India-gates/ICs/9mo/Load_${subj}_cond5_Unmasked_oxy.nii


done

