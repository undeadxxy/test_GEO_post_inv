function stpSubPlotTightest( M, N, index)
%% ���������ڷǳ����յ���ʾ�ֵ�ѧϰ�Ľ��
%
% ����
% M             ����
% N             ����
% index         �ڼ���
%
% ���           ��

    dw = 0.98/N;  dh = 0.98/M;
    w = dw; h = dh ;
    
    y = floor( (index-1) / N);
    x = mod(index-1, N);
    subplot('Position', [x*dw+0.01 1.0-(y+1)*dh w h]);
end

