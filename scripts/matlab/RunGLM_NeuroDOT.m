%regressorList = vector of regressor numbers you want to include in the GLM

%rDuration = the duration of the boxcar input for each event in the GLM

%rName = a text input used for labelling the output files from this GLM

%newSamplingFreq = the sampling frequency used for output files from the
%ImageRecon processing.

function RunGLM_NeuroDOT(subjectListFile,regressorList,rDuration,rName,newSamplingFreq)

%run interactively
if 0
    subjectListFile = 'Y1_finalComboSubjListGroup_1Subj.prn';
    regressorList = [1, 2, 3];
    rDuration = 10;
    rName = 'GatesTest';
    newSamplingFreq = 10;
end

logFilename = ['RunGLM_NeuroDOT_', datestr(now, 'yyyy-mm-dd-THHMMSS') '.log'];
fileIDlog = fopen(logFilename,'a');

fileID = fopen(subjectListFile,'r');
if fileID < 0
    fprintf(fileIDlog,'Failed to open the subjectListFile for reading\n');
else
    
    %VAM - Update to support updates to the driver file
    %   set useLegacyCode=1 to revert back to old behavior
    useLegacyCode = 0;
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
                numItems=size(tmp);
                for i=1:numItems(2)
                    subjectList{i}=[{tmp{i}}];
                end
                firstLine=0;
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
    if 0
        subjectListTemp = subjectList;
        [subjects2,uindex]=unique(subjectListTemp{1,1});
        for x=1:size(subjectListTemp,2)
            for y=1:size(uindex,1)
                subjectList2{x}{y,1} = subjectListTemp{x}{uindex(y)};
            end
        end
        
        clear subjectList;
        subjectList = subjectList2;
    end
    
    subjects=subjectList{1,1};
    
    %changed to dim1 by JPS
    numSubjects=size(subjects,1);
    
    
    %% Load HRF from file
    load('hrf_DOT3.mat'); % HbO hrf
    infoHRF.system.framerate=1;
    hrf=resample_tts(hrf,infoHRF,newSamplingFreq,1e-3,1);
    hrfR = hrf;
    
    numRegressors = size(regressorList,2);
    regressorListND = regressorList+1;
    
    for n=1:numSubjects
        
        sID=subjects{n}
        fprintf(fileIDlog,'Processing Subject %s\n',sID);
        
        inputFileStr=strcat(subjectList{5}{n}, '/',sID,'*_ND.mat');
        files=dir(inputFileStr);
        
        foldernames = {files.folder};
        files = {files.name};
        filenames = strcat(foldernames,'/',files);
        
        numRuns=size(filenames,2);
        
        if numRuns == 0
            fprintf(fileIDlog,'No ND files for Subject %s\n',sID);
        else
            
            didGLM = 0;
            NData = zeros(numRegressors,numRuns); %count of stims for weighting
            for r=1:numRuns
                
                varName2 = ['run' int2str(r)];
                NDFile=strcat(subjectList{5}{n},'/',sID,'_',varName2,'_ND.mat');
                
                %Load NeuroDOT image file: data are voxels x time
                load(NDFile,'-mat');
                
                %check if events in regressors specified by user
                doGLM = 0;
                for j=1:numRegressors
                    stims = find(info.paradigm.synchtype == regressorListND(j));
                    NData(j,r) = size(stims,1);
                    
                    if ~isempty(info.paradigm.(['Pulse_',num2str(regressorListND(j))]))
                        doGLM = 1;
                        didGLM = 1;
                    end
                end
                
                %initialize data frames
                if r == 1
                    b_HbO = zeros(size(cortex_HbO,1),numRegressors+1); %add one for linear term...
                    b_HbR = zeros(size(cortex_HbR,1),numRegressors+1);
                end
                
                %% glm your data
                if doGLM
                    %inserted to test Gates data
                    %cortex_HbO = cortex_HbO.*1000; %MILLIMOLAR
                    %cortex_HbR = cortex_HbR.*1000;
                    
                    params.DoFilter=0;
                    params.events=regressorListND;
                    params.event_length=rDuration;
                    params.zscore=0; %don't zscore the design matrix
                    params.DoFilter=0;
                   
                    %HbO
                    [bO,eO,DMO,EDMO]=GLM_181206(cortex_HbO,hrf,info,params); %b is the beta values for each event,e is the reisduals, dm is the design matrix, edm is a different version of the design matrix you can set a flag to use where every
                    
                    %HbR
                    %%% WHAT WILL GLM RETURN IF 0 STIMS FOR A REGRESSOR?
                    [bR,eR,DMR,EDMR]=GLM_181206(cortex_HbR,hrfR,info,params); %b is the beta values for each event,e is the reisduals, dm is the design matrix, edm is a different version of the design matrix you can set a flag to use where every
                    
                    %Compute weighted sum for weighted mean
                    for bct=2:numRegressors+1
                        b_HbO(:,bct)=b_HbO(:,bct)+(bO(:,bct).*NData(bct-1,r));
                        b_HbR(:,bct)=b_HbR(:,bct)+(bR(:,bct).*NData(bct-1,r));
                    end
                else
                    fprintf(fileIDlog,'No regressor events for Run %d for Subject %s\n',r,sID);
                end
                
            end
            
            if didGLM
                
                %weighted means across runs -- divide by total stims
                for bct=2:numRegressors+1
                    b_HbO(:,bct) = b_HbO(:,bct) ./ sum(NData(bct-1,:));
                    b_HbR(:,bct) = b_HbR(:,bct) ./ sum(NData(bct-1,:));
                end
                
                BetaFile=strcat(subjectList{5}{n},'/',sID,'_Betas_',rName,'.mat');
                save(BetaFile,'b_HbO','b_HbR','NData');
                
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
            else
                fprintf(fileIDlog,'No regressor events and no beta maps for Subject %s\n',sID);
            end %didGLM
        end %runs found
    end %subjects
    
end %subject file found

fclose(fileIDlog);


