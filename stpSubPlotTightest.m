function stpSubPlotTightest( M, N, index)
%% 本程序用于非常紧凑的显示字典学习的结果
%
% 输入
% M             行数
% N             列数
% index         第几个
%
% 输出           无

    dw = 0.98/N;  dh = 0.98/M;
    w = dw; h = dh ;
    
    y = floor( (index-1) / N);
    x = mod(index-1, N);
    subplot('Position', [x*dw+0.01 1.0-(y+1)*dh w h]);
end

