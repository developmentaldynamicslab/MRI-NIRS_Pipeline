%%
data_path='/Users/administrator/Desktop/54HWB088'

nDotDDPath='/Users/administrator/Documents/NeuroDOT_DDLab';
nDotPath='/Users/administrator/Documents/NeuroDOT_Beta';
hmrPath='/Users/administrator/Desktop/homer2-scm-2018-12-16';
%old_hmrPath='/local/epf15fpu/Desktop/homer2';
nirFastPath='/Users/administrator/Documents/NIRFAST-9.0';
%all of this is set up to go to one file--need a loop through all of the
%participant directories/participants. This script needs to be run in the
%folder with the RAW NIRS data
cd([data_path]);

sID='54HWB088.txt';
sDir=[data_path,'/',sID];
%cd([sDir]);

addpath(genpath(nDotPath))
addpath(genpath(nDotDDPath))
%rmpath(genpath(old_hmrPath))
addpath(genpath(hmrPath))


%% Loading data and setting up info structure for NeuroDOT

%Make the more compact light model stuff--look into whether we will use a
%separate light sensitivity profile for each wavelength
[Anii,infoAnii] = LoadVolumetricData(['AdotVol_NeuroDOT2mm'], [],'nii');
Nm=size(Anii,4);
A=reshape(Anii,[],Nm);
aM=max(A(:));
info.tissue.infoT1=infoAnii;
info.tissue.dim=infoAnii;
info.tissue.dim.Good_Vox=find(sum(A,2)>(aM*1e-5)); % set threshold here
info.tissue.dim.sV=info.tissue.dim.mmx;
A=A(info.tissue.dim.Good_Vox,:)';
save('Adot_54HWB088_nd2_2mm','A','info','-v7.3')

% %%%%% Set Parameters for Processing
% params.bthresh=1.0; %set the threshold for how much noise you will tolerate--will prune the entire channel--go no higher than 1.0
% params.logfft=1;
% params.hpfco=0.016; %this was set to 0.2 for some reason but my pipeline is 0.016.
% params.lpfco1=1;
% params.ssr=0;
% params.lpfco12=0.5; %low pass filter 
% params.A_fn='A_Pad_Pad_54HWB088.txt_190919_190919.mat_on_54HWB088.txt_HD_Mesh0a_r3dlt60mm_.mat';
params.lambda_1=0.1; %range between 0.2-0.01--smoothness vs variance 
params.lambda_2=0.1; %range between 0.2-0.01--what is this??
params.gsigma=3; % standard deviation of Gaussian smoothing kernel in mm 
% params.rs_Hz=1;     % resample freq
% params.rs_tol=1e-5;     % resample tolerance


%Get preprocessed NIRS file into NeuroDOT format
load('54HWB088_run01.nirs', '-mat');

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
info.MEAS.GI=procResult.SD.MeasListAct; %need to work out why pruning differs for different wavelengths in homer

%View the raw data (d) as a function of time (t)
figure;
subplot(2,1,1);semilogy(t,procResult.dod);xlabel('time [sec]');ylabel('\Phi')
subplot(2,1,2);plot(t,procResult.s);xlabel('time [sec]');ylabel('Events')


%loops through all of the regressors (2-9 are counted as regressors 1-8 in
%the s matrix) and looks for 1s in each column to extract the time of each
%event How do we mark which events are omitted due to motion correction if
%we're pulling them directly from the s matrix? 
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
% Plot_RawData_Time_Traces_Overview(data,info); %shows the measurements at each wavelenth at the top, and the filtered data with the syncpoints at the bottom. 
% Plot_RawData_Metrics_I_DQC(data,info, params); %top left, shows the strength of light against the source detector distance--they should all be clustered together if you have the same distance. 
% %bottom left, shows what frequencies have the most signal power--if you
% %don't see an increase in the cardiac and respiratory bands and have the
% %highest power in lower bands, you have noisy data. Here you might also see a spike where the strongest response to your stimulus is.  
% SaveGCF_to_PNG([sID,'_Raw_Data_Metrics'],1);


% %% Temporal Processing--view the preprocessing script
% lmdata = logmean(data);                                             % log mean--this is a way to identify good measurements
% info = FindGoodMeas(lmdata,info,params.bthresh);                    % threshold noisy measurements--takes as inputs the logmean data, the noise threshold, and various parameters related to optodes and framerate--but, why don't we have "info.system.synchpts after running it? 
% lmdata = detrend_tts(lmdata);                                       % Detrend--takes takes a raw light-level data array
% %   "data_in" of the format MEAS x TIME and removes the straight-line fit
% %   along the TIME dimension from each measurement, returning it as
% %   "data_out". 
% lmdata = highpass(lmdata, params.hpfco, info.system.framerate);     % high pass filter
% lmdata = lowpass(lmdata, params.lpfco1, info.system.framerate);     % Low pass filter
% if params.ssr                                               % Superficial signal regression%   If y_{r} is the signal to be regressed out and y_{in} is a data
% %   time trace (either source-detector or imaged), then the output
% %   is the least-squares regression: 
%     hem(1,:) = mean(data(info.pairs.WL==1,:));
%     hem(2,:) = mean(data(info.pairs.WL==2,:));
%     [lmdata, ~] = regcorr(lmdata, info, hem);
% end
% lmdata = lowpass(lmdata, params.lpfco12, info.system.framerate);
% [lmdata, info] = resample_tts(lmdata, info, params.rs_Hz, params.rs_tol); %   Resample NIRS data to 1 Hz. Note: This function resamples synch points in addition to data. Be sure
% %   to take care that your data and synch points match after running this
% %   function! "info.paradigm.init_synchpts" stores the original synch
% %   points if you need to restore them.

ba_channel = BlockAverage(data,info.paradigm.synchpts(info.paradigm.Pulse_3), 300);

%% Image reconstruction
figure; imagesc(data) %change colormap to view by channel
figure; imagesc(ba_channel)
lmdata=data;
A=cat(1,A,A);
Nvox=size(A,2);
Nt=size(lmdata,2);
cortex_mu_a=zeros(Nvox,Nt,2);
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

save([sID,'sarasdata'],'cortex_HbO','cortex_HbR','info', '-v7.3');
%save('myFile.mat', 'Variablename', '-v7.3')

% To save in nifti format, eg
HbO_Vox=Good_Vox2vol(cortex_HbO,info.tissue.dim);
SaveVolumetricData();

HbR_Vox=Good_Vox2vol(cortex_HbR,info.tissue.dim);
SaveVolumetricData();
%% glm your data
load('/Users/administrator/Documents/NeuroDOT_Beta/Support_Files/GLM/hrf_DOT3.mat'); % HbO hrf

%look at naming events to comp test first 
%info.paradigm=rmfield(info.paradigm, {'Pulse_8', 'Pulse_9', 'Pulse_10',8:17);
params.DoFilter=0;
[b,e,DM,EDM]=GLM_181206(cortex_HbO,hrf,info,params); %b is the beta values for each event,e is the reisduals, dm is the design matrix, edm is a different version of the design matrix you can set a flag to use where every 
figure;
imagesc(DM);
colormap('gray')

bmap=Good_Vox2vol(b(:,3), info.tissue.dim);
PlotSlices(bmap, info.tissue.dim)

%This function is run on the image reconstructed data but could be run in
%channel space if you change the data. 
ba = BlockAverage(cortex_HbO,info.paradigm.synchpts(info.paradigm.Pulse_3), 300);
% pulse = info.paradigm,synchpts(info.paradigm.Pulse_3)
%dt = time window for regression in samples (150 would be 6 seconds)
figure;
imagesc(ba)


