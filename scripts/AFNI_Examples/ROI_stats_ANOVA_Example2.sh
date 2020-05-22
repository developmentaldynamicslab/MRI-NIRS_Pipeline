#!/bin/bash

regionlist='4Hb 5AgexHb 10SSxHb 11AgexSSxHb 21Hb_Age1v2 23Hb_Age2v3 25Hb_SS1v2 27Hb_SS2v3'


subjlist='S385 S395 S398 S402 S409 S416 S430 S439 S461 S462 S464 S467 S468 S470 S486 S510'

for region in $regionlist
do

mkdir Infants_cPL_gesConHb3/0.01/${region}/ROIstats/

for names in $subjlist
do

3dROIstats -mask Infants_cPL_gesConHb3/0.01/${region}/clust_order_${region}_l1_01.nii Infants_cPL_gesConHb3/Concat_4mo_${names}.nii'[0,1,2,3,4,5]' > \
Infants_cPL_gesConHb3/0.01/${region}/ROIstats/${region}_4mo_${names}.1D

done
done


subjlist='S327 S331 S335 S356 S361 S396 S403 S437 S438 S447 S466 S473 S480 S483 S489 S503 S505 S513 S519'

for region in $regionlist
do

mkdir Infants_cPL_gesConHb3/0.01/${region}/ROIstats/

for names in $subjlist
do

3dROIstats -mask Infants_cPL_gesConHb3/0.01/${region}/clust_order_${region}_l1_01.nii Infants_cPL_gesConHb3/Concat_1yo_${names}.nii'[0,1,2,3,4,5]' > \
Infants_cPL_gesConHb3/0.01/${region}/ROIstats/${region}_1yo_${names}.1D

done
done


subjlist='S311 S315 S321 S322 S323 S330 S336 S345 S348 S355 S357 S360 S369 S387 S408 S411 S414 S423 S426 S440 S442 S453'

for region in $regionlist
do

mkdir Infants_cPL_gesConHb3/0.01/${region}/ROIstats/

for names in $subjlist
do

3dROIstats -mask Infants_cPL_gesConHb3/0.01/${region}/clust_order_${region}_l1_01.nii Infants_cPL_gesConHb3/Concat_2yo_${names}.nii'[0,1,2,3,4,5]' > \
Infants_cPL_gesConHb3/0.01/${region}/ROIstats/${region}_2yo_${names}.1D

done
done


