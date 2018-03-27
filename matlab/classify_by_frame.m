%% ֱ��ʹ��ģ�ͽ����б�
%% ����
clear;
close all;

%% ��ȡ���ݣ���������
sFileData='../data/psZsum_200kHz_2000rps_4rpf_4t12r_stand_fall.mat';
sFileClassifier='../data/fall_classifier_by_frame.mat';

load(sFileData)
load(sFileClassifier)       %����ģ��

psZsum=permute(log2array(logsout,'psZsumSim'),[1,3,2]);
psZsum=psZsum./repmat(max(psZsum),length(zsF),1);

%% ���Ʊ���z����ͼ
 
imagesc(flipud(psZsum));

%% ����ת��Ϊ���+״̬�б�
oritable=array2table(psZsum');  %ԭʼ����ת��Ϊ���


result=fall_classifier_by_frame.predictFcn(oritable); %����״̬�б���������result��

%% �����������+�����˲�����
% figure(2)
hold on
plot(result'*(2)+13,'k-p');
result2=smooth(result,5,'rlowess');%ʹ��rlowess�˲����Խ������ƽ��

plot(result2'*(2)+13,'r-p');
title('0 ����վ�ţ�-1�������,-2����ˤ,1��������');