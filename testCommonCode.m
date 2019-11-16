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

GSegyInfo.isNegative = 0;
basePath = 'D:/data/matlab_data/2018_POST_DLSR/geoeast';

%% path folder
GPostInvParam.modelSavePath = sprintf('%s/welllogTest', basePath);
mkdir(GPostInvParam.modelSavePath);

load wellLogs;
load timeLine.mat;
load wavelet;

%% segy information of initial model 
GPostInvParam.initModel.initLog = [];
GPostInvParam.initModel.filtCoef = 0.4;
% GPostInvParam.initModel.mode = 'filter_from_true_log';
GPostInvParam.initModel.mode = 'segy';
GPostInvParam.initModel.segyInfo = GSegyInfo;
GPostInvParam.initModel.segyInfo.isPosZero = 0;

GPostInvParam.initModel.segyInfo.t0 = 0;
GPostInvParam.initModel.segyInfo.inlineId = 3;
GPostInvParam.postSeisData.segyInfo.crosslineId = 6;
GPostInvParam.initModel.segyFileName = 'C:\Users\binst\HRS projects\GEO_POST\model\inv_multi_wells_for_init_IP_Horizon_init_005_onewell.sgy';

% GPostInvParam.initModel.segyInfo.t0 = 755;
% GPostInvParam.initModel.segyFileName = 'D:\data\seismic data\geo-block\data\model\Imp_Lu_init_AM50Hz.sgy';

% GPostInvParam.initModel.segyInfo.inlineId = 48;
% GPostInvParam.initModel.segyInfo.crosslineId = 6;
% GPostInvParam.initModel.segyInfo.t0 = 0;
% GPostInvParam.initModel.segyFileName = 'D:\data\seismic data\geo-block\data\model\Imp_BGP_Init.sgy';

% GPostInvParam.initModel.segyInfo.t0 = 780;
% GPostInvParam.initModel.segyFileName = 'C:\Users\binst\HRS projects\GEO_POST\inv_result\geoeast_impedance_sparse_impulse_bgp.sgy';

% GPostInvParam.initModel.segyInfo.inlineId = 48;
% GPostInvParam.postSeisData.segyInfo.crosslineId = 6;
% GPostInvParam.initModel.segyInfo.t0 = 0;
% GPostInvParam.initModel.segyFileName = 'C:\Users\binst\HRS projects\GEO_POST\model\modelall_Volume_PP_IMP.sgy';

% segy information of poststack file
GPostInvParam.postSeisData.segyInfo = GSegyInfo;
GPostInvParam.postSeisData.segyInfo.t0 = 0;
GPostInvParam.postSeisData.segyInfo.isPosZero = 0;
GPostInvParam.postSeisData.segyInfo.inlineId = 3;
GPostInvParam.postSeisData.segyInfo.crosslineId = 6;
GPostInvParam.postSeisData.segyFileName = 'D:\data\seismic data\geo-block\data\seismic\seismic.sgy';

% some other information
GPostInvParam.postSeisData.shiftSegyFileName = 'D:\data\seismic data\geo-block\data\seismic\phase_shift_90.sgy';
GPostInvParam.dt = 1;                           
GPostInvParam.isNormal = 1;                     % whether normalize
GPostInvParam.upNum = 80;   
% GPostInvParam.upNum = 80;  
GPostInvParam.downNum = 50;      
GPostInvParam.waveletFreq = 45;
GPostInvParam.isParallel = 1;
GPostInvParam.isSaveMode = 0;
GPostInvParam.isReadMode = 0;

GPostInvParam.bound.mode = 'based_on_init';
GPostInvParam.bound.offset_init = 2500;

GPostInvParam.indexOfTimeInWellData = 2;

% load zeroPhaseWavelet.mat;
% load ricker.mat;
% load rickerWavelet.mat;
% load extractedWavelet.mat;
load extractedZeroPhaseWavelet.mat;
GPostInvParam.wavelet = wavelet;

%% set the options for showing the results 
GShowProfileParam.isLegend = 0;
GShowProfileParam.plotParam = GPlotParam;
GShowProfileParam.rangeSeismic = [];
% GShowProfileParam.showProfileFiltCoef = 1;
GShowProfileParam.scaleFactor = 5;  % interpolate the inversion results avoid zigzag 
   
GShowProfileParam.showWellOffset = 1;
GShowProfileParam.showWellFiltCoef = 0.4;
load attColor.mat;
load original_color.mat
GShowProfileParam.dataColorTbl = original_color;
GShowProfileParam.isColorReverse = 0;           % whether call filpud fcn to reverse the color table

%% set the options of inversion process
seisInvOptions = bsCreateSeisInv1DOptions();
seisInvOptions.GBOptions.optAlgHandle = @bsOptQCG;          % using Quasi-Newton conjugate gradient optimizer
seisInvOptions.GBOptions.display = 'off';
seisInvOptions.GBOptions.optAlgParam.updateFlag = 'PR';     % PR formulation, could be also FR, HS, DY
seisInvOptions.GBOptions.isSaveMiddleRes = false;           % Whether save the middle results

seisInvOptions.addLowFreqConstraint = true;
seisInvOptions.initRegParam = 0.5;
seisInvOptions.searchRegParamFcn = [];

%% set the options for training dictionary
GTrainDICParam.sizeAtom = 60;
GTrainDICParam.nAtom = 8000;
GTrainDICParam.filtCoef= 0.5;

%% set the options for sparse inversion
GSparseInvParam.sparsity =1;
GSparseInvParam.stride = 1;
GSparseInvParam.isSparseRebuild = 1;
