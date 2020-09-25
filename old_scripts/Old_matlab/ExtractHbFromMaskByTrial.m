function ExtractHbFromMaskByTrial(subjectListFile,regressorList,rName,newSamplingFreq,HRFDuration,MaxClustValue,checkAlignment,showHRF)

%to run interactively for debugging...
if(0)
    subjectListFile='Y2_finalComboSubjListGroup3.prn';
    regressorList=[1,2,3];
    rName='BA';
    newSamplingFreq=10;
    HRFDuration=18;
    MaxClustValue=1;
    checkAlignment=0; %toggle on/off to view headvol and mask alignment for each subject
    showHRF=0; %display figure per subject, effect, and cluster
end


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
    
    %process data for each run per subject -- do this as outer loop since
    %it takes forever to load the ND files...
    inputFileStr=strcat(subjectList{5}{n}, '/',sID,'*_ND.mat');
    files=dir(inputFileStr);
    
    foldernames = {files.folder};
    files = {files.name};
    filenames = strcat(foldernames,'/',files);
    
    numRuns=size(filenames,2);
    
    %process data for each mask effect file...
    inputFileStr=strcat(subjectList{16}{n},'/clust_order_*.nii');
    files=dir(inputFileStr);
    
    foldernames = {files.folder};
    filesEff = {files.name};
    filenamesEff = strcat(foldernames,'/',filesEff);
    
    numEff=size(filenamesEff,2);
    
    dt=HRFDuration*newSamplingFreq;
    NClust = zeros(1,numEff); %stores number of clusters for each effect
    %note that the 2 index = HbO and HbR
    NData = zeros(numEff,MaxClustValue,numRegressors,numRuns); %count of stims for weighting
    MData = zeros(numEff,MaxClustValue,numRegressors,2,numRuns,dt); %mean
    SData = zeros(numEff,MaxClustValue,numRegressors,2,numRuns,dt); %sum
    SEData = zeros(numEff,MaxClustValue,numRegressors,2,numRuns,dt); %se
    MDataTr = zeros(numEff,MaxClustValue,numRegressors,2,numRuns,dt); %mean
    SEDataTr = zeros(numEff,MaxClustValue,numRegressors,2,numRuns,dt); %se
    
    for r=1:numRuns
        
        varName2 = ['run' int2str(r)];
        NDFile=strcat(subjectList{5}{n},'/',sID,'_',varName2,'_ND.mat');
        
        %Load NeuroDOT image file: data are voxels x time
        load(NDFile,'-mat');
        
        %ch 34 = ef 27
        %ch 35 = ef 28
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
                
                [~,keepGood]=ismember(keepVox,info.tissue.dim.Good_Vox);
                keepGood(keepGood==0)=[];
                HbO_cluster_only = cortex_HbO(keepGood,:);
                %                 HbO_TimeTrace=mean(HbO_cluster_only,1);
                HbR_cluster_only = cortex_HbR(keepGood,:);
                %                 HbR_TimeTrace=mean(HbR_cluster_only,1);
                
                if 1
                    HbO_TimeMAvg = mean(HbO_cluster_only,1);
                    HbR_TimeMAvg = mean(HbR_cluster_only,1);
                    
                    %load('012run2.mat','-mat');
                    %load('118run1.mat','-mat');
                    %load('06IND103B-VWM2_run01.nirs','-mat');
                    %load('103run1.mat','-mat');
                    load('239run2.mat','-mat');

                    info.system.framerate=25; %old frame rate
                    paddingStart=20;
                    paddingEnd=40;
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
                    data=squeeze(procResult.dc(startframe:endframe,1,:))'.*10^6;
                    lmdata=data;
                    newSamplingFreq=10;
                    
                    params.rs_Hz=newSamplingFreq;         % resample freq
                    params.rs_tol=1e-5;     % resample tolerance
                    [lmdata, info] = resample_tts(lmdata, info, params.rs_Hz, params.rs_tol);

                    figure;
                    plot(lmdata(35,:),'k');
                    hold on;
                    plot(HbO_TimeMAvg,'r');
                    hold off;

                    data=squeeze(procResult.dc(startframe:endframe,2,:))'.*10^6;
                    lmdata=data;
                    newSamplingFreq=10;
                    
                    params.rs_Hz=newSamplingFreq;         % resample freq
                    params.rs_tol=1e-5;     % resample tolerance
                    [lmdata, info] = resample_tts(lmdata, info, params.rs_Hz, params.rs_tol);
                                      
                    figure;
                    plot(lmdata(35,:),'k');
                    hold on;
                    plot(HbR_TimeMAvg,'r');
                    hold off;
                end
                
                %compute weighted mean over runs (based on stims per run)
                for reg=1:numRegressors
                    
                    stims = find(info.paradigm.synchtype == regressorListND(reg));
                    NData(ef,cl,reg,r) = size(stims,1);
                    
                    if size(stims,1) > 0
                        
                        for nstims=1:size(stims,1)
                            
                            starttime=info.paradigm.synchpts(stims(nstims));
                            endtime=starttime+(HRFDuration*newSamplingFreq);
                            if endtime > size(HbO_cluster_only,2)
                                endtime = size(HbO_cluster_only,2);
                            end
                            HbO_Time = HbO_cluster_only(:,starttime:endtime);
                            HbO_TimeM(nstims,:) = mean(HbO_Time,1);
                            %HbO_TimeM(nstims,:) = HbO_TimeM(nstims,:) - HbO_TimeM(nstims,1);
                            HbR_Time = HbR_cluster_only(:,starttime:endtime);
                            HbR_TimeM(nstims,:) = mean(HbR_Time,1);
                            %HbR_TimeM(nstims,:) = HbR_TimeM(nstims,:) - HbR_TimeM(nstims,1);
                            
                            if nstims == 1
                                figure;
                            end
                            plot(HbO_TimeM(nstims,:));
                            if nstims == 1
                                hold on;
                            end
                        end
                        HbO_TimeMAvg = mean(HbO_TimeM,1);
                        HbR_TimeMAvg = mean(HbR_TimeM,1);
                        HbO_TimeMSE = std(HbO_TimeM,1)/sqrt(size(stims,1));
                        HbR_TimeMSE = std(HbR_TimeM,1)/sqrt(size(stims,1));
                        plot(HbO_TimeMAvg,'k')
                        hold off;
                        
                        if 0
                            figure;
                            x=[1:HRFDuration*newSamplingFreq+1];
                            mseb(x, HbO_TimeMAvg, HbO_TimeMSE, [], 1);
                        end
                        MDataTr(ef,cl,reg,1,r,:) = HbO_TimeMAvg; % your mean vector in micromolar;
                        SEDataTr(ef,cl,reg,1,r,:) = HbO_TimeMSE; %SE                        
                        MDataTr(ef,cl,reg,2,r,:) = HbR_TimeMAvg; % your mean vector in micromolar;
                        SEDataTr(ef,cl,reg,2,r,:) = HbR_TimeMSE; %SE                        

                        %extract block average time series for HbO...
                        [BA_out,BSTD_out] = BlockAverage(HbO_cluster_only, info.paradigm.synchpts(stims), dt);
                        
                        MData(ef,cl,reg,1,r,:) = nanmean(BA_out); % your mean vector in micromolar;
                        SData(ef,cl,reg,1,r,:) = nansum(BA_out); % your summed vector in micromolar;
                        SEData(ef,cl,reg,1,r,:) = (nanmean(BSTD_out))/sqrt(size(stims,1)); %SE
                        
                        if 0
                            figure;
                            x = 1:dt;
                            y = nanmean(BA_out);
                            sdtime = nanmean(BSTD_out)/sqrt(size(stims,1));
                            mseb(x, y, sdtime, [], 1);
                        end
                        
                        %extract block average time series for HbR...
                        [BA_out,BSTD_out] = BlockAverage(HbR_cluster_only, info.paradigm.synchpts(stims), dt);
                        MData(ef,cl,reg,2,r,:) = nanmean(BA_out); % your mean vector in micromolar;
                        SData(ef,cl,reg,2,r,:) = nansum(BA_out); % your summed vector in micromolar;
                        SEData(ef,cl,reg,2,r,:) = (nanmean(BSTD_out))/sqrt(size(stims,1)); %SE
                        
                        %                         figure;
                        %                         x = 1:dt;
                        %                         y = nanmean(BA_out);
                        %                         sdtime = nanmean(BSTD_out)/sqrt(size(stims,1));
                        %                         mseb(x, y, sdtime, [], 1);
                        
                    end
                end %regressors
                
                cl=cl+1;
                keepVox = find(MaskData(:) == cl);
                
            end %while cluster
            
            NClust(1,ef) = cl-1;
            
        end %effect
    end %runs
    
    %compute weighted mean and SE and output to csv...
    for ef=1:numEff
        
        effName = char(filesEff(ef));
        effectN = effName(13:size(effName,2)-4);
        OutFileN=strcat(subjectList{16}{n},'/TsHb_',rName,'_',effectN,'.csv');
        if (exist(OutFileN,'file') == 0)
            outfile = fopen(OutFileN,'w');
            fprintf(outfile,'AnalysisLabel,Subject,Effect,Cluster,Cond,Chromophore,N,Time,Mean,Sum,SE\n');
        else
            outfile = fopen(OutFileN,'a');
        end
        
        for cl=1:NClust(1,ef)
            newfig=1;
            
            for reg=1:numRegressors
                for Hb=1:2
                    
                    W=zeros(numRuns,1);
                    AM=zeros(numRuns,dt);
                    ASE=zeros(numRuns,dt);
                    
                    %compute weighting over number of stims per run
                    for r=1:numRuns
                        W(r,1) = squeeze(NData(ef,cl,reg,r));
                        AM(r,:) = squeeze(MData(ef,cl,reg,Hb,r,:));
                        AS(r,:) = squeeze(SData(ef,cl,reg,Hb,r,:));
                        ASE(r,:) = squeeze(SEData(ef,cl,reg,Hb,r,:));
                    end
                    sumW=sum(W);
                    W=W/sum(W);
                    WM = mean(W.'*AM,1);
                    WS = mean(W.'*AS,1);
                    MSE = mean(ASE,1); %don't do a weighted SE here as SE already weighted by sqrt(N)
                    x = (1:dt)/newSamplingFreq; %HRF time in seconds
                    
                    if showHRF
                        if newfig == 1
                            figure;
                            newfig=0;
                            hold on;
                        end
                        if(Hb == 1)
                            lineProps2.col{1}='b';
                            mseb(x, WM, MSE, lineProps2, 1);
                        else
                            lineProps2.col{1}='r';
                            mseb(x, WM, MSE, lineProps2, 1);
                        end
                    end
                    
                    
                    for i=1:dt
                        if Hb == 1
                            fprintf(outfile,'%s,%s,%s,%d,%d,%s,%d,%.1f,%8.6f,%8.6f,%8.6f\n',rName,char(subjects{n}),effName(13:size(effName,2)-4),cl,regressorList(reg),'HbO',sumW,x(i),WM(1,i),WS(1,i),MSE(1,i));
                        else
                            fprintf(outfile,'%s,%s,%s,%d,%d,%s,%d,%.1f,%8.6f,%8.6f,%8.6f\n',rName,char(subjects{n}),effName(13:size(effName,2)-4),cl,regressorList(reg),'HbR',sumW,x(i),WM(1,i),WS(1,i),MSE(1,i));
                        end
                    end
                end
            end
            if showHRF
                xlabel('seconds');
                ylabel('micromolar');
                title(strcat(effName(13:size(effName,2)-4),' Cluster',int2str(cl)));
                hold off;
            end
        end
        fclose(outfile);
        
    end
    
    
end %subjects


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

