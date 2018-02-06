%% ���в�������
doFindpeaksTest_findpeaks=0;
doFindFirstpeakSampleTest_findpeaks=0;
doFindFirstpeakTest_findpeaks=0;

%% ����
close all;

%% ����/��ȡ���ݡ�����
load '../data/foreground_1MHz_400rps_1rpf_1t8r_walking.mat'

nRx=size(antBits,1);
fo=log2array(logsout,'foregroundSim');
fo=fo(:,:,100:end);
fo=permute(fo,[1,3,2]);
lRamp=fS/fTr;%length ramp
lSp=size(fo,1);
fF=fTr/nRx/nCyclePF;

fBw=2e9;%frequency bandwidth
fPm=fBw*fTr/3e8;%frequency per meter
fD=fS/lFft;%frequency delta
dPs=fD/fPm;%distance per sample
fs=linspace(0,fD*(lSp-1),lSp);
ds=fs/fPm;
ts=linspace(0,size(fo,2)/fF,size(fo,2));%3Rx��5֡ƽ��

%% ����ÿ�����ߵĲ���
% ���㷢�����ߵ�����������֮��ľ���
dsTxRxi=zeros(nRx,1);%��ʱֻ��һ����������
for iRx=1:nRx
    dsTxRxi(iRx,:)=pdist([antCoor(iRx,:);antCoor(nRx+1,:)]);
end

% �ų����³��ȣ���ȡ��Ч����
fo=fo(ds>=dCa,:,:);
ds=ds(ds>=dCa)-dCa;

%% ��ȡǰ����Чʱ��;��뷶Χ
tMi=2;
tMa=20;
dMi=max(dsTxRxi);
dMa=20;
valT=ts>=tMi & ts<=tMa;
valD=ds>=dMi & ds<=dMa;

fo=fo(valD,valT,:);
ts=ts(valT);
ds=ds(valD);


%% ��ʾ���������ٲ�ͼ
figure('name','���������ٲ�ͼ');
for iRx=1:nRx
    subplot(1,nRx,iRx);
    imagesc(ds,ts,log(fo(:,:,iRx)'));
    xlabel('d(m)');
    ylabel('t(s)');
    title(['Rx' num2str(iRx)]);
end

%% ����findpeaks����
if doFindpeaksTest_findpeaks
    hFP=figure('name','����findpeaks����');
    for iF=1:5:size(fo,2)
        figure(hFP);
        for iRx=1:nRx
            subplot(1,nRx,iRx);
            findpeaks(fo(:,iF,iRx),ds,'MinPeakProminence',max(fo(:,iF,iRx))*0.8,'Annotate','extents','NPeaks',1);
            title(['��' num2str(ts(iF)) 's Rx' num2str(iRx) '��Ƶ��']);
        end
        pause(0.5);
    end
end

%% ��ʾʾ��֡������findFirstPeak����
if doFindFirstpeakSampleTest_findpeaks
    iSam=find(ts>10,1);
    foSam=permute(fo(:,iSam,:),[1,3,2]);
    hSam=figure('name','ʾ��֡Ѱ�����');
    for iRx=1:nRx
        subplot(1,nRx,iRx);
        plot(ds,foSam(:,iRx));
        xlabel('d(m)');
        title(['��' num2str(ts(iSam)) 's Rx' num2str(iRx) '��Ƶ��']);
    end
    
    iFp=findFirstPeak(foSam,0.7);
    figure(hSam);
    for iRx=1:nRx
        subplot(1,nRx,iRx);
        hold on;
        plot(ds(iFp(iRx)),foSam(iFp(iRx),iRx),'o');
        hold off;
    end
end

%% �������֡�ķ�ֵ������findFirstPeak����
if doFindFirstpeakTest_findpeaks
    dsTa=zeros(size(fo,2),nRx);
    for iF=1:size(fo,2);
        dsTa(iF,:)=findFirstPeak(permute(fo(:,iF,:),[1,3,2]),0.7);
    end
    dsTa=dsTa.*dPs;
    hDT=figure('name','Ѱ��õ��ľ��롪��ʱ������');
    for iRx=1:nRx
        subplot(1,nRx,iRx);
        plot(dsTa(:,iRx),ts);
        ylabel('t(s)');
        xlabel('d(m)');
        title(['Rx' num2str(iRx) '�ľ��롪��ʱ������']);
    end
    
    %% �Ծ��롪��ʱ���������쳣ֵ�޳����˲�����
    dsTaHampel=hampel(dsTa,11,0.5);
    figure(hDT);
    for iRx=1:nRx
        subplot(1,nRx,iRx);
        hold on;
        plot(dsTaHampel(:,iRx),ts);
    end
    
    dsTaFiltered=filter(0.2,[1,-0.8],dsTaHampel);
    figure(hDT);
    for iRx=1:nRx
        subplot(1,nRx,iRx);
        hold on;
        plot(dsTaFiltered(:,iRx),ts);
    end
end

%% 