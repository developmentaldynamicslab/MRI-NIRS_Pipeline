function ExtractHbFromMask_TimeSeries(subjectListFile,regressorList,rName,newSamplingFreq,HRFDuration,MaxClustValue,checkAlignment,showHRF,BaselineDuration)

%%%% Function is designed to take one effect mask with multiple clusters
%%%% and return a DCM-ready matlab file with the time series for each
%%%% cluster for each run along with the associated design matrix... Note
%%%% that 'effect' remains below for consistency, but there should be only
%%%% one 'effect' in the target input folder.

%to run interactively for debugging...
if(0)
    subjectListFile='Y1_finalComboSubjListGroup_DCM.prn';
    regressorList=[1,2,3];
    rName='Y1';
    newSamplingFreq=10;
    HRFDuration=20;
    MaxClustValue=2;    
    checkAlignment=0; %toggle on/off to view headvol and mask alignment for each subject
    showHRF=0; %display figure per subject, effect, and cluster
    BaselineDuration=4; %subtract mean over baseline duration from block average -- if 0, does nothing
end

BoxcarDuration=10;
%clusters
ClNames{1}='lIPS';
ClNames{2}='rTPJ';


fileID = fopen(subjectListFile,'r');
if fileID < 0
    error 'Failed to open the subjectListFile for reading'
end

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
if (0)
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

numRegressors = size(regressorList,2);
regressorListND = regressorList+1;

for n=1:numSubjects
    
    sID=subjects{n}
    if n > 1
        clear('Sess');
    end
    foundSessData = 0;
    
    %process data for each run per subject -- do this as outer loop since
    %it takes forever to load the ND files...
    inputFileStr=strcat(subjectList{5}{n}, '/',sID,'*_ND.mat');
    files=dir(inputFileStr);
    
    foldernames = {files.folder};
    files = {files.name};
    filenamesND = strcat(foldernames,'/',files);
    
    numRuns=size(filenamesND,2);
    
    %process data for each mask effect file...
    inputFileStr=strcat(subjectList{16}{n},'/clust_order_*.nii');
    files=dir(inputFileStr);
    
    foldernames = {files.folder};
    filesEff = {files.name};
    filenamesEff = strcat(foldernames,'/',filesEff);
    
    numEff=size(filenamesEff,2);
    
    dtbase=round(BaselineDuration*newSamplingFreq);
    dt=round(HRFDuration*newSamplingFreq);
    NClust = zeros(1,numEff); %stores number of clusters for each effect

    for r=1:numRuns
        
        %create data structures for DCM analysis
        Sess(r).Y.name_hemo{1} = 'Deoxy';
        Sess(r).Y.name_hemo{2} = 'Total';
        Sess(r).Y.dt = 1/newSamplingFreq;
    
        NDFile=filenamesND{r};
        
        %Load NeuroDOT image file: data are voxels x time
        load(NDFile,'-mat');
        
        %should be only one effect...otherwise, output file will reflect
        %only final effect.
        for ef=1:numEff
            
            %Load effect mask in subject space
            MaskName=strcat(sID,'_',char(filesEff(ef)));
            MaskPath=strcat(subjectList{16}{n},'/');
            [MaskData, header] = LoadVolumetricData(MaskName,MaskPath,'nii');
            
            if(checkAlignment)
                %load headvol (not really needed unless checking data)
                checkName3=strcat(sID,'_headvol2mm');
                [checkData3,header3] = LoadVolumetricData(checkName3,MaskPath,'nii');
                
                %code to view data to ensure everything lines up
                GVmask=Good_Vox2vol(ones(length(info.tissue.dim.Good_Vox),1),info.tissue.dim);
                PlotSlices(checkData3,header3,[],GVmask); %q to exit viewer
                PlotSlices(checkData3,header3,[],MaskData);
                %PlotSlices(MaskData,header,[],GVmask);
            end
            
            
            %iterate through the clusters until no new entries
            cl=1;
            keepVox = find(MaskData(:) == cl);
            while size(keepVox,1) > 0
                
                foundSessData = 1;
                
                [~,keepGood]=ismember(keepVox,info.tissue.dim.Good_Vox);
                keepGood(keepGood==0)=[];
                HbO_cluster_only = cortex_HbO(keepGood,:);
%                 HbO_TimeTrace=mean(HbO_cluster_only,1);
                HbR_cluster_only = cortex_HbR(keepGood,:);
%                 HbR_TimeTrace=mean(HbR_cluster_only,1);

                HbO_TimeMAvg = mean(HbO_cluster_only,1);
                HbR_TimeMAvg = mean(HbR_cluster_only,1);
                
                %write data DCM structures
                Sess(r).Y.name_region{cl} = ClNames{cl};
                Sess(r).Y.y(:,1,cl) = zeros(1,size(HbR_TimeMAvg,2));
                Sess(r).Y.y(:,2,cl) = zeros(1,size(HbR_TimeMAvg,2));
                
                Sess(r).Y.y(:,1,cl) = HbR_TimeMAvg;
                Sess(r).Y.y(:,2,cl) = HbR_TimeMAvg + HbO_TimeMAvg;
                                
                %output design/input structure
                for reg=1:numRegressors
                    
                    stims = find(info.paradigm.synchtype == regressorList(reg));
                    Sess(r).U(reg).dt = 1/newSamplingFreq;
                    Sess(r).U(reg).name = regressorList(reg);
                    Sess(r).U(reg).u = zeros(1,size(HbR_TimeMAvg,2));
                    
                    if size(stims,1) > 0
                        for st=1:size(stims,1)
                            Sess(r).U(reg).u(info.paradigm.synchpts(stims(st)):(info.paradigm.synchpts(stims(st))+fix(BoxcarDuration*newSamplingFreq)))=1;
                        end
                    end
                end %regressors
                
                cl=cl+1;
                keepVox = find(MaskData(:) == cl);
                
            end %while cluster
            
            NClust(1,ef) = cl-1;
            
        end %effect
    end %runs

    if foundSessData == 1
        %output DCM data for this effect...
        effName = char(filesEff(ef));
        effectN = effName(13:size(effName,2)-4);
        OutFileN=strcat(subjectList{16}{n},'/',sID,'_',effectN,'.mat');
        %overwrite file if already exists...
        outfile = fopen(OutFileN,'w');
        save(OutFileN,'Sess');
        fclose(outfile);
    end
    
end %subjects
