function BetasExtractAndAverage(analysisDir, subjects)
% BetasExtractAndAverage(analysisDir)
%       Extracts the Betas per channel and averages
%       the data across runs. The resulkt is a csv
%       file that can be used later to generate an
%       image based representation of the results.
%       This is done in two steps to match what was
%       previously done
%


numSubjects=size(subjects,2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract the Beta s from the NIRS file and write to an
% ASCII text file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load the NIRS files for the specified subjects
% and write out the corresponding Oxy and Deoxy files.

for n=1:numSubjects

  inputFileStr=strcat(analysisDir, '/', subjects{n}, '*.nirs');
  files=dir(inputFileStr);
  filenames = {files.name};
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

        if SD.MeasListAct(x)==1 && SD.MeasListAct(numChannels+x)==1 && procResult.nTrials(y) > 0
          O_run(x,y)=1000000*(procResult.beta(1,1,x,y));
          D_run(x,y)=1000000*(procResult.beta(1,2,x,y));
        else
          O_run(x,y)=0;
          D_run(x,y)=0;
        end % End If

      end % end conditions loop

    end % end channel loop

    %% Write out the extracted betas
    outputOxyFile=strcat(analysisDir, '/', filenames{r}, '_O.txt');
    csvwrite(outputOxyFile,nanmean(O_run,3));
    outputDeoxyFile=strcat(analysisDir, '/', filenames{r}, '_D.txt');
    csvwrite(outputDeoxyFile,nanmean(D_run,3));
  end % end of run loop
end % end subject loop



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Average the results across runs for the specified subjects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

meanOxy=zeros(numChannels, numConditions);
meanDeoxy=zeros(numChannels, numConditions);

for s=1:numSubjects

  inputFileStr=strcat(analysisDir, '/', subjects{s}, '*.nirs_D.txt');
  files=dir(inputFileStr);

  filenames = {files.name};

  numRuns=size(filenames,2);
  deoxy=zeros(numChannels, numConditions, numRuns);

  %% Loop Over Runs
  for r=1:numRuns
    inputDeoxyFile=strcat(analysisDir, '/', filenames{r});
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

  outputFile=strcat(analysisDir, '/Final_D_', subjects{s}, '.csv');
  csvwrite(outputFile,meanDeoxy);

end


for s=1:numSubjects

  inputFileStr=strcat(analysisDir, '/', subjects{s}, '*.nirs_O.txt');
  files=dir(inputFileStr);

  filenames = {files.name};

  numRuns=size(filenames,2);
  oxy=zeros(numChannels, numConditions, numRuns);

  %% Loop Over Runs
  for r=1:numRuns
    inputOxyFile=strcat(analysisDir, '/', filenames{r});
    oxy(:,:, r)=load(inputOxyFile);
  end

  %% Loop Over Channels
  for n=1:numChannels
    %% Loop Over Conditions
    for m=1:numConditions
      if nnz(oxy(n,m,:))>=1
        meanOxy(n,m) = mean(nonzeros(deoxy(n,m,:)));
      else
        meanOxy(n,m) = 0.0;
      end
    end
  end

  outputFile=strcat(analysisDir, '/Final_O_', subjects{s}, '.csv');
  csvwrite(outputFile,meanOxy);

end














