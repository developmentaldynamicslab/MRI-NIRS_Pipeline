function digPtsToAnatomical(subjectDir, anatVoxFileName)
% digPtsToAnatomical(subjectDir) Converts the digpts file
% to subject space. The resulting points are written out in
% Slicer Fiducial format.
%

% Set the standard filenames used by AtlasViwer
fwVoxFileName=strcat(subjectDir,'/fw/headvol.vox');
%anatVoxFileName=strcat(subjectDir,'/anatomical/headvol.vox');
%anatVoxFileName=strcat(subjectDir,'/anatomical/headvol.vox');


% Basename for the output data
outputFile=strcat(subjectDir,'/viewer/Subject/digpts.fcsv');
%outputFile=strcat(subjectDir,'/anatomical/digptsTest.fcsv');

digpts = initDigpts();
digpts = getDigpts(digpts, subjectDir);
refpts = initRefpts();
refpts = getRefpts(refpts,subjectDir);

numLandmarks = size(digpts.refpts.labels,2);
numSource = size(digpts.srcpos,1);
numDetector = size(digpts.detpos,1);

% Read the Forward Model Headvol file
fwVox=load_vox( fwVoxFileName );

% Read the Anatomical Vox file using the tools provided in AtlasViewer
anatVox=load_vox( anatVoxFileName );



%
% Create the Header for the Slicer fiducial file
%
fileID = fopen(outputFile,'w');
fprintf(fileID,'# Fiducial List file %s\n', outputFile);
fprintf(fileID,'# name = digpts\n');
fprintf(fileID,'# numPoints = %d\n');
fprintf(fileID,'# symbolScale = 10\n');
fprintf(fileID,'# symbolType = 12\n');
fprintf(fileID,'# visibility = 1\n');
fprintf(fileID,'# textScale = 7.0\n');
fprintf(fileID,'# color = 0.4,1,1\n');
fprintf(fileID,'# selectedColor = 0.807843,0.560784,1\n');
fprintf(fileID,'# opacity = 1\n');
fprintf(fileID,'# ambient = 0\n');
fprintf(fileID,'# diffuse = 1\n');
fprintf(fileID,'# specular = 0\n');
fprintf(fileID,'# power = 1\n');
fprintf(fileID,'# locked = 0\n');
fprintf(fileID,'# columns = label,x,y,z,sel,vis\n');


% Convert the location of the reference points to Subject Space
subjectSpaceRefPts = xform_apply(digpts.refpts.pos, inv(fwVox.T_2digpts));
subjectSpaceRefPts = xform_apply(subjectSpaceRefPts, fwVox.T_2ras);

for i=[1:numLandmarks]
  fprintf(fileID,'%s,%f,%f,%f,0,1\n',string(digpts.refpts.labels(i)),subjectSpaceRefPts(i,1),subjectSpaceRefPts(i,2),subjectSpaceRefPts(i,3));
end;


% Read the headsurf file - Source and Detectors are projected to this surface
headsurf = initHeadsurf();
headsurf = getHeadsurf(headsurf, subjectDir);

% Convert the location of the Source Optodes
subjectSpaceSource = xform_apply(digpts.srcpos, inv(fwVox.T_2digpts));
subjectSpaceSource = pullPtsToSurf(subjectSpaceSource, headsurf, 'center', 0, false);
subjectSpaceSource = xform_apply(subjectSpaceSource, fwVox.T_2ras);

for i=[1:numSource]
  fprintf(fileID,'%s,%f,%f,%f,0,1\n','S'+string(i),subjectSpaceSource(i,1),subjectSpaceSource(i,2),subjectSpaceSource(i,3));
end;

% Convert the location of the Detector Optodes
subjectSpaceDetect = xform_apply(digpts.detpos, inv(fwVox.T_2digpts));
subjectSpaceDetect = pullPtsToSurf(subjectSpaceDetect, headsurf, 'center', 0, false);
subjectSpaceDetect = xform_apply(subjectSpaceDetect, fwVox.T_2ras);

for i=[1:numSource]
  fprintf(fileID,'%s,%f,%f,%f,0,1\n','D'+string(i),subjectSpaceDetect(i,1),subjectSpaceDetect(i,2),subjectSpaceDetect(i,3));
end;

fclose(fileID);



