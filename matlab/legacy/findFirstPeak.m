%% ����������Ѱ�����֮�ϵ�һ������±�
% iFp: ���֮�ϵ�һ������±�
% v: �����������������ɵľ���ÿ��Ϊһ��ͨ��
% thres: �����ֵ�������������
function isFp=findFirstPeak(v,thres)
isFp=zeros(1,size(v,2));
for i=1:size(v,2);
    [~,ip]=findpeaks(v(:,i),'MinPeakHeight',max(v(:,i))*thres,'NPeaks',1);
    if isempty(ip)
        isFp(i)=nan;
    else
        isFp(i)=ip;
    end
    
end
end