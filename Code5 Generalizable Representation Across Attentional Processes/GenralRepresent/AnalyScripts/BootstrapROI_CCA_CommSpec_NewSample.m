%% Perform bootstrap analysis for inference within each ROI
% Create RDM-based model
n_bs         = 5000;                                 % Number of bootstrap
sub_ageClow  = [34 34 34 34];                        % number of children in the four low age group
sub_ageChigh = [34 34 34 34];                        % number of children in the four high age group
sub_ageA     = [19 19 19 18];                        % number of adults in the four age group
sub_con      = [136 136 136 136 136 136 75 75 75];   % number of participants in the each process
sub_grp      = [408 408 225];                        % number of participants in the each attention domain
res_name     = 'bs_CCA_CommSpec_NewSample_5000.mat'; % Name of the result file

%% Create variable with roi names
rois = {
    'Grp_CBD_Comm_fdr05_r00_all',...
    'Grp_CBD_Comm_fdr05_r01_fef_b',...
    'Grp_CBD_Comm_fdr05_r02_spl_b',...
    'Grp_CBD_Speci_fdr05_r01_angular_b',...
    'Grp_CBD_Speci_fdr05_r02_tpj_b',...
    'Grp_CBD_Speci_fdr05_r03_dacc_r'
    };

% rois = {
%     'Comm_r00_all',...
%     'Comm_r01_fef_b',...
%     'Comm_r02_spl_b',...
%     'Speci_r01_ai_b',...
%     'Speci_r02_dacc_r',...
%     'Speci_r03_tpj_r'
%     };

%% create RDMs (same for all rois)
% Construct vectors indicating the membership of children in the four low age group
sub_age_X_Clow = []; age_cnt_Clow = 0; sub_cnt_Clow = 0;
for icon = 1:3
    for isub = 1:length(sub_ageClow)
        age_cnt_Clow = age_cnt_Clow + 1;
        for iage = 1:sub_ageClow(1,isub)
            sub_cnt_Clow = sub_cnt_Clow + 1;
            sub_age_X_Clow(sub_cnt_Clow,1) = age_cnt_Clow; %#ok<*SAGROW>
        end
    end
end

% Construct vectors indicating the membership of children in the four high age group
sub_age_X_Chigh = []; age_cnt_Chigh = 12; sub_cnt_Chigh = 0;
for icon = 1:3
    for isub = 1:length(sub_ageChigh)
        age_cnt_Chigh = age_cnt_Chigh + 1;
        for iage = 1:sub_ageChigh(1,isub)
            sub_cnt_Chigh = sub_cnt_Chigh + 1;
            sub_age_X_Chigh(sub_cnt_Chigh,1) = age_cnt_Chigh; %#ok<*SAGROW>
        end
    end
end

% Construct vectors indicating the membership of adults in the four age group
sub_age_X_A = []; age_cnt_A = 24; sub_cnt_A = 0;
for icon = 1:3
    for isub = 1:length(sub_ageA)
        age_cnt_A = age_cnt_A + 1;
        for iage = 1:sub_ageA(1,isub)
            sub_cnt_A = sub_cnt_A + 1;
            sub_age_X_A(sub_cnt_A,1) = age_cnt_A; %#ok<*SAGROW>
        end
    end
end

% Merge vectors of each age group for low age children, high age children and adults
sub_age_X = cat(1,sub_age_X_Clow,sub_age_X_Chigh,sub_age_X_A);

% Construct vectors indicating the membership of each process
sub_con_X = []; con_cnt = 0; sub_cnt = 0;
for isub = 1:length(sub_con)
    con_cnt = con_cnt + 1;
    for iage = 1:sub_con(1,isub)
        sub_cnt = sub_cnt + 1;
        sub_con_X(sub_cnt,1) = con_cnt; %#ok<*SAGROW>
    end
end

% Construct vectors indicating the membership of each attention domain
sub_grp_X = []; grp_cnt = 0; sub_cnt = 0;
for isub = 1:length(sub_grp)
    grp_cnt = grp_cnt + 1;
    for iage = 1:sub_grp(1,isub)
        sub_cnt = sub_cnt + 1;
        sub_grp_X(sub_cnt,1) = grp_cnt; %#ok<*SAGROW>
    end
end

inds_age=condf2indic(ceil(sub_age_X)); % Matrix of 0/1 based on age group membership
inds_con=condf2indic(ceil(sub_con_X)); % Matrix of 0/1 based on process membership
inds_grp=condf2indic(ceil(sub_grp_X)); % Matrix of 0/1 based on domain membership

% Effects unique to each age group (36 total)
for i=1:size(inds_age,2)
    RDM_age(i,:)=pdist(inds_age(:,i),'seuclidean');
end

% RDM for each attention process separately (9 total)
for i=1:size(inds_con,2)
    RDM_con(i,:)= pdist(inds_con(:,i),'seuclidean');
end

