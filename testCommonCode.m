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
basePath = 'E:/HRS projects/GEO_POST/';

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
GPostInvParam.initModel.segyInfo.inlineId = 9;
GPostInvParam.initModel.segyInfo.crosslineId = 21;
GPostInvParam.initModel.segyFileName = sprintf('%s/model/inv_multi_wells_for_init_IP_Horizon_init_005_onewell.sgy', basePath);

% GPostInvParam.initModel.segyInfo.t0 = 755;
% GPostInvParam.initModel.segyFileName = sprintf('%s/model/Imp_Lu_init_AM50Hz.sgy', basePath);

% GPostInvParam.initModel.segyInfo.inlineId = 189;
% GPostInvParam.initModel.segyInfo.crosslineId = 21;
% GPostInvParam.initModel.segyInfo.t0 = 0;
% GPostInvParam.initModel.segyFileName = sprintf('%s/model/Imp_BGP_Init.sgy', basePath);

% GPostInvParam.initModel.segyInfo.inlineId = 189;
% GPostInvParam.initModel.segyInfo.crosslineId = 21;
% GPostInvParam.initModel.segyInfo.t0 = 0;
% GPostInvParam.initModel.segyFileName = sprintf('%s/model/modelall_Volume_PP_IMP.sgy', basePath);

% GPostInvParam.initModel.segyInfo.inlineId = 189;
% GPostInvParam.initModel.segyInfo.crosslineId = 21;
% GPostInvParam.initModel.segyInfo.t0 = 780;
% GPostInvParam.initModel.segyFileName = sprintf('%s/model/geoeast_impedance_sparse_impulse_bgp.sgy', basePath);

% GPostInvParam.initModel.segyInfo.inlineId = 189;
% GPostInvParam.initModel.segyInfo.crosslineId = 21;
% GPostInvParam.initModel.segyInfo.t0 = 0;
% GPostInvParam.initModel.segyFileName = sprintf('%s/model/modelall_Volume_PP_IMP.sgy', basePath)
% segy information of poststack file
GPostInvParam.postSeisData.segyInfo = GSegyInfo;
GPostInvParam.postSeisData.segyInfo.t0 = 0;
GPostInvParam.postSeisData.segyInfo.isPosZero = 0;
GPostInvParam.postSeisData.segyInfo.inlineId = 9;
GPostInvParam.postSeisData.segyInfo.crosslineId = 21;
GPostInvParam.postSeisData.segyFileName = sprintf('%s/seismic/seismic.sgy', basePath);


% some other information
GPostInvParam.modelSavePath = basePath;

GPostInvParam.postSeisData.shiftSegyFileName = sprintf('%s/seismic/phase_shift_90.sgy', basePath);
GPostInvParam.dt = 1;                           

GPostInvParam.isNormal = 1;                     % whether normalize  
GPostInvParam.isSaveMode = 1;
GPostInvParam.isNormal = 1;                     % whether normalize
GPostInvParam.upNum = 80;   
% GPostInvParam.upNum = 80;  
GPostInvParam.downNum = 50;      
GPostInvParam.waveletFreq = 45;
GPostInvParam.isParallel = 1;
GPostInvParam.numWorkers = bsGetMaxNumWorkers();

GPostInvParam.isSaveMode = 0;
GPostInvParam.isReadMode = 0;

GPostInvParam.bound.mode = 'based_on_init';
GPostInvParam.bound.offset_init = 2500;

GPostInvParam.indexInWellData.time = 2;
GPostInvParam.indexInWellData.Ip = 1;
% if you want to see the progress information, set it as 1. But it should
% be noted that this setting will decrease the efficiency a little bit and 
% call I/O many times.
GPostInvParam.isPrintBySavingFile = 0; 
% load zeroPhaseWavelet.mat;
% load ricker.mat;
% load rickerWavelet.mat;
% load extractedWavelet.mat;
% load extractedZeroPhaseWavelet.mat;
wavelet = bsExtractWavelet(GPostInvParam, timeLine, wellLogs, 'zero-phase');
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
trainNum = 100;
% train_names = {'W1-1901', 'W1-2013', 'W1-2133', 'W2-1901', 'W2-2024', 'W2-2214', 'W3-1833'};
% train_ids = getIdsFromWelllogs(wellLogs, train_names);
train_ids = randperm(length(wellLogs), trainNum);
% trainNum = length(trainWelllogs);
[DIC, train_ids] = bsTrainOneDIC(wellLogs, train_ids, GTrainDICParam);

blind_ids = setdiff(1:length(wellLogs), train_ids);
GSparseInvParam.DIC = DIC;



%%