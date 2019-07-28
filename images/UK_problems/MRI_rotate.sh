subjlist='001b'
for subj in $subjlist
do

  cd  /Volumes/PegasusDDLab/VWMseg/001/
  #use the below iff the rotation is too far off what we expect Vince's script to fix:
  3drotate  -ashift 0 -8 0 -rotate 0 0 -78 -linear -zpad 200 -noclip -prefix ${subj}_neurologicalHighRes3.nii ${subj}_neurologicalHighRes_orig.nii 
  #fslorient -deleteorient ${subj}_neurologicalHighRes_orig2.nii
  #fslswapdim S R P ${subj}_neurologicalHighRes_orig2.niifslorient -setqformcode 1
  #fslswapdim ${subj}_neurologicalHighRes_orig.nii -z y x ${subj}_neurologicalHighRes3.nii
  #To deoblique:
  #3dWarp -deoblique ${subj}_neurologicalHighRes.nii
  #3rd dimension to mod head diag
done
