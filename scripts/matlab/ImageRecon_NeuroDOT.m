%oldSamplingFreq = sampling frequency of NIRS data in Hz (included here since not
%contained in the TechEN header...)

%newSamplingFreq --> specify a new sampling freq (e.g., if you want to
%downsample). Otherwise, oldSamplingFreq and newSamplingFreq should match.
%Specify this in Hz.

%padding --> only reconstruct data from first to last stim mark to keep
%file sizes as small as possible. Padding gives you a bit of extra data
%before the first stim and after the last stim in case you want a baseline.
%Specify this in seconds.

%baseSDmm --> the 'base' separation between sources and detectors in mm.
%Not currently used in this code, but a parameter one can use in NeuroDOT
%so setting it explicitly here.

%FFRproportion --> threshold the spectroscopy results by normalizing the
%flat field reconstruction by the max(ffr) and then take any normalized
%value > FFRproportion (e.g., anything > 5%)

%usePrahl --> use extinction coefficients from Scott Prahl. If this flag is
%set to 0, we are assuming the desired coeffs are in SD.extCoef in the
%.nirs file and in (1/cm)/(moles/liter) units. Note that these values are
%converted to millimolar in the code. Note also that this is the default
%option if using .snirf files (as there is no option to include this in the
%SD.extCoef structure).

function ImageRecon_NeuroDOT(subjectListFile,oldSamplingFreq,newSamplingFreq,paddingStart,paddingEnd,baseSDmm,FFRproportion,usePrahl,GSR)

%run interactively
if 0
    subjectListFile = 'Y2_finalComboSubjListGroup_1Subj.prn';
    oldSamplingFreq = 25;
    newSamplingFreq = 10;
    paddingStart = 20;
    paddingEnd = 40;
    baseSDmm = 30;
    FFRproportion = 0.05;
    usePrahl = 1;
    GSR = 1; %use global signal regression
end

%flag to view the FFR data for each subject/run if desired
viewFFR = 0;

