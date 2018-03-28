%% ����
clear;
close all;

%% ���в�������
doLabel=1;

%% ����/��ȡ���ݡ�����
sFileData='../data/psZsum_200kHz_2000rps_4rpf_4t12r_stand_fall.mat';
sFileTime='../data/psZsum_200kHz_2000rps_4rpf_4t12r_stand_fall.txt';
load(sFileData)

psZsum=permute(log2array(logsout,'psZsumSim'),[1,3,2]);

ts=linspace(0,size(psZsum,2)/fF,size(psZsum,2));

%% ��ʾz�Ṧ�ʷֲ�

psZsumAj=psZsum./repmat(max(psZsum),length(zsF),1);
hpsZ=figure('name','Ŀ��� z�����ϸ���Ĺ�����ʱ��仯��ϵͼ');
imagesc(ts,zsF,psZsumAj);
set(gca, 'XDir','normal', 'YDir','normal');
title('Ŀ��� z�����ϸ���Ĺ�����ʱ��仯��ϵͼ');
xlabel('t(s)');
ylabel('z(m)');

if doLabel
    %% ��ȡlabel
    idFileTime=fopen(sFileTime);
    
    % ����ʱ��
    contentFileTime=textscan(idFileTime,'%f %f %f');
    tsLabel=cumsum(contentFileTime{2}*60+contentFileTime{3});
    tFirstLabel=input('����z�����Ϲ��ʷֲ�ͼ�е�һ���������ʱ��(s)��');
    tsLabel=tsLabel-tsLabel(1)+tFirstLabel;
    
    % �����ǩ
    lbsChange=tsLabel;
    
    fclose(idFileTime);
    
    %% �����ǩ�ͱ�ǩʱ��
    save(sFileData,'lbsChange','-append');
end
%% չʾ��ǩ
[~,isZMax]=max(psZsum);
zsMax=zsF(isZMax);
figure('name','չʾ��ǩ');
plot(ts,zsMax);
hold on;
isLbsChange=interp1(ts,1:length(ts),lbsChange,'nearst');
plot(lbsChange,zsMax(isLbsChange),'o');
hold off;



