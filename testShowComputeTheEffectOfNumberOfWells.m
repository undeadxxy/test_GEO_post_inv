figure;
colors = {'r-+', 'k-o', 'b-+', 'g-o'};

% matResults = cell2mat(results);
fcn = @(data, t)(median(data, t));
showData = cell(1, 5);

allData = cell(5, nTrainCases);

for i = 1 : 5
    data = zeros(nTrainCases, nSimulations);
    
    for j = 1 : nTrainCases
        for k = 1 : nSimulations
            train_ids = results{j, k}.train_ids;
            test_ids = setdiff(1:nWell, train_ids);
            
            switch i
                case 1
                    invData = results{j, k}.DLSR;
                    index = train_ids;
                case 2
                    invData = results{j, k}.DLSR;
                    index = test_ids;
                case 3
                    invData = results{j, k}.DLSR_EB;
                    index = train_ids;
                case 4
                    invData = results{j, k}.DLSR_EB;
                    index = test_ids;
                case 5
                    invData = baseline;
                    index = 1 : nWell;
            end
        
            rmse_values = bsCalcRRSE(wellData(:, index), ...
                initModel(:, index),...
                invData(:, index));
            data(j, k) = fcn(rmse_values, 2);
            
            allData{i, j} = [allData{i, j}, rmse_values];
        end
        
        
    end
    
    showData{i} = fcn(data, 2);

end

for i = 1 : 4
    plot(1:nTrainCases, showData{i}, colors{i}, 'linewidth', 2); hold on;
end
legend('DLSR (Train)', 'DLSR (Test)', 'DLSR-EM (Train)', 'DLSR-EM (Test)');
bsSetDefaultPlotSet(bsGetDefaultPlotSet());

figure;
set(gcf, 'position', [342   171   845   331]);
iCase = 2;
tstrs = {'(a) Distributions of RRSE for training data', '(b) Distributions of RRSE for test data'};
binLimits = {[0 1], [0.4 1.7]};

for i = 1 : 2
    bsSubPlotFit(1, 2, i, 0.96, 0.88, 0.08, 0.1, 0.08, 0);

    if i == 2
        histogram(allData{i+3, iCase}, 100, 'Normalization', 'probability', 'EdgeColor', 'green', ...
        'FaceColor',  'green', 'FaceAlpha', 1, 'EdgeAlpha', 1, 'BinLimits', binLimits{i});
        hold on;
    end
    
    histogram(allData{i, iCase}, 100, 'Normalization', 'probability', 'EdgeColor', 'blue', ...
        'FaceColor',  'blue', 'FaceAlpha', 0.6, 'EdgeAlpha', 0.6, 'BinLimits', binLimits{i});
    hold on
    histogram(allData{i+2, iCase}, 100, 'Normalization', 'probability', 'EdgeColor', 'red', ...
        'FaceColor',  'red', 'FaceAlpha', 0.6, 'EdgeAlpha', 0.6, 'BinLimits', binLimits{i});

    
    title(tstrs{i}, 'fontweight', 'bold');
    switch i
        case 1
            legend('DLSR', 'DLSR-EM');
        case 2
            legend('TK', 'DLSR', 'DLSR-EM');
    end
    
    
    xlabel('RRMSE');
    ylabel('Probability');
    bsSetDefaultPlotSet(bsGetDefaultPlotSet());
end



