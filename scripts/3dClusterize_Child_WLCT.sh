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

effectlist='6Hb 7AgexHb'

mkdir Child_WLCT/0.01

let "COUNTER=5"
echo ${COUNTER}

let "COUNTER2=21"

for effect in $effectlist
do

mkdir Child_WLCT/0.01/${effect}

let "COUNTER++"
let "COUNTER2++"
echo ${COUNTER}
echo ${COUNTER2}

3dclusterize -inset HWB_Child_WLCT+orig \
	-ithr ${COUNTER} \
	-mask NIRS_Mask70.nii \
	-NN 1 \
	-1sided RIGHT_TAIL 7.4073 \
	-clust_nvox 329 \
	-pref_map Child_WLCT/0.01/${effect}/clust_order_${effect}_l1_01.nii \
 	> Child_WLCT/0.01/${effect}/${effect}_l1_01.1D


3dROIstats -mask Child_WLCT/0.01/${effect}/clust_order_${effect}_l1_01.nii HWB_Child_WLCT+orig"[$COUNTER2]" > \
	Child_WLCT/0.01/${effect}/${effect}_l1_01_ges.1D

cp T1_RAS.nii Child_WLCT/0.01//${effect}/
cp 32HWB036_T1_to_Atlas.nii.gz Child_WLCT/0.01/${effect}/

done


effectlist='10LearnedxHb 11AgexLearnedxHb 12PhasexHb 13AgexPhasexHb 14LearnedxPhasexHb 15AgexLearnedxPhasexHb'


let "COUNTER=9"
echo ${COUNTER}

let "COUNTER2=25"

for effect in $effectlist
do

mkdir Child_WLCT/0.01/${effect}

let "COUNTER++"
let "COUNTER2++"
echo ${COUNTER}
echo ${COUNTER2}

3dclusterize -inset HWB_Child_WLCT+orig \
	-ithr ${COUNTER} \
	-mask NIRS_Mask70.nii \
	-NN 1 \
	-1sided RIGHT_TAIL 7.4073 \
	-clust_nvox 329 \
	-pref_map Child_WLCT/0.01/${effect}/clust_order_${effect}_l1_01.nii \
 	> Child_WLCT/0.01/${effect}/${effect}_l1_01.1D


3dROIstats -mask Child_WLCT/0.01/${effect}/clust_order_${effect}_l1_01.nii HWB_Child_WLCT+orig"[$COUNTER2]" > \
	Child_WLCT/0.01/${effect}/${effect}_l1_01_ges.1D

whereami -coord_file Child_WLCT/0.01/${effect}/${effect}_l1_01.1D'[13,14,15]' -tab -space MNI > Child_WLCT/0.01/${effect}/${effect}_l1_01_wai.1D

cp T1_RAS.nii Child_WLCT/0.01//${effect}/
cp 32HWB036_T1_to_Atlas.nii.gz Child_WLCT/0.01/${effect}/

done






