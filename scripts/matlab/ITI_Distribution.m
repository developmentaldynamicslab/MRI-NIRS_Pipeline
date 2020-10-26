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
%converted to millimolar in the code.

function ITI_Distribution(subjectListFile,oldSamplingFreq)

%run interactively
if 0
    subjectListFile = 'Y2_finalComboSubjListGroup_1Subj.prn';
    oldSamplingFreq = 25;
end

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
        
        
        inputFileStr=strcat(subjectList{4}{n}, '/', subjects{n}, '*.nirs');
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
            load(filenames{r}, '-mat');
            
            %find first and last event in s matrix -- this defines the window
            %of data we want to reconstruct...minus Xs padding.
            info.system.framerate=oldSamplingFreq;
            [i,j]=find(procResult.s == 1);
            
            if isempty(i)
                fprintf(fileIDlog,'No stims in NIRS file for run %d for Subject %s\n',r,sID);
            else
                
                ITI_Dist
                
                startframe = min(i) - (info.system.framerate*paddingStart);
                if (startframe < 1)
                    startframe = 1;
                end
                endframe = max(i) + (info.system.framerate*paddingEnd);
                if (endframe > size(procResult.s,1))
                    endframe = size(procResult.s,1);
                end
                goodtime = endframe - startframe + 1;
                new_s = zeros(goodtime,size(procResult.s,2));
                for a=1:size(i,1)
                    new_s((i(a,1) - startframe) + 1, j(a,1)) = 1;
                end
                
            end %no stims
        end %runs
        
    end %subjects
    
end %subject file found

fclose(fileIDlog);

