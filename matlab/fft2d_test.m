%% ����
clear;
close all;

%% ���в�������
doFindpeaksTest_findpeaks=0;
doFindFirstpeakSampleTest_findpeaks=0;
doFindFirstpeakTest_findpeaks=0;
doShowHeatMapsBefore=0;
doShowHeatMapsAfter=1;
delAng=0.5;

%% ����/��ȡ���ݡ�����
load '../data/yLoCut_1MHz_400rps_1rpf_1t8r_walking.mat'

nRx=size(antBits,1);
yLoCut=log2array(logsout,'yLoCutSim');

fF=fTr/nRx/nCyclePF;

dLambda=3e8/fCen;
fPm=fBw*fTr/3e8;%frequency per meter
fD=fS/lFft;%frequency delta
dPs=fD/fPm;%distance per sample
ts=linspace(0,size(yLoCut,3)/fF,size(yLoCut,3));

tsRamp=(0:lFft-1)/fS*fftDownFac;

% angMax=asind(dLambda/2/abs(antCoor(1,1)-antCoor(2,1)));
% nAng=floor(angMax*2/delAng);
% angs=linspace(-angMax,angMax,nAng);

%% ����ÿ�����ߵĲ���
% ���㷢�����ߵ�����������֮��ľ���
dsTxRxi=zeros(nRx,1);%��ʱֻ��һ����������
for iRx=1:nRx
    dsTxRxi(iRx,:)=pdist([antCoor(iRx,:);antCoor(nRx+1,:)]);
end

% %% ��ȡ��Чʱ��
% tMi=5;
% tMa=38;
% valT=ts>=tMi & ts<=tMa;
% 
% yLoCut=yLoCut(:,:,valT);
% ts=ts(valT);

%% 2DFFT
% yLoCut=yLoCut...
%     .*repmat(hamming(size(yLoCut,2))',size(yLoCut,1),1,size(yLoCut,3))...
%     .*repmat(hamming(size(yLoCut,1)),1,size(yLoCut,2),size(yLoCut,3));
heatMaps=fft2(yLoCut,lFft,nAng);
heatMaps=heatMaps(isD,:,:);

heatMaps=circshift(heatMaps,ceil(size(heatMaps,2)/2),2);
heatMaps=flip(heatMaps,2);

if doShowHeatMapsBefore
    %% ��������
    heatMapsB=filter(0.2,[1,-0.8],heatMaps,0,3);
    heatMapsF=abs(heatMaps-heatMapsB);
    
    %% ��ʾ���ʷֲ�
    hHea=figure('name','�ռ��ȶ�ͼ');
    for iFrame=1:size(heatMapsF,3)
        figure(hHea);
        heatMap=heatMapsF(:,:,iFrame);
        imagesc(angs,dsC,heatMap);
        set(gca, 'XDir','normal', 'YDir','normal');
        title(['��' num2str(ts(iFrame)) 's �Ŀռ��ȶ�ͼ']);
        ylabel('y(m)');
        xlabel('angle(��)');
        pause(0.01);
    end
end

if doShowHeatMapsAfter
    %% ������ת��
    xsCoor=single(-8:0.2:8);
    ysCoor=single(dMi:0.2:dMa);
    
    [xsMesh,ysMesh]=meshgrid(xsCoor,ysCoor);
    heatMapsCar=zeros(length(ysCoor),length(xsCoor),length(ts),'single');
    
    % ��������ӳ�����
    dsPo2Car=sqrt(xsMesh.^2+ysMesh.^2);
    angsPo2Car=atand(xsMesh./ysMesh);
    angsPo2Car(isnan(angsPo2Car))=0;
    
    for iFrame=1:length(ts)
        heatMapsCar(:,:,iFrame)=interp2(angs,dsC,heatMaps(:,:,iFrame),angsPo2Car,dsPo2Car,'linear',0);
    end
    
    %% ��������
    heatMapsCarB=filter(0.2,[1,-0.8],heatMapsCar,0,3);
    heatMapsCarF=abs(heatMapsCar-heatMapsCarB);
    
    %% ��ʾ���ʷֲ�
    hHea=figure('name','�ռ��ȶ�ͼ');
    for iFrame=1:size(heatMapsCarF,3)
        figure(hHea);
        heatMap=heatMapsCarF(:,:,iFrame);
        imagesc(xsCoor,ysCoor,heatMap);
        set(gca, 'XDir','normal', 'YDir','normal');
        title(['��' num2str(ts(iFrame)) 's �Ŀռ��ȶ�ͼ']);
        ylabel('y(m)');
        xlabel('x(m)');
        pause(0.01);
    end
end
