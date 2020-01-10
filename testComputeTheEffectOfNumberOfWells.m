testCommonCode;

GInvParam.isParallel = 1;
GInvParam.isPrintBySavingFile = 0;
nSimulations = 20;
trainingCases = 10:10:100;
% trainingCases = 20;

wells = cell2mat(wellLogs);
nWell = length(wells);

inIds = [wells.inline];
crossIds = [wells.crossline];

% [~, ~, GInvParam, data] = bsBuildInitModel(GInvParam, timeLine, wellLogs, ...
%     'title', 'test', ...
%     'isRebuild', 1, ...
%     'p', 1.2, ...
%     'nPointsUsed', 14, ...
%     'inIds', inIds, ...
%     'crossIds', crossIds ...
% );

GTrainSynDICParam = bsCreateGTrainDICParam(...
    'csr', ...
    'title', 'error', ...
    'iterNum', 5, ...
    'sizeAtom', 80, ...
    'sparsity', 5, ...
    'nAtom', 6000, ...
    'isNormalize', 0, ...
    'isShowIterInfo', 'n', ...
    'filtCoef', 1);
% build synthetic data
[synWellLogs, dataIndex, type] = bsGetErrorOfWelllog(GInvParam, timeLine, wellLogs);

% the method to test
methods = {
    struct(...
        'name', 'DLSR (gamma=0.8)', ...
        'flag', 'DLSR', ...
        'regParam', struct('lambda', 2, 'gamma', 0.4), ...
        'parampkgs', GSparseInvParam, ...
        'options', bsSetFields(GInvParam.seisInvOptions, ...
            {'maxIter', 5; 'innerIter', 20; 'initRegParam', 0.1}) ...
    );
    
};

wellHorizonTimes = bsGetHorizonTime(timeLine{GInvParam.usedTimeLineId}, ...
        inIds, crossIds);
trueModel = bsGetWellData(GInvParam, synWellLogs, wellHorizonTimes, ...
    GInvParam.indexInWellData.ip, 1);
wellData = bsFilterProfileData(trueModel, GShowProfileParam.showWellFiltCoef, 0);


initModel = bsFilterProfileData(trueModel, GInvParam.initModel.filtCoef, 0);
GInvParam.initModel.mode = 'function';
GInvParam.initModel.fcn = @(inline, crossline, startTime)...
            (initModel(:, inIds==inline &crossIds==crossline));

initModel = bsFilterProfileData(trueModel, 0.05, 0);
        
nTrainCases = length(trainingCases);
GInvParam.postSeisData.segyInfo = GSegyInfo;
GInvParam.postSeisData.fileName = sprintf('%s/seismic/seismic.sgy', basePath);
GTrainDICParam.isShowIterInfo = 'n';

results = cell(nTrainCases, nSimulations);

realData = bsReadTracesByIdsAndTimeLine(GInvParam.postSeisData.fileName, ...
    GInvParam.postSeisData.segyInfo, inIds, crossIds, ...
    timeLine{GInvParam.usedTimeLineId}, GInvParam.upNum, GInvParam.downNum, GInvParam.dt);


for i = 1 : nTrainCases
    nTrainingIds = trainingCases(i);
    for j = 1 : nSimulations
        fprintf('Testing of #train =%d, #simulation=%d...\n', i, j);
        
        train_ids = bsRandSeq(1:104, nTrainingIds);
        
        GTrainDICParam.nAtom = 90 * nTrainingIds;
        GTrainSynDICParam.nAtom = 70 * nTrainingIds;
        
        % for inversion
        [DIC, train_ids] = bsTrainDics(GTrainDICParam, wellLogs, train_ids, ...
            [   GInvParam.indexInWellData.ip], 1);
        methods{1}.parampkgs.DIC = DIC;
        
        % for rebuilding seismic data
        [SynDIC, train_ids] = bsTrainDics(GTrainSynDICParam, synWellLogs, train_ids, ...
            [ dataIndex-2, dataIndex], 1);
        GSynSparse = bsCreateGSparseInvParam(SynDIC, 'csr', 'sparsity', 1);

        % get syn data
        [~, ~, ~, dstFileNames, segyInfo] ...
            = bsPostBuildSynData(GInvParam, GSynSparse, timeLine, ...
            'inIds', inIds, ...
            'crossIds', crossIds, ...
            'gamma', 0.9, ...
            'isRebuild', 1 ...
            );
        
        synData = bsReadTracesByIdsAndTimeLine(dstFileNames{1}, segyInfo, inIds, crossIds, ...
            timeLine{GInvParam.usedTimeLineId}, GInvParam.upNum, GInvParam.downNum, GInvParam.dt);
    
