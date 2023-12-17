%% Set some parameters, configure MATLAB path, and load data
% Configure analyses:
ConfigureAnalysisOptions

% Load data
%ReadSharedData_Age
A     = load('E:\ResearchData\2018_Hao_AttenNeuroDev\GenRep\FirstLvData_IncluMiss\FullDataSet_CBDA_75.mat');     % Read adult data
Clow  = load('E:\ResearchData\2018_Hao_AttenNeuroDev\GenRep\FirstLvData_IncluMiss\FullDataSet_CBDC_low136.mat');  % Read low age group children data
Chigh = load('E:\ResearchData\2018_Hao_AttenNeuroDev\GenRep\FirstLvData_IncluMiss\FullDataSet_CBDC_high136.mat'); % Read high age group children data

% Mask data
MaskLONI_CommSpec

% Clear command line
clc