logFilename = ['ImageRecon_NeuroDOT_', datestr(now, 'yyyy-mm-dd-THHMMSS') '.log'];
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
    
    for n=1:numSubjects
        
        sID=subjects{n}
        fprintf(fileIDlog,'Processing Subject %s\n',sID);
        
        %% Loading data and setting up info structure for NeuroDOT
        imageFile=strcat(subjectList{3}{n},'/viewer/Subject/AdotVol_NeuroDOT2mm');
        
        if ~exist(strcat(imageFile,'.nii'))
            fprintf(fileIDlog,'Failed to open light model: %s\n',strcat(imageFile,'.nii'));
        else
            
            [Anii,infoAnii] = LoadVolumetricData(imageFile, [],'nii');
            Nm=size(Anii,4);
            A=reshape(Anii,[],Nm);
            aM=max(A(:));
            info.tissue.infoT1=infoAnii;
            info.tissue.dim=infoAnii;
            info.tissue.dim.Good_Vox=find(sum(A,2)>(aM*1e-5)); % set threshold here
            info.tissue.dim.sV=info.tissue.dim.mmx;
            A=A(info.tissue.dim.Good_Vox,:)';
            
            % %%%%% Set Parameters for Processing
            params.lambda_1=0.1; %range between 0.2-0.01--smoothness vs variance
            params.lambda_2=0.1; %range between 0.2-0.01--pushing reconstruction into the volume
            params.gsigma=3; % standard deviation of Gaussian smoothing kernel in mm
            
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
            
            for r=1:numRuns
                
                %Get preprocessed NIRS file into NeuroDOT format
                [filepath,name,ext] = fileparts(filenames{r});
                if strcmp(ext,'.nirs')
                    %if .nirs file
                    load(filenames{r},'-mat');
                    
                    nLambda = size(SD.Lambda,2);
                    dLambda = SD.Lambda; %[690,830];
                    dextCoef = SD.extCoef; %2x2 matrix
                    smatrix = procResult.s; %time x regressors
                    timepts = size(smatrix,1); %time
                    nregressors = size(smatrix,2); %regressors
                    doddata = procResult.dod; %time x ch
                    meas=size(SD.MeasList,1); %length ch*WL
                    sourcelist = SD.MeasList(:,1); %source list ch*WL
                    detectorlist = SD.MeasList(:,2); %det list ch*WL
                    wavelengthlist = SD.MeasList(:,4); %WL list ch*WL
                    includedCh = procResult.SD.MeasListAct; %1 = included ch*WL

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
                
                %load Prahl extinction coeffs and write to .nirs file
                if usePrahl | strcmp(ext,'.snirf')
                    %Prahl mat file has an 'info' structure that is
                    %overwriting my info from the light model. Prevent this
                    %from happening...
                    infoSafe = info;
                    load('Ecoeff_Prahl.mat');
                    info = infoSafe;
                    
                    %step through each wavelength
                    ExtCoeff = zeros(nLambda,2); %second dim is HbO, HbR
                    for j = 1:nLambda
                        ExtCoeff(j,:) = prahlEC(ismember(prahlEC(:,1),dLambda(j)),2:3).*[2.303,2.303]./1000; %divide by 1000 to move to 1/millimolar
                    end
                    dextCoef = ExtCoeff.*1000; %write output in 1/molar
                    if strcmp(ext,'.nirs')
                        save(char(filenames{r}),'aux','d','dStd','ml','procInput','procResult','s','SD','systemInfo','t','tdml','tIncMan','userdata','-mat');
                    end
                end
                dextCoef = dextCoef./1000; %assuming input coeffs are in 1/molar; convert to 1/millimolar
                
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
                    fprintf(fileIDlog,'No stims in NIRS file for run %d for Subject %s\n',r,sID);
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
                    data=doddata(startframe:endframe,:)';
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
                    
                    if (r == 1)
                        imageFileND=strcat(subjectList{5}{n},'/Adot_',sID,'_nd2_2mm');
                        save(imageFileND,'A','info','-v7.3')
                    end
                    
                    %%update so pruning channels based on bad channels on either wavelength
                    for ct=1:ch
                        if (includedCh(ct) == 0 | includedCh(ct+ch) == 0)
                            includedCh(ct) = 0;
                            includedCh(ct+ch) = 0;
                        end
                    end
                    
                    info.MEAS.GI=includedCh;
                    
                    %%if no data, move on...
                    if sum(includedCh) == 0
                        fprintf(fileIDlog,'All NIRS channels pruned for Subject %s Run %d\n',sID,r);
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
                        
                        %% Image reconstruction
                        lmdata=data;
                        
                        if (GSR)
                            % lmdata is Nm measurements by Nt time with first Nm/2 as 1 wavelength and 2nd set as 2nd wavelength.
                            keep1= ((info.MEAS.GI==1).*(info.pairs.WL==1))==1;
                            keep2= ((info.MEAS.GI==1).*(info.pairs.WL==2))==1;
                            
                            WL1gdave=nanmean(lmdata(keep1,:),1);
                            WL2gdave=nanmean(lmdata(keep2,:),1);
                            
                            meanSign = cat(1,WL1gdave, WL2gdave);   % 2xNt matrix of mean signals for each wavelength
                            lmdata = regcorr(lmdata, info, meanSign);
                        end
                        
                        if (newSamplingFreq ~= info.system.framerate)
                            
                            if isfield(info.paradigm,'init_synchpts')
                                info.paradigm = rmfield(info.paradigm,'init_synchpts');
                            end
                            params.rs_Hz=newSamplingFreq;         % resample freq
                            params.rs_tol=1e-5;     % resample tolerance
                            [lmdata, info] = resample_tts(lmdata, info, params.rs_Hz, params.rs_tol);
                        end
                        
                        Nvox=size(A,2);
                        Nt=size(lmdata,2);
                        cortex_mu_a=zeros(Nvox,Nt,2);
                        
                        %%step through wavelengths...
                        for j = 1:nLambda
                            keep = (info.pairs.WL == j) & info.MEAS.GI; %COULD ADD CUTOFF HERE BASED ON DISTANCE
                            disp('> Inverting A')
                            iA = Tikhonov_invert_Amat(A(keep, :), params.lambda_1, params.lambda_2); % Invert A-Matrix
                            disp('> Smoothing iA')
                            iA = smooth_Amat(iA, info.tissue.dim, params.gsigma);         % Smooth Inverted A-Matrix
                            cortex_mu_a(:, :, j) = reconstruct_img(lmdata(keep, :), iA);% Reconstruct Image Volume
                        end
                        
                        % FFR
                        ffr=makeFlatFieldRecon(A(keep, :),iA); % make ?flat field? use for masking data
                        ffrNorm=ffr./max(ffr);
                        maskffr=+(ffrNorm>FFRproportion); %threshold at 1%
                        
                        %Code to view the flat field reconstruction
                        if viewFFR
                            headvolFile=strcat(subjectList{3}{n},'/viewer/Subject/headvol_2mm');
                            [Anii2,infoAnii2]=LoadVolumetricData(headvolFile,[],'nii');
                            ffrnormb=Good_Vox2vol(ffrNorm,info.tissue.dim);
                            ffrnormc=Good_Vox2vol(maskffr,info.tissue.dim);
                            PlotSlices(Anii2,info.tissue.dim,[],ffrnormc)
                        end
                        
                        %% Spectroscopy
                        E=dextCoef;
                        cortex_Hb = spectroscopy_img(cortex_mu_a, E);
                        
                        cortex_Hb = bsxfun(@times, cortex_Hb, maskffr);
                        
                        cortex_HbO = cortex_Hb(:, :, 1).*1000; %convert to micromolar; see 10/12/19 email
                        cortex_HbR = cortex_Hb(:, :, 2).*1000; %convert to micromolar; see 10/12/19 email
                        cortex_HbT = cortex_HbO + cortex_HbR;
                        
                        %% Save your data--output in ND format to save space.
                        varName2 = ['run' int2str(r)];
                        NDFile=strcat(subjectList{5}{n},'/',sID,'_',varName2,'_ND');
                        save(NDFile,'cortex_HbO','cortex_HbR','info', '-v7.3');
                        
                    end %channels pruned
                end %no stims
            end %runs
            
        end %imageFile found
        
    end %subjects
    
end %subject file found

fclose(fileIDlog);

