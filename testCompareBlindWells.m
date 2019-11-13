testCommonCode;
          
GPostInvParam.bound.mode = 'off';
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

GPostInvParam.initModel.initLog = [];
GPostInvParam.initModel.filtCoef = 1;

% set the options for training dictionary
GTrainDICParam.sizeAtom = 80;
GTrainDICParam.nAtom = 8000;
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
% 1. name:      method name
% 2. flag:      method flag
% 3. regParam:  regularization parameter
% 4. parampkgs: some other information required for regularization
% 5. options:   options for controling inversion process
    
    struct(...
        'name', 'TV-1', ...
        'flag', 'TV', ...
        'regParam', 0.2, ...
        'parampkgs', struct('diffOrder', 1), ...
        'options', bsSetFields(seisInvOptions, {'maxIter', 200; 'initRegParam', 0.5}) ...
    ); 
    struct(...
        'name', 'TK-1', ...
        'flag', 'TK', ...
        'regParam', 0.4, ...
        'parampkgs', struct('diffOrder', 2), ...
        'options', bsSetFields(seisInvOptions, {'maxIter', 200; 'initRegParam', 0.5}) ...
    ); 
    struct(...
        'name', 'MGS', ...
        'flag', 'MGS', ...
        'regParam', 0.4, ...
        'parampkgs', struct('diffOrder', 2, 'beta', 0.015), ...
        'options', bsSetFields(seisInvOptions, {'maxIter', 400}) ...
    );
    struct(...
        'name', 'DLSR', ...
        'flag', 'DLSR', ...
        'regParam', struct('lambda', 0.5, 'gamma', 0.5), ...
        'parampkgs', struct('GSparseInvParam', GSparseInvParam), ...
        'options', bsSetFields(seisInvOptions, {'maxIter', 5; 'innerIter', 100; 'initRegParam', 0.2}) ...
    )
};

% inverse the blind wells
for iWell = blind_ids
    wellInfo = wellLogs{iWell};
    [invVals, model] = bsPostInvTrueWell(GPostInvParam, wellInfo, timeLine, methods);
    
    bsShowPostInvLogResult(GPostInvParam, GPlotParam, GShowProfileParam, model, invVals, methods, 0.6);
%     title(sprintf('Well %s', wellLogs{iWell}.wellName));
end

