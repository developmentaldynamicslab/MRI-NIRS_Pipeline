#!/bin/bash


subjlist='06IND001B	06IND003G	06IND006B	06IND007G	06IND012B	06IND014B	06IND016G	06IND027G	06IND030G	06IND045G	06IND047B	06IND049G	06IND066B	06IND071B	06IND073B	06IND107B	06IND118G	06IND120G	06IND121B	06IND130B	06IND131B	06IND132B	06IND142B	06IND149G	06IND156B	06IND160B	06IND161G	06IND163B	06IND164B	06IND168B	06IND170B	06IND172G	06IND203G	06IND204B	06IND206B	06IND207B	06IND211G	06IND215G	06IND217B	06IND223B	06IND227G	06IND230B	06IND243B	06IND256G	06IND260G	06IND262B	06IND271G	06IND277B	06IND279G	06IND303B	06IND311B	06IND321G	06IND322G	06IND325B	06IND327G	06IND328G	06IND335B	06IND336B	06IND337G	06IND353B	06IND355G	06IND360B	06IND361B	06IND374B	09IND031G	09IND037G	09IND038G	09IND039G	09IND046G	09IND051B	09IND054G	09IND060B	09IND070B	09IND072B	09IND082G	09IND106B	09IND109B	09IND110G	09IND114B	09IND116B	09IND119B	09IND126G	09IND127B	09IND133G	09IND136B	09IND138G	09IND141G	09IND151G	09IND154G	09IND157G	09IND159G	09IND167G	09IND175G	09IND201B	09IND202B	09IND210B	09IND213B	09IND216G	09IND218G	09IND240G	09IND247B	09IND249G	09IND252G	09IND265G	09IND269B	09IND270G	09IND273G	09IND275G	09IND302B	09IND304B	09IND312B	09IND357B	09IND358G	09IND363B	09IND365B	09IND369B	09IND370G	09IND371G	09IND372B	09IND377B	09IND384B	09IND385B	09IND386G	09IND390B'


condlist='cond1 cond2 cond3'

triallist='Load'

chromlist='oxy'

for sub in $subjlist
do

for cond in $condlist
do

for chrom in $chromlist
do

for trial in $triallist
do

cd /media/sw57/MAXTOR/India-gates/ICs/Final

3dresample -dxyz 1 1 1 -prefix R_${sub}_${trial}_${sub}_${cond}_Unmasked_${chrom}_To_Atlas1mm.nii -input ${sub}_${trial}_${sub}_${cond}_Unmasked_${chrom}_To_Atlas.nii

done

done

done

done