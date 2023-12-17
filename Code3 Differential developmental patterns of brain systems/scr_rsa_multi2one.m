# written by dr.haol
# haolll@swu.edu.cn
restoredefaultpath
clear

%% Basic information set up
resubmask  = 1; % Mask data within region of interest (ROI), 1 for yes, 0 for no
img_type   = 'con'; % What imaging type used for calculation, 'con' or 'spmT'
task_name  = 'ANT'; % Task name
cond_name  = {'c1A';'c2O';'c3E'}; % Name of each condition
rsa_file   = {  % Neural activity pattern averaged across adults for each condition, corresponding for 'cond_name'
    'E:\ResearchData\2018_Hao_AttenNeuroDev\ImgRes\IMGs\Grp_CBDA_IncluIncorr\con_0001.nii';
    'E:\ResearchData\2018_Hao_AttenNeuroDev\ImgRes\IMGs\Grp_CBDA_IncluIncorr\con_0002.nii';
    'E:\ResearchData\2018_Hao_AttenNeuroDev\ImgRes\IMGs\Grp_CBDA_IncluIncorr\con_0003.nii'};

spm_dir   = 'D:\Applications\NeuToolbox\spm12'; % Path of spm12
roi_dir   = 'E:\ResearchData\2018_Hao_AttenNeuroDev\ImgRes\ROIs\Grp_CBDA_SDM'; % Path of ROIs, all ROIs under this path will be calculated
firlv_dir = 'E:\ResearchData\2018_Hao_AttenNeuroDev\FirstLv\IncluIncorr'; % Path of the first level analysis results
subjlist  = 'E:\ResearchData\2018_Hao_AttenNeuroDev\Sublist\sublist_grp_CBDC_NewSample.txt'; % Path of the participants list

%% Add directory of spm to search path
%addpath(genpath(spm_dir));
addpath(spm_dir);
%% Read participants list
fid = fopen(subjlist); sublist = {}; cnt_list = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    sublist(cnt_list,:) = linedata{1}; cnt_list = cnt_list + 1; %#ok<*SAGROW>
end
fclose(fid);

%% Acquire ROIs list
roilist = dir(fullfile(roi_dir,'*.nii'));
roilist = struct2cell(roilist);
roilist = roilist(1,:)';

%% Calculate multivariate maturation index
% Calculate maturation index for each condition
for icon = 1:length(cond_name)
    allres = {'Scan_ID'};
    % Calculate maturation index for each ROI
    for iroi = 1:length(roilist)
        allres{1,iroi+1} = roilist{iroi,1}(1:end-4); % Write index of column for each ROI to results file
        roifile          = fullfile(roi_dir, roilist{iroi,1}); % Path of each ROI
        roimask          = logical(spm_read_vols(spm_vol(roifile))); % Read ROI data
        
        rsa_img  = spm_read_vols(spm_vol(rsa_file{icon,1})); % Read neural activity pattern averaged across adults for each condition
        rsa_vect = rsa_img(roimask(:)==1);                      % Acquire neural activity pattern averaged across adults within ROI
        
        % Calculate maturation index for each participant
        for isub = 1:length(sublist)
            allres{isub+1,1} = sublist{isub,1}; % Write index of row for each participant to results file
            
            % Read neural activity pattern of each child
            yearID  = ['20',sublist{isub,1}(1:2)];
            sub_file = fullfile(firlv_dir, yearID, sublist{isub,1},...
                'fMRI', 'Stats_spm12', task_name, 'Stats_spm12_swcra', ...
                [img_type, '_000', num2str(icon), '.nii']);
            sub_img = spm_read_vols(spm_vol(sub_file));
            
            % Redo mask by removing voxels of no activation for each participant
            if resubmask == 1
                sub_vect_nan = sub_img(roimask(:)==1);
                rsa_vect = rsa_vect(~isnan(sub_vect_nan));
                
                submaskfile = fullfile(firlv_dir, yearID, sublist{isub,1},...
                    'fMRI', 'Stats_spm12', task_name, 'Stats_spm12_swcra', 'mask.nii');
                submask = logical(spm_read_vols(spm_vol(submaskfile)));
                roimask = submask & roimask;
            end
            
            % Acquire neural activity pattern of each child within ROI
            sub_vect = sub_img(roimask(:)==1); 
            
            [rsa_r, rsa_p] = corr(rsa_vect, sub_vect);             % Calculate the spatial correlation of neural activity pattern between each child and adults
            allres{isub+1,iroi+1} = 0.5*log((1+rsa_r)/(1-rsa_r)); % Transform r to Fisher z'
        end
    end
    
    % Name of the result file
    save_name = ['multi2one_', cond_name{icon,1}, '_', img_type,'.csv'];
    % Save the result file to disk
    fid = fopen(save_name, 'w');
    [nrows,ncols] = size(allres);
    col_num = '%s';
    for col_i = 1:(ncols-1); col_num = [col_num,',','%s']; end %#ok<*AGROW>
    col_num = [col_num, '\n'];
    for row_i = 1:nrows; fprintf(fid, col_num, allres{row_i,:}); end
    fclose(fid);
end

%% Done
disp('=== Done ===');