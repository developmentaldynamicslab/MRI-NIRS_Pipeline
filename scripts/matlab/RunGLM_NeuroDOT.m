function RunGLM_NeuroDOT(subjectListFile)

%% John questions
%% --create image file for each run. Then average beta maps per run within the same volume
%% --add code to marry up .nirs file with light model from the correct session for NIH

fileID = fopen(subjectListFile,'r');
if fileID < 0
    error 'Failed to open the subjectListFile for reading'
end
subjectList = textscan(fileID,'%s %s %s %s %s %s');
fclose(fileID);

%JPS added to pull out unique subjects
%needed in cases where input file has multiple rows with
%data from multiple sessions per subject
subjectListTemp = subjectList;
[subjects2,uindex]=unique(subjectListTemp{1,1});
for x=1:size(subjectListTemp,2)
    for y=1:size(uindex,1)
        subjectList2{x}{y,1} = subjectListTemp{x}{uindex(y)};
    end
end

clear subjectList;
subjectList = subjectList2;

subjects=subjectList{1,1};

%changed to dim1 by JPS
numSubjects=size(subjects,1);

for n=1:numSubjects
    
    n
    sID=subjects{n};

%% glm your data
load('/Users/administrator/Documents/NeuroDOT_Beta/Support_Files/GLM/hrf_DOT3.mat'); % HbO hrf

%look at naming events to comp test first 
%info.paradigm=rmfield(info.paradigm, {'Pulse_8', 'Pulse_9', 'Pulse_10',8:17);


hrfR = hrf*-1;

%iterate through for oxy, deoxy
params.DoFilter=0;
[b,e,DM,EDM]=GLM_181206(cortex_HbO,hrf,info,params); %b is the beta values for each event,e is the reisduals, dm is the design matrix, edm is a different version of the design matrix you can set a flag to use where every 
figure;
imagesc(DM);
colormap('gray')

%save beta maps for each condition...set up structure to select particular
%conditions...
bmap=Good_Vox2vol(b(:,3), info.tissue.dim);
SaveVolumetricData(bmap,info.tissue.dim,outputname,pathname,'nii');


PlotSlices(bmap, info.tissue.dim)

%This function is run on the image reconstructed data but could be run in
%channel space if you change the data. 
ba = BlockAverage(cortex_HbO,info.paradigm.synchpts(info.paradigm.Pulse_3), 300);
% pulse = info.paradigm,synchpts(info.paradigm.Pulse_3)
%dt = time window for regression in samples (150 would be 6 seconds)
figure;
imagesc(ba)


        varName2 = ['run' int2str(r)];
% %         oxyFile=strcat(subjectList{5}{n},'/',sID,'_',varName2,'_Unmasked_oxy_ND.nii');
% %         deoxyFile=strcat(subjectList{5}{n},'/',sID,'_',varName2,'_Unmasked_deoxy_ND.nii');


