clear all

%cd /Volumes/ExFAT_2/Final_Gates/Group_Result/PL/Infants_cPL2017/p0.05/AllEffects/Masks_alleffects/HC/AgexHb/newROIstats
subjlist={'06IND012B' '06IND014B' '06IND016G' '06IND045G' '06IND047B' '06IND066B' '06IND073B' '06IND118G' '06IND120G' '06IND121B' '06IND131B' ...
    '06IND132B' '06IND137G' '06IND142B' '06IND144B' '06IND156B' '06IND160B' '06IND161G' '06IND168B' '06IND170B' '06IND172G' '06IND203G' ...
    '06IND204B' '06IND206B' '06IND211G' '06IND215G' '06IND217B' '06IND227G' '06IND256G' '06IND262B' '06IND271G' '06IND277B' '06IND279G' ...
    '06IND301G' '06IND303B' '06IND311B' '06IND321G' '06IND322G' '06IND327G' '06IND328G' '06IND334B' '06IND335B' '06IND336B' '06IND337G' ...
    '06IND355G' '06IND356G' '06IND361B' '06IND374B' '06IND387B' '09IND039G' '09IND060B' '09IND082G' '09IND106B' '09IND109B' '09IND110G' ...
    '09IND114B' '09IND116B' '09IND119B' '09IND133G' '09IND136B' '09IND151G' '09IND152G' '09IND154G' '09IND157G' '09IND167G' '09IND201B' ...
    '09IND202B' '09IND209B' '09IND210B' '09IND213B' '09IND216G' '09IND218G' '09IND240G' '09IND249G' '09IND252G' '09IND261B' '09IND265G' ...
    '09IND269B' '09IND270G' '09IND273G' '09IND302B' '09IND304B' '09IND312B' '09IND314G' '09IND315B' '09IND357B' '09IND358G' '09IND363B' ...
    '09IND365B' '09IND369B' '09IND370G' '09IND371G' '09IND377B' '09IND384B' '09IND385B' '09IND386G' '09IND390B' };

regionlist={'12Chrom' '13GenderxChrom' '14SESxChrom' '15GenderxSESxChrom' '20YearxChrom' '21GenderxYearxChrom' '22SESxYearxChrom' ...
    '23GenderxSESxYearxChrom' '24CondxChrom' '25GenderxCondxChrom' '26SESxCondxChrom' '27GenderxSESxCondxChrom' '28YearxCondxChrom' ...
    '29GenderxYearxCondxChrom' '30SESxYearxCondxChrom' '31GenderxSESxYearxCondxChrom'};

FName='Long_ANOVA/0.01/Long_ANOVA_ROIStats_Subj.csv';
outfile=fopen(FName,'a');
fct=1;

for r = 1:size(regionlist,2)
    
    for s = 1:size(subjlist,2)
        
        filename = char(strcat('Long_ANOVA/0.01/',regionlist(r),'/ROIstats/',regionlist(r),'_',subjlist(s),'.1D'));
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
                    elseif brick == 7
                        fprintf(outfile,'%s,%s,%d,%d,%d,%s,%8.6f\n',char(subjlist(s)),char(regionlist(r)),cl,2,1,'HbO',ftemp(s).data(brick,cl));
                    elseif brick == 8
                        fprintf(outfile,'%s,%s,%d,%d,%d,%s,%8.6f\n',char(subjlist(s)),char(regionlist(r)),cl,2,1,'HbR',ftemp(s).data(brick,cl));
                    elseif brick == 9
                        fprintf(outfile,'%s,%s,%d,%d,%d,%s,%8.6f\n',char(subjlist(s)),char(regionlist(r)),cl,2,2,'HbO',ftemp(s).data(brick,cl));
                    elseif brick == 10
                        fprintf(outfile,'%s,%s,%d,%d,%d,%s,%8.6f\n',char(subjlist(s)),char(regionlist(r)),cl,2,2,'HbR',ftemp(s).data(brick,cl));
                    elseif brick == 11
                        fprintf(outfile,'%s,%s,%d,%d,%d,%s,%8.6f\n',char(subjlist(s)),char(regionlist(r)),cl,2,3,'HbO',ftemp(s).data(brick,cl));
                    elseif brick == 12
                        fprintf(outfile,'%s,%s,%d,%d,%d,%s,%8.6f\n',char(subjlist(s)),char(regionlist(r)),cl,2,3,'HbR',ftemp(s).data(brick,cl));
                    end
                end
            end
        end
        
    end
    
    clear ftemp;
    
end

fclose(outfile);

