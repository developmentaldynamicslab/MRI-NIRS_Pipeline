%regressorList = vector of regressor numbers you want to include in the GLM

%rDuration = the duration of the boxcar input for each event in the GLM (in
%seconds*newSamplingFreq -- so a 10s boxcar at 10Hz = 100)

%rName = a text input used for labelling the output files from this GLM

%oldSamplingFreq = the original NIRS sampling freq

%newSamplingFreq = the NIRS sampling frequency after processing (this will
%typically be the same as the old sampling freq)

%hrfName = name of file with hrf data if NOT using standard; use '' if
%standard option

%GSR = global signal regression; 1 = yes, 0 = no

function RunGLM_Channel_NeuroDOT(subjectListFile,oldSamplingFreq,newSamplingFreq,paddingStart,paddingEnd,baseSDmm,regressorList,rDuration,rName,hrfName,GSR)

%run interactively
if 0
    subjectListFile = 'Y1_finalComboSubjListGroup_MRITemplate.prn';
    oldSamplingFreq = 25;
    newSamplingFreq = 25;
    paddingStart = 20;
    paddingEnd = 40;
    baseSDmm = 30;
    regressorList = [1, 2, 3];
    rDuration = 10;
    rName = 'ChTest';
    hrfName='';
    GSR = 1;
end

