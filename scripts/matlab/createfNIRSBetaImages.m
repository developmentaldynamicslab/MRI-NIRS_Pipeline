function createfNIRSBetaImages(subjectListFile)
% createfNIRSBetaImages(analysiDir,betaDir,subjectList)
%       Creates NIFTI images corresponding to the
%       combination of the Betas as well as the
%       fNIRS sensitivity profiles. The user provides
%       a list of subjects to be analyzed in a file
%       with the following format:
%       SubjectId NIRSFile ImageDir BetaDir ResultDir
%       The resulting NIFTI images wre written into
%       the ResultDir directory.
%

fileID = fopen(subjectListFile,'r');
if fileID < 0
    error 'Failed to open the subjectListFile for reading'
end
subjectList = textscan(fileID,'%s %s %s %s %s');
fclose(fileID)

numSubjects=size(subjectList{1},1);

for sub=1:numSubjects
    
    %% ACCESSES NIRS FILE FROM THE DIGITIZATION FOLDER
    load(subjectList{2}{sub}, '-mat');
    
    nWav = length(SD.Lambda);
    ml = SD.MeasList;
    e = GetExtinctions( SD.Lambda );
    if ~isfield(SD,'SpatialUnit')
        e = e(:,1:2) / 10;
    elseif strcmpi(SD.SpatialUnit,'mm')
        e = e(:,1:2) / 10;
    elseif strcmpi(SD.SpatialUnit,'cm')
        e = e(:,1:2) ;
    end
    
    lst = find( ml(:,4)==1 );
    %VAM - This needs to be checked
    numChannels=length(lst);
    %numChannels = 36;
    
    for idx=1:length(lst)
        idx1 = lst(idx);
        idx2 = find( ml(:,4)>1 & ml(:,1)==ml(idx1,1) & ml(:,2)==ml(idx1,2) );
        Rho(idx,1) = norm(SD.SrcPos(ml(idx1,1),:)-SD.DetPos(ml(idx1,2),:));
    end
    
    d=6*Rho;
    
    d=d([1:numChannels]);
    sd_pairs=[1:numChannels];
    
    
    %% Get the Subject Beta Files    
    oxyName=strcat(subjectList{4}{sub},'/Final_O_', subjectList{1}{sub},'.csv');
    fileID = fopen(oxyName,'r');
    if fileID < 0
        error 'Failed to open the NIRS beta file for reading'
    else
                
        oxyData=importdata(strcat(subjectList{4}{sub},'/Final_O_', subjectList{1}{sub},'.csv'));
        deoxyData=importdata(strcat(subjectList{4}{sub},'/Final_D_', subjectList{1}{sub},'.csv'));
        
        Y=[(e(1,1)*(d*ones(1,size(oxyData,2))).*oxyData)+ ...
            (e(1,2)*(d*ones(1,size(deoxyData,2))).*deoxyData); ...
            (e(2,1)*(d*ones(1,size(oxyData,2))).*oxyData)+ ...
            (e(2,2)*(d*ones(1,size(deoxyData,2))).*deoxyData)]*1E-6;  %convert to molar units
        
        
        for i=1:numel(d)
            %VAM - OLD Filename matching
            %varName1 = ['A' int2str(sd_pairs(i))];
            %VAM This filename needs to checked
            %imageFile=strcat(subjectList{3}{sub},'/',varName1,'_resam.nii');
            %imageFile=strcat(subjectList{3}{sub},'/',varName1,'.nii');
            %VAM - NEW Filename matching
            varName1 = ['C' int2str(sd_pairs(i))];
            matchStr=strcat(subjectList{3}{sub},'/viewer/Subject/AdotVol_S*_D*_',varName1,'.nii');
            niiFiles=dir(matchStr);
            imageFile=strcat(subjectList{3}{sub},'/viewer/Subject/',niiFiles(1).name);
            %VAM - Alternate Filename - Removed based on comments from John
            %imageFile=strcat(subjectList{3}{sub},'/viewer/Subject/AdotVol_Thresh_',varName1,'.nii');
            A_load = load_untouch_nii(imageFile);
            Adot(i,:)=reshape(A_load.img,1,[]);
            clear A_load;
        end
        
        e = GetExtinctions( SD.Lambda );  % You need to use the original (cm) version of e
        
        Adot=sparse(Adot.*(Adot>eps('single')));
        L = [(e(1,1)*Adot),(e(1,2)*Adot);(e(2,1)*Adot),(e(2,2)*Adot)];
        x=zeros(size(L,2),size(Y,2));
        lst_valid=find(sum(L,1)>0);
        
        [V,s,U]= svd(full(L(:,lst_valid))',0);
        s_diag=diag(s);
        
        for j=1:size(Y,2)
            lambda(j)= l_curve(U,s_diag,Y(:,j),'Tikh');
        end
        
        for j=1:size(Y,2)
            [x(lst_valid,j),rho,eta] = tikhonov(U,s_diag,V,Y(:,j),mean(lambda));
        end
        
        
        %% LOAD AN EXAMPLE SENSITIVITY PROFILE SO THAT THE RECONSTRUCTED IMAGE CAN BE LOADED INTO THE SAME STRUCTURE
        
        tempHbO = load_untouch_nii(imageFile);
        tempHbR = load_untouch_nii(imageFile);
        
        for j=1:size(Y,2)
            tempHbO.img=reshape(x(1:end/2,j),size(tempHbO.img))*1E6;  % Moves to micro-molar
            tempHbR.img=reshape(x(1+end/2:end,j),size(tempHbR.img))*1E6;
            
            varName2 = ['cond' int2str(j)];
            
            %% OUTPUT WILL BE SAVED for OXY AND DEOXY
            oxyFile=strcat(subjectList{5}{sub},'/Beta_', subjectList{1}{sub},'_', varName2,'_Unmasked_oxy.nii');
            save_untouch_nii(tempHbO,oxyFile);
            deoxyFile=strcat(subjectList{5}{sub},'/Beta_', subjectList{1}{sub},'_', varName2,'_Unmasked_deoxy.nii');
            save_untouch_nii(tempHbR,deoxyFile);
        end
        
    end
    
    clear Adot;
end



