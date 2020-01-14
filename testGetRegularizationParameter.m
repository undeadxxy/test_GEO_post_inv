testCommonCode;

GInvParam.seisInvOptions.GBOptions.isSaveMiddleRes = 1;
GInvParam.seisInvOptions.searchRegParamFcn = @bsBestParameterByLCurve;
GInvParam.seisInvOptions.regParams = exp(-10:1:0);
methods = {
    
%     
%     struct(...
%         'name', 'TV', ...
%         'flag', 'TV', ...
%         'regParam', [], ...
%         'parampkgs', struct('diffOrder', 1), ...
%         'options', bsSetFields(GInvParam.seisInvOptions, {'maxIter', 50; 'initRegParam', 0.05}) ...
%     ); 

    
    struct(...
        'name', 'LFC', ...
        'flag', 'LFC', ...
        'regParam', [], ...
        'parampkgs', [], ...
        'options', bsSetFields(GInvParam.seisInvOptions, {'maxIter', 50}) ...
    );
};

% for iWell = [23, 21, 18, 53, 80, 75]
for iWell = 23
% for iWell = train_ids
    wellInfo = wellLogs{iWell};
    [invVals, outputs] = bsPostInvTrueWell(GInvParam, wellInfo, timeLine, methods);
    
%     bsShowPostInvLogResult(GInvParam, GShowProfileParam, invVals, GTrainDICParam.filtCoef, 0);
%     title(sprintf('Well %s', wellLogs{iWell}.wellName));
    bsShowIterationProcess(GShowProfileParam, invVals, outputs, wellInfo);
end