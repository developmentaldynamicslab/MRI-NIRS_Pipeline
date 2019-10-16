function BetasExtractAndAverage(subjectListFile)
% BetasExtractAndAverage(analysisDir, subjectListFile)
%       Extracts the Betas per channel and averages
%       the data across runs. The resulkt is a csv
%       file that can be used later to generate an
%       image based representation of the results.
%       This is done in two steps to match what was
%       previously done. The input to this function
%       are the analysisDirectory and a file containing
%       the subject list. The subject list file needs to
%       have a five columns with the following format:
%
%       SubjectId NIRSFile ImageDir BetaDir ResultDir AnatomicalHeadVox
%
%       This format now matches the commands used in
%       these steps.


fileID = fopen(subjectListFile,'r');
if fileID < 0
    error 'Failed to open the subjectListFile for reading'
end
%subjectList = textscan(fileID,'%s');
subjectList = textscan(fileID,'%s %s %s %s %s %s');
fclose(fileID)

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract the Beta s from the NIRS file and write to an
% ASCII text file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load the NIRS files for the specified subjects
% and write out the corresponding Oxy and Deoxy files.

for n=1:numSubjects
    
    n
    
    inputFileStr=strcat(subjectList{4}{n}, '/', subjects{n}, '*.nirs');
    files=dir(inputFileStr);
    
    %JPS edits
    foldernames = {files.folder};
    files = {files.name};
    filenames = strcat(foldernames,'/',files);
    
    numRuns=size(filenames,2);
    
    for r=1:numRuns
        load(filenames{r}, '-mat');
        
        k = find(SD.MeasList(:,4)==1);
        probe = SD.MeasList(k,:);
        numChannels = size(probe,1)
        numConditions=size(procResult.s,2)
        
        % Loop over Source/ Detector Pairs
        for x=1:numChannels
            
            % Loop over number of conditions
            for y=1:numConditions
                
                %JPS added conditional here since some files might have no
                %stim marks...
                if size(procResult.nTrials,1) > 0
                    if SD.MeasListAct(x)==1 && SD.MeasListAct(numChannels+x)==1 && procResult.nTrials(y) > 0
                        O_run(x,y)=1000000*(procResult.beta(1,1,x,y));
                        D_run(x,y)=1000000*(procResult.beta(1,2,x,y));
                    else
                        O_run(x,y)=0;
                        D_run(x,y)=0;
                    end                    
                else
                    O_run(x,y)=0;
                    D_run(x,y)=0;
                end % End If
                
            end % end conditions loop
            
        end % end channel loop
        
        %% Write out the extracted betas
        %JPS edit
        %    outputOxyFile=strcat(subjectList{4}{n}, '/', filenames{r}, '_O.txt');
        outputOxyFile=strcat(filenames{r}, '_O.txt');
        csvwrite(outputOxyFile,nanmean(O_run,3));
        
        %JPS edit
        %    outputDeoxyFile=strcat(subjectList{4}{n}, '/', filenames{r}, '_D.txt');
        outputDeoxyFile=strcat(filenames{r}, '_D.txt');
        csvwrite(outputDeoxyFile,nanmean(D_run,3));
        
        clear aux d dStd ml procInput procResult s SD systemInfo t tdml tIncMan userdata
        
    end % end of run loop
end % end subject loop



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Average the results across runs for the specified subjects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

meanOxy=zeros(numChannels, numConditions);
meanDeoxy=zeros(numChannels, numConditions);

for s=1:numSubjects
    
    inputFileStr=strcat(subjectList{4}{s}, '/', subjects{s}, '*.nirs_D.txt');
    files=dir(inputFileStr);
    
    filenames = {files.name};
    
    numRuns=size(filenames,2);
    deoxy=zeros(numChannels, numConditions, numRuns);
    
    %% Loop Over Runs
    for r=1:numRuns
        inputDeoxyFile=strcat(subjectList{4}{s}, '/', filenames{r});
        deoxy(:,:, r)=load(inputDeoxyFile);
    end
    
    %% Loop Over Channels
    for n=1:numChannels
        %% Loop Over Conditions
        for m=1:numConditions
            if nnz(deoxy(n,m,:))>=1
                meanDeoxy(n,m) = mean(nonzeros(deoxy(n,m,:)));
            else
                meanDeoxy(n,m) = 0.0;
            end
        end
    end
    
    outputFile=strcat(subjectList{4}{s}, '/Final_D_', subjects{s}, '.csv');
    csvwrite(outputFile,meanDeoxy);
    
end


for s=1:numSubjects
    
    inputFileStr=strcat(subjectList{4}{s}, '/', subjects{s}, '*.nirs_O.txt');
    files=dir(inputFileStr);
    
    filenames = {files.name};
    
    numRuns=size(filenames,2);
    oxy=zeros(numChannels, numConditions, numRuns);
    
    %% Loop Over Runs
    for r=1:numRuns
        inputOxyFile=strcat(subjectList{4}{s}, '/', filenames{r});
        oxy(:,:, r)=load(inputOxyFile);
    end
    
    %% Loop Over Channels
    for n=1:numChannels
        %% Loop Over Conditions
        for m=1:numConditions
            if nnz(oxy(n,m,:))>=1
                meanOxy(n,m) = mean(nonzeros(oxy(n,m,:)));
            else
                meanOxy(n,m) = 0.0;
            end
        end
    end
    
    outputFile=strcat(subjectList{4}{s}, '/Final_O_', subjects{s}, '.csv');
    csvwrite(outputFile,meanOxy);
    
end















