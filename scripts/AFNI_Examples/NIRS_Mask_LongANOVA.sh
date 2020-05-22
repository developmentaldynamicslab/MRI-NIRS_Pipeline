#!/bin/bash

#create initial image...
subjlist='06IND001B'

cd /Users/nfb15zpu/Documents/J-Files/Grants/Grant_GatesFoundation_Phase2/AnalysisOct2019/Long_FinalImages

for subj in $subjlist
do

3dcalc -a BetaY1_${subj}_cond1_Unmasked_oxy_To_Atlas_CliptoBrain.nii.gz \
 -b BetaY1_${subj}_cond2_Unmasked_oxy_To_Atlas_CliptoBrain.nii.gz \
 -c BetaY1_${subj}_cond3_Unmasked_oxy_To_Atlas_CliptoBrain.nii.gz \
 -d BetaY2_${subj}_cond1_Unmasked_oxy_To_Atlas_CliptoBrain.nii.gz \
 -e BetaY2_${subj}_cond2_Unmasked_oxy_To_Atlas_CliptoBrain.nii.gz \
 -f BetaY2_${subj}_cond3_Unmasked_oxy_To_Atlas_CliptoBrain.nii.gz \
 -g BetaY1_${subj}_cond1_Unmasked_deoxy_To_Atlas_CliptoBrain.nii.gz \
 -h BetaY1_${subj}_cond2_Unmasked_deoxy_To_Atlas_CliptoBrain.nii.gz \
 -i BetaY1_${subj}_cond3_Unmasked_deoxy_To_Atlas_CliptoBrain.nii.gz \
 -j BetaY2_${subj}_cond1_Unmasked_deoxy_To_Atlas_CliptoBrain.nii.gz \
 -k BetaY2_${subj}_cond2_Unmasked_deoxy_To_Atlas_CliptoBrain.nii.gz \
 -l BetaY2_${subj}_cond3_Unmasked_deoxy_To_Atlas_CliptoBrain.nii.gz \
 -expr 'ispositive(abs(a)+abs(b)+abs(c)+abs(d)+abs(e)+abs(f)+abs(g)+abs(h)+abs(i)+abs(j)+abs(k)+abs(l))' -prefix NIRS_Mask.nii

done


