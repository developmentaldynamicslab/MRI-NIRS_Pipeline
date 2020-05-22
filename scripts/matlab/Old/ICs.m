clear all

%% SUBJECT LIST
subjects={'06IND001B 06IND045G'};


for total=1:size(subjects,2)

files=(subjects{total});

%% ACCESSES NIRS FILE FROM THE DIGITIZATION FOLDER
eval(['load ''/home/sw57/Desktop/MCs/' files '/digitization2/IND.nirs'' -mat'])

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
for idx=1:length(lst)
    idx1 = lst(idx);
    idx2 = find( ml(:,4)>1 & ml(:,1)==ml(idx1,1) & ml(:,2)==ml(idx1,2) );
    Rho(idx,1) = norm(SD.SrcPos(ml(idx1,1),:)-SD.DetPos(ml(idx1,2),:));
end
d=6*Rho;  

%% NUMBER OF CHANNELS
d=d([1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36]);  
sd_pairs=[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36];


%% ACCESSES BETA FILES
eval(['Data_O=importdata(''/home/sw57/Desktop/Betas/Final_O_' files ''');']);
eval(['Data_D=importdata(''/home/sw57/Desktop/Betas/Final_D_' files ''');']);

Y=[(e(1,1)*(d*ones(1,size(Data_O,2))).*Data_O)+(e(1,2)*(d*ones(1,size(Data_D,2))).*Data_D);(e(2,1)*(d*ones(1,size(Data_O,2))).*Data_O)+(e(2,2)*(d*ones(1,size(Data_D,2))).*Data_D)]*1E-6;  %convert to molar units


%% ACCESSES SENSITIVITY PROFILES FROM WITHIN DIGITIZATION FOLDER 
eval(['cd /home/sw57/Desktop/MCs/' files '/digitization2/viewer/Subject']);


for i=1:numel(d)
varName1 = ['A' int2str(sd_pairs(i))];
eval(['A_load = load_untouch_nii(''' varName1 '_resam.nii'');']);
Adot(i,:)=reshape(A_load.img,1,[]);
clear A_load;
end;


e = GetExtinctions( SD.Lambda );  

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

eval(['tempHbO = load_untouch_nii(''' varName1 '_resam.nii'');']);
eval(['tempHbR = load_untouch_nii(''' varName1 '_resam.nii'');']);

for j=1:size(Y,2) 
    tempHbO.img=reshape(x(1:end/2,j),size(tempHbO.img))*1E6;  % Moves to micro-molar
    tempHbR.img=reshape(x(1+end/2:end,j),size(tempHbR.img))*1E6;  
 
    
    varName2 = ['cond' int2str(j)];
    
%% OUTPUT WILL BE SAVED for OXY AND DEOXY    
    
    save_untouch_nii(tempHbO,['Load_' files '_' varName2 '_Unmasked_oxy.nii']);
    save_untouch_nii(tempHbR,['Load_' files '_' varName2 '_Unmasked_deoxy.nii']);
    
end

clear tempHbO tempHbR


clearvars -except subjects total


end
