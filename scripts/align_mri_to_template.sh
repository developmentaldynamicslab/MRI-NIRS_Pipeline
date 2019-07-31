
subjlist=''

for subj in $subjlist
do

  3dresample -input ${subj}_neurologicalHighRes2.nii -orient rpi -prefix ${subj}_neurologicalHighRes_rpi.nii


  3dAllineate -base  ../06monthTemplate_rot.nii -1Dmatrix_save ${subj}_brain_orient_alignT2 -input ${subj}_neurologicalHighRes_rpi.nii -warp shift_rotate_scale -cost mi

  3dAllineate -master ../06monthTemplate_rot.nii -1Dmatrix_apply ${subj}_brain_orient_alignT2.aff12.1D -input ${subj}_neurologicalHighRes_rpi.nii -final linear -mast_dxyz 1.0 -prefix ${subj}_NRH2temp_1mm.nii

done
