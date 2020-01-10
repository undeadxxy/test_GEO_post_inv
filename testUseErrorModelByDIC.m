testCommonCode;

GInvParam.isParallel = 1;
GInvParam.isPrintBySavingFile = 0;

ids = bsGetIdsFromWelllogs(wellLogs, {'W1-2214', 'W1-2132', 'W1-2113', 'W2-2024',...
    'W2-2013','W3-1931', 'W3-1901'});
% ids = [23, 21, 18, 53, 80, 75];
[inIds, crossIds] = bsGetProfileCrossingWells(GInvParam, wellLogs(ids), ...
    'isAlongCrossline', 0);

[~, ~, GInvParam, data] = bsBuildInitModel(GInvParam, timeLine, wellLogs, ...
    'title', 'test', ...
    'isRebuild', 1, ...
    'p', 1.2, ...
    'nPointsUsed', 14, ...
    'inIds', inIds, ...
    'crossIds', crossIds ...
);

% build synthetic data
[synWellLogs, dataIndex, type] = bsGetErrorOfWelllog(GInvParam, timeLine, wellLogs);

r_ids = bsGetIdsFromWelllogs(synWellLogs, {'W1-2113', 'W3-1931'});
% r_ids = [];
% 
% train_ids = bsRandSeq(1:104, 80);
% train_ids = unique([train_ids,ids]);
% train_ids = setdiff(train_ids, r_ids);
load train_ids.mat;
GTrainDICParam = bsCreateGTrainDICParam(...
    'csr', ...
    'title', 'error', ...
    'sizeAtom', 90, ...
    'sparsity', 5, ...
    'nAtom', 5000, ...
    'filtCoef', 1);
GTrainDICParam.isNormalize = 0;

[DIC, train_ids] = bsTrainDics(GTrainDICParam, synWellLogs, train_ids, ...
    [ dataIndex-2, dataIndex], 0);

GSynSparse = bsCreateGSparseInvParam(DIC, 'csr', 'sparsity', 1);

[~, ~, ~, dstFileNames, segyInfo] ...
    = bsPostBuildSynData(GInvParam, GSynSparse, timeLine, ...
    'inIds', inIds, ...
    'crossIds', crossIds, ...
    'gamma', 0.8, ...
    'isRebuild', 1 ...
    );

realData = bsReadTracesByIdsAndTimeLine(GInvParam.postSeisData.fileName, ...
    GInvParam.postSeisData.segyInfo, inIds, crossIds, ...
    timeLine{GInvParam.usedTimeLineId}, GInvParam.upNum, GInvParam.downNum, GInvParam.dt);


synData = bsReadTracesByIdsAndTimeLine(dstFileNames{1}, segyInfo, inIds, crossIds, ...
        timeLine{GInvParam.usedTimeLineId}, GInvParam.upNum, GInvParam.downNum, GInvParam.dt);
synData = bsNLMByRef(synData, realData);

[wellPos, wellIndex, wellNames] = bsFindWellLocation(synWellLogs, inIds, crossIds);
synWellLogs = bsSetNameForWelllogs(synWellLogs);
tmpWellLog = synWellLogs(wellIndex);

for i = 1:length(wellPos)
    index = wellIndex(i);

    tmpWellLog{i}.wellLog = [tmpWellLog{i}.wellLog, synData(1:end-1, wellPos(i))];
    
end

bsShowWellLogs(tmpWellLog(2:end-1), GInvParam.indexInWellData.time, [-2, -1, 1]+dataIndex, ...
    {'Real data (d)', 'Synthetic data (Gx)', "Reconstructed d'"}, ...
    'colors', {'k', 'b', 'r'}, ...
    'isNormal', 0, ...
    'range', [-2.5 2.5]*1e4 ...
);
set(gcf, 'position', [0.4840    0.0540    1.1096    0.3640]*1000);

errorData = realData - synData;

