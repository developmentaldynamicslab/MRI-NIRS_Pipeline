function AVAdotVol3pt2nii(subjectDir, anatVoxFileName, nirsFileName)
% AVAdotVol3pt2nii(subjectDir) Converts
%       an AtlasViewer AdotVol.3pt which contains the
%       data from the individual channels to a NIFTI
%       image for each channel. The AtlasViewer subject directory
%       anatomical image, and NIRS filename are specified as
%       inputs.
%


% Set the standard filenames used by AtlasViwer
profileFileName=strcat(subjectDir,'/fw/AdotVol.3pt');
fwVoxFileName=strcat(subjectDir,'/fw/headvol.vox');
%anatVoxFileName=strcat(subjectDir,'/anatomical/headvol.vox');

% Basename for the output data
AdotNiftFileBase=strcat(subjectDir,'/viewer/Subject/AdotVol');

% Read the Forward Model Headvol file
fwVox=load_vox( fwVoxFileName );
tissueMask = (fwVox.img >= 3);
dims=size(fwVox.img);
nx=dims(1);
ny=dims(2);
nz=dims(3);

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

% Read the Anatomical Vox file using the tools provided in AtlasViewer
anatVox=load_vox( anatVoxFileName );

% Read the nirs file to get the number of channels
isOctave = exist('OCTAVE_VERSION') ~= 0;

[filepath,name,extNIRS] = fileparts(nirsFileName); 
if strcmp(extNIRS,'.nirs')
    %if .nirs file
    if (isOctave)
        load(nirsFileName);
    else
        load(nirsFileName,'-mat');
    end
    nMeas = size(SD.MeasList,1);
elseif strcmp(extNIRS,'.snirf')
    %if .snirf file
    snirfdata = ReadSnirf(nirsFileName);
    nMeas = size(snirfdata.data.measurementList,2);
end

% Read the 3pt file - convert to a 3D array - Write as Nifti
fid = fopen(profileFileName,'r');
for i=[0:nMeas-1]
  fseek(fid, nx*ny*nz*4*i, 'bof');
  tmpImage=fread(fid,nx*ny*nz,'single');
  vox=reshape(tmpImage, dims);  
  %vox=vox .* tissueMask;

  T_2mcInv =  inv(fwVox.T_2digpts);
  resampleImage = xform_apply_vol_smooth(vox, T_2mcInv);

  % Create the NIFTI Image
  spacing=[abs(fwVox.T_2ras(1,1)),abs(fwVox.T_2ras(2,2)),abs(fwVox.T_2ras(3,3))];
  origin=size(fwVox.img)/2;
  datatype=16;
  description='3ptToNii';
  nii = make_nii(resampleImage,spacing,origin,datatype,description);

  % Update the NIFTI header Information. The logic here is outlined in
  % the AVfwVol2AnatNii function.
  origDims = size(anatVox.img);
  newDims  = size(resampleImage);
  offsetx = (newDims(1) - origDims(1)) / 2.0 * spacing(1) * signX;
  offsety = (newDims(2) - origDims(2)) / 2.0 * spacing(2) * signY;
  offsetz = (newDims(3) - origDims(3)) / 2.0 * spacing(3) * signZ;

  nii.hdr.hist.srow_x=[fwVox.T_2ras(1,1),fwVox.T_2ras(1,2),fwVox.T_2ras(1,3),fwVox.T_2ras(1,4)-offsetx];
  nii.hdr.hist.srow_y=[fwVox.T_2ras(2,1),fwVox.T_2ras(2,2),fwVox.T_2ras(2,3),fwVox.T_2ras(2,4)-offsety];
  nii.hdr.hist.srow_z=[fwVox.T_2ras(3,1),fwVox.T_2ras(3,2),fwVox.T_2ras(3,3),fwVox.T_2ras(3,4)-offsetz];
  nii.hdr.hist.sform_code = 1;
  nii.hdr.hist.qform_code = 0;
  nii.hdr.hist.quatern_d = 1.0;

  % Set the NIFTI FIlename based on source and detectors
  if strcmp(extNIRS,'.nirs')
      %if .nirs file
      sdpair=SD.MeasList(i+1,:);
      source=sdpair(1);
      detector=sdpair(2);
  elseif strcmp(extNIRS,'.snirf')
      %if .snirf file
      source = snirfdata.data.measurementList(1,i+1).sourceIndex;
      detector = snirfdata.data.measurementList(1,i+1).detectorIndex;
  end
  
  sourceStr=int2str(source);
  detectorStr=int2str(detector);
  channelStr=int2str(i+1);
  disp(channelStr)
  
  if (nMeas < 100)
      if (i+1 < 10)
          AdotNiftFileName=strcat(AdotNiftFileBase,'_C0',channelStr,'_S',sourceStr,'_D',detectorStr,'_temp.nii');
      else
          AdotNiftFileName=strcat(AdotNiftFileBase,'_C',channelStr,'_S',sourceStr,'_D',detectorStr,'_temp.nii');
      end
  else
      if (i+1 < 10)
          AdotNiftFileName=strcat(AdotNiftFileBase,'_C00',channelStr,'_S',sourceStr,'_D',detectorStr,'_temp.nii');
      elseif (i+1 < 100)
          AdotNiftFileName=strcat(AdotNiftFileBase,'_C0',channelStr,'_S',sourceStr,'_D',detectorStr,'_temp.nii');
      else
          AdotNiftFileName=strcat(AdotNiftFileBase,'_C',channelStr,'_S',sourceStr,'_D',detectorStr,'_temp.nii');
      end
  end      

  % Write out the NIFTI Image
  save_nii(nii, AdotNiftFileName);

end;

fclose(fid);
