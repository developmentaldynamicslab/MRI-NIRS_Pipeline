function TrimNIRS(inputFile,SamplingFreq,paddingStart,paddingEnd)

if 0
    inputFile = '09IND110G-VWM_run02.nirs';
    SamplingFreq = 25;
    paddingStart = 20;
    paddingEnd = 40;
end

%Read preprocessed NIRS file
load(inputFile, '-mat');

%save a copy of the original
oldFile = strcat(inputFile,'_orig');
save(char(oldFile),'aux','d','dStd','ml','procInput','procResult','s','SD','systemInfo','t','tdml','tIncMan','userdata');

%find first and last event in s matrix -- this defines the window
%of data we want...minus Xs padding.
[i,j]=find(procResult.s == 1);

startframe = min(i) - (SamplingFreq*paddingStart);
if (startframe < 1)
    startframe = 1;
end
endframe = max(i) + (SamplingFreq*paddingEnd);
if (endframe > size(procResult.s,1))
    endframe = size(procResult.s,1);
end
goodtime = endframe - startframe + 1;
new_s = zeros(goodtime,size(procResult.s,2));
for a=1:size(i,1)
    new_s((i(a,1) - startframe) + 1, j(a,1)) = 1;
end

%update data frames
aux = aux(startframe:endframe,:);
d = d(startframe:endframe,:);

procResult.dod=procResult.dod(startframe:endframe,:);
procResult.dc=procResult.dc(startframe:endframe,:,:);
procResult.tIncAuto=procResult.tIncAuto(startframe:endframe,:);
procResult.tIncAuto0=procResult.tIncAuto0(startframe:endframe,:);
procResult.tIncChAuto=procResult.tIncChAuto(startframe:endframe,:);
procResult.s=new_s;
s=new_s;

systemInfo.recInfo = systemInfo.recInfo(:,startframe:endframe);
systemInfo.rec999 = systemInfo.rec999(:,startframe:endframe);

t = t(startframe:endframe,:);
tdml = tdml(:,startframe:endframe);
tIncMan = tIncMan(startframe:endframe,:);

save(char(inputFile),'aux','d','dStd','ml','procInput','procResult','s','SD','systemInfo','t','tdml','tIncMan','userdata');
            
