testCommonCode;


GInvParam.isParallel = 1;
GInvParam.isPrintBySavingFile = 0;

rangeInline = [1, 142];
rangeCrossline = [1, 110];

[inIds, crossIds] = bsGetCDPsByRange(rangeInline, rangeCrossline);

% inverse a profile
% [~, ~, GInvParam, data] = bsBuildInitModel(GInvParam, timeLine, wellLogs, ...
%     'title', 'cross_well', ...
%     'inIds', inIds, ...
%     'filtCoef', 0.15, ...
%     'crossIds', crossIds, ...
%     'isRebuild', 1, ...
%     'p', 2, ...
%     'nPointsUsed', 3 ...
% );


methods = {
  
%     struct(...
%         'name', 'LFC', ...
%         'flag', 'LFC', ...
%         'regParam', 0.1, ...
%         'parampkgs', [], ...
%         'options', bsSetFields(GInvParam.seisInvOptions, {'maxIter', 50;}), ...
%         'showFiltCoef', 0, ...
%         'isSaveSegy', 1 ...
%     ); 


    struct(...
        'name', 'DLSR_New (gamma=0.2 sparsity=2)', ...
        'flag', 'DLSR', ...
        'regParam', struct('lambda', 1, 'gamma', 0.2), ...
        'parampkgs', bsSetFields(GSparseInvParam, {'sparsity', 2}), ...
        'options', bsSetFields(GInvParam.seisInvOptions, ...
            {'maxIter', 5; 'innerIter', 40; 'initRegParam', 0.1}), ...
        'isSaveSegy', 1, ...
        'isSaveMat', 1 ...
    );
    
    struct(...
        'name', 'DLSR_New (gamma=0.2 sparsity=1)', ...
        'flag', 'DLSR', ...
        'regParam', struct('lambda', 1, 'gamma', 0.2), ...
        'parampkgs', bsSetFields(GSparseInvParam, {'sparsity', 1}), ...
        'options', bsSetFields(GInvParam.seisInvOptions, ...
            {'maxIter', 5; 'innerIter', 40; 'initRegParam', 0.1}), ...
        'isSaveSegy', 1, ...
        'isSaveMat', 1, ...
        'load', struct(...
            'mode', 'off', ...
            'fileName', '' ...
        )...
    );
};

% perform the inversion process based on given methods
invResults = bsPostInvTrueMultiTraces(GInvParam, inIds, crossIds, timeLine, methods);

% reshape as 3D
invResults3D = bsReshapeInvResultsAs3D(invResults, rangeInline, rangeCrossline);

% NLM process
NLMResults = bsNLMInvResults(invResults3D, invResults3D{1}.data, ...
    'searchOffset', 4, 'windowSize', [1, 4, 4], 'nPointsUsed', 3, ...
    'stride', [1, 1, 1], 'searchStride', [1, 1, 1] ...
);

% reshape as 2D
invResults2D = bsReshapeInvResultsAs2D(NLMResults);

% write the results
bsWriteInvResultsIntoSegyFiles(GInvParam, invResults2D, ...
    sprintf('NLM_2020_01_13_inline_[%d_%d]_crossline_[%d_%d]', ...
    rangeInline(1), rangeInline(2), ...
    rangeCrossline(1), rangeCrossline(2)));