subjlist='06IND003G 06IND006B 06IND007G 06IND012B 06IND014B 06IND016G 06IND017B 06IND026B 06IND027G 06IND028G 06IND030G 06IND033B 06IND036B 06IND040B 06IND045G 06IND047B 06IND049G 06IND063G 06IND064G 06IND066B 06IND067B 06IND071B 06IND073B 06IND076G 06IND077G 06IND078G 06IND080G 06IND081G 06IND083G 06IND084B 06IND103B 06IND107B 06IND108G 06IND118G 06IND120G 06IND121B 06IND125G 06IND130B 06IND131B 06IND132B 06IND137G 06IND142B 06IND144B 06IND149G 06IND150B 06IND156B 06IND160B 06IND161G 06IND163B 06IND164B 06IND165G 06IND166B 06IND168B 06IND170B 06IND172G 06IND203G 06IND204B 06IND205G 06IND206B 06IND207B 06IND211G 06IND212G 06IND215G 06IND217B 06IND220G 06IND222B 06IND223B 06IND227G 06IND230B 06IND235G 06IND239G 06IND243B 06IND245G 06IND250B 06IND255G 06IND256G 06IND260G 06IND262B 06IND266B 06IND267B 06IND271G 06IND276G 06IND277B 06IND279G 06IND280B 06IND282G 06IND300G 06IND301G 06IND303B 06IND310B 06IND311B 06IND318G 06IND321G 06IND322G 06IND323G 06IND325B 06IND327G 06IND328G 06IND330B 06IND334B 06IND335B 06IND336B 06IND337G 06IND344G 06IND345B 06IND353B 06IND354B 06IND355G 06IND356G 06IND360B 06IND361B 06IND368G 06IND374B 06IND375G 06IND378G 06IND387B 09IND002B 09IND004G 09IND011B 09IND013B 09IND023B 09IND024G 09IND029G 09IND031G 09IND035B 09IND037G 09IND038G 09IND039G 09IND043G 09IND046G 09IND050B 09IND051B 09IND052G 09IND054G 09IND058G 09IND059G 09IND060B 09IND061G 09IND062G 09IND070B 09IND072B 09IND079G 09IND082G 09IND102G 09IND104B 09IND106B 09IND109B 09IND110G 09IND114B 09IND116B 09IND119B 09IND122B 09IND126G 09IND127B 09IND133G 09IND136B 09IND138G 09IND139B 09IND141G 09IND151G 09IND152G 09IND153G 09IND154G 09IND157G 09IND159G 09IND167G 09IND175G 09IND176G 09IND201B 09IND202B 09IND209B 09IND210B 09IND213B 09IND214B 09IND216G 09IND218G 09IND226G 09IND238B 09IND240G 09IND244B 09IND246B 09IND247B 09IND249G 09IND252G 09IND257B 09IND261B 09IND265G 09IND268G 09IND269B 09IND270G 09IND272G 09IND273G 09IND275G 09IND302B 09IND304B 09IND308B 09IND312B 09IND313G 09IND314G 09IND315B 09IND316B 09IND332G 09IND342B 09IND357B 09IND358G 09IND362B 09IND363B 09IND364B 09IND365B 09IND369B 09IND370G 09IND371G 09IND372B 09IND377B 09IND380G 09IND382B 09IND383G 09IND384B 09IND385B 09IND386G 09IND389B 09IND390B'

for subj in $subjlist
do

3dcalc -a BetaY1_${subj}_cond1_Unmasked_oxy_To_Atlas_CliptoBrain.nii.gz \
 -b BetaY1_${subj}_cond2_Unmasked_oxy_To_Atlas_CliptoBrain.nii.gz \
 -c BetaY1_${subj}_cond3_Unmasked_oxy_To_Atlas_CliptoBrain.nii.gz \
 -d BetaY2_${subj}_cond1_Unmasked_oxy_To_Atlas_CliptoBrain.nii.gz \
 -e BetaY2_${subj}_cond2_Unmasked_oxy_To_Atlas_CliptoBrain.nii.gz \
 -f BetaY2_${subj}_cond3_Unmasked_oxy_To_Atlas_CliptoBrain.nii.gz \
 -g BetaY1_${subj}_cond1_Unmasked_deoxy_To_Atlas_CliptoBrain.nii.gz \
 -h BetaY1_${subj}_cond2_Unmasked_deoxy_To_Atlas_CliptoBrain.nii.gz \
 -i BetaY1_${subj}_cond3_Unmasked_deoxy_To_Atlas_CliptoBrain.nii.gz \
 -j BetaY2_${subj}_cond1_Unmasked_deoxy_To_Atlas_CliptoBrain.nii.gz \
 -k BetaY2_${subj}_cond2_Unmasked_deoxy_To_Atlas_CliptoBrain.nii.gz \
 -l BetaY2_${subj}_cond3_Unmasked_deoxy_To_Atlas_CliptoBrain.nii.gz \
 -m NIRS_Mask.nii -expr 'ispositive(abs(a)+abs(b)+abs(c)+abs(d)+abs(e)+abs(f)+abs(g)+abs(h)+abs(i)+abs(j)+abs(k)+abs(l))+m' -prefix NIRS_Mask_Temp.nii
 
rm NIRS_Mask.nii
mv NIRS_Mask_Temp.nii NIRS_Mask.nii

done

#keep voxels with 60% or greater participants contributing...97*.6 = 58.2
3dcalc -a NIRS_Mask.nii -expr 'astep(a,156)' -prefix Y1Mask.nii