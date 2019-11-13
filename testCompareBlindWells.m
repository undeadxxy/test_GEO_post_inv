testCommonCode;
          
GPostInvParam.bound.mode = 'based_on_init';
GPostInvParam.bound.offset_init = 2000;

% set the options of inversion process
seisInvOptions = bsCreateSeisInv1DOptions();
seisInvOptions.GBOptions.optAlgHandle = @bsOptQCG;
seisInvOptions.GBOptions.display = 'off';
seisInvOptions.GBOptions.optAlgParam.updateFlag = 'PR';
seisInvOptions.GBOptions.isSaveMiddleRes = true;

seisInvOptions.maxIter = 400;
seisInvOptions.innerIter = 5;
seisInvOptions.addLowFreqConstraint = true;
seisInvOptions.initRegParam = 0.5;
seisInvOptions.searchRegParamFcn = [];

GPostInvParam.initModel.initLog = 0.5;

% set the options for training dictionary
GTrainDICParam.sizeAtom = 80;
GTrainDICParam.nAtom = 6000;
GTrainDICParam.filtCoef= 0.5;

% set the options for sparse inversion
GSparseInvParam.sparsity = 1;
GSparseInvParam.stride = 1;

% set the options for showing the results
GShowProfileParam.dataRange = [5000 8000];        

% the name of the folder to save the learned dictionaries
trainNum = 80;
% train_names = {'W1-1901', 'W1-2013', 'W1-2133', 'W2-1901', 'W2-2024', 'W2-2214', 'W3-1833'};
% train_ids = getIdsFromWelllogs(wellLogs, train_names);
train_ids = randperm(length(wellLogs), trainNum);
% trainNum = length(trainWelllogs);
[DIC, train_ids] = bsTrainOneDIC(wellLogs, train_ids, GTrainDICParam);

blind_ids = setdiff(1:length(wellLogs), train_ids);
GSparseInvParam.DIC = DIC;

% test methods
methods = {
% 1. method name
% 2. method flag
% 3. regularization parameter
% 4. some other information required for regularization
% 5. options for controling inversion process

'TV-1', 'TV', 0.2, struct('diffOrder', 1), ...
    bsSetFields(seisInvOptions, {'maxIter', 400});
'TK-1', 'TK', 0.4, struct('diffOrder', 2), ...
    bsSetFields(seisInvOptions, {'maxIter', 400});
'MGS', 'MGS', 0.4, struct('diffOrder', 2, 'beta', 0.015), ...
    bsSetFields(seisInvOptions, {'maxIter', 400});
'DLSR', 'DLSR', struct('lambda', 0.5, 'gamma', 0.1), struct('GSparseInvParam', GSparseInvParam), ...
    bsSetFields(seisInvOptions, {'maxIter', 5; 'innerIter', 100; 'initRegParam', 0.5});
};

% inverse the blind wells
for iWell = blind_ids
    wellInfo = wellLogs{iWell};
    [invVals, model] = bsPostInvTrueWell(GPostInvParam, wellInfo, timeLine, methods);
    
    bsShowPostInvLogResult(GPostInvParam, GPlotParam, GShowProfileParam, model, invVals, methods(:, 1), 0.6);
%     title(sprintf('Well %s', wellLogs{iWell}.wellName));
end

