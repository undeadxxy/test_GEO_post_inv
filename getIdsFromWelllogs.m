function ids = getIdsFromWelllogs(welllogs, names)
    
    ids = zeros(1, length(names));
    
    for k = 1 : length(names)
        
        name = names{k};
        
        for i = 1 : length(welllogs)
            if strcmp(name, welllogs{i}.wellName)
                ids(k) = i;
                break;
            end
        end
    end
end