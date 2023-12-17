# written by dr.haol
# haolll@swu.edu.cn
restoredefaultpath
clear

%% Basic information set up
task_name = 'ANT'; % Task name
img_type  = 'con'; % What imaging type used for calculation, 'con' or 'spmT'
grp_name  = 'g1C'; % Pairs between each condition

spm_dir    = 'D:\Applications\ImgAnaly\spm12'; % Path of spm12
roi_dir    = 'D:\Documents\BaiduSyncdisk\Research\2018_Hao_AttenNeuroDev\ImgRes\ROIs\MainCond_ROIs_NewSample'; % Path of ROIs, all ROIs under this path will be calculated
firlv_dir  = 'E:\2018_Hao_AttenNeuroDev\FirstLv\OnlyCorr'; % Path of the first level analysis results
subjlist   = 'D:\Documents\BaiduSyncdisk\Research\2018_Hao_AttenNeuroDev\Sublist\sublist_grp_CBDC_NewSample.txt'; % Path of the participants list

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
allres = {'Scan_ID', 'Group', 'EucliDist'};
% Calculate  neural similarity for each ROI
for sub_i = 1:length(sublist)
    vect_c1a = []; vect_c2o = []; vect_c3e = [];
    for roi_i = 1:length(roi_list)
        roi_file = fullfile(roi_dir, roi_list{roi_i,1}); % Path of each ROI

        % Calculate neural similarity for each participant

        allres{sub_i+1,1} = sublist{sub_i,1}; % Write index of row for each participant to results file
        allres{sub_i+1,2} = grp_name; % Write index of row for each pair of conditions to results file

        % Read neural activity pattern of each condition for each participant
        yearID = ['20', sublist{sub_i,1}(1:2)];
        img1 = fullfile(firlv_dir, yearID, sublist{sub_i,1},'fMRI', 'Stats_spm12', ...
            task_name, 'Stats_spm12_swcra', [img_type,'_0001.nii']);
        mean1 = rex(img1,roi_file,'select_clusters', 0);  % Write mean value to results file

        img2 = fullfile(firlv_dir, yearID, sublist{sub_i,1},'fMRI', 'Stats_spm12', ...
            task_name, 'Stats_spm12_swcra', [img_type,'_0002.nii']);
        mean2 = rex(img2,roi_file,'select_clusters', 0);  % Write mean value to results file

        img3 = fullfile(firlv_dir, yearID, sublist{sub_i,1},'fMRI', 'Stats_spm12', ...
            task_name, 'Stats_spm12_swcra', [img_type,'_0003.nii']);
        mean3 = rex(img3,roi_file,'select_clusters', 0);  % Write mean value to results file

        vect_c1a = [vect_c1a; mean1]; vect_c2o = [vect_c2o; mean2]; vect_c3e = [vect_c3e; mean3];
    end

    dissim_12 = sqrt(sum(pdist([vect_c1a, vect_c2o], 'euclidean')));
    dissim_13 = sqrt(sum(pdist([vect_c1a, vect_c3e], 'euclidean')));
    dissim_23 = sqrt(sum(pdist([vect_c2o, vect_c3e], 'euclidean')));

    allres{sub_i+1, 3} = (dissim_12 + dissim_13 + dissim_23)/3;
end

% Name of the result file
save_name = ['dissoc_degr_overall_',grp_name, '.csv'];
% Save the result file to disk
fid = fopen(save_name, 'w');
[nrows,ncols] = size(allres);
col_num = '%s';
for col_i = 1:(ncols-1); col_num = [col_num,',','%s']; end %#ok<*AGROW>
col_num = [col_num, '\n'];
for row_i = 1:nrows; fprintf(fid, col_num, allres{row_i,:}); end
fclose(fid);

%% Done
disp('=== Done ===');