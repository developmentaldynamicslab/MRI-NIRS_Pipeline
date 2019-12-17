#F crit values from afni...
#1-7: 6.9135
#8-11: 4.7325
#12-15: 6.9135
#16-19: 4.7325
#20-23: 6.9135
#24-31: 4.7325

#computed NIRS_Mask60 and applying to ANOVA results...
#3dcalc -a LONGVWManova+orig -b NIRS_Mask60.nii -expr 'a*b' -prefix LONGVWManovaMASK+orig

effectlist='12Chrom 13GenderxChrom 14SESxChrom 15GenderxSESxChrom 16 17 18 19 20YearxChrom 21GenderxYearxChrom 22SESxYearxChrom 23GenderxSESxYearxChrom'

mkdir 0.01

let "COUNTER=11"
echo ${COUNTER}

for effect in $effectlist
do

mkdir 0.01/${effect}

let "COUNTER++"
echo ${COUNTER}

3dclust -prefix LongANOVA/0.01/${effect}/${effect}_l1_01.nii -noabs -1thresh 6.9135 3 -8 LONGVWManovaMASK+orig"[${COUNTER}]" > 0.01/${effect}/${effect}_l1_01.1D
3dmerge -1clust_order 3 -8 -1thresh 6.9135 -prefix 0.01/${effect}/clust_order_${effect}_l1_01.nii LONGVWManovaMASK+orig"[${COUNTER}]"
cp indiaOveralltemplate_scale2mm.nii.gz /Users/nfb15zpu/Documents/J-Files/Grants/Grant_GatesFoundation_Phase2/AnalysisOct2019/Long_ANOVA/0.01/${effect}/

done

effectlist='24CondxChrom 25GenderxCondxChrom 26SESxCondxChrom 27GenderxSESxCondxChrom 28YearxCondxChrom 29GenderxYearxCondxChrom 30SESxYearxCondxChrom 31GenderxSESxYearxCondxChrom'

let "COUNTER=23"
echo ${COUNTER}

for effect in $effectlist
do

mkdir 0.01/${effect}

let "COUNTER++"
echo ${COUNTER}

3dclust -prefix LongANOVA/0.01/${effect}/${effect}_l1_01.nii -noabs -1thresh 4.7325 3 -8 LONGVWManovaMASK+orig"[${COUNTER}]" > 0.01/${effect}/${effect}_l1_01.1D
3dmerge -1clust_order 3 -8 -1thresh 4.7325 -prefix 0.01/${effect}/clust_order_${effect}_l1_01.nii LONGVWManovaMASK+orig"[${COUNTER}]"
cp indiaOveralltemplate_scale2mm.nii.gz /Users/nfb15zpu/Documents/J-Files/Grants/Grant_GatesFoundation_Phase2/AnalysisOct2019/Long_ANOVA/0.01/${effect}/

done


