#!/bin/bash

subjlist='06IND335B'

## Sean's template

#3dcalc -a indiaOveralltemplate.nii.gz -expr 'a*1000' -prefix indiaOveralltemplate_scale.nii.gz

#3dSkullStrip -prefix indiaOveralltemplate_brain.nii.gz -mask_vol -input indiaOveralltemplate_scale.nii.gz -avoid_eyes -init_radius 50 -use_skull -exp_frac 0.05

# Transformation:

for subj in $subjlist
do

bash /media/sw57/DRIVE10/India_Gates/Scripts/registerCommon.sh \
-t /media/sw57/DRIVE10/India_Gates/MCs/6mo/${subj}/struc/T1_RAS.nii \
-s /media/sw57/DRIVE10/India_Gates/MCs/6mo/${subj}/struc/T1_Mask.nii \
-a /media/sw57/DRIVE10/India_Gates/indiaTemplates/india_ageGroupTemplatesAndTransforms/indiaOveralltemplate_scale.nii.gz \
-b /media/sw57/DRIVE10/India_Gates/indiaTemplates/india_ageGroupTemplatesAndTransforms/indiaOveralltemplate_brain.nii.gz \
-i ${subj} \
-o /media/sw57/MAXTOR/India-gates/ICs/6mo/Transformed \
-w /media/sw57/MAXTOR/India-gates/ICs/6mo/Load_${subj}_cond1_Unmasked_deoxy.nii \
-w /media/sw57/MAXTOR/India-gates/ICs/6mo/Load_${subj}_cond2_Unmasked_deoxy.nii \
-w /media/sw57/MAXTOR/India-gates/ICs/6mo/Load_${subj}_cond3_Unmasked_deoxy.nii \
-w /media/sw57/MAXTOR/India-gates/ICs/6mo/Load_${subj}_cond4_Unmasked_deoxy.nii \
-w /media/sw57/MAXTOR/India-gates/ICs/6mo/Load_${subj}_cond5_Unmasked_deoxy.nii \
-w /media/sw57/MAXTOR/India-gates/ICs/6mo/Load_${subj}_cond1_Unmasked_oxy.nii \
-w /media/sw57/MAXTOR/India-gates/ICs/6mo/Load_${subj}_cond2_Unmasked_oxy.nii \
-w /media/sw57/MAXTOR/India-gates/ICs/6mo/Load_${subj}_cond3_Unmasked_oxy.nii \
-w /media/sw57/MAXTOR/India-gates/ICs/6mo/Load_${subj}_cond4_Unmasked_oxy.nii \
-w /media/sw57/MAXTOR/India-gates/ICs/6mo/Load_${subj}_cond5_Unmasked_oxy.nii


done