logFilename = ['RunGLM_Channel_NeuroDOT_', datestr(now, 'yyyy-mm-dd-THHMMSS') '.log'];
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
    if (isempty(hrfName))
        load('hrf_DOT3.mat'); % HbO hrf
    else
        load(hrfName)
    end
    infoHRF.system.framerate=1;
    hrf=resample_tts(hrf,infoHRF,newSamplingFreq,1e-3,1);
    hrfR = hrf;

    numRegressors = size(regressorList,2);
    regressorListND = regressorList+1;

    for n=1:numSubjects

        sID=subjects{n}
        fprintf(fileIDlog,'Processing Subject %s\n',sID);
       
        BetaFileN=strcat(subjectList{5}{n},'/NIRSChannelBetas_',rName,'.csv');
        if (exist(BetaFileN,'file') == 0)
            outfile = fopen(BetaFileN,'w');
            fprintf(outfile,'Subject,Chromophore,Channel,Condition,Beta\n');
        else
            outfile = fopen(BetaFileN,'a');
        end       
        
        [filepath,name,extNIRS] = fileparts(subjectList{2}{n});
        inputFileStr=strcat(subjectList{4}{n}, '/', subjects{n}, strcat('*',extNIRS));
        files=dir(inputFileStr);

        foldernames = {files.folder};
        files = {files.name};
        filenames = strcat(foldernames,'/',files);

        numRuns=size(filenames,2);

        if numRuns == 0
            fprintf(fileIDlog,'No NIRS runs for Subject %s\n',sID);
        end

        didGLM = 0;
        NData = zeros(numRegressors,numRuns); %count of stims for weighting
        for r=1:numRuns

            %Get preprocessed NIRS file into NeuroDOT format
            [filepath,name,ext] = fileparts(filenames{r});
            runNumber = str2num(name((size(name,2)-1):size(name,2)));

            if strcmp(ext,'.nirs')
                %if .nirs file
                load(filenames{r},'-mat');

                nLambda = size(SD.Lambda,2);
                dLambda = SD.Lambda; %[690,830];
                dextCoef = SD.extCoef; %2x2 matrix
                smatrix = procResult.s; %time x regressors
                timepts = size(smatrix,1); %time
                nregressors = size(smatrix,2); %regressors
                doddata = procResult.dod; %time x ch*WL
                dcdata = procResult.dc; %time x type x ch
                meas=size(SD.MeasList,1); %length ch*WL
                sourcelist = SD.MeasList(:,1); %source list ch*WL
                detectorlist = SD.MeasList(:,2); %det list ch*WL
                wavelengthlist = SD.MeasList(:,4); %WL list ch*WL
                %includedCh = procResult.SD.MeasListAct; %1 = included ch*WL
                includedCh = SD.MeasListAct; %1 = included ch*WL

            elseif strcmp(ext,'.snirf')
                %if .snirf file
                snirfdata = ReadSnirf(filenames{r});
                load(strcat(filepath,'/',name,'.mat'));

                nLambda = size(snirfdata.probe.wavelengths,1);
                dLambda = snirfdata.probe.wavelengths'; %[690,830];
                %dextCoef -- not in snirf so use defaulting to Prahl
                %smatrix -- re-mapped to ND structure below
                timepts = size(snirfdata.data.time,1); %time
                nregressors = size(snirfdata.stim,2); %regressors
                doddata = output.dod.dataTimeSeries;
                dcdata = output.dc.dataTimeSeries;
                meas = size(snirfdata.data.measurementList,2);
                for tmp=1:meas
                    sourcelist(tmp,1) = snirfdata.data.measurementList(1,tmp).sourceIndex;
                end
                for tmp=1:meas
                    detectorlist(tmp,1) = snirfdata.data.measurementList(1,tmp).detectorIndex;
                end
                for tmp=1:meas
                    wavelengthlist(tmp,1) = snirfdata.data.measurementList(1,tmp).wavelengthIndex;
                end
                for tmp=1:meas
                    if ~isfield(output.misc,'mlActAuto')
                        includedCh(tmp,1) = 1;
                    else
                        includedCh(tmp,1) = output.misc.mlActAuto(tmp,1);
                    end
                end

            end

            % % %             %load Prahl extinction coeffs and write to .nirs file
            % % %             if usePrahl | strcmp(ext,'.snirf')
            % % %                 %Prahl mat file has an 'info' structure that is
            % % %                 %overwriting my info from the light model. Prevent this
            % % %                 %from happening...
            % % %                 infoSafe = info;
            % % %                 load('Ecoeff_Prahl.mat');
            % % %                 info = infoSafe;
            % % %
            % % %                 %step through each wavelength
            % % %                 ExtCoeff = zeros(nLambda,2); %second dim is HbO, HbR
            % % %                 for j = 1:nLambda
            % % %                     ExtCoeff(j,:) = prahlEC(ismember(prahlEC(:,1),dLambda(j)),2:3).*[2.303,2.303]./1000; %divide by 1000 to move to 1/millimolar
            % % %                 end
            % % %                 dextCoef = ExtCoeff.*1000; %write output in 1/molar
            % % %                 if strcmp(ext,'.nirs')
            % % %                     save(char(filenames{r}),'aux','d','dStd','ml','procInput','procResult','s','SD','systemInfo','t','tdml','tIncMan','userdata','-mat');
            % % %                 end
            % % %             end
            % % %             dextCoef = dextCoef./1000; %assuming input coeffs are in 1/molar; convert to 1/millimolar

            %find first and last event in s matrix -- this defines the window
            %of data we want to reconstruct...minus Xs padding.
            info.system.framerate=oldSamplingFreq;

            NoStims = 0;
            if strcmp(ext,'.nirs')
                [i,j]=find(smatrix == 1);
                if isempty(i)
                    NoStims = 1;
                end
            elseif strcmp(ext,'.snirf')
                if isempty(snirfdata.stim)
                    NoStims = 1;
                end
            end

            if NoStims
                fprintf(fileIDlog,'No stims in NIRS file for run %d for Subject %s\n',runNumber,sID);
            else

                if strcmp(ext,'.nirs')
                    minstim = min(i);
                    maxstim = max(i);
                elseif strcmp(ext,'.snirf')
                    for tmp=1:nregressors
                        minstims(1,tmp) = min(snirfdata.stim(1,tmp).data(:,1));
                        maxstims(1,tmp) = max(snirfdata.stim(1,tmp).data(:,1));
                    end
                    mintime = min(minstims);
                    minstim = find(snirfdata.data.time == mintime);
                    maxtime = max(maxstims);
                    maxstim = find(snirfdata.data.time == maxtime);
                end

                startframe = minstim - (info.system.framerate*paddingStart);
                if (startframe < 1)
                    startframe = 1;
                end
                endframe = maxstim + (info.system.framerate*paddingEnd);
                if (endframe > timepts)
                    endframe = timepts;
                end
                goodtime = endframe - startframe + 1;

                %%%update stim times, subtracting off startframe
                %%%for snirf, doing this below as easier; see events
                if strcmp(ext,'.nirs')
                    new_s = zeros(goodtime,nregressors);
                    for a=1:size(i,1)
                        new_s((i(a,1) - startframe) + 1, j(a,1)) = 1;
                    end
                end

                %%%%% put .nirs data into NeuroDOT structure %%%%%%%%%%
                data_dod=doddata(startframe:endframe,:)';
                data_HbO=squeeze(dcdata(startframe:endframe,1,:))';
                data_HbR=squeeze(dcdata(startframe:endframe,2,:))';
                data_HbT=squeeze(dcdata(startframe:endframe,3,:))';
                ch=meas/2;
                %%%Can't find in .nirs file...grr. Hardcoding here.
                info.pairs=table;
                info.pairs.Src=sourcelist;
                info.pairs.Det=detectorlist;
                info.pairs.WL=wavelengthlist;
                info.pairs.lambda=cat(1,ones(ch,1).*dLambda(1), ones(ch,1).*dLambda(2));
                info.pairs.NN=ones(meas,1);
                info.pairs.Mod=repmat({'CW'},[meas,1]);
                info.pairs.r2d=ones(meas,1).*baseSDmm; %%30MM 2D AND 3D DISTANCE BETWEEN PAIRS; ARE THESE IN .NIRS FILE?
                info.pairs.r3d=ones(meas,1).*baseSDmm; %%30MM 2D AND 3D DISTANCE BETWEEN PAIRS

                % % %                 if (runNumber == 1)
                % % %                     imageFileND=strcat(subjectList{5}{n},'/Adot_',sID,'_nd2_2mm');
                % % %                     save(imageFileND,'A','info','-v7.3')
                % % %                 end

                %%update so pruning channels based on bad channels on either wavelength
                for ct=1:ch
                    if (includedCh(ct) == 0 | includedCh(ct+ch) == 0)
                        includedCh(ct) = 0;
                        includedCh(ct+ch) = 0;
                    end
                end

                info.MEAS.GI=includedCh;
                inclChannel=includedCh(1:ch);

                %%if no data, move on...
                if sum(includedCh) == 0
                    fprintf(fileIDlog,'All NIRS channels pruned for Subject %s Run %d\n',sID,runNumber);
                else

                    if strcmp(ext,'.nirs')
                        %%%%read in regressors (s matrix in .nirs file)...
                        info.paradigm.synchpts=[];
                        info.paradigm.synchtype=[];
                        for j=1:nregressors
                            events=find(new_s(:,j));
                            info.paradigm.synchpts=cat(1,info.paradigm.synchpts,events);
                            info.paradigm.synchtype=cat(1,info.paradigm.synchtype,ones(length(events),1).*j);
                        end
                        [info.paradigm.synchpts,idx]=sort(info.paradigm.synchpts);
                        info.paradigm.synchtype=info.paradigm.synchtype(idx);
                    elseif strcmp(ext,'.snirf')
                        %%%map .snirf stim structure to ND stims
                        info.paradigm.synchpts=[];
                        info.paradigm.synchtype=[];
                        for j=1:nregressors
                            clear('events');
                            for tmp=1:size(snirfdata.stim(1,j).data(:,1),1)
                                %subtracting startframe here to trim
                                events(tmp) = find(snirfdata.data.time == snirfdata.stim(1,j).data(tmp,1)) - startframe;
                            end
                            events=events';
                            info.paradigm.synchpts=cat(1,info.paradigm.synchpts,events);
                            info.paradigm.synchtype=cat(1,info.paradigm.synchtype,ones(length(events),1).*j);
                        end
                        [info.paradigm.synchpts,idx]=sort(info.paradigm.synchpts);
                        info.paradigm.synchtype=info.paradigm.synchtype(idx);
                    end

                    for j=1:nregressors
                        info.paradigm.(['Pulse_',num2str(j+1)])=find(info.paradigm.synchtype==j);
                    end

                    info.paradigm.Pulse_1=[]; %dummy regressor in NeuroDOT

                    if (GSR)
                        
                        %do GSR on concentration data
                        keep1 = (inclChannel==1);
                        
                        HbOgdave=nanmean(data_HbO(keep1,:),1);
                        HbRgdave=nanmean(data_HbR(keep1,:),1);
                        
                        data_dcALL = cat(1, data_HbO, data_HbR);
                        data_gdave = cat(1, HbOgdave, HbRgdave);
                        data_dcAllnew = regcorr(data_dcALL, info, data_gdave); 
                        
                        data_HbOnew = data_dcAllnew(1:ch,:);
                        data_HbRnew = data_dcAllnew(ch+1:ch*2,:);
                        
                    else
                        data_HbOnew = data_HbO;
                        data_HbRnew = data_HbR;
                    end

                    %write GSR-corrected concentration data to .nirs file?
                    %Maybe not -- can always just re-run...

                    %% run GLM

                    %check if events in regressors specified by user
                    doGLM = 0;
                    for j=1:numRegressors
                        stims = find(info.paradigm.synchtype == regressorList(j));
                        NData(j,r) = size(stims,1);

                        if ~isempty(info.paradigm.(['Pulse_',num2str(regressorListND(j))]))
                            doGLM = 1;
                            didGLM = 1;
                        end
                    end

                    %initialize data frames
                    if r == 1
                        b_HbO = zeros(size(data_HbOnew,1),numRegressors+1); %add one for linear term...
                        b_HbR = zeros(size(data_HbRnew,1),numRegressors+1);
                    end

                    if doGLM

                        params.DoFilter=0;
                        params.events=regressorListND;
                        params.event_length=rDuration; %an input parameter
                        params.zscore=0; %don't zscore the design matrix
                        params.DoFilter=0;

                        %HbO
                        [bO,eO,DMO,EDMO]=GLM_181206(data_HbOnew,hrf,info,params); %b is the beta values for each event,e is the reisduals, dm is the design matrix, edm is a different version of the design matrix you can set a flag to use where every

                        %HbR
                        [bR,eR,DMR,EDMR]=GLM_181206(data_HbRnew,hrfR,info,params); %b is the beta values for each event,e is the reisduals, dm is the design matrix, edm is a different version of the design matrix you can set a flag to use where every

                        %Compute weighted sum for weighted mean
                        for bct=2:numRegressors+1
                            b_HbO(:,bct)=b_HbO(:,bct)+(bO(:,bct).*NData(bct-1,r));
                            b_HbR(:,bct)=b_HbR(:,bct)+(bR(:,bct).*NData(bct-1,r));
                        end
                    else
                        fprintf(fileIDlog,'No regressor events for Run %d for Subject %s\n',r,sID);
                    end
                end %all channels pruned
            end %no stims
        end %runs for this subject

        if didGLM
            
            %% write long-form .csv file output to read into R
            for bct=2:numRegressors+1
                for chn = 1:ch
                    fprintf(outfile,'%s,%s,%d,%d,%8.6f\n',sID,'HbO',chn,bct-1,b_HbO(chn,bct)*1000000); %Homer2 concentration is Molar mm so convert to micromolar
                    fprintf(outfile,'%s,%s,%d,%d,%8.6f\n',sID,'HbR',chn,bct-1,b_HbR(chn,bct)*1000000); %Homer2 concentration is Molar mm so convert to micromolar
                end
            end
            
        else
            fprintf(fileIDlog,'No regressor events and no beta maps for Subject %s\n',sID);
        end %didGLM

        fclose(outfile);

    end %subjects
end %read input file

fclose(fileIDlog);

