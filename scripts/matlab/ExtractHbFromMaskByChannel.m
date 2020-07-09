function ExtractHbFromMaskByChannel(subjectListFile,oldSamplingFreq,newSamplingFreq,paddingStart,paddingEnd,HRFDuration,MaxClustValue,checkAlignment)

%to run interactively for debugging...
if(0)
    subjectListFile='Y2_finalComboSubjListGroup3.prn';
    oldSamplingFreq = 25;
    newSamplingFreq=10;
    paddingStart=20;
    paddingEnd=40;
    HRFDuration=18;
    MaxClustValue=1;
    checkAlignment=0; %toggle on/off to view headvol and mask alignment for each subject
end

nPlotsPerFig = 6;

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

OutFileN='Correlations.csv';
if (exist(OutFileN,'file') == 0)
    outfile = fopen(OutFileN,'w');
    fprintf(outfile,'Subject,Run,Chromophore,Channel,Cluster,Corr\n');
else
    outfile = fopen(OutFileN,'a');
end

for n=1:numSubjects
    
    sID=subjects{n}
    
    %process data for each run per subject -- do this as outer loop since
    %it takes forever to load the ND files...
    inputFileStr=strcat(subjectList{5}{n}, '/',sID,'*_ND.mat');
    files=dir(inputFileStr);
    
    foldernames = {files.folder};
    files = {files.name};
    filenames = strcat(foldernames,'/',files);
    
    numRuns=size(filenames,2);
    
    inputFileStrNIRS=strcat(subjectList{4}{n}, '/', subjects{n}, '*.nirs');
    filesNIRS=dir(inputFileStrNIRS);
    foldernamesNIRS = {filesNIRS.folder};
    filesNIRS = {filesNIRS.name};
    filenamesNIRS = strcat(foldernamesNIRS,'/',filesNIRS);
    
    %process data for each mask effect file...
    inputFileStr=strcat(subjectList{16}{n},'/clust_order_*.nii');
    files=dir(inputFileStr);
    
    foldernames = {files.folder};
    filesEff = {files.name};
    filenamesEff = strcat(foldernames,'/',filesEff);
    
    numEff=size(filenamesEff,2);
    
    %store correlation data per subject
    CData = zeros(numRuns,2,numEff,MaxClustValue); %mean
    
    for r=1:numRuns
        
        varName2 = ['run' int2str(r)];
        NDFile=strcat(subjectList{5}{n},'/',sID,'_',varName2,'_ND.mat');
        
        %Load NeuroDOT image file: data are voxels x time
        load(NDFile,'-mat');
        
        %Get preprocessed NIRS file into NeuroDOT format
        load(filenamesNIRS{r}, '-mat');
        
        for chrom=1:2
            figct=0;
            for ef=1:numEff
                
                effName = char(filesEff(ef));
                effCh = str2double(effName(18:19));
                if isnan(effCh)
                    effCh = str2double(effName(18:18));
                end
                
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
                    
                    [~,keepGood]=ismember(keepVox,info.tissue.dim.Good_Vox);
                    keepGood(keepGood==0)=[];
                    HbO_cluster_only = cortex_HbO(keepGood,:);
                    %                 HbO_TimeTrace=mean(HbO_cluster_only,1);
                    HbR_cluster_only = cortex_HbR(keepGood,:);
                    %                 HbR_TimeTrace=mean(HbR_cluster_only,1);
                    
                    HbO_TimeMAvg = mean(HbO_cluster_only,1);
                    HbR_TimeMAvg = mean(HbR_cluster_only,1);
                    
                    info.system.framerate=oldSamplingFreq; %old frame rate
                    [i,j]=find(procResult.s == 1);
                    startframe = min(i) - (info.system.framerate*paddingStart);
                    if (startframe < 1)
                        startframe = 1;
                    end
                    endframe = max(i) + (info.system.framerate*paddingEnd);
                    if (endframe > size(procResult.s,1))
                        endframe = size(procResult.s,1);
                    end
                    goodtime = endframe - startframe + 1;
                    new_s = zeros(goodtime,size(procResult.s,2));
                    for a=1:size(i,1)
                        new_s((i(a,1) - startframe) + 1, j(a,1)) = 1;
                    end
                    
                    %%%%% put .nirs data into NeuroDOT structure %%%%%%%%%%
                    data=squeeze(procResult.dc(startframe:endframe,chrom,:))'.*10^6;
                    lmdata=data;
                    newSamplingFreq=10;
                    
                    params.rs_Hz=newSamplingFreq;         % resample freq
                    params.rs_tol=1e-5;     % resample tolerance
                    [lmdata, info] = resample_tts(lmdata, info, params.rs_Hz, params.rs_tol);
                    
                    if mod(ef-1,nPlotsPerFig) == 0
                        figure;
                        figct=figct+1;
                    end
                    subplot(nPlotsPerFig,1,mod(ef-1,nPlotsPerFig)+1);
                    plot(lmdata(effCh,:),'k');
                    hold on;
                    if chrom == 1
                        plot(HbO_TimeMAvg,'r');
                        CData(r,chrom,ef,cl) = corr(squeeze(lmdata(effCh,:))',HbO_TimeMAvg');
                        fprintf(outfile,'%s,%d,%s,%d,%d,%8.6f\n',sID,r,'HbO',effCh,cl,CData(r,chrom,ef,cl));
                    else
                        plot(HbR_TimeMAvg,'r');
                        CData(r,chrom,ef,cl) = corr(squeeze(lmdata(effCh,:))',HbR_TimeMAvg');
                        fprintf(outfile,'%s,%d,%s,%d,%d,%8.6f\n',sID,r,'HbR',effCh,cl,CData(r,chrom,ef,cl));
                    end
                    xlabel(strcat('Channel ',int2str(effCh)));
                    hold off;

                    if chrom == 1
                        title('HbO');
                    else
                        title('HbR');
                    end
                    
                    cl=cl+1;
                    keepVox = find(MaskData(:) == cl);
                    
                end %while cluster
                
                if mod(ef-1,nPlotsPerFig) == 5
                    figName = strcat(sID,'_Run',int2str(r),'_Chrom',int2str(chrom),'_Figure',int2str(figct));
                    savefig(figName);
                end
                
            end %effect
        end %chrom
    end %runs
