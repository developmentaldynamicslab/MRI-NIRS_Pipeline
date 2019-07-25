clear all

%% LOAD ALL NIRS FILES WITHIN A DIRECTIORY
files = dir('*nirs'); 

filenames = {files.name};

for n=1:size(filenames,2)
    
    
eval(['load ' filenames{n} ' -mat'])

%% NUMBER OF CHANNELS
sd=1:36;

for x=1:numel(sd)
    
    %% NUMBER OF CONDITIONS
    for y=1:5
             if SD.MeasListAct(sd(x))==1 && SD.MeasListAct(numel(sd)+sd(x))==1 && procResult.nTrials(y) > 0
             O_run(x,y)=1000000*(procResult.beta(1,1,sd(x),y));
             D_run(x,y)=1000000*(procResult.beta(1,2,sd(x),y));

             else
                
            O_run(x,y)=0;
            D_run(x,y)=0;    
             end

    end 
end

%% WRITE OUT THE OUTPUT
eval(['FileNameO = sprintf(''' filenames{n} '_O.txt'')'])
csvwrite(FileNameO,nanmean(O_run,3));
eval(['FileNameD = sprintf(''' filenames{n} '_D.txt'')'])
csvwrite(FileNameD,nanmean(D_run,3));

clearvars -except Subj Subjects run runs filenames files

end













