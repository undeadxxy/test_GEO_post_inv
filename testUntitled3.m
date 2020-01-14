clear;
close all;
clc;

% load timeLine.mat;
load hrs_horizon.mat;
load wellLogs.mat;

basePath = 'E:/HRS projects/GEO_POST/';

GShowProfileParam = bsCreateGShowProfileParam();
GInvParam = bsCreateGInvParam('poststack');
GSegyInfo = bsCreateGSegyInfo();
GShowProfileParam.showWellFiltCoef = 0.4; % filter coeficient for displaying color wells in profile

GInvParam.dt = 1;    
GInvParam.upNum = 80;
GInvParam.downNum = 50;
GInvParam.indexInWellData.ip = 1;
GInvParam.indexInWellData.time = 2;
GInvParam.usedTimeLineId = 2;
GInvParam.isParallel = 1;
GInvParam.isPrintBySavingFile = 0;
GInvParam.postSeisData.segyInfo = GSegyInfo;
GInvParam.postSeisData.fileName = [basePath, '/seismic/phase_shift_90.sgy'];

% sprintf('%s/seismic/seismic.sgy', basePath);

GSegyInfo.inlineId = 9;
GSegyInfo.crossId = 21;
GSegyInfo.t0 = 0;

validRange = [1 1e10];

% Get inline and crossline of a profile crossing several wells
[inIds, crossIds] = bsGetCDPsByRange([1:142], [1:110]);

highName = [basePath, '\sgy_results\0111SMIResult_wellnumber15.sgy'];
lowName = [basePath, '\sgy_results\Ip-DLSR_New (gamma=0.2 sparsity=2)-NLM_2020_01_13_inline_[1_142]_crossline_[1_110].sgy'];
% lowName = [basePath, '\sgy_results\Ip_DLSR (gamma=0.4 sparsity=2)_inline_[1_142]_crossline_[1_110].sgy'];
outFileName = [basePath, '\sgy_results\Mixed.sgy'];
fs1 = 50;
fs2 = 60;

bsMixTwoResults(lowName, highName, outFileName, GSegyInfo, ...
    inIds, crossIds, timeLine{1}, timeLine{3}, GInvParam.dt, validRange, fs1, fs2);

methods = {
    
    struct(...
        'name', 'DLSR inversion result', ...
        'load', struct(...
            'mode', 'segy', ...
            'fileName', lowName, ...
            'segyInfo', GSegyInfo ...
        )...
    );...
  
    struct(...
        'name', 'ChenTing result', ...
        'load', struct(...
            'mode', 'segy', ...
            'fileName', highName, ...
            'segyInfo', GSegyInfo ...
        )...
    );...
    
    struct(...
        'name', 'Mixed', ...
        'load', struct(...
            'mode', 'segy', ...
            'fileName', outFileName, ...
            'segyInfo', GSegyInfo ...
        )...
    );...
    
};

[inIds, crossIds] = bsGetProfileCrossingWells(GInvParam, wellLogs(20), ...
    'isAlongCrossline', 1);

invResults = bsPostInvTrueMultiTraces(GInvParam, inIds, crossIds, timeLine, methods);

% NLMResults = bsNLMInvResults(invResults, invResults{1}.data, ...
%     'searchOffset', 3, 'windowSize', [1, 3], 'nPointsUsed', 3, ...
%     'stride', [1, 1, 1], 'searchStride', [1, 1, 1] ...
% );

GShowProfileParam.range.ip = [5800 7900];
GShowProfileParam.range.seismic = [-3 3]*1e4;
GShowProfileParam.colormap.allTheSame = bsGetColormap('original');
GShowProfileParam.isColorReverse = 0;

GShowProfileParam.scaleFactor = 5;
GShowProfileParam.showWellOffset = 1;
GShowProfileParam.plotParam.fontsize = 11;
GShowProfileParam.showPartVert.mode = 'in_2_horizons';
GShowProfileParam.showPartVert.horizonIds = [1, 3];

bsShowInvProfiles(GInvParam, GShowProfileParam, invResults, wellLogs, timeLine);
set(gcf, 'position', [ 96          54        1672         670]);