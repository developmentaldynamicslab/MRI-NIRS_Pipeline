#!/bin/bash

mypwd=/Volumes/DRIVE10/India_Gates/MCs/9mo

subjlist='09IND389B'

#09IND002B 09IND004G 09IND011B 09IND013B 09IND023B 09IND035B 09IND050B 09IND052G 09IND058G 09IND059G 09IND061G 09IND062G 09IND079G 09IND102G 09IND104B 09IND115B 09IND122B 09IND139B 09IND153G 09IND176G 09IND214B 09IND226G 09IND238B 09IND244B 09IND246B 09IND257B 09IND268G 09IND308B 09IND313G 09IND316B 09IND332G 09IND342B 09IND362B 09IND364B 09IND380G 09IND383G 09IND389B 09IND005G 09IND015G 09IND024G 09IND025B 09IND029G 09IND031G 09IND032B 09IND038G 09IND039G 09IND046G 09IND051B 09IND053G 09IND054G 09IND060B 09IND070B 09IND072B 09IND082G 09IND106B 09IND109B 09IND110G 09IND114B 09IND136B 09IND151G 09IND157G 09IND159G 09IND167G 09IND175G 09IND201B 09IND202B 09IND209B 09IND210B 09IND213B 09IND216G 09IND218G 09IND240G 09IND241B 09IND247B 09IND249G 09IND252G 09IND253B 09IND261B 09IND265G 09IND269B 09IND270G 09IND272G 09IND273G 09IND275G 09IND302B 09IND304B 09IND312B 09IND314G 09IND315B 09IND350G 09IND357B 09IND358G 09IND363B 09IND365B 09IND369B 09IND370G 09IND371G 09IND372B 09IND377B 09IND382B 09IND384B 09IND385B 09IND386G 09IND390B 09IND037G 09IND116B 09IND119B 09IND126G 09IND127B 09IND133G 09IND138G 09IND141G 09IND152G 09IND154G'

chanlist='1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36'


for sub in $subjlist
do

cd ${mypwd}/${sub}/digitization2/viewer/Subject

3dcalc -a AdotVol_S1_D1_C1.nii -expr  'a*astep(a,0.0001)'  -prefix A1.nii
3dcalc -a  AdotVol_S1_D2_C2.nii -expr  'a*astep(a,0.0001)'  -prefix A2.nii
3dcalc -a  AdotVol_S2_D1_C3.nii -expr  'a*astep(a,0.0001)'  -prefix A3.nii
3dcalc -a  AdotVol_S2_D3_C4.nii -expr  'a*astep(a,0.0001)'  -prefix A4.nii
3dcalc -a  AdotVol_S2_D4_C5.nii -expr  'a*astep(a,0.0001)'  -prefix A5.nii
3dcalc -a  AdotVol_S3_D1_C6.nii -expr  'a*astep(a,0.0001)'  -prefix A6.nii
3dcalc -a  AdotVol_S3_D2_C7.nii -expr  'a*astep(a,0.0001)'  -prefix A7.nii
3dcalc -a  AdotVol_S3_D4_C8.nii -expr  'a*astep(a,0.0001)'  -prefix A8.nii
3dcalc -a  AdotVol_S3_D5_C9.nii -expr  'a*astep(a,0.0001)'  -prefix A9.nii
3dcalc -a  AdotVol_S4_D6_C10.nii -expr  'a*astep(a,0.0001)'  -prefix A10.nii
3dcalc -a  AdotVol_S4_D7_C11.nii -expr  'a*astep(a,0.0001)'  -prefix A11.nii
3dcalc -a  AdotVol_S5_D6_C12.nii -expr  'a*astep(a,0.0001)'  -prefix A12.nii
3dcalc -a  AdotVol_S5_D8_C13.nii -expr  'a*astep(a,0.0001)'  -prefix A13.nii
3dcalc -a  AdotVol_S5_D9_C14.nii -expr  'a*astep(a,0.0001)'  -prefix A14.nii
3dcalc -a  AdotVol_S6_D6_C15.nii -expr  'a*astep(a,0.0001)'  -prefix A15.nii
3dcalc -a  AdotVol_S6_D7_C16.nii -expr  'a*astep(a,0.0001)'  -prefix A16.nii
3dcalc -a  AdotVol_S6_D9_C17.nii -expr  'a*astep(a,0.0001)'  -prefix A17.nii
3dcalc -a  AdotVol_S6_D10_C18.nii -expr  'a*astep(a,0.0001)'  -prefix A18.nii
3dcalc -a  AdotVol_S7_D12_C19.nii -expr  'a*astep(a,0.0001)'  -prefix A19.nii
3dcalc -a  AdotVol_S7_D13_C20.nii -expr  'a*astep(a,0.0001)'  -prefix A20.nii
3dcalc -a  AdotVol_S7_D14_C21.nii -expr  'a*astep(a,0.0001)'  -prefix A21.nii
3dcalc -a  AdotVol_S7_D15_C22.nii -expr  'a*astep(a,0.0001)'  -prefix A22.nii
3dcalc -a  AdotVol_S8_D11_C23.nii -expr  'a*astep(a,0.0001)'  -prefix A23.nii
3dcalc -a  AdotVol_S8_D12_C24.nii -expr  'a*astep(a,0.0001)'  -prefix A24.nii
3dcalc -a  AdotVol_S8_D13_C25.nii -expr  'a*astep(a,0.0001)'  -prefix A25.nii
3dcalc -a  AdotVol_S9_D14_C26.nii -expr  'a*astep(a,0.0001)'  -prefix A26.nii
3dcalc -a  AdotVol_S9_D15_C27.nii -expr  'a*astep(a,0.0001)'  -prefix A27.nii
3dcalc -a  AdotVol_S10_D18_C28.nii -expr  'a*astep(a,0.0001)'  -prefix A28.nii
3dcalc -a  AdotVol_S10_D19_C29.nii -expr  'a*astep(a,0.0001)'  -prefix A29.nii
3dcalc -a  AdotVol_S10_D20_C30.nii -expr  'a*astep(a,0.0001)'  -prefix A30.nii
3dcalc -a  AdotVol_S11_D16_C31.nii -expr  'a*astep(a,0.0001)'  -prefix A31.nii
3dcalc -a  AdotVol_S11_D17_C32.nii -expr  'a*astep(a,0.0001)'  -prefix A32.nii
3dcalc -a  AdotVol_S12_D16_C33.nii -expr  'a*astep(a,0.0001)'  -prefix A33.nii
3dcalc -a  AdotVol_S12_D17_C34.nii -expr  'a*astep(a,0.0001)'  -prefix A34.nii
3dcalc -a  AdotVol_S12_D19_C35.nii -expr  'a*astep(a,0.0001)'  -prefix A35.nii
3dcalc -a  AdotVol_S12_D20_C36.nii -expr  'a*astep(a,0.0001)'  -prefix A36.nii

for chan in $chanlist
do

3dresample -dxyz 2 2 2 -prefix A${chan}_resam.nii -input A${chan}.nii


done

done
