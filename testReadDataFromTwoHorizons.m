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
GInvParam.indexInWellData.ip = 1;
GInvParam.indexInWellData.time = 2;
GInvParam.isParallel = 1;
GInvParam.isPrintBySavingFile = 0;
GInvParam.postSeisData.segyInfo = GSegyInfo;
GInvParam.postSeisData.fileName = [basePath, '/seismic/phase_shift_90.sgy'];

% sprintf('%s/seismic/seismic.sgy', basePath);

GSegyInfo.inlineId = 9;
GSegyInfo.crossId = 21;
GSegyInfo.t0 = 0;

seismicValidRange = [-1e10, 1e10];
invResultValidRange = [1 1e10];

% Get inline and crossline of a profile crossing several wells
[inIds, crossIds] = bsGetCDPsByRange([1:142], [1:110]);

[seismicData, sampNum] = bsReadTracesByIdsAndHorizons(GInvParam.postSeisData.fileName, ...
    GSegyInfo, inIds, crossIds, ...
    timeLine{1}, timeLine{3}, GInvParam.dt, seismicValidRange);

invResultFileName = [basePath, '\inv_result\0109SMI_10mcmcaverage_20well_butterworth_filt_0.5_slice100_hori28_3_0.5_resample.sgy'];
invResults = bsReadTracesByIdsAndHorizons(invResultFileName, GSegyInfo, inIds, crossIds, ...
    timeLine{1}, timeLine{3}, GInvParam.dt, invResultValidRange);

seismicVolume = bsReshapeDataAs3D(seismicData, 142, 110);

invResultsVolume = bsReshapeDataAs3D(invResults, 142, 110);

GInvParam.usedTimeLineId = 1;
GInvParam.upNum = 0;   
GInvParam.downNum = sampNum;

%% the following code is only applied to 2D case
% try 
%     load weightInfo;
% catch
    weighInfo = [];
% end

[invResultsNLM, weightInfo] = bsNLMByRef(invResultsVolume, [], ...
    'searchOffset', 5, 'windowSize', [3, 5, 5], 'nPointsUsed', 6, ...
    'stride', [1, 1, 1], 'searchStride', [1, 1, 1], 'weightInfo', []);

save weightInfo weightInfo;

invResultsNLM2D = bsReshapeDataAs2D(invResultsNLM);

methods = {

    struct(...
        'name', 'Inversion result', ...
        'load', struct(...
            'mode', 'assign', ...
            'data', invResults ...
        )...
    );...
    
    struct(...
        'name', 'Inversion result by NLM', ...
        'isSaveSegy', 1, ...
        'load', struct(...
            'mode', 'assign', ...
            'data', invResultsNLM2D ...
        )...
    );...
};


invResults = bsPostInvTrueMultiTraces(GInvParam, inIds, crossIds, timeLine, methods);
GShowProfileParam.isScaleHorizon = 0;
GShowProfileParam.scaleFactor = 10;
profile = invResults{2};
[basicInfo] = bsInitBasicInfoForShowingProfile(GShowProfileParam, ...
    GInvParam, [], timeLine, profile);

[newProfileData] = bsReScaleAndRestoreData(basicInfo, profile.data, GInvParam.isParallel);    
profile.dt = basicInfo.newDt;

dstFileName = sprintf('%s/sgy_results/%s_dt%.2f.sgy', basePath, profile.name, profile.dt);
bsWriteInvResultIntoSegyFile(profile, newProfileData, ...
    GInvParam.postSeisData.fileName, GSegyInfo, dstFileName);

% [inIds, crossIds] = bsGetProfileCrossingWells(GInvParam, wellLogs([1]), ...
%     'isAlongCrossline', 0);
% invResults2D = bsPostInvTrueMultiTraces(GInvParam, inIds, crossIds, timeLine, methods);
% 
% % show the results
% GShowProfileParam.range.ip = [6400 7700];
% GShowProfileParam.range.seismic = [-3 3]*1e4;
% GShowProfileParam.colormap.allTheSame = bsGetColormap('velocity');
% GShowProfileParam.isColorReverse = 1;
% GShowProfileParam.scaleFactor = 5;
% GShowProfileParam.showWellOffset = 1;
% GShowProfileParam.plotParam.fontsize = 11;
% GShowProfileParam.showPartVert.horizonIds = [1, 3];
% % GShowProfileParam.showPartVert.mode = 'off';
% 
% GShowProfileParam.isShowHorizon = 0;
% bsShowInvProfiles(GInvParam, GShowProfileParam, invResults2D, [], timeLine);
% set(gcf, 'position', [ 96          54        1672         670]);