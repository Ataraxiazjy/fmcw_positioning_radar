%% ����
clear;
close all;

%% ���в�������
doShowPsZsum=1;

%% ����/��ȡ���ݡ�����
filename='../data/psZsum_200kHz_800rps_1rpf_4t12r_ztest_stand_squat_lie.mat';
load(filename)

psZsum=permute(log2array(logsout,'psZsumSim'),[1,3,2]);

ts=linspace(0,size(psZsum,2)/fF,size(psZsum,2));

%% ��ʾz�Ṧ�ʷֲ�
if doShowPsZsum
    psZsum=psZsum./repmat(max(psZsum),length(zsF),1);
    hpsZ=figure('name','Ŀ��� z�����ϸ���Ĺ�����ʱ��仯��ϵͼ');
    imagesc(ts,zsF,psZsum);
    set(gca, 'XDir','normal', 'YDir','normal');
    title('Ŀ��� z�����ϸ���Ĺ�����ʱ��仯��ϵͼ');
    xlabel('t(s)');
    ylabel('z(m)');
end
