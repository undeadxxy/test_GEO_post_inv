close all;

from = invResults{4}.data(14:end-5, :);    % �ֵ䷴�ݽ��
to = invResults{5}.data(14:end-5, :);      % ��ͦ���ݽ��
% Wn = 0.15;
% [b, a] = butter(10, Wn, 'high');
% for i = 1 : size(to, 2)
%     to(:, i) = filtfilt(b, a, to(:, i));
%     from(:, i) = filtfilt(b, a, from(:, i));
% end

to = s_convert(to, 0, GInvParam.dt);
from = s_convert(from, 0, GInvParam.dt);
wfilter = s_wiener_filter(from, to, {'option', 'dataset'}, {'flength', 21});
wavelet = wfilter.traces;

sampNum = size(to.traces, 1);
% �����˲��������˲�����
W = bsWaveletMatrix(sampNum, wavelet, [], GInvParam.dt);

% ���˲����
result = W * from.traces;

% Ƶ�ʺϳ�
jointData = zeros(size(result));
dJointData = zeros(size(result));
dt = GInvParam.dt;
% 
parfor i = 1 : size(result, 2)
    jointData(:, i) = bsMixTwoSignal(from.traces(:, i), result(:, i), 80, 120, dt/1000);
    dJointData(:, i) = bsMixTwoSignal(from.traces(:, i), to.traces(:, i), 80, 120, dt/1000);
end
    
dJointData = bsNLMByRef(dJointData, [], 'searchOffset', 3, 'windowSize', [1, 3], 'nPointsUsed', 3, ...
    'stride', [1, 1, 1], 'searchStride', [1, 1, 1] ...
);

showResults = invResults;
showResults(1:3) = [];
% showResults{1}.data = invResults{3}.data(14:end-5, :);
showResults{1}.data = invResults{4}.data(14:end-5, :);
showResults{2}.data = invResults{5}.data(14:end-5, :);

showResults{3} = showResults{2};
showResults{3}.data = result; % ����resultΪjointData�����Ƿ��˲����
showResults{3}.name = 'ά���˲� (�����)';

showResults{4} = showResults{2};
showResults{4}.data = jointData; % ����resultΪjointData�����Ƿ��˲����
showResults{4}.name = 'ά���˲� (�����) + Ƶ�ʺϲ�';

showResults{5} = showResults{2};
showResults{5}.data = dJointData; % ����resultΪjointData�����Ƿ��˲����
showResults{5}.name = '�ֵ�+����ͳ��ѧ Ƶ��ֱ�Ӻϲ�';

GShowInvParam = GInvParam;
GShowInvParam.upNum = GInvParam.upNum - 13; % ���ڳ�ͦ�����ݳ���Ҫ��һЩ���˴���Ҫ����upNum��downNum
GShowInvParam.downNum = GInvParam.downNum - 5;

% ��������
bsShowInvProfiles(GShowInvParam, GShowProfileParam, showResults, wellLogs, timeLine);
set(gcf, 'position', [ 141         193        1580         620]);

% Ƶ�׶Ա�
id = 1;
bsShowFFTResultsComparison(GInvParam, GShowProfileParam, [from.traces(:, id), to.traces(:, id), result(:, id)], ...
    {'�ֵ�', '��ͦ', 'ά���˲� (�����)'});
