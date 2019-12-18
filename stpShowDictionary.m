function stpShowDictionary(Dic)

    %global GSparseInvParam;
    
    figure;
    
    %temp = nAtom;
    [sizeAtom, nAtom] = size(Dic);
    
    if( nAtom <= 10)
%         row = round( sqrt( nAtom / 2 ) );
        row = 1;
    elseif nAtom <= 100
        row = 4;
    else
%         Dic = Dic(:, randperm(nAtom, 100));
%         Dic = Dic(:, 21:80);
%         Dic(:, 9:10) = Dic(:, 79:80);
        
%         nAtom = 60;
%         row = 5;
        nAtom = 40;
        row = 4;
    end
    
    col = (nAtom / row);

%     seq = randperm(size(Dic, 2), nAtom);
    
    for i = 1 : nAtom
        stpSubPlotTightest(row, col, i);

%         tmp = abs(Dic(:, i));
        tmp = Dic(:, i);
        tmp = mapminmax(tmp', 0, 1);
        tmp = tmp';
        
        plot(tmp, 1:length(tmp), 'k', 'linewidth', 1.5);
%         maxVal = max(tmp);
%         minVal = min(tmp);
%         set(gca, 'xlim', [0.95*minVal, 1.05*maxVal]);
        
        set(gca, 'xlim', [-0.05, 1.05]);
        set(gca, 'ylim', [0, sizeAtom+1]);
        set(gca,'xtick',[],'xticklabel',[])
        set(gca,'ytick',[],'yticklabel',[])
        
        set(gca,'ydir','reverse');
    end
    
    set(gcf, 'position', stpCalcBestPosition(0.3, 0.3) );
%     set(gcf, 'position', [ 941   169   469   207]);
    %nAtom = temp;
   
end