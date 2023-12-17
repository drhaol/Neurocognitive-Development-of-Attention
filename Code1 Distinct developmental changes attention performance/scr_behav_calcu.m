# written by dr.haol
# haolll@swu.edu.cn
clear
clc

%% Basic Information Set up
group  = 'CBDHA';
subgrp = 'CBDHA';
task   = 'ANT2';

edata_file  = '/Users/haol/Downloads/EprimeData/CBDHA_80/CBDHA_ANT2.txt';
subj_file   = '/Users/haol/Downloads/EprimeData/CBDHA_80/CBDHA_ANT2_list.txt';
res_savedir = '/Users/haol/Downloads/EprimeData/CBDHA_80';

%% Read E-Prime Data Index
index = {'Subject';
    'PracSlideTarget.OnsetTime';
    'PracSlideFixationStart.OnsetTime';
    'PracSlideTarget.ACC';
    'PracSlideTarget.RT';
    'FlankerType';
    'WarningType'};

%% Import E-prime_ID & Img_ID
fid = fopen(subj_file); sublist = {}; cnt_sub = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    sublist(cnt_sub,:) = linedata{1}; cnt_sub = cnt_sub+1; %#ok<*SAGROW>
end
fclose(fid);

%% Import E-prime data (Edata)
fid = fopen(edata_file); edata_all = {}; cnt_data = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    edata_all(cnt_data,:) = linedata{1}; cnt_data = cnt_data+1;
end
fclose(fid);

all_index = edata_all(1,:);
for a = 1:length(index)
    for b = 2:length(edata_all)
        edata(b-1,a) = edata_all(b,strcmp(all_index,index{a,1}));
    end
end

%% Calcu Behavior
allres={'Subj_ID','Scan_ID','Group','SubGrp',...
    'A_NoDoub_med','O_CenSpat_med','C_InconCon_med',...
    'A_NoDoub_mean','O_CenSpat_mean','C_InconCon_mean',...
    'RT_Con_No_med','RT_Con_Cent_med','RT_Con_Doub_med','RT_Con_Spat_med',...
    'RT_Incon_No_med','RT_Incon_Cent_med','RT_Incon_Doub_med','RT_Incon_Spat_med',...
    'RT_Con_No_mean','RT_Con_Cent_mean','RT_Con_Doub_mean','RT_Con_Spat_mean',...
    'RT_Incon_No_mean','RT_Incon_Cent_mean','RT_Incon_Doub_mean','RT_Incon_Spat_mean',...
    'ACC_Con_No','ACC_Con_Cent','ACC_Con_Doub','ACC_Con_Spat',...
    'ACC_Incon_No','ACC_Incon_Cent','ACC_Incon_Doub','ACC_Incon_Spat', ...
    'ACC_mean'};

% 'A_No-Cen_med_abs','A_No-Doub_med_abs','O_Cen-Spat_med_abs','C_Incon-Con_med_abs',...
% 'A_No-Cen_mean_abs','A_No-Doub_mean_abs','O_Cen-Spat_mean_abs','C_Incon-Con_mean_abs',...

