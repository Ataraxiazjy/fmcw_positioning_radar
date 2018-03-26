%% ����
clear;
close all;

%% ���в�������
doShowPsZsum=1;

%% ����/��ȡ���ݡ�����
filename='../data/psZsum_200kHz_2000rps_4rpf_4t12r_stand_fall.mat';
load(filename)

psZsum=permute(log2array(logsout,'psZsumSim'),[1,3,2]);

ts=linspace(0,size(psZsum,2)/fF,size(psZsum,2));

%% ��ʾz�Ṧ�ʷֲ�
if doShowPsZsum
    psZsumAj=psZsum./repmat(max(psZsum),length(zsF),1);
    hpsZ=figure('name','Ŀ��� z�����ϸ���Ĺ�����ʱ��仯��ϵͼ');
    imagesc(ts,zsF,psZsumAj);
    set(gca, 'XDir','normal', 'YDir','normal');
    title('Ŀ��� z�����ϸ���Ĺ�����ʱ��仯��ϵͼ');
    xlabel('t(s)');
    ylabel('z(m)');
end
