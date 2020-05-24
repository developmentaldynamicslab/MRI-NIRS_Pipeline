#!/bin/bash

mypwd=/media/sw57/DRIVE10/India_Gates/MCs/6mo

subjlist='06IND387B' 


#06IND001B 06IND003G 06IND006B 06IND007G 06IND012B 06IND014B 06IND016G 06IND017B 06IND026B 06IND027G 06IND028G 06IND030G 06IND033B 06IND036B 06IND040B 06IND045G 06IND047B 06IND049G 06IND063G 06IND064G 06IND066B 06IND067B 06IND071B 06IND073B 06IND076G 06IND077G 06IND078G 06IND080G 06IND081G 06IND083G 06IND084B 06IND103B 06IND107B 06IND108G 06IND118G 06IND120G 06IND121B 06IND125G 06IND130B 06IND131B 06IND132B 06IND137G 06IND142B 06IND144B 06IND149G 06IND150B 06IND156B 06IND160B 06IND161G 06IND163B 06IND164B 06IND165G 06IND166B 06IND168B 06IND170B 06IND172G 06IND203G 06IND204B 06IND205G 06IND206B 06IND207B 06IND211G 06IND212G 06IND215G 06IND217B 06IND220G 06IND222B 06IND223B 06IND227G 06IND230B 06IND235G 06IND239G 06IND243B 06IND245G 06IND250B 06IND255G 06IND256G 06IND260G 06IND262B 06IND266B 06IND267B 06IND271G 06IND276G 06IND277B 06IND278G 06IND279G 06IND280B 06IND282G 06IND300G 06IND301G 06IND303B 06IND305B 06IND306G 06IND309G 06IND310B 06IND311B 06IND318G 06IND321G 06IND322G 06IND323G 06IND325B 06IND327G 06IND328G 06IND330B 06IND334B 06IND335B 06IND336B 06IND337G 06IND344G 06IND345B 06IND353B 06IND354B 06IND355G 06IND356G 06IND360B 06IND361B 06IND368G 06IND374B 06IND375G 06IND378G 06IND387B' 

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
