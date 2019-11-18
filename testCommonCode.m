% clc;
clear all;
close all;

load GPostInvParam.mat;
load GSegyInfo;
load GShowProfileParam.mat;
load GSparseInvParam.mat;
load GTrainDICParam;

GPlotParam.fontname = 'Times New Roman';
GPlotParam.linewidth = 1.5;
GPlotParam.fontsize = 9;
GPlotParam.fontweight = 'bold';

GShowProfileParam.isLegend = 0;
GShowProfileParam.plotParam = GPlotParam;

GSegyInfo.isNegative = 0;
basePath = 'G:\matlab_projects_inv';

%% path folder
GPostInvParam.modelSavePath = sprintf('%s/welllogTest', basePath);
mkdir(GPostInvParam.modelSavePath);

load wellLogs;
load timeLine.mat;
load wavelet;

% segy information of initial model 
GPostInvParam.initModel.mode = 'segy';
GPostInvParam.initModel.segyInfo = GSegyInfo;
GPostInvParam.initModel.segyInfo.isPosZero = 0;

GPostInvParam.initModel.segyInfo.t0 = 0;
GPostInvParam.initModel.segyInfo.inlineId = 3;
GPostInvParam.postSeisData.segyInfo.crosslineId = 6;
% GPostInvParam.initModel.segyFileName = 'C:\Users\binst\HRS projects\GEO_POST\model\inv_multi_wells_for_init_IP_Horizon_init_005_onewell.sgy';

% GPostInvParam.initModel.segyInfo.t0 = 755;
% GPostInvParam.initModel.segyFileName = 'D:\data\seismic data\geo-block\data\model\Imp_Lu_init_AM50Hz.sgy';

% GPostInvParam.initModel.segyInfo.inlineId = 48;
% GPostInvParam.postSeisData.segyInfo.crosslineId = 6;
% GPostInvParam.initModel.segyInfo.t0 = 0;
% GPostInvParam.initModel.segyFileName = 'D:\data\seismic data\geo-block\data\model\Imp_BGP_Init.sgy';

% GPostInvParam.initModel.segyInfo.inlineId = 48;
% GPostInvParam.postSeisData.segyInfo.crosslineId = 6;
% GPostInvParam.initModel.segyInfo.t0 = 0;
% GPostInvParam.initModel.segyFileName = 'G:\matlab_projects_inv\data\model\modelall_Volume_PP_IMP.sgy';

GPostInvParam.initModel.segyInfo.inlineId = 48;
GPostInvParam.postSeisData.segyInfo.crosslineId = 6;
GPostInvParam.initModel.segyInfo.t0 = 780;
GPostInvParam.initModel.segyFileName = 'G:\matlab_projects_inv\data\BGP_result\geoeast_impedance_sparse_impulse_bgp.sgy';

% segy information of poststack file
GPostInvParam.postSeisData.segyInfo = GSegyInfo;
GPostInvParam.postSeisData.segyInfo.t0 = 0;
GPostInvParam.postSeisData.segyInfo.isPosZero = 0;
GPostInvParam.postSeisData.segyInfo.inlineId = 3;
GPostInvParam.postSeisData.segyInfo.crosslineId = 6;
GPostInvParam.postSeisData.segyFileName = 'G:\matlab_projects_inv\data\seismic\seismic.sgy';

% some other information
GPostInvParam.postSeisData.shiftSegyFileName = 'D:\data\seismic data\geo-block\data\seismic\phase_shift_90.sgy';
GPostInvParam.dt = 1;                           
GPostInvParam.isNormal = 1;                     % whether normalize  
GPostInvParam.isSaveMode = 1;
GPostInvParam.waveletFreq = 45;

% load zeroPhaseWavelet.mat;
% load ricker.mat;
load rickerWavelet.mat;
GPostInvParam.wavelet = wavelet;
parentPath = 'IP_DIC';

