clear all

subjlist={'4mo_S385' '4mo_S395' '4mo_S398' '4mo_S402' '4mo_S409' '4mo_S416' '4mo_S430' '4mo_S439' '4mo_S461' '4mo_S462' '4mo_S464' '4mo_S467' ...
    '4mo_S468' '4mo_S470' '4mo_S486' '4mo_S510' ...
    '1yo_S327' '1yo_S331' '1yo_S335' '1yo_S356' '1yo_S361' '1yo_S396' '1yo_S403' '1yo_S437' '1yo_S438' '1yo_S447' '1yo_S466' '1yo_S473' ...
    '1yo_S480' '1yo_S483' '1yo_S489' '1yo_S503' '1yo_S505' '1yo_S513' '1yo_S519' ...
    '2yo_S311' '2yo_S315' '2yo_S321' '2yo_S322' '2yo_S323' '2yo_S330' '2yo_S336' '2yo_S345' '2yo_S348' '2yo_S355' '2yo_S357' '2yo_S360' ...
    '2yo_S369' '2yo_S387' '2yo_S408' '2yo_S411' '2yo_S414' '2yo_S423' '2yo_S426' '2yo_S440' '2yo_S442' '2yo_S453'};

regionlist={'4Hb' '5AgexHb' '10SSxHb' '11AgexSSxHb' '21Hb_Age1v2' '23Hb_Age2v3' '25Hb_SS1v2' '27Hb_SS2v3'};

FName='Infants_cPL_gesConHb3/0.01/cPL_gesConHb3_ROIStats_Subj.csv';
outfile=fopen(FName,'a');
fct=1;

for r = 1:size(regionlist,2)
    
    for s = 1:size(subjlist,2)
        
        filename = char(strcat('Infants_cPL_gesConHb3/0.01/',regionlist(r),'/ROIstats/',regionlist(r),'_',subjlist(s),'.1D'));
        if ~(exist(filename,'file') == 0)
            
            ftemp(s) = importdata(filename);
            
            if fct == 1
                fct=0;
                fprintf(outfile,'Subject,Effect,Cluster,Year,Cond,Chromophore,Beta\n');
            end
            
            for cl=1:size(ftemp(s).data,2)
                for brick=1:12
                    if brick == 1
                        fprintf(outfile,'%s,%s,%d,%d,%d,%s,%8.6f\n',char(subjlist(s)),char(regionlist(r)),cl,1,1,'HbO',ftemp(s).data(brick,cl));
                    elseif brick == 2
                        fprintf(outfile,'%s,%s,%d,%d,%d,%s,%8.6f\n',char(subjlist(s)),char(regionlist(r)),cl,1,1,'HbR',ftemp(s).data(brick,cl));
                    elseif brick == 3
                        fprintf(outfile,'%s,%s,%d,%d,%d,%s,%8.6f\n',char(subjlist(s)),char(regionlist(r)),cl,1,2,'HbO',ftemp(s).data(brick,cl));
                    elseif brick == 4
                        fprintf(outfile,'%s,%s,%d,%d,%d,%s,%8.6f\n',char(subjlist(s)),char(regionlist(r)),cl,1,2,'HbR',ftemp(s).data(brick,cl));
                    elseif brick == 5
                        fprintf(outfile,'%s,%s,%d,%d,%d,%s,%8.6f\n',char(subjlist(s)),char(regionlist(r)),cl,1,3,'HbO',ftemp(s).data(brick,cl));
                    elseif brick == 6
                        fprintf(outfile,'%s,%s,%d,%d,%d,%s,%8.6f\n',char(subjlist(s)),char(regionlist(r)),cl,1,3,'HbR',ftemp(s).data(brick,cl));
                    end
                end
            end
        end
        
    end
    
    clear ftemp;
    
end

fclose(outfile);

