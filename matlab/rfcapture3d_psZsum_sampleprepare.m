%% ����
clear;
close all;

%% ���в�������
doShowSam=0;
lSweep=1;
doPrepareFallingWindow=0;
doPrepareStandWindow=1;
doPrepareFallenWindow=0;
doClearHistory=0;
doAdd2Sample=1;
labelFalling=1;
labelStand=0;
labelFallen=1;
%% ����/��ȡ���ݡ�����
sFileData='../data/psZsum_200kHz_2000rps_4rpf_4t12r_stand_fall.mat';
sFileSample='../data/inoutputs_200kHz_2000rps_4rpf_4t12r_walk_fall.mat';
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
isLbsChange=interp1(ts,1:length(ts),lbsChange,'nearst');
plot(lbsChange,zsMax(isLbsChange),'o');
hold off;

%% �и�����
if doPrepareFallingWindow
    isSamW=-round(tSam*fF/2):round(tSam*fF/2)-lSweep/2;
    label=labelFalling;
elseif doPrepareStandWindow
    isSamW=(-round(tSam*fF)-1:0)-lSweep;
    label=labelStand;
elseif doPrepareFallenWindow
    isSamW=0:round(tSam*fF)+1;
    label=labelFallen;
end
tsSamW=isSamW/fF;

psZsumSam=zeros(size(psZsum,1),length(isSamW),length(size(lbsChange,1))*lSweep);

for i=1:size(lbsChange,1)
    tSamCen=lbsChange(i);
    iSamCen=interp1(ts,1:length(ts),tSamCen,'nearst');
    
    for j=0:lSweep-1
        psZsumSam(:,:,lSweep*(i-1)+j+1)=psZsum(:,iSamCen+isSamW+j);
    end
end
%% ��ʾ��5��
if doShowSam
    hSam=figure('name','��ʾ����');
    for i=1:size(psZsumSam,3)
        figure(hSam);
        psZsumSamAj=psZsumSam(:,:,i)./repmat(max(psZsumSam(:,:,i)),length(zsF),1);
        imagesc(tsSamW,zsF,psZsumSamAj);
        set(gca, 'XDir','normal', 'YDir','normal');
        title(['����' num2str(i) '/' num2str(size(psZsumSam,3))]);
        xlabel('t(s)');
        ylabel('z(m)');
        pause(0.1);
    end
end

%% ����������ǰԤ����
psZReshapeSam=permute(reshape(psZsumSam,size(psZsumSam,1)*size(psZsumSam,2),size(psZsumSam,3)),[2,1]);
% ��һ��
psZReshapeSam=psZReshapeSam./repmat(max(psZReshapeSam,[],2),1,size(psZReshapeSam,2));

%% ��ӵ�����
if doAdd2Sample
    if doClearHistory
        inputs=[];
        targets=[];
        samples=[];
    else
        load(sFileSample)
    end
    inputs=[inputs;psZReshapeSam];
    targets=[targets;repmat(label,size(psZReshapeSam,1),1)];
    samples=[targets,inputs];
    save(sFileSample,'inputs','targets','samples');
end