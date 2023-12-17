%% Set some parameters for doing analyses and configure path
computeBootstrap = true;                       % Perform bootstrap analyses (if true, this can be slow) or load bootstrap results (if false)
basedir = which('ConfigureAnalysisOptions.m'); % Location of scripts folder
basedir = basedir(1:end-46);                   % Location of base folder
warning off stats:pdist:ConstantPoints         % Some subjects have missing data in ROIs (and are excluded from some analyses), this suppressing warning about low variance

restoredefaultpath                                  % Restores the MATLAB search path to default
addpath(genpath(basedir));                          % Add basepath and subfolders
addpath(genpath('D:\Research\2018_Hao_AttenNeuroDev\ImgRes\ROIs\Grp_CBD_Overlap_NewSample_IncluMiss')) % Add ROIs directory
addpath(genpath('D:\Applications\NeuToolbox\spm12'));         % Add spm directory
addpath(genpath('D:\Applications\NeuToolbox\CanlabCore'));    % Add canlab core codes