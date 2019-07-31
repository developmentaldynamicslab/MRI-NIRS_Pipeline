#!/bin/bash

namelist='s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12 s13 s14 s15 s16 d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 d16 d17 d18 d19 d20 d21 d22 d23 d24 d25 d26 d27 d28 d29 d30 d31 d32' 
subjlist='MCinput'
wavelist='fw1 fw2'
for subj in $subjlist

do

for name in $namelist

do

for wave in $wavelist

do

cd /gpfs/home/amz15eku/NIHNIRS/ToGo/${subj}/fw/

sed -i -e "s/Users\/lourdesmarielle\/Desktop\/MR\/nih30\/TemplateTest\/MCinput/gpfs\/home\/amz15eku\/NIHNIRS\/ToGo\/${subj}/"  ${wave}.${name}.inp



#sed -i -e 's/06142\///' ${wave}.${name}.inp
#sed -i -e "s/2yoOld/${subj}/" fw1.${name}.inp 

#mv fw1.${name}.inp fw1.${name}.inp

done

done

done