% RDM for each attention domain separately (3 total)
for i=1:size(inds_grp,2)
    RDM_grp(i,:)= pdist(inds_grp(:,i),'seuclidean');
end

% Place RDMs in design matrix
X=[RDM_age' RDM_con' RDM_grp'];

% Scale to have mean of 1000
for i=1:size(X,2)
    X(:,i)=1000*X(:,i)/sum(X(:,i));
end

%% Do bootstrap resampling separately for each neural RDM (per ROI)
if computeBootstrap
    clear b;
    for r = 1:length(rois)
        rng(6) % Start with same seed for each region of interest
        
        % Mask out data that is not within this ROI
        roi_masked_dat_Clow  = apply_mask(masked_dat_Clow, remove_empty(fmri_data(which([rois{r} '.nii']))));
        roi_masked_dat_Chigh = apply_mask(masked_dat_Chigh, remove_empty(fmri_data(which([rois{r} '.nii']))));
        roi_masked_dat_A     = apply_mask(masked_dat_A, remove_empty(fmri_data(which([rois{r} '.nii']))));
        roi_masked_dat.dat   = cat(2,roi_masked_dat_Clow.dat, roi_masked_dat_Chigh.dat, roi_masked_dat_A.dat);
        
        % Bootstrap resampling of subjects within age group
        bootstrap_num = 0;
        for it = 1:n_bs % 5000 bootstrap samples
            bootstrap_num = bootstrap_num + 1;
            disp(['bootstrap number = ', num2str(bootstrap_num)])
            
            bs_inds(1:34)=randi([1,34],1,34);       % Resample with replacement within first age group
            bs_inds(35:68)=randi([35,68],1,34);     % Resample with replacement within second age group
            bs_inds(69:102)=randi([69,102],1,34);     % Resample with replacement within third age group
            bs_inds(103:136)=randi([103,136],1,34);     % ... ...
            bs_inds(137:170)=randi([137,170],1,34);   % ... ...
            bs_inds(171:204)=randi([171,204],1,34); % ... ...
            bs_inds(205:238)=randi([205,238],1,34); % ... ...
            bs_inds(239:272)=randi([239,272],1,34); % ... ...
            bs_inds(273:306)=randi([273,306],1,34); % ... ...
            bs_inds(307:340)=randi([307,340],1,34); % ... ...
            bs_inds(341:374)=randi([341,374],1,34); % ... ...
            bs_inds(375:408)=randi([375,408],1,34); % ... ...
            
            bs_inds(409:442)=randi([409,442],1,34); % ... ...
            bs_inds(443:476)=randi([443,476],1,34); % ... ...
            bs_inds(477:510)=randi([477,510],1,34); % ... ...
            bs_inds(511:544)=randi([511,544],1,34); % ... ...
            bs_inds(545:578)=randi([545,578],1,34); % ... ...
            bs_inds(579:612)=randi([579,612],1,34); % ... ...
            bs_inds(613:646)=randi([613,646],1,34); % ... ...
            bs_inds(647:680)=randi([647,680],1,34); % ... ...
            bs_inds(681:714)=randi([681,714],1,34); % ... ...
            bs_inds(715:748)=randi([715,748],1,34); % ... ...
            bs_inds(749:782)=randi([749,782],1,34); % ... ...
            bs_inds(783:816)=randi([783,816],1,34); % ... ...
            
            bs_inds(817:835)=randi([817,835],1,19); % ... ...
            bs_inds(836:854)=randi([836,854],1,19); % ... ...
            bs_inds(855:873)=randi([855,873],1,19); % ... ...
            bs_inds(874:891)=randi([874,891],1,18); % ... ...
            bs_inds(892:910)=randi([892,910],1,19); % ... ...
            bs_inds(911:929)=randi([911,929],1,19); % ... ...
            bs_inds(930:948)=randi([930,948],1,19); % ... ...
            bs_inds(949:966)=randi([949,966],1,18); % ... ...
            bs_inds(967:985)=randi([967,985],1,19); % ... ...
            bs_inds(986:1004)=randi([986,1004],1,19); % ... ...
            bs_inds(1005:1023)=randi([1005,1023],1,19); % ... ...
            bs_inds(1024:1041)=randi([1024,1041],1,18); % Resample with replacement within thirty-six age group
            
            resampled_mat = roi_masked_dat.dat(:,bs_inds)'; % Grab data from bootstrap indices
            Y = pdist(resampled_mat,'correlation');         % Compute distance matrix on this data
            Y(Y<.00001) = NaN;                              % Exclude very small off diagonal elements (because subjects can be replicated, and because some subjects have low variance)
            
            [full_x] = glmfit([ones(length(Y),1) double(X)],Y','normal','constant','off'); % Estimate coefficients with OLS
            b(it,r,:) = full_x;                                                            % Store bootstrap statistic for each iteration, each roi
            
        end
        save([basedir filesep 'Results' filesep res_name],'b', '-v7.3'); % Save bootstrap statistics to disk
    end
end