end

fclose(outfile);


%OLD NOTES...

%plot the time traces along with the stim events for learned
%and unlearned
%             plot(HbO_TimeTrace)
%             hold
%             plot(HbR_TimeTrace,'r')
%             %             stimsL = find(info.paradigm.synchtype == 1 | info.paradigm.synchtype == 4);
%             %             stimsUL = find(info.paradigm.synchtype == 2 | info.paradigm.synchtype == 5);
%             stimsL = find(info.paradigm.synchtype == 1);
%             stimsUL = find(info.paradigm.synchtype == 2);
%             for j=1:size(stimsL,1)
%                 xline(info.paradigm.synchpts(stimsL(j),1),'g')
%             end
%             for j=1:size(stimsUL,1)
%                 xline(info.paradigm.synchpts(stimsUL(j),1),'b')
%             end
%             hold off

%output timeseries for each mask...
%need to look at WTC code to create dummy .nirs file

%what about opening the orig .nirs file, replacing channels
%with new HbO and HbR data and then writing to new file. Then
%WTC code should work as is...

%info.paradigm.synchpts = timings
%info.paradigm.synchtype = stim marks
%so figure out which stims I need to write and then create a
%new s matrix. then output s matrix and HbO and HbR time series
%to a mock .nirs file that can be read by WTC code.
%need to replicate the Child and Parent folders within
%Coherence_Child? Or just child in this folder, and parent in
%the other, then update paths in WTC.

