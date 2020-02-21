function RunGLM_NeuroDOT(subjectListFile,regressorList,rDuration,rName,newSamplingFreq)

%% John questions
%% --add code to marry up .nirs file with light model from the correct session for NIH

fileID = fopen(subjectListFile,'r');
if fileID < 0
    error 'Failed to open the subjectListFile for reading'
end

%VAM - Update to support updates to the driver file
%   set useLegacyCode=1 to revert back to old behavior
useLegacyCode = 1;
if ( useLegacyCode )
  subjectList = textscan(fileID,'%s %s %s %s %s %s %s %s %s %s %s %s %s');
else
  tline = fgetl(fileID);
  firstLine=1;
  while ischar(tline)
      tmp=strsplit(tline);
      if (size(tmp{1}) == 0)
        break
      end
      if (firstLine == 1)
        subjectList=tmp;
        firstLine=0;
        numItems=size(tmp);
      else
        for i=1:numItems(2)
          subjectList{i}=[subjectList{i};{tmp{i}}];
        end
      end
      tline = fgetl(fileID);
  end
end
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


%% Load HRF from file
load('hrf_DOT3.mat'); % HbO hrf
infoHRF.system.framerate=1;
hrf=resample_tts(hrf,infoHRF,newSamplingFreq,1e-3,1);
hrfR = hrf*-1;

numRegressors = size(regressorList,2);
regressorListND = regressorList+1;

for n=1:numSubjects
    
    sID=subjects{n}
    
    inputFileStr=strcat(subjectList{5}{n}, '/',sID,'*_ND.mat');
    files=dir(inputFileStr);
    
    foldernames = {files.folder};
    files = {files.name};
    filenames = strcat(foldernames,'/',files);
    
    numRuns=size(filenames,2);
    
    runCt = 0;
    for r=1:numRuns
        
        varName2 = ['run' int2str(r)];
        NDFile=strcat(subjectList{5}{n},'/',sID,'_',varName2,'_ND.mat');
        
        %Load NeuroDOT image file: data are voxels x time
        load(NDFile,'-mat');
        
        %check if events in regressors specified by user
        doGLM = 0;
        for j=1:numRegressors
            if ~isempty(info.paradigm.(['Pulse_',num2str(regressorListND(j))]))
                doGLM = 1;
                runCt = runCt+1;
            end
        end
        
        if r == 1
            b_HbO = zeros(size(cortex_HbO,1),numRegressors+1); %add one for linear term...
            b_HbR = zeros(size(cortex_HbR,1),numRegressors+1);
        end
        
        %% glm your data
        if doGLM
            
            %fix scale on image recon data; see Adam email 10/12/19
            cortex_HbO = cortex_HbO.*1000;
            cortex_HbR = cortex_HbR.*1000;
            
            params.DoFilter=0;
            params.events=regressorListND;
            params.event_length=rDuration;
            
            %HbO
            [bO,eO,DMO,EDMO]=GLM_181206(cortex_HbO,hrf,info,params); %b is the beta values for each event,e is the reisduals, dm is the design matrix, edm is a different version of the design matrix you can set a flag to use where every
            b_HbO=b_HbO+bO;
                        
            %HbR
            params.DoFilter=0;
            [bR,eR,DMR,EDMR]=GLM_181206(cortex_HbR,hrfR,info,params); %b is the beta values for each event,e is the reisduals, dm is the design matrix, edm is a different version of the design matrix you can set a flag to use where every
            b_HbR=b_HbR+bR;

        end
        
    end
    
    %average beta maps across runs
    b_HbO = b_HbO ./ runCt;
    b_HbR = b_HbR ./ runCt;

    BetaFile=strcat(subjectList{5}{n},'/',sID,'_Betas_',rName,'.mat');
    save(BetaFile,'b_HbO','b_HbR','runCt');

    dim2 = info.tissue.dim; %set time points to 1 for beta map
    dim2.nVt = 1;

    %output beta mapas for each condition...
    for bct=2:numRegressors+1
        
        pathname=subjectList{5}{n};
        varName2 = ['cond' int2str(regressorList(bct-1))];
        
        outputname=strcat('/',sID,'_',rName,'_',varName2,'_Unmasked_oxy_ND');
        bmap=Good_Vox2vol(b_HbO(:,bct), dim2);
        SaveVolumetricData(bmap,dim2,outputname,pathname,'nii');
        
        outputname=strcat('/',sID,'_',rName,'_',varName2,'_Unmasked_deoxy_ND');
        bmap=Good_Vox2vol(b_HbR(:,bct), dim2);
        SaveVolumetricData(bmap,dim2,outputname,pathname,'nii');
        
    end
end
