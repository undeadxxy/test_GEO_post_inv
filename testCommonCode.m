clc;
% clear all;
close all;

basePath = 'E:/HRS projects/GEO_POST/';

load wellLogs;
% load timeLine.mat;
load hrs_horizon.mat;
load wavelet;

% smooth horizon
% timeLine = bsSmoothHorizon(timeLine, 5);

GSegyInfo = bsCreateGSegyInfo();
%% set the options for showing the results 
GShowProfileParam = bsCreateGShowProfileParam();
GShowProfileParam.showWellFiltCoef = 0.4;

%% set the options for inversion
GInvParam = bsCreateGInvParam('poststack');
% segy information of initial model 
GInvParam.initModel.filtCoef = 0.15;
% GInvParam.initModel.mode = 'filter_from_true_log';
GInvParam.initModel.mode = 'segy';

% GInvParam.initModel.mode = 'segy';
GInvParam.initModel.ip.segyInfo = GSegyInfo;
% GInvParam.initModel.ip.segyInfo.t0 = 0;
% GInvParam.initModel.ip.segyInfo.inlineId = 9;
% GInvParam.initModel.ip.segyInfo.crosslineId = 21;
% GInvParam.initModel.ip.fileName = sprintf('%s/model/inv_multi_wells_for_init_IP_Horizon_init_005_onewell.sgy', basePath);

% GInvParam.initModel.ip.segyInfo.inlineId = 9;
% GInvParam.initModel.ip.segyInfo.crosslineId = 21;
% GInvParam.initModel.ip.segyInfo.t0 = 755;
% GInvParam.initModel.ip.fileName = sprintf('%s/model/Imp_Lu_init_AM50Hz.sgy', basePath);

GInvParam.initModel.ip.segyInfo.inlineId = 189;
GInvParam.initModel.ip.segyInfo.crosslineId = 21;
GInvParam.initModel.ip.segyInfo.t0 = 0;
GInvParam.initModel.ip.fileName = sprintf('%s/model/Imp_BGP_Init.sgy', basePath);

% GInvParam.initModel.ip.segyInfo.inlineId = 189;
% GInvParam.initModel.ip.segyInfo.crosslineId = 21;
% GInvParam.initModel.ip.segyInfo.t0 = 0;
% GInvParam.initModel.ip.fileName = sprintf('%s/model/modelall_Volume_PP_IMP.sgy', basePath);

% GInvParam.initModel.ip.segyInfo.inlineId = 189;
% GInvParam.initModel.ip.segyInfo.crosslineId = 21;
% GInvParam.initModel.ip.segyInfo.t0 = 780;
% GInvParam.initModel.ip.fileName = [basePath, '\inv_result\geoeast_impedance_sparse_impulse_bgp.sgy'];

% segy information of poststack file
GInvParam.postSeisData.segyInfo = GSegyInfo;
GInvParam.postSeisData.segyInfo.t0 = 0;
GInvParam.postSeisData.segyInfo.isPosZero = 0;
GInvParam.postSeisData.segyInfo.inlineId = 9;
GInvParam.postSeisData.segyInfo.crosslineId = 21;
GInvParam.postSeisData.fileName = sprintf('%s/seismic/seismic.sgy', basePath);
GInvParam.postSeisData.shiftfileName = sprintf('%s/seismic/phase_shift_90.sgy', basePath);

% some other information
GInvParam.dt = 1;                           
GInvParam.usedTimeLineId = 2;               % set the index of target horizon in timeLine
GInvParam.upNum = 80;   
GInvParam.downNum = 50;      
GInvParam.isParallel = 1;
GInvParam.indexInWellData.ip = 1;
GInvParam.indexInWellData.time = 2;
GInvParam.modelSavePath = [basePath, 'inversion_results/'];

% load zeroPhaseWavelet.mat;
% load ricker.mat;
% load rickerWavelet.mat;
% load extractedWavelet.mat;
% load extractedZeroPhaseWavelet.mat;
% [wavelet, GInvParam] = bsExtractWavelet(GInvParam, timeLine, wellLogs, 'zero-phase');
GInvParam.depth2time.isShowCompare = 0;
GInvParam.depth2time.showCompareNum = 10;
GInvParam.depth2time.saveOffsetNum = 10;
GInvParam.depth2time.searchOffsetNum = 0;
% load wavelet.mat;
% GInvParam.wavelet = wavelet;
% [GInvParam, wellLogs, wavelet] = bsDepth2Time(GInvParam, timeLine, wellLogs, 'ricker');
load ricker.mat;
GInvParam.wavelet = wavelet;
% GInvParam.wavelet = wavelet * 0.1;

%% set the options for training dictionary
GTrainDICParam = bsCreateGTrainDICParam(...
    'one', ...
    'isAddLocInfo', 0, ...
    'isAddTimeInfo', 0, ...
    'normalizationMode', 'off', ...
    'feature_reduction', 'off', ...
    'sizeAtom', 80, ...
    'nAtom', 8000, ...
    'isRebuild', 0, ...
    'filtCoef', GShowProfileParam.showWellFiltCoef);
GTrainDICParam.iterNum = 5;

trainNum = 104;
train_ids = randperm(length(wellLogs), trainNum);


% trainNum = length(trainWelllogs);
[DIC, train_ids, rangeCoef, output] = bsTrainDics(GTrainDICParam, wellLogs, train_ids, ...
    [   GInvParam.indexInWellData.ip]);
blind_ids = setdiff(1:length(wellLogs), train_ids);

%% set the options for sparse inversion
GSparseInvParam = bsCreateGSparseInvParam(DIC, GTrainDICParam, 'rangeCoef', rangeCoef, 'output', output);

% [values] = bsGetFieldsAsCellArray(GOOptions);
% GInvParam.seisInvOptions.GOOptions = values;

GInvParam.bound.mode = 'off';
% GInvParam.bound.mode = 'based_on_init';
% GInvParam.bound.offset_init.ip = 2000;