%         figure; 
%         subplot(2,2,1); imagesc(synData); colorbar;
%         subplot(2,2,2); imagesc(realData);  colorbar;
%         subplot(2,2,3); imagesc(realData - synData); colorbar;
        
        GInvParam.postSeisData.mode = 'segy';
        invResults1 = bsPostInvTrueMultiTraces(GInvParam, inIds, crossIds, timeLine, methods);

        GInvParam.postSeisData.mode = 'function';
        GInvParam.postSeisData.fcn = @(inline, crossline, startTime)...
            (synData(1:end-1, inIds==inline &crossIds==crossline));
        invResults2 = bsPostInvTrueMultiTraces(GInvParam, inIds, crossIds, timeLine, methods);

        res.train_ids = train_ids;
        res.DLSR = invResults1{1}.data;
        res.DLSR_EB = invResults2{1}.data;
        results{i, j} = res;
        
        test_ids = setdiff(1:nWell, train_ids);
        
        res.DLSR_Train_RRSE = bsCalcRRSE(wellData(:, train_ids), initModel(:, train_ids), res.DLSR(:, train_ids));
        res.DLSR_Train_Avg_RRSE = mean(res.DLSR_Train_RRSE);
        res.DLSR_Test_RRSE = bsCalcRRSE(wellData(:, test_ids), initModel(:, test_ids), res.DLSR(:, test_ids));
        res.DLSR_Test_Avg_RRSE = mean(res.DLSR_Test_RRSE);
        
        res.DLSR_EB_Train_RRSE = bsCalcRRSE(wellData(:, train_ids), initModel(:, train_ids), res.DLSR_EB(:, train_ids));
        res.DLSR_EB_Train_Avg_RRSE = mean(res.DLSR_EB_Train_RRSE);
        res.DLSR_EB_Test_RRSE = bsCalcRRSE(wellData(:, test_ids), initModel(:, test_ids), res.DLSR_EB(:, test_ids));
        res.DLSR_EB_Test_Avg_RRSE = mean(res.DLSR_EB_Test_RRSE);
        
        fprintf('DLSR->(TRAIN_RRSE:%.4f, TEST_RRSE:%.4f) \n DLSR_EB->(TRAIN_RRSE:%.4f, TEST_RRSE:%.4f)...\n', ...
            res.DLSR_Train_Avg_RRSE, res.DLSR_Test_Avg_RRSE, ...
            res.DLSR_EB_Train_Avg_RRSE, res.DLSR_EB_Test_Avg_RRSE);
        
        results{i, j} = res;
        
%         figure;
%         histogram(res.DLSR_Test_RRSE, 20); hold on;
%         histogram(res.DLSR_EB_Test_RRSE, 20); hold on;
%         figure;
%         index = bsRandSeq(1:nWell, 1);
%         plot(wellData(:, index), 1:size(wellData, 1), 'k', 'linewidth', 2); hold on;
%         plot(res.DLSR(:, index), 1:size(wellData, 1), 'r', 'linewidth', 2);
%         plot(res.DLSR_EB(:, index), 1:size(wellData, 1), 'b', 'linewidth', 2);
%         set(gca, 'ydir', 'reverse');
%         set(gcf, 'position', [ 336   240   373   666]);
%         legend('True', 'DLSR', 'DLSR-EB');
        try 
            save CompareTheEffectOfNumberOfWells;
        catch
            save CompareTheEffectOfNumberOfWells -v7.3;
        end
    end
    
end

% the method to test
methods = {
    struct(...
        'name', 'LFC', ...
        'flag', 'LFC', ...
        'regParam', 0.1, ...
        'parampkgs', [], ...
        'options', bsSetFields(GInvParam.seisInvOptions, {'maxIter', 400}) ...
    );
    
};
GInvParam.postSeisData.mode = 'segy';
invResults1 = bsPostInvTrueMultiTraces(GInvParam, inIds, crossIds, timeLine, methods);

baseline = invResults1{1}.data;

testShowComputeTheEffectOfNumberOfWells;

