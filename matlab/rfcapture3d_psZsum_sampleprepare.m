%% ����
clear;
close all;

%% ���в�������
doShowSam=1;

%% ����/��ȡ���ݡ�����
sFileData='../data/psZsum_200kHz_2000rps_4rpf_4t12r_stand_fall.mat';
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

%% չʾ��ǩ
[~,isZMax]=max(psZsum);
zsMax=zsF(isZMax);
figure('name','չʾ��ǩ');
plot(ts,zsMax);
hold on;
isLbsChange=interp1(ts,1:length(ts),lbsChange(:,2),'nearst');
plot(lbsChange(:,2),zsMax(isLbsChange),'o');
text(lbsChange(:,2),double(zsMax(isLbsChange))+0.03,num2str(lbsChange(:,1)));
hold off;

%% �и�����
isSamW=-round(tSam*fF/2):round(tSam*fF/2);
tsSamW=isSamW/fF;
psZsumSam=zeros(size(psZsum,1),length(isSamW),length(size(lbsChange,1)));

for i=1:size(lbsChange,1)
    tSamCen=lbsChange(i,2);
    iSamCen=interp1(ts,1:length(ts),tSamCen,'nearst');
    psZsumSam(:,:,i)=psZsum(:,iSamCen+isSamW);
end

%% ��ʾ����
if doShowSam
    hSam=figure('name','��ʾ����');
    for i=1:size(psZsumSam,3)
        figure(hSam);
        psZsumSamAj=psZsumSam(:,:,i)./repmat(max(psZsumSam(:,:,i)),length(zsF),1);
        imagesc(tsSamW+lbsChange(i,2),zsF,psZsumSamAj);
        set(gca, 'XDir','normal', 'YDir','normal');
        title(['����' num2str(i) '/' num2str(size(psZsumSam,3))]);
        xlabel('t(s)');
        ylabel('z(m)');
        pause(0.5);
    end
end

