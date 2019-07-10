#!/bin/bash
subjlist='06IND003G'
for subj in $subjlist
do

  cd  /Volumes/PegasusDDLab/Pipeline/

  mkdir -p /Volumes/PegasusDDLab/Pipeline/${subj}/

  bash autoSegment20190428.sh -t /Volumes/PegasusDDLab/Pipeline/${subj}_neurologicalHighRes.nii -o /Volumes/PegasusDDLab/Pipeline/${subj}/ -s 0.5 -c 3 -b -m

done
