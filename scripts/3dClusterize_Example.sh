#fcrit values from AFNI along with sub-brick []
#Hb [4] 7.1193 – 4 clusters
#Age x Hb [5] 5.0205 – 3 clusters
#SS x Hb wMVT [10]  5.0205 – 0 clusters
#Age x SS x Hb [11] 3.4979 – 1 cluster
#GLT-contrasts: 2.6749
#--Hb_Age1v2 [21] – 4 clusters (3 4mo>1yo; 1 1yo>4mo)
#--Hb_Age2v3 [23]– 1 cluster (1yo > 2yo)
#--Hb_SS1v2 [25]– 0 clusters
#--Hb_SS2v3 [27]– 1 cluster (SS med > SS high)
#ges Hb [16] AgexHb [17] SSxHb [18] AgexSSxHb [19]

effectlist='4Hb'

mkdir Infants_cPL_gesConHb3/0.01

let "COUNTER=3"
echo ${COUNTER}

for effect in $effectlist
do

mkdir Infants_cPL_gesConHb3/0.01/${effect}

let "COUNTER++"
echo ${COUNTER}

3dclusterize -inset GatesPLAgeSSHb_gesConHb3+tlrc \
	-ithr ${COUNTER} \
	-mask NIRS_Mask60.nii \
	-NN 1 \
	-bisided p=0.01 \
	-clust_nvox 98 \
	-pref_map Infants_cPL_gesConHb3/0.01/${effect}/clust_order_${effect}_l1_01.nii \
 	> Infants_cPL_gesConHb3/0.01/${effect}/${effect}_l1_01.1D


3dROIstats -mask Infants_cPL_gesConHb3/0.01/${effect}/clust_order_${effect}_l1_01.nii GatesPLAgeSSHb_gesConHb3+tlrc'[16]' > \
Infants_cPL_gesConHb3/0.01/${effect}/${effect}_l1_01_ges.1D

whereami -coord_file Infants_cPL_gesConHb3/0.01/${effect}/${effect}_l1_01.1D'[13,14,15]' -tab -space MNI > Infants_cPL_gesConHb3/0.01/${effect}/${effect}_l1_01_wai.1D
cp MNI_avg152T1+tlrc.BRIK Infants_cPL_gesConHb3/0.01/${effect}/
cp MNI_avg152T1+tlrc.HEAD Infants_cPL_gesConHb3/0.01/${effect}/

done


effectlist='5AgexHb'

let "COUNTER=4"
echo ${COUNTER}

for effect in $effectlist
do

mkdir Infants_cPL_gesConHb3/0.01/${effect}

let "COUNTER++"
echo ${COUNTER}

3dclust -prefix Infants_cPL_gesConHb3/0.01/${effect}/${effect}_l1_01.nii -noabs -1thresh 5.0205 -NN1 98 GatesPLAgeSSHb_gesConHb3+tlrc"[${COUNTER}]" > Infants_cPL_gesConHb3/0.01/${effect}/${effect}_l1_01.1D
3dmerge -1clust_order 2 784 -1thresh 5.0205 -prefix Infants_cPL_gesConHb3/0.01/${effect}/clust_order_${effect}_l1_01.nii GatesPLAgeSSHb_gesConHb3+tlrc"[${COUNTER}]"

3dROIstats -mask Infants_cPL_gesConHb3/0.01/${effect}/clust_order_${effect}_l1_01.nii GatesPLAgeSSHb_gesConHb3+tlrc'[17]' > \
Infants_cPL_gesConHb3/0.01/${effect}/${effect}_l1_01_ges.1D

whereami -coord_file Infants_cPL_gesConHb3/0.01/${effect}/${effect}_l1_01.1D'[13,14,15]' -tab -space MNI > Infants_cPL_gesConHb3/0.01/${effect}/${effect}_l1_01_wai.1D
cp MNI_avg152T1+tlrc.BRIK Infants_cPL_gesConHb3/0.01/${effect}/
cp MNI_avg152T1+tlrc.HEAD Infants_cPL_gesConHb3/0.01/${effect}/

done


effectlist='10SSxHb'

let "COUNTER=9"
echo ${COUNTER}

for effect in $effectlist
do

mkdir Infants_cPL_gesConHb3/0.01/${effect}

let "COUNTER++"
echo ${COUNTER}

