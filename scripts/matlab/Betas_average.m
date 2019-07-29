clear all

%% SUBJECT LIST FOR HbR extraction
subjects={'06IND001B*_D.txt'} 

for total=1:size(subjects,2)

files=dir(subjects{total});

filenames = {files.name};

%% NUMBER OF CHANNELS
for n=1:36
    
    %% NUMBER OF CONDITIONS
    for m=1:5
            
for Subj=1:size(filenames,2)
    
eval(['temp_' num2str(Subj) '=load(''' filenames{Subj} ''');'])

eval(['temp(Subj,1)=temp_' num2str(Subj) '(n,m)']);
        
        
if nnz(temp)>=1
    [r,p]=find(temp~=0);
    temp_final(n,m)=mean(temp(r,1));
    
elseif nnz(temp)==0
    temp_final(n,m)=0;

 clear r p temp
 

end

end

end
end

subjects_split=regexp(subjects,'*','split');

%% SAVE A SINGLE BETA FILE AFTER COMBINING OUTPUTS
eval(['FileNameOD = sprintf(''Final_D_' subjects_split{total}{1,1} ''')'])
csvwrite(FileNameOD,nanmean(temp_final,3));

clearvars -except subjects total 

end

clear all

%% SUBJECT LIST FOR HbO extraction
subjects={'06IND001B*_O.txt'} 

for total=1:size(subjects,2)

files=dir(subjects{total});

filenames = {files.name};

%% NUMBER OF CHANNELS
for n=1:36
    
    %% NUMBER OF CONDITIONS
    for m=1:5
            
for Subj=1:size(filenames,2)
    
eval(['temp_' num2str(Subj) '=load(''' filenames{Subj} ''');'])

eval(['temp(Subj,1)=temp_' num2str(Subj) '(n,m)']);
        
        
if nnz(temp)>=1
    [r,p]=find(temp~=0);
    temp_final(n,m)=mean(temp(r,1));
    
elseif nnz(temp)==0
    temp_final(n,m)=0;

 clear r p temp
 

end

end

end
end

subjects_split=regexp(subjects,'*','split');

%% SAVE A SINGLE BETA FILE AFTER COMBINING OUTPUTS
eval(['FileNameOD = sprintf(''Final_O_' subjects_split{total}{1,1} ''')'])
csvwrite(FileNameOD,nanmean(temp_final,3));

clearvars -except subjects total 

end

