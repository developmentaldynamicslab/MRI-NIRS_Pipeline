%oldSamplingFreq = sampling frequency of NIRS data in Hz (included here since not
%contained in the TechEN header...)

function ITI_Distribution(subjectListFile,regressorList,rName,oldSamplingFreq)

%run interactively
if 0
    subjectListFile = 'Y1_finalComboSubjListGroup.prn';
    regressorList = [1,2,3];
    rName = 'Y1';
    oldSamplingFreq = 25;
end

OutFileN = [rName '_ITI_Distribution.csv'];
if (exist(OutFileN,'file') == 0)
    fileIDlog = fopen(OutFileN,'w');
    fprintf(fileIDlog,'AnalysisLabel,Subject,Run,ITI\n');
else
    fileIDlog = fopen(OutFileN,'a');
end

fileID = fopen(subjectListFile,'r');
if fileID < 0
    fprintf('Failed to open the subjectListFile for reading\n');
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
                
        inputFileStr=strcat(subjectList{4}{n}, '/', subjects{n}, '*.nirs');
        files=dir(inputFileStr);
        
        foldernames = {files.folder};
        files = {files.name};
        filenames = strcat(foldernames,'/',files);
        
        numRuns=size(filenames,2);
        
        if numRuns == 0
            fprintf('No NIRS runs for Subject %s\n',sID);
        end
        
        for r=1:numRuns
            
            %Get preprocessed NIRS file into NeuroDOT format
            load(filenames{r}, '-mat');
            
            %find first and last event in s matrix -- this defines the window
            %of data we want to reconstruct...minus Xs padding.
            info.system.framerate=oldSamplingFreq;
            [i,j]=find(procResult.s == 1);
            
            if isempty(i)
                fprintf('No stims in NIRS file for run %d for Subject %s\n',r,sID);
            else
            
                k = find(j == regressorList(1));
                for tmp = 2:size(regressorList,2)
                    tmp2 = find(j == regressorList(tmp));
                    if ~isempty(k) && ~isempty(tmp2)
                        k = [k(:,1)' tmp2(:,1)']';
                    else
                        if ~isempty(tmp2)
                            k = [tmp2(:,1)']';
                        end
                    end
                end
                
                stims = sort(i(k));
                ITIs = diff(stims)./oldSamplingFreq;
                for tmp3=1:size(ITIs,1)
                    fprintf(fileIDlog,'%s,%s,%d,%.2f\n',rName,char(subjects{n}),r,ITIs(tmp3));
                end
                
            end %no stims
        end %runs
        
    end %subjects
    
end %subject file found

fclose(fileIDlog);

