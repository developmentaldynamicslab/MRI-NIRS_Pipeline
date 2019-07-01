function AVfwVol2AnatNii(fwHeadVolFile, anatHeadVol, niiFile)
% AVfwVol2AnatNii(fwHeadVolFile,anatHeadVol, niiFile)
%   Converts an image from the AtlasViewer Forward Model Coordinate
%   system back to subject space and will save the image as a
%   NIFTI image. The anatomical Head vol image is also required
%   since the offset for the image origin is calculated using this
%   information.
%


% Read the Forward Model Vox file using the tools provided in AtlasViewer
fwVox=load_vox( fwHeadVolFile );

% Resample the image back to subject space
T_2mcInv =  inv(fwVox.T_2digpts);
resampleImage = xform_apply_vol_smooth(fwVox.img, T_2mcInv);

% Convert the resampled image to NIFTI - The image orientation and origin
% are updated below
spacing=[abs(fwVox.T_2ras(1,1)),abs(fwVox.T_2ras(2,2)),abs(fwVox.T_2ras(3,3))];
origin=size(fwVox.img)/2;
datatype=2;
description='VoxToNii';
nii = make_nii(resampleImage,spacing,origin,datatype,description);


% Read the Anatomical Vox file using the tools provided in AtlasViewer
anatVox=load_vox( anatHeadVol );

% Now the image is back in subject space - Use the T_2ras transform to
% get the orientation correct. Origin needs to be updated since AtlasViewer
% changes the image dimensions and this needs to be taken into account.
origDims = size(anatVox.img);
newDims  = size(resampleImage);
offsetx = (newDims(1) - origDims(1)) / 2.0 * spacing(1);
offsety = (newDims(2) - origDims(2)) / 2.0 * spacing(2);
offsetz = (newDims(3) - origDims(3)) / 2.0 * spacing(3);

% Now determine the direction of the shift based on the image orientation
if (fwVox.T_2ras(1,1) < 0.0)
  signX = -1.0;
else
  signX = 1.0;
end
if (fwVox.T_2ras(2,2) < 0.0)
  signY = -1.0;
else
  signY = 1.0;
end
if (fwVox.T_2ras(3,3) < 0.0)
  signZ = -1.0;
else
  signZ = 1.0;
end
nii.hdr.hist.srow_x=[fwVox.T_2ras(1,1),fwVox.T_2ras(1,2),fwVox.T_2ras(1,3),fwVox.T_2ras(1,4)-signX*offsetx];
nii.hdr.hist.srow_y=[fwVox.T_2ras(2,1),fwVox.T_2ras(2,2),fwVox.T_2ras(2,3),fwVox.T_2ras(2,4)-signY*offsety];
nii.hdr.hist.srow_z=[fwVox.T_2ras(3,1),fwVox.T_2ras(3,2),fwVox.T_2ras(3,3),fwVox.T_2ras(3,4)-signZ*offsetz];
nii.hdr.hist.sform_code = 1;
nii.hdr.hist.qform_code = 0;
nii.hdr.hist.quatern_d = 1.0;

save_nii(nii, niiFile);

