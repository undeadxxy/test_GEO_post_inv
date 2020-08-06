function [outputData] = bsPostReBuildByDualSR(GInvParam, GSparseInvParam, inputData)

    [sampNum, traceNum] = size(inputData);


    GSparseInvParam = bsInitDLSRPkgs(GSparseInvParam, sampNum);

        % tackle the inverse task
    outputData = zeros(sampNum, traceNum);
    dt = GInvParam.dt;
    GInvParam.isParallel = 0;
    
    if GInvParam.isParallel

        pbm = bsInitParforProgress(GInvParam.numWorkers, ...
            traceNum, ...
            'Rebuid data progress information', ...
            GInvParam.modelSavePath, ...
            GInvParam.isPrintBySavingFile);

        % parallel computing
        parfor iTrace = 1 : traceNum
            outputData(:, iTrace) = bsHandleOneTrace(GSparseInvParam, inputData(:, iTrace));
            bsIncParforProgress(pbm, iTrace, 10000);
        end
        
        bsDeleteParforProgress(pbm);
        
    else
        % non-parallel computing 
        for iTrace = 1 : traceNum
%             fprintf('Reconstructing the %d-th trace...\n', iTrace);
            outputData(:, iTrace) = bsHandleOneTrace(GSparseInvParam, inputData(:, iTrace));
        end
    end
    
end

function newData = bsHandleOneTrace(GSparseInvParam, low)

    sampNum = size(low, 1);
    ncell = GSparseInvParam.ncell;
    sizeAtom = GSparseInvParam.sizeAtom;
    patches = zeros(sizeAtom*3, ncell);
    max_val = GSparseInvParam.DIC.max_val;
    min_val = GSparseInvParam.DIC.min_val;
    
    low = (low - min_val) / (max_val - min_val);
    low1 = conv(low, [1,0,-1], 'same'); % the filter is centered and scaled well for s=3
	low2 = conv(low, [1,0,-2,0,1]/2, 'same');
        
    for j = 1 : ncell
        js = GSparseInvParam.index(j);
        ee = js+sizeAtom-1;
        patches(:, j) = [low(js : ee); low1(js : ee); low2(js : ee)];
    end
    
    PL = GSparseInvParam.DIC.B' * patches;
    
    gammas = omp(GSparseInvParam.D1'*PL, ...
                    GSparseInvParam.omp_G, ...
                    GSparseInvParam.sparsity);
    
    new_patches = GSparseInvParam.D2 *  gammas;
    
    tmpData = bsAvgPatches(new_patches, GSparseInvParam.index, sampNum);
    
    newData = tmpData + low;
    
    % 合并低频和中低频
%     if strcmp(options.mode, 'low_high')
%         ft = 1/dt*1000/2;
%         newData = bsMixTwoSignal(low, tmpData, options.lowCut*ft, options.lowCut*ft, dt/1000);
% %         bsShowFFTResultsComparison(1, [low, tmpData, newData], {'反演结果', '高频', '合并'});
%     else
%         newData = tmpData;
%     end
    
end

function GSparseInvParam = bsInitDLSRPkgs(GSparseInvParam, sampNum)

    validatestring(string(GSparseInvParam.reconstructType), {'equation', 'simpleAvg'});
    
%     [sizeAtom, nAtom] = size(GSparseInvParam.DIC);
%     sizeAtom = sizeAtom / 2;
    
    sizeAtom = GSparseInvParam.trainDICParam.sizeAtom;
    nAtom = GSparseInvParam.trainDICParam.nAtom;
    
    GSparseInvParam.sizeAtom = sizeAtom;
    GSparseInvParam.nAtom = nAtom;
    
    GSparseInvParam.nrepeat = sizeAtom - GSparseInvParam.stride;
    
    index = 1 : GSparseInvParam.stride : sampNum - sizeAtom + 1;
    if(index(end) ~= sampNum - sizeAtom + 1)
        index = [index, sampNum - sizeAtom + 1];
    end
    
    GSparseInvParam.index = index;
    GSparseInvParam.ncell = length(index);

    D1 = GSparseInvParam.DIC.AL;
    D2 = GSparseInvParam.DIC.AH;
    
%     [D1, D2, C] = bsNormalDIC(D1, D2);
    
    GSparseInvParam.D1 = D1;
    
    GSparseInvParam.omp_G = D1' * D1;
    GSparseInvParam.D2 = D2;
    
%     GSparseInvParam.neiborIndecies = bsGetNeiborIndecies(D1, GSparseInvParam.nNeibor);
end

% function [D1, D2, C] = bsNormalDIC(D1, D2)
%     C = zeros(size(D1, 2), 1);
%     
%     for i = 1 : size(D1, 2)
%         normCoef = norm(D1(:, i));
%         D1(:, i) = D1(:, i) / normCoef;
%         D2(:, i) = D2(:, i) / normCoef;
%         C(i) = normCoef;
%     end
% end
  