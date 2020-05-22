subjlist=''
for subj in $subjlist
do

  cd  /Volumes/PegasusDDLab/VWMseg/30moSeg
  #use the below iff the rotation is too far off what we expect Vince's script to fix:
  3drotate -ashift 0 -8 0 -rotate 0 0 -78 -zpad 256 -prefix ${subj}_neurologicalHighRes2.nii ${subj}_neurologicalHighRes.nii
  #To deoblique:
done
