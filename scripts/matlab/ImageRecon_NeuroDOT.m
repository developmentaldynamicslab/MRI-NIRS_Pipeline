function ImageRecon_NeuroDOT(subjectListFile)

%% John questions
%% --create image file for each run? Need to concat over runs when running GLM
%% or average betas as in Homer2?
%% --is framerate specified in the .nirs file? Would be best to read that in
%% --need to update section below on regressors / design matrix


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
    
    %% Loading data and setting up info structure for NeuroDOT
    imageFile=strcat(subjectList{3}{n},'/viewer/Subject/AdotVol_NeuroDOT2mm');

    [Anii,infoAnii] = LoadVolumetricData(imageFile, [],'nii');
    Nm=size(Anii,4);
    A=reshape(Anii,[],Nm);
    aM=max(A(:));
    info.tissue.infoT1=infoAnii;
    info.tissue.dim=infoAnii;
    info.tissue.dim.Good_Vox=find(sum(A,2)>(aM*1e-5)); % set threshold here
    info.tissue.dim.sV=info.tissue.dim.mmx;
    A=A(info.tissue.dim.Good_Vox,:)';
    imageFileND=strcat(subjectList{3}{n},'/viewer/Subject/Adot_',sID,'_nd2_2mm');
    save(imageFileND,'A','info','-v7.3')
    
    % %%%%% Set Parameters for Processing
    params.lambda_1=0.1; %range between 0.2-0.01--smoothness vs variance
    params.lambda_2=0.1; %range between 0.2-0.01--what is this??
    params.gsigma=3; % standard deviation of Gaussian smoothing kernel in mm
    
    inputFileStr=strcat(subjectList{4}{n}, '/', subjects{n}, '*.nirs');
    files=dir(inputFileStr);
    
    %JPS edits
    foldernames = {files.folder};
    files = {files.name};
    filenames = strcat(foldernames,'/',files);
    
    numRuns=size(filenames,2);
    
    for r=1:numRuns
        
        %Get preprocessed NIRS file into NeuroDOT format
        load(filenames{r}, '-mat');
        
        %%%JPS: check for any hard-coded values below (e.g., 40?),
        %%%wavelengths? 30? -- need to ensure code generalizes
        
        %%%%% put .nirs data into NeuroDOT structure %%%%%%%%%%
        data=procResult.dod';
        info.system.framerate=25;
        info.pairs=table;
        info.pairs.Src=SD.MeasList(:,1);
        info.pairs.Det=SD.MeasList(:,2);
        info.pairs.WL=SD.MeasList(:,4);
        info.pairs.lambda=cat(1,ones(20,1).*690, ones(20,1).*830);
        info.pairs.NN=ones(40,1);
        info.pairs.Mod=repmat({'CW'},[40,1]);
        info.pairs.r2d=ones(40,1).*30;
        info.pairs.r3d=ones(40,1).*30;
        
        %%JPS: update based on homer book-keeping
        info.MEAS.GI=procResult.SD.MeasListAct; %need to work out why pruning differs for different wavelengths in homer
        
        %View the raw data (d) as a function of time (t)
        % %         figure;
        % %         subplot(2,1,1);semilogy(t,procResult.dod);xlabel('time [sec]');ylabel('\Phi')
        % %         subplot(2,1,2);plot(t,procResult.s);xlabel('time [sec]');ylabel('Events')
        
        
        %loops through all of the regressors (2-9 are counted as regressors 1-8 in
        %the s matrix) and looks for 1s in each column to extract the time of each
        %event How do we mark which events are omitted due to motion correction if
        %we're pulling them directly from the s matrix?
        
        %%%%JPS needs to edit this section--need to figure out what we need
        %%%%for GLM, what to store in the image recon file, etc...
        [Nt,Nsptype]=size(procResult.s(:,1:6));
        info.paradigm.synchpts=[];
        info.paradigm.synchtype=[];
        for j=1:Nsptype
            events=find(procResult.s(:,j));
            info.paradigm.synchpts=cat(1,info.paradigm.synchpts,events);
            info.paradigm.synchtype=cat(1,info.paradigm.synchtype,ones(length(events),1).*j);
        end
        %syncpoints are like a placeholder or index for events--they just aren't coded by
        %the type of regressor
        [info.paradigm.synchpts,idx]=sort(info.paradigm.synchpts);
        info.paradigm.synchtype=info.paradigm.synchtype(idx);
        
        for j=1:Nsptype
            info.paradigm.(['Pulse_',num2str(j+1)])=find(info.paradigm.synchtype==j);
        end
        
        info.paradigm.Pulse_1=[];
        
        %% Image reconstruction
        % %         ba_channel = BlockAverage(data,info.paradigm.synchpts(info.paradigm.Pulse_3), 300);
        % %         figure; imagesc(data) %change colormap to view by channel
        % %         figure; imagesc(ba_channel)
        
        lmdata=data;
        params.rs_Hz=10;         % resample freq
        params.rs_tol=1e-5;     % resample tolerance
        [lmdata, info] = resample_tts(lmdata, info, params.rs_Hz, params.rs_tol);
        
        A=cat(1,A,A);
        Nvox=size(A,2);
        Nt=size(lmdata,2);
        cortex_mu_a=zeros(Nvox,Nt,2);
        
        %%JPS: what is j here?
        for j = 1:2
            keep = (info.pairs.WL == j) & info.MEAS.GI;
            disp('> Inverting A')
            iA = Tikhonov_invert_Amat(A(keep, :), params.lambda_1, params.lambda_2); % Invert A-Matrix
            disp('> Smoothing iA')
            iA = smooth_Amat(iA, info.tissue.dim, params.gsigma);         % Smooth Inverted A-Matrix
            cortex_mu_a(:, :, j) = reconstruct_img(lmdata(keep, :), iA);% Reconstruct Image Volume
        end
        
        %% Spectroscopy
        E=SD.extCoef;
        cortex_Hb = spectroscopy_img(cortex_mu_a, E);
        cortex_HbO = cortex_Hb(:, :, 1);
        cortex_HbR = cortex_Hb(:, :, 2);
        cortex_HbT = cortex_HbO + cortex_HbR;
        
        %% Save your data--create the nifti files with the nirs data in voxel space.
        varName2 = ['run' int2str(r)];
        oxyFile=strcat(subjectList{5}{n},'/',sID,'_',varName2,'_Unmasked_oxy_ND.nii');
        deoxyFile=strcat(subjectList{5}{n},'/',sID,'_',varName2,'_Unmasked_deoxy_ND.nii');
        NDFile=strcat(subjectList{5}{n},'/',sID,'_',varName2,'_ND');
       
        save(NDFile,'cortex_HbO','cortex_HbR','info', '-v7.3');
        
        % To save in nifti format, eg
% %         HbO_Vox=Good_Vox2vol(cortex_HbO,info.tissue.dim);
% %         SaveVolumetricData(oxyFile);
% %         
% %         HbR_Vox=Good_Vox2vol(cortex_HbR,info.tissue.dim);
% %         SaveVolumetricData(deoxyFile);
        
    end
end

