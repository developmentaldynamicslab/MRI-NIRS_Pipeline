function ImageRecon_NeuroDOT(subjectListFile)

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
    
    % %%%%% Set Parameters for Processing
    params.lambda_1=0.1; %range between 0.2-0.01--smoothness vs variance
    params.lambda_2=0.1; %range between 0.2-0.01--what is this??
    params.gsigma=3; % standard deviation of Gaussian smoothing kernel in mm
    
    inputFileStr=strcat(subjectList{4}{n}, '/', subjects{n}, '*.nirs');
    files=dir(inputFileStr);
    
    foldernames = {files.folder};
    files = {files.name};
    filenames = strcat(foldernames,'/',files);
    
    numRuns=size(filenames,2);
    
    for r=1:numRuns
        
        %Get preprocessed NIRS file into NeuroDOT format
        load(filenames{r}, '-mat');
                
        %%%%% put .nirs data into NeuroDOT structure %%%%%%%%%%
        data=procResult.dod';
        meas=size(SD.MeasList,1);
        ch=meas/2;
        info.system.framerate=25;  %%%Can't find in .nirs file...grr. Hardcoding here.
        info.pairs=table;
        info.pairs.Src=SD.MeasList(:,1);
        info.pairs.Det=SD.MeasList(:,2);
        info.pairs.WL=SD.MeasList(:,4);
        info.pairs.lambda=cat(1,ones(ch,1).*procInput.SD.Lambda(1), ones(ch,1).*procInput.SD.Lambda(2));
        info.pairs.NN=ones(meas,1); 
        info.pairs.Mod=repmat({'CW'},[meas,1]);  
        info.pairs.r2d=ones(meas,1).*30; %%30MM 2D AND 3D DISTANCE BETWEEN PAIRS
        info.pairs.r3d=ones(meas,1).*30; %%30MM 2D AND 3D DISTANCE BETWEEN PAIRS
        
        if (r == 1)
            imageFileND=strcat(subjectList{5}{n},'Adot_',sID,'_nd2_2mm');
            save(imageFileND,'A','info','-v7.3')
        end
        
        %%update so pruning channels based on bad channels on either wavelength
        for ct=1:ch
            if (procResult.SD.MeasListAct(ct) == 0 | procResult.SD.MeasListAct(ct+ch) == 0)
                procResult.SD.MeasListAct(ct) = 0;
                procResult.SD.MeasListAct(ct+ch) = 0;
            end
        end
        info.MEAS.GI=procResult.SD.MeasListAct;
        
        %%%%read in regressors (s matrix in .nirs file)...
        [Nt,Nsptype]=size(procResult.s);
        info.paradigm.synchpts=[];
        info.paradigm.synchtype=[];
        for j=1:Nsptype
            events=find(procResult.s(:,j));
            info.paradigm.synchpts=cat(1,info.paradigm.synchpts,events);
            info.paradigm.synchtype=cat(1,info.paradigm.synchtype,ones(length(events),1).*j);
        end
        [info.paradigm.synchpts,idx]=sort(info.paradigm.synchpts);
        info.paradigm.synchtype=info.paradigm.synchtype(idx);
        
        for j=1:Nsptype
            info.paradigm.(['Pulse_',num2str(j+1)])=find(info.paradigm.synchtype==j);
        end
        
        info.paradigm.Pulse_1=[]; %dummy regressor in NeuroDOT
        
        %% Image reconstruction
        lmdata=data;
% %         params.rs_Hz=10;         % resample freq
% %         params.rs_tol=1e-5;     % resample tolerance
% %         [lmdata, info] = resample_tts(lmdata, info, params.rs_Hz, params.rs_tol);
        
        Nvox=size(A,2);
        Nt=size(lmdata,2);
        cortex_mu_a=zeros(Nvox,Nt,2);
        
        %%step through wavelengths...
        for j = 1:size(procInput.SD.Lambda,2)
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
        
        %% Save your data--output in ND format to save space.
        varName2 = ['run' int2str(r)];
        NDFile=strcat(subjectList{5}{n},'/',sID,'_',varName2,'_ND');       
        save(NDFile,'cortex_HbO','cortex_HbR','info', '-v7.3');
        
    end
end
