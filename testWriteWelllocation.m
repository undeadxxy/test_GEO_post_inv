load wellLogs.mat;

nWell = length(wellLogs);

fid = fopen('well_locations.txt', 'w');
for i = 1 : nWell
    t = wellLogs{i};
    fwrite(fid, sprintf('%s \t %.2f \t %.2f \t %d \t %d\n', t.wellName, t.X, t.Y, t.inline, t.crossline));
end

fclose(fid);