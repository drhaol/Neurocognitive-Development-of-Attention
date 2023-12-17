# written by dr.haol
# haolll@swu.edu.cn
restoredefaultpath
clear

%% Basic information set up
resubmask = 1;                % Mask data within region of interest (ROI), 1 for yes, 0 for no
task_name = 'ANT';            % Task name
img_type  = 'con';            % What imaging type used for calculation, 'con' or 'spmT'
grp_name  = 'g2A'; % Pairs between each condition
cond_num  = {'12';'13';'23'}; % Pairs between each condition

spm_dir    = 'D:\Applications\ImgAnaly\spm12'; % Path of spm12
roi_dir    = 'D:\Documents\BaiduSyncdisk\Research\2018_Hao_AttenNeuroDev\ImgRes\ROIs\Grp_CBD_Overlap_NewSample_OnlyCorr'; % Path of ROIs, all ROIs under this path will be calculated
firlv_dir  = 'E:\2018_Hao_AttenNeuroDev\FirstLv\OnlyCorr'; % Path of the first level analysis results
subjlist   = 'D:\Documents\BaiduSyncdisk\Research\2018_Hao_AttenNeuroDev\Sublist\sublist_grp_CBDA.txt'; % Path of the participants list

%% Add directory of spm to search path
addpath(genpath(spm_dir));

%% Read participants list
fid = fopen(subjlist); sublist = {}; cnt_list = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    sublist(cnt_list,:) = linedata{1}; cnt_list = cnt_list + 1; %#ok<*SAGROW>
end
fclose(fid);

%% Acquire ROIs list
roi_list = dir(fullfile(roi_dir,'*.nii'));
roi_list = struct2cell(roi_list);
roi_list = roi_list(1,:)';

%% Calculate neural similarity
% Calculate neural similarity for pairs between each condition
allres = {'Scan_ID', 'Group'};
% Calculate  neural similarity for each ROI
for roi_i = 1:length(roi_list)
    allres{1,roi_i+2} = roi_list{roi_i,1}(1:end-4);  % Write index of column for each ROI to results file
    roi_file = fullfile(roi_dir, roi_list{roi_i,1}); % Path of each ROI
    mask = spm_read_vols(spm_vol(roi_file));         % Read ROI data
    
    % Calculate neural similarity for each participant
    for sub_i = 1:length(sublist)
        allres{sub_i+1,1} = sublist{sub_i,1};       % Write index of row for each participant to results file
        allres{sub_i+1,2} = grp_name; % Write index of row for each pair of conditions to results file
        for con_i = 1:length(cond_num)
            % Read neural activity pattern of each condition for each participant
            yearID = ['20', sublist{sub_i,1}(1:2)];
            img1 = fullfile(firlv_dir, yearID, sublist{sub_i,1},'fMRI', 'Stats_spm12', ...
                task_name, 'Stats_spm12_swcra', [img_type,'_0001.nii']);
            img2 = fullfile(firlv_dir, yearID, sublist{sub_i,1},'fMRI', 'Stats_spm12', ...
                task_name, 'Stats_spm12_swcra', [img_type,'_0002.nii']);
            img3 = fullfile(firlv_dir, yearID, sublist{sub_i,1},'fMRI', 'Stats_spm12', ...
                task_name, 'Stats_spm12_swcra', [img_type,'_0003.nii']);
            
            sub_img1 = spm_read_vols(spm_vol(img1)); % Acquire neural activity pattern of 1st condition
            sub_img2 = spm_read_vols(spm_vol(img2)); % Acquire neural activity pattern of 2nd condition
            sub_img3 = spm_read_vols(spm_vol(img3)); % Acquire neural activity pattern of 3rd condition
            
            % Redo mask by removing voxels of no activation for each participant
            if resubmask == 1
                submaskfile = fullfile(firlv_dir, yearID, sublist{sub_i,1},...
                    'fMRI', 'Stats_spm12', task_name, 'Stats_spm12_swcra', 'mask.nii');
                submask = spm_read_vols(spm_vol(submaskfile));
                mask = submask & mask;
            end
            
            sub_vect1 = sub_img1(mask(:)==1); % Acquire neural activity pattern of 1st condition within ROI
            sub_vect2 = sub_img2(mask(:)==1); % Acquire neural activity pattern of 2nd condition within ROI
            sub_vect3 = sub_img3(mask(:)==1); % Acquire neural activity pattern of 2nd condition within ROI
            
            [rsa_r12, rsa_p12] = corr(sub_vect1, sub_vect2);
            [rsa_r13, rsa_p13] = corr(sub_vect1, sub_vect3);
            [rsa_r23, rsa_p23] = corr(sub_vect2, sub_vect3);
            allres{sub_i+1,roi_i+2} = 0.5*log((1+rsa_r12)/(1-rsa_r12)) + ...
                0.5*log((1+rsa_r13)/(1-rsa_r13)) + 0.5*log((1+rsa_r23)/(1-rsa_r23));
        end
    end
    
    % Name of the result file
    save_name = ['stability_',grp_name, '.csv'];
    % Save the result file to disk
    fid = fopen(save_name, 'w');
    [nrows,ncols] = size(allres);
    col_num = '%s';
    for col_i = 1:(ncols-1); col_num = [col_num,',','%s']; end %#ok<*AGROW>
    col_num = [col_num, '\n'];
    for row_i = 1:nrows; fprintf(fid, col_num, allres{row_i,:}); end;
    fclose(fid);
end

%% Done
disp('=== Done ===');