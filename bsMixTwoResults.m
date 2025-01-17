function bsMixTwoResults(lowFileName, highFileName, outFileName, GSegyInfo, ...
    inIds, crossIds, horizon, upNum, downNum, dt, validRange, fs1, fs2)

%     [highData, ~, startTime] = bsReadTracesByIdsAndHorizons(highFileName, GSegyInfo, inIds, crossIds, ...
%         horizon1, horizon2, dt, validRange);
%     lowData = bsReadTracesByIdsAndHorizons(lowFileName, GSegyInfo, inIds, crossIds, ...
%         horizon1, horizon2, dt, validRange);

    horizonTime = bsGetHorizonTime(horizon, inIds, crossIds, 1);
    
    startTime = horizonTime - upNum * dt;
    sampNum = upNum + downNum;
    
    highData = bsReadTracesByIds(highFileName, GSegyInfo, inIds, crossIds, startTime, sampNum, dt);
    lowData = bsReadTracesByIds(lowFileName, GSegyInfo, inIds, crossIds, startTime, sampNum, dt);
    
    

    jointData = zeros(size(lowData));
    nTrace = size(highData, 2);
    
    parfor i = 1 : nTrace
        jointData(:, i) = bsMixTwoSignal(lowData(:, i), highData(:, i), fs1, fs2, dt/1000);

%         if mod(i, 1000) == 0
%             fprintf('Mixing signals %d/%d...\n', i, nTrace);
%         end
    end
    
    res.inIds = inIds;
    res.crossIds = crossIds;
    res.dt = dt;
    res.upNum = 0;
    res.horizon = startTime;
   
    bsWriteInvResultIntoSegyFile(res, jointData, lowFileName, GSegyInfo, outFileName);
end