3dclust -prefix Infants_cPL_gesConHb3/0.01/${effect}/${effect}_l1_01.nii -noabs -1thresh 5.0205 -NN1 98 GatesPLAgeSSHb_gesConHb3+tlrc"[${COUNTER}]" > Infants_cPL_gesConHb3/0.01/${effect}/${effect}_l1_01.1D
3dmerge -1clust_order 2 784 -1thresh 5.0205 -prefix Infants_cPL_gesConHb3/0.01/${effect}/clust_order_${effect}_l1_01.nii GatesPLAgeSSHb_gesConHb3+tlrc"[${COUNTER}]"

3dROIstats -mask Infants_cPL_gesConHb3/0.01/${effect}/clust_order_${effect}_l1_01.nii GatesPLAgeSSHb_gesConHb3+tlrc'[18]' > \
Infants_cPL_gesConHb3/0.01/${effect}/${effect}_l1_01_ges.1D

whereami -coord_file Infants_cPL_gesConHb3/0.01/${effect}/${effect}_l1_01.1D'[13,14,15]' -tab -space MNI > Infants_cPL_gesConHb3/0.01/${effect}/${effect}_l1_01_wai.1D
cp MNI_avg152T1+tlrc.BRIK Infants_cPL_gesConHb3/0.01/${effect}/
cp MNI_avg152T1+tlrc.HEAD Infants_cPL_gesConHb3/0.01/${effect}/

done


effectlist='11AgexSSxHb'

let "COUNTER=10"
echo ${COUNTER}

for effect in $effectlist
do

mkdir Infants_cPL_gesConHb3/0.01/${effect}

let "COUNTER++"
echo ${COUNTER}

3dclust -prefix Infants_cPL_gesConHb3/0.01/${effect}/${effect}_l1_01.nii -noabs -1thresh 3.4979 -NN1 98 GatesPLAgeSSHb_gesConHb3+tlrc"[${COUNTER}]" > Infants_cPL_gesConHb3/0.01/${effect}/${effect}_l1_01.1D
3dmerge -1clust_order 2 784 -1thresh 3.4979 -prefix Infants_cPL_gesConHb3/0.01/${effect}/clust_order_${effect}_l1_01.nii GatesPLAgeSSHb_gesConHb3+tlrc"[${COUNTER}]"

3dROIstats -mask Infants_cPL_gesConHb3/0.01/${effect}/clust_order_${effect}_l1_01.nii GatesPLAgeSSHb_gesConHb3+tlrc'[19]' > \
Infants_cPL_gesConHb3/0.01/${effect}/${effect}_l1_01_ges.1D

whereami -coord_file Infants_cPL_gesConHb3/0.01/${effect}/${effect}_l1_01.1D'[13,14,15]' -tab -space MNI > Infants_cPL_gesConHb3/0.01/${effect}/${effect}_l1_01_wai.1D
cp MNI_avg152T1+tlrc.BRIK Infants_cPL_gesConHb3/0.01/${effect}/
cp MNI_avg152T1+tlrc.HEAD Infants_cPL_gesConHb3/0.01/${effect}/

done


effectlist='21Hb_Age1v2 23Hb_Age2v3 25Hb_SS1v2 27Hb_SS2v3'

let "COUNTER=19"
echo ${COUNTER}

for effect in $effectlist
do

mkdir Infants_cPL_gesConHb3/0.01/${effect}

let "COUNTER++"
let "COUNTER++"
echo ${COUNTER}

3dclust -prefix Infants_cPL_gesConHb3/0.01/${effect}/${effect}_l1_01.nii -noabs -1thresh 2.6749 -NN1 98 GatesPLAgeSSHb_gesConHb3+tlrc"[${COUNTER}]" > Infants_cPL_gesConHb3/0.01/${effect}/${effect}_l1_01.1D
3dmerge -1clust_order 2 784 -1thresh 2.6749 -prefix Infants_cPL_gesConHb3/0.01/${effect}/clust_order_${effect}_l1_01.nii GatesPLAgeSSHb_gesConHb3+tlrc"[${COUNTER}]"

whereami -coord_file Infants_cPL_gesConHb3/0.01/${effect}/${effect}_l1_01.1D'[13,14,15]' -tab -space MNI > Infants_cPL_gesConHb3/0.01/${effect}/${effect}_l1_01_wai.1D
cp MNI_avg152T1+tlrc.BRIK Infants_cPL_gesConHb3/0.01/${effect}/
cp MNI_avg152T1+tlrc.HEAD Infants_cPL_gesConHb3/0.01/${effect}/

done






