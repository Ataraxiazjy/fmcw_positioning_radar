%% ����������Ѱ�����֮�ϵ�һ������±�
% iFp: ���֮�ϵ�һ������±�
% v: �����������������ɵľ���ÿ��Ϊһ��ͨ��
function iFp=findFirstPeak(v)
    for i=1:size(v,2);
        findpeaks(v);
    end
end