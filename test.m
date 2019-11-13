usedTimeLine = timeLine{2}
for i = 1 : length(wellLogs)
    wellInfo = wellLogs{i};
    [~, ~, horizonTime] = bsCalcWellBaseInfo(usedTimeLine, ...
        wellInfo.inline, wellInfo.crossline, 1, 2, 1, 2, 3);
    wellInfo.t0 = horizonTime - 130;
    wellLogs{i} = wellInfo;
end