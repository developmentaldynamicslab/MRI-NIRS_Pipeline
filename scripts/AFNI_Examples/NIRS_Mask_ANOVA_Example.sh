#!/bin/bash

#create initial image...
subjlist='06IND012B'

cd /Users/nfb15zpu/Documents/J-Files/Grants/Grant_GatesFoundation_Phase2/AnalysisOct2019/Long_FinalImages

for subj in $subjlist
do

3dcalc -a BetaY1_${subj}_cond1_Unmasked_oxy_ND_To_Atlas_CliptoBrain.nii.gz \
	-b BetaY1_${subj}_cond2_Unmasked_oxy_ND_To_Atlas_CliptoBrain.nii.gz \
	-c BetaY1_${subj}_cond3_Unmasked_oxy_ND_To_Atlas_CliptoBrain.nii.gz \
	-d BetaY2_${subj}_cond1_Unmasked_oxy_ND_To_Atlas_CliptoBrain.nii.gz \
	-e BetaY2_${subj}_cond2_Unmasked_oxy_ND_To_Atlas_CliptoBrain.nii.gz \
	-f BetaY2_${subj}_cond3_Unmasked_oxy_ND_To_Atlas_CliptoBrain.nii.gz -expr 'ispositive(abs(a)+abs(b)+abs(c)+abs(d)+abs(e)+abs(f))' -prefix NIRS_Mask.nii

done


subjlist='06IND014B 06IND016G 06IND045G 06IND047B 06IND066B 06IND073B 06IND118G 06IND120G 06IND121B 06IND131B 06IND132B 06IND137G 06IND142B 06IND144B 06IND156B 06IND160B 06IND161G 06IND168B 06IND170B 06IND172G 06IND203G 06IND204B 06IND206B 06IND211G 06IND215G'
subjlist+=' 06IND217B 06IND227G 06IND256G 06IND262B 06IND271G 06IND277B 06IND279G 06IND301G 06IND303B 06IND311B 06IND321G 06IND322G 06IND327G 06IND328G 06IND334B 06IND335B 06IND336B 06IND337G 06IND355G 06IND356G 06IND361B 06IND374B 06IND387B 09IND039G 09IND060B 09IND082G'
subjlist+=' 09IND106B 09IND109B 09IND110G 09IND114B 09IND116B 09IND119B 09IND133G 09IND136B 09IND151G 09IND152G 09IND154G 09IND157G 09IND167G 09IND201B 09IND202B 09IND209B 09IND210B 09IND213B 09IND216G 09IND218G 09IND240G 09IND249G 09IND252G 09IND261B 09IND265G 09IND269B'
subjlist+=' 09IND270G 09IND273G 09IND302B 09IND304B 09IND312B 09IND314G 09IND315B 09IND357B 09IND358G 09IND363B 09IND365B 09IND369B 09IND370G 09IND371G 09IND377B 09IND384B 09IND385B 09IND386G 09IND390B' 


for subj in $subjlist
do

3dcalc -a BetaY1_${subj}_cond1_Unmasked_oxy_To_Atlas_CliptoBrain.nii.gz \
	-b BetaY1_${subj}_cond2_Unmasked_oxy_To_Atlas_CliptoBrain.nii.gz \
	-c BetaY1_${subj}_cond3_Unmasked_oxy_To_Atlas_CliptoBrain.nii.gz \
	-d BetaY2_${subj}_cond1_Unmasked_oxy_To_Atlas_CliptoBrain.nii.gz \
	-e BetaY2_${subj}_cond2_Unmasked_oxy_To_Atlas_CliptoBrain.nii.gz \
	-f BetaY2_${subj}_cond3_Unmasked_oxy_To_Atlas_CliptoBrain.nii.gz \
	-g NIRS_Mask.nii -expr 'ispositive(abs(a)+abs(b)+abs(c)+abs(d)+abs(e)+abs(f))+g' -prefix NIRS_Mask_Temp.nii
	
rm NIRS_Mask.nii
mv NIRS_Mask_Temp.nii NIRS_Mask.nii

done

#keep voxels with 60% or greater participants contributing...97*.6 = 58.2
3dcalc -a NIRS_Mask.nii -expr 'ispositive(a-58)' -prefix NIRS_Mask60.nii