[nsub,~] = size(sublist);
for isub = 1:nsub
    %% Acquire Each Subject Edata Matrix
    [sub_trial,~] = find(str2double(edata(:,strcmp(index,'Subject')))==str2double(sublist{isub,1}));
    sub_edata     = edata(sub_trial,:);
    
    %% Calcu Each Condition Trial Number
    Sum_Con_NoCue     = 0;
    Sum_Con_DoubCue   = 0;
    Sum_Con_CentCue   = 0;
    Sum_Con_SpatCue   = 0;
    Sum_Incon_NoCue   = 0;
    Sum_Incon_DoubCue = 0;
    Sum_Incon_CentCue = 0;
    Sum_Incon_SpatCue = 0;
    
    for d = 1:length(sub_trial)
        if strcmp(sub_edata(d,strcmp(index,'FlankerType')),'congruent') && strcmp(sub_edata(d,strcmp(index,'WarningType')),'no')
            Sum_Con_NoCue = Sum_Con_NoCue + 1;
        end
        
        if strcmp(sub_edata(d,strcmp(index,'FlankerType')),'congruent') && strcmp(sub_edata(d,strcmp(index,'WarningType')),'double')
            Sum_Con_DoubCue = Sum_Con_DoubCue + 1;
        end
        
        if strcmp(sub_edata(d,strcmp(index,'FlankerType')),'congruent') && strcmp(sub_edata(d,strcmp(index,'WarningType')),'center')
            Sum_Con_CentCue = Sum_Con_CentCue + 1;
        end
        
        if (strcmp(sub_edata(d,strcmp(index,'FlankerType')),'congruent') && strcmp(sub_edata(d,strcmp(index,'WarningType')),'up') || ...
                strcmp(sub_edata(d,strcmp(index,'FlankerType')),'congruent') && strcmp(sub_edata(d,strcmp(index,'WarningType')),'down'))
            Sum_Con_SpatCue = Sum_Con_SpatCue + 1;
        end
        
        if strcmp(sub_edata(d,strcmp(index,'FlankerType')),'incongruent') && strcmp(sub_edata(d,strcmp(index,'WarningType')),'no')
            Sum_Incon_NoCue = Sum_Incon_NoCue + 1;
        end
        
        if strcmp(sub_edata(d,strcmp(index,'FlankerType')),'incongruent') && strcmp(sub_edata(d,strcmp(index,'WarningType')),'double')
            Sum_Incon_DoubCue = Sum_Incon_DoubCue + 1;
        end
        
        if strcmp(sub_edata(d,strcmp(index,'FlankerType')),'incongruent') && strcmp(sub_edata(d,strcmp(index,'WarningType')),'center')
            Sum_Incon_CentCue = Sum_Incon_CentCue + 1;
        end
        
        if (strcmp(sub_edata(d,strcmp(index,'FlankerType')),'incongruent') && strcmp(sub_edata(d,strcmp(index,'WarningType')),'up') || ...
                strcmp(sub_edata(d,strcmp(index,'FlankerType')),'incongruent') && strcmp(sub_edata(d,strcmp(index,'WarningType')),'down'))
            Sum_Incon_SpatCue = Sum_Incon_SpatCue + 1;
        end
    end
    
    %% Acquire Each Condition Data Matrix
    RT_NoCueMat   = [];
    RT_DoubCueMat = [];
    RT_CentCueMat = [];
    RT_SpatCueMat = [];
    RT_CongMat    = [];
    RT_IncongMat  = [];
    
    RT_Con_NoCue_Mat     = [];
    RT_Con_DoubCue_Mat   = [];
    RT_Con_CentCue_Mat   = [];
    RT_Con_SpatCue_Mat   = [];
    RT_Incon_NoCue_Mat   = [];
    RT_Incon_DoubCue_Mat = [];
    RT_Incon_CentCue_Mat = [];
    RT_Incon_SpatCue_Mat = [];
    
    ACC_Con_NoCue_Mat     = [];
    ACC_Con_DoubCue_Mat   = [];
    ACC_Con_CentCue_Mat   = [];
    ACC_Con_SpatCue_Mat   = [];
    ACC_Incon_NoCue_Mat   = [];
    ACC_Incon_DoubCue_Mat = [];
    ACC_Incon_CentCue_Mat = [];
    ACC_Incon_SpatCue_Mat = [];
    
    for e = 1:length(sub_trial)
        % Acquire CueRT Matrix
        if (str2double(edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(e,1),strcmp(index,'WarningType')),'no'))
            temp_val = edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.RT'));
            RT_NoCueMat = [RT_NoCueMat;str2double(temp_val{1,1})]; %#ok<*AGROW>
        end
        
        if (str2double(edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(e,1),strcmp(index,'WarningType')),'double'))
            temp_val = edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.RT'));
            RT_DoubCueMat = [RT_DoubCueMat;str2double(temp_val{1,1})];
        end
        
        if (str2double(edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(e,1),strcmp(index,'WarningType')),'center'))
            temp_val = edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.RT'));
            RT_CentCueMat = [RT_CentCueMat;str2double(temp_val{1,1})];
        end
        
        if (str2double(edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.ACC')))==1 && (strcmp(edata(sub_trial(e,1),strcmp(index,'WarningType')),'up') || ...
                strcmp(edata(sub_trial(e,1),strcmp(index,'WarningType')),'down')))
            temp_val = edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.RT'));
            RT_SpatCueMat = [RT_SpatCueMat;str2double(temp_val{1,1})];
        end
        
        % Acquire TargetRT Matrix
        if (str2double(edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(e,1),strcmp(index,'FlankerType')),'congruent'))
            temp_val = edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.RT'));
            RT_CongMat = [RT_CongMat;str2double(temp_val{1,1})];
        end
        
        if (str2double(edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(e,1),strcmp(index,'FlankerType')),'incongruent'))
            temp_val = edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.RT'));
            RT_IncongMat = [RT_IncongMat;str2double(temp_val{1,1})];
        end
        
        % Acquire RT Matrix
        if (str2double(edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(e,1),strcmp(index,'FlankerType')),'congruent') && ...
                strcmp(edata(sub_trial(e,1),strcmp(index,'WarningType')),'no'))
            temp_val = edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.RT'));
            RT_Con_NoCue_Mat = [RT_Con_NoCue_Mat;str2double(temp_val{1,1})];
        end
        
        if (str2double(edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(e,1),strcmp(index,'FlankerType')),'congruent') && ...
                strcmp(edata(sub_trial(e,1),strcmp(index,'WarningType')),'double'))
            temp_val = edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.RT'));
            RT_Con_DoubCue_Mat = [RT_Con_DoubCue_Mat;str2double(temp_val{1,1})];
        end
        
        if (str2double(edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(e,1),strcmp(index,'FlankerType')),'congruent') && ...
                strcmp(edata(sub_trial(e,1),strcmp(index,'WarningType')),'center'))
            temp_val = edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.RT'));
            RT_Con_CentCue_Mat = [RT_Con_CentCue_Mat;str2double(temp_val{1,1})];
        end
        
        if (str2double(edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(e,1),strcmp(index,'FlankerType')),'congruent') && ...
                (strcmp(edata(sub_trial(e,1),strcmp(index,'WarningType')),'up') || strcmp(edata(sub_trial(e,1),strcmp(index,'WarningType')),'down')))
            temp_val = edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.RT'));
            RT_Con_SpatCue_Mat = [RT_Con_SpatCue_Mat;str2double(temp_val{1,1})];
        end
        
        if (str2double(edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(e,1),strcmp(index,'FlankerType')),'incongruent') && ...
                strcmp(edata(sub_trial(e,1),strcmp(index,'WarningType')),'no'))
            temp_val = edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.RT'));
            RT_Incon_NoCue_Mat = [RT_Incon_NoCue_Mat;str2double(temp_val{1,1})];
        end
        
        if (str2double(edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(e,1),strcmp(index,'FlankerType')),'incongruent') && ...
                strcmp(edata(sub_trial(e,1),strcmp(index,'WarningType')),'double'))
            temp_val = edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.RT'));
            RT_Incon_DoubCue_Mat = [RT_Incon_DoubCue_Mat;str2double(temp_val{1,1})];
        end
        
        if (str2double(edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(e,1),strcmp(index,'FlankerType')),'incongruent') && ...
                strcmp(edata(sub_trial(e,1),strcmp(index,'WarningType')),'center'))
            temp_val = edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.RT'));
            RT_Incon_CentCue_Mat = [RT_Incon_CentCue_Mat;str2double(temp_val{1,1})];
        end
        
        if (str2double(edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(e,1),strcmp(index,'FlankerType')),'incongruent') && ...
                (strcmp(edata(sub_trial(e,1),strcmp(index,'WarningType')),'up') || strcmp(edata(sub_trial(e,1),strcmp(index,'WarningType')),'down')))
            temp_val = edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.RT'));
            RT_Incon_SpatCue_Mat = [RT_Incon_SpatCue_Mat;str2double(temp_val{1,1})];
        end
        
        % Acquire ACC Matrix
        if (str2double(edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(e,1),strcmp(index,'FlankerType')),'congruent') && ...
                strcmp(edata(sub_trial(e,1),strcmp(index,'WarningType')),'no'))
            temp_val = edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.ACC'));
            ACC_Con_NoCue_Mat = [ACC_Con_NoCue_Mat;str2double(temp_val{1,1})];
        end
        
        if (str2double(edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(e,1),strcmp(index,'FlankerType')),'congruent') && ...
                strcmp(edata(sub_trial(e,1),strcmp(index,'WarningType')),'double'))
            temp_val = edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.ACC'));
            ACC_Con_DoubCue_Mat = [ACC_Con_DoubCue_Mat;str2double(temp_val{1,1})];
        end
        
        if (str2double(edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(e,1),strcmp(index,'FlankerType')),'congruent') && ...
                strcmp(edata(sub_trial(e,1),strcmp(index,'WarningType')),'center'))
            temp_val = edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.ACC'));
            ACC_Con_CentCue_Mat = [ACC_Con_CentCue_Mat;str2double(temp_val{1,1})];
        end
        
        if (str2double(edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(e,1),strcmp(index,'FlankerType')),'congruent') && ...
                (strcmp(edata(sub_trial(e,1),strcmp(index,'WarningType')),'up') || strcmp(edata(sub_trial(e,1),strcmp(index,'WarningType')),'down')))
            temp_val = edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.ACC'));
            ACC_Con_SpatCue_Mat = [ACC_Con_SpatCue_Mat;str2double(temp_val{1,1})];
        end
        
        if (str2double(edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(e,1),strcmp(index,'FlankerType')),'incongruent') && ...
                strcmp(edata(sub_trial(e,1),strcmp(index,'WarningType')),'no'))
            temp_val = edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.ACC'));
            ACC_Incon_NoCue_Mat = [ACC_Incon_NoCue_Mat;str2double(temp_val{1,1})];
        end
        
        if (str2double(edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(e,1),strcmp(index,'FlankerType')),'incongruent') && ...
                strcmp(edata(sub_trial(e,1),strcmp(index,'WarningType')),'double'))
            temp_val = edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.ACC'));
            ACC_Incon_DoubCue_Mat = [ACC_Incon_DoubCue_Mat;str2double(temp_val{1,1})];
        end
        
        if (str2double(edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(e,1),strcmp(index,'FlankerType')),'incongruent') && ...
                strcmp(edata(sub_trial(e,1),strcmp(index,'WarningType')),'center'))
            temp_val = edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.ACC'));
            ACC_Incon_CentCue_Mat = [ACC_Incon_CentCue_Mat;str2double(temp_val{1,1})];
        end
        
        if (str2double(edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(e,1),strcmp(index,'FlankerType')),'incongruent') && ...
                (strcmp(edata(sub_trial(e,1),strcmp(index,'WarningType')),'up') || strcmp(edata(sub_trial(e,1),strcmp(index,'WarningType')),'down')))
            temp_val = edata(sub_trial(e,1),strcmp(index,'PracSlideTarget.ACC'));
            ACC_Incon_SpatCue_Mat = [ACC_Incon_SpatCue_Mat;str2double(temp_val{1,1})];
        end
    end
    %% Calculate Alerting & Orienting & Conflict RT
    
    RT_NoCue_mean   = mean(RT_NoCueMat);
    RT_DoubCue_mean = mean(RT_DoubCueMat);
    RT_CentCue_mean = mean(RT_CentCueMat);
    RT_SpatCue_mean = mean(RT_SpatCueMat);
    RT_Cong_mean    = mean(RT_CongMat);
    RT_Incong_mean  = mean(RT_IncongMat);
    
    RT_NoCue_med   = median(RT_NoCueMat);
    RT_DoubCue_med = median(RT_DoubCueMat);
    RT_CentCue_med = median(RT_CentCueMat);
    RT_SpatCue_med = median(RT_SpatCueMat);
    RT_Cong_med    = median(RT_CongMat);
    RT_Incong_med  = median(RT_IncongMat);
    
    %% Calculate Alerting & Orienting & Conflict Network Index
    A_NoDoub_med_abs   = RT_NoCue_med - RT_DoubCue_med;
    O_CenSpat_med_abs  = RT_CentCue_med - RT_SpatCue_med;
    C_InconCon_med_abs = RT_Incong_med - RT_Cong_med;
    
    A_NoDoub_mean_abs   = RT_NoCue_mean - RT_DoubCue_mean;
    O_CenSpat_mean_abs  = RT_CentCue_mean - RT_SpatCue_mean;
    C_InconCon_mean_abs = RT_Incong_mean - RT_Cong_mean;
    
    %% Calcu Each Mean RT
    RT_Con_NoCue_mean     = mean(RT_Con_NoCue_Mat);
    RT_Con_DoubCue_mean   = mean(RT_Con_DoubCue_Mat);
    RT_Con_CentCue_mean   = mean(RT_Con_CentCue_Mat);
    RT_Con_SpatCue_mean   = mean(RT_Con_SpatCue_Mat);
    RT_Incon_NoCue_mean   = mean(RT_Incon_NoCue_Mat);
    RT_Incon_DoubCue_mean = mean(RT_Incon_DoubCue_Mat);
    RT_Incon_CentCue_mean = mean(RT_Incon_CentCue_Mat);
    RT_Incon_SpatCue_mean = mean(RT_Incon_SpatCue_Mat);
    
    %% Calcu Each Median RT
    RT_Con_NoCue_med     = median(RT_Con_NoCue_Mat);
    RT_Con_DoubCue_med   = median(RT_Con_DoubCue_Mat);
    RT_Con_CentCue_med   = median(RT_Con_CentCue_Mat);
    RT_Con_SpatCue_med   = median(RT_Con_SpatCue_Mat);
    RT_Incon_NoCue_med   = median(RT_Incon_NoCue_Mat);
    RT_Incon_DoubCue_med = median(RT_Incon_DoubCue_Mat);
    RT_Incon_CentCue_med = median(RT_Incon_CentCue_Mat);
    RT_Incon_SpatCue_med = median(RT_Incon_SpatCue_Mat);
    
    %% Calcu Each Mean ACC
    ACC_Con_NoCue     = sum(ACC_Con_NoCue_Mat) / Sum_Con_NoCue;
    ACC_Con_DoubCue   = sum(ACC_Con_DoubCue_Mat) / Sum_Con_DoubCue;
    ACC_Con_CentCue   = sum(ACC_Con_CentCue_Mat) / Sum_Con_CentCue;
    ACC_Con_SpatCue   = sum(ACC_Con_SpatCue_Mat) / Sum_Con_SpatCue;
    ACC_Incon_NoCue   = sum(ACC_Incon_NoCue_Mat) / Sum_Incon_NoCue;
    ACC_Incon_DoubCue = sum(ACC_Incon_DoubCue_Mat) / Sum_Incon_DoubCue;
    ACC_Incon_CentCue = sum(ACC_Incon_CentCue_Mat) / Sum_Incon_CentCue;
    ACC_Incon_SpatCue = sum(ACC_Incon_SpatCue_Mat) / Sum_Incon_SpatCue;
    ACC_mean = (ACC_Con_NoCue+ACC_Con_DoubCue+ACC_Con_CentCue+ACC_Con_SpatCue + ...
        ACC_Incon_NoCue+ACC_Incon_DoubCue+ACC_Incon_CentCue+ACC_Incon_SpatCue)/8;
    
    % Write Result to allres
    allres{isub+1,1} = sublist{isub,1};
    allres{isub+1,2} = sublist{isub,2};
    allres{isub+1,3} = group;
    allres{isub+1,4} = subgrp;
    
    allres{isub+1,5} = A_NoDoub_med_abs;
    allres{isub+1,6} = O_CenSpat_med_abs;
    allres{isub+1,7} = C_InconCon_med_abs;
    
    allres{isub+1,8}  = A_NoDoub_mean_abs;
    allres{isub+1,9}  = O_CenSpat_mean_abs;
    allres{isub+1,10} = C_InconCon_mean_abs;
    
    allres{isub+1,11} = RT_Con_NoCue_med;
    allres{isub+1,12} = RT_Con_CentCue_med;
    allres{isub+1,13} = RT_Con_DoubCue_med;
    allres{isub+1,14} = RT_Con_SpatCue_med;
    allres{isub+1,15} = RT_Incon_NoCue_med;
    allres{isub+1,16} = RT_Incon_CentCue_med;
    allres{isub+1,17} = RT_Incon_DoubCue_med;
    allres{isub+1,18} = RT_Incon_SpatCue_med;
    
    allres{isub+1,19} = RT_Con_NoCue_mean;
    allres{isub+1,20} = RT_Con_CentCue_mean;
    allres{isub+1,21} = RT_Con_DoubCue_mean;
    allres{isub+1,22} = RT_Con_SpatCue_mean;
    allres{isub+1,23} = RT_Incon_NoCue_mean;
    allres{isub+1,24} = RT_Incon_CentCue_mean;
    allres{isub+1,25} = RT_Incon_DoubCue_mean;
    allres{isub+1,26} = RT_Incon_SpatCue_mean;
    
    allres{isub+1,27} = ACC_Con_NoCue;
    allres{isub+1,28} = ACC_Con_CentCue;
    allres{isub+1,29} = ACC_Con_DoubCue;
    allres{isub+1,30} = ACC_Con_SpatCue;
    allres{isub+1,31} = ACC_Incon_NoCue;
    allres{isub+1,32} = ACC_Incon_CentCue;
    allres{isub+1,33} = ACC_Incon_DoubCue;
    allres{isub+1,34} = ACC_Incon_SpatCue;
    allres{isub+1,35} = ACC_mean;
end

res_file = fullfile(res_savedir,['res_', subgrp, '_',task]);
eval(cat(2,'save ',res_file,' allres'));

%% All Done
clear
disp('All Done');