methods = {
    
    struct(...
        'name', 'Original seismic d', ...
        'type', 'Seismic', ...
        'load', struct(...
            'mode', 'assign', ...
            'data', realData ...
        )...
    );...

    
    struct(...
        'name', 'Error model e', ...
        'type', 'Seismic', ...
        'load', struct(...
            'mode', 'assign', ...
            'data', errorData ...
        )...
    );...
    
    struct(...
        'name', "Reconstruct seismic d' = d - e", ...
        'type', 'Seismic', ...
        'load', struct(...
            'mode', 'assign', ...
            'data', synData ...
        )...
    );...
};

methods1 = {
    
    
    struct(...
        'name', 'Jason', ...
        'isSaveMat', 0, ...
        'load', struct(...
            'mode', 'segy', ...
            'fileName', [basePath, '\inv_result\inverted_impedance_jason_bgp.sgy'], ...
            'segyInfo', bsSetFields(GSegyInfo, {'inlineId', 189; 'crossId', 21; 't0', 750}) ...
        )...
    ); 
    
    struct(...
        'name', 'DLSR', ...
        'flag', 'DLSR', ...
        'regParam', struct('lambda', 0.4, 'gamma', 0.4), ...
        'parampkgs', GSparseInvParam, ...
        'options', bsSetFields(GInvParam.seisInvOptions, ...
            {'maxIter', 5; 'innerIter', 40; 'initRegParam', 0.04}), ...
        'showFiltCoef', 1, ...
        'load', struct(...
            'mode', 'off', ...
            'fileName', '' ...
        )...
    );
    
};

inputDatas = bsPostInvTrueMultiTraces(GInvParam, inIds, crossIds, timeLine, methods);

GInvParam.postSeisData.mode = 'segy';
GInvParam.postSeisData.segyInfo = GSegyInfo;
GInvParam.postSeisData.fileName = sprintf('%s/seismic/seismic.sgy', basePath);

invResults1 = bsPostInvTrueMultiTraces(GInvParam, inIds, crossIds, timeLine, methods1);

GInvParam.postSeisData.mode = 'function';
GInvParam.postSeisData.fcn = @(inline, crossline, startTime)...
    (synData(1:end-1, inIds==inline &crossIds==crossline));
invResults2 = bsPostInvTrueMultiTraces(GInvParam, inIds, crossIds, timeLine, methods1(2));
invResults2{1}.name = 'DLSR-EB';

invResults = [invResults1, invResults2];

NLM = bsNLMInvResults([inputDatas, invResults], inputDatas{1}.data);


GShowProfileParam.showLeftTrNumByWells = 500;
GShowProfileParam.showRightTrNumByWells = 500;
GShowProfileParam.range.seismic = [-1.5 1.5]*1e4;
GShowProfileParam.range.ip = [5800 7700];

GShowProfileParam.colormap.allTheSame = bsGetColormap('original');
% GShowProfileParam.colormap.allTheSame = bsGetColormap('velocity');
GShowProfileParam.isColorReverse = 0;

GShowProfileParam.scaleFactor = 6;
GShowProfileParam.showWellOffset = 1;
GShowProfileParam.plotParam.fontsize = 10;
GShowProfileParam.showPartVert.upTime = 80;
GShowProfileParam.showPartVert.downTime = 50;
% GShowProfileParam.showPartVert.mode = 'off';
GShowProfileParam.showPartVert.mode = 'up_down_time';
% GShowProfileParam.showPartVert.mode = 'in_2_horizons';
% GShowProfileParam.showPartVert.horizonIds = [1, 2];
GShowProfileParam.isShowColorWells = 1;
GShowProfileParam.isShowWellNames = 1;

newNameWellLogs = bsSetNameForWelllogs(wellLogs);

GShowProfileParam.isShowHorizon = 0;
bsShowInvProfiles(GInvParam, GShowProfileParam, (NLM), newNameWellLogs, timeLine);
set(gcf, 'position', [  96          54        1514         668]);
% bsSetPosition(0.5740,    0.7111);

