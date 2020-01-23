#!/bin/bash

#4mo: S385 S395 S398 S402 S409 S416 S430 S439 S461 S462 S464 S467 S468 S470 S486 S510
#1yo: S327 S331 S335 S356 S361 S396 S403 S437 S438 S447 S466 S473 S480 S483 S489 S503 S505 S513 S519
#2yo: S311 S315 S321 S322 S323 S330 S336 S345 S348 S355 S357 S360 S369 S387 S408 S411 S414 S423 S426 S440 S442 S453 


subjlist='S385 S395 S398 S402 S409 S416 S430 S439 S461 S462 S464 S467 S468 S470 S486 S510'

cd /Users/nfb15zpu/Documents/J-Files/Papers/NIRS_Gates_PL/Analysis2020/4mo/ImageReconstructions

for subj in $subjlist
do

3dTcat MNI_${subj}_cond1_Masked_Ted_oxy.nii MNI_${subj}_cond1_Masked_Ted_deoxy.nii \
	MNI_${subj}_cond2_Masked_Ted_oxy.nii MNI_${subj}_cond2_Masked_Ted_deoxy.nii \
	MNI_${subj}_cond3_Masked_Ted_oxy.nii MNI_${subj}_cond3_Masked_Ted_deoxy.nii \
	-prefix /Users/nfb15zpu/Documents/J-Files/Papers/NIRS_Gates_PL/Analysis2020/Infants_cPL_gesConHb2/Concat_4mo_${subj}.nii -verb

done

subjlist='S327 S331 S335 S356 S361 S396 S403 S437 S438 S447 S466 S473 S480 S483 S489 S503 S505 S513 S519'

cd /Users/nfb15zpu/Documents/J-Files/Papers/NIRS_Gates_PL/Analysis2020/1yo/ImageReconstructions

for subj in $subjlist
do

3dTcat MNI_${subj}_cond1_Masked_Ted_oxy.nii MNI_${subj}_cond1_Masked_Ted_deoxy.nii \
	MNI_${subj}_cond2_Masked_Ted_oxy.nii MNI_${subj}_cond2_Masked_Ted_deoxy.nii \
	MNI_${subj}_cond3_Masked_Ted_oxy.nii MNI_${subj}_cond3_Masked_Ted_deoxy.nii \
	-prefix /Users/nfb15zpu/Documents/J-Files/Papers/NIRS_Gates_PL/Analysis2020/Infants_cPL_gesConHb2/Concat_1yo_${subj}.nii -verb

done

subjlist='S311 S315 S321 S322 S323 S330 S336 S345 S348 S355 S357 S360 S369 S387 S408 S411 S414 S423 S426 S440 S442 S453'

cd /Users/nfb15zpu/Documents/J-Files/Papers/NIRS_Gates_PL/Analysis2020/2yo/ImageReconstructions

for subj in $subjlist
do

3dTcat MNI_${subj}_cond1_Masked_Ted_oxy.nii MNI_${subj}_cond1_Masked_Ted_deoxy.nii \
	MNI_${subj}_cond2_Masked_Ted_oxy.nii MNI_${subj}_cond2_Masked_Ted_deoxy.nii \
	MNI_${subj}_cond3_Masked_Ted_oxy.nii MNI_${subj}_cond3_Masked_Ted_deoxy.nii \
	-prefix /Users/nfb15zpu/Documents/J-Files/Papers/NIRS_Gates_PL/Analysis2020/Infants_cPL_gesConHb2/Concat_2yo_${subj}.nii -verb

done
