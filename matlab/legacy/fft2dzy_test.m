%% ����
clear;
close all;

%% ���в�������
% doFindpeaksTest_findpeaks=0;
% doFindFirstpeakSampleTest_findpeaks=0;
% doFindFirstpeakTest_findpeaks=0;
doShowHeatMapsBefore=0;
doShowHeatMapsAfter=1;

%% ����/��ȡ���ݡ�����
load '../data/yLoCut_200kHz_800rps_1rpf_4t12r_ztest.mat'

yLoCut=log2array(logsout,'yLoCutSim');
yLoReshape=reshape(yLoCut,size(yLoCut,1),nRx,nTx,size(yLoCut,3));

ts=linspace(0,size(yLoCut,3)/fF,size(yLoCut,3));
tsRamp=(0:lFft-1)/fS*fftDownFac;

% %% ����ÿ�����ߵĲ���
% % ���㷢�����ߵ�����������֮��ľ���
% dsTxRxi=zeros(nRx,1);%��ʱֻ��һ����������
% for iRx=1:nRx
%     dsTxRxi(iRx,:)=pdist([antCoor(iRx,:);antCoor(nRx+1,:)]);
% end

% %% ��ȡ��Чʱ��
% tMi=5;
% tMa=38;
% valT=ts>=tMi & ts<=tMa;
%
% yLoCut=yLoCut(:,:,valT);
% ts=ts(valT);

%% ��ֱzy����2DFFT
yLoTsrampTRTs=permute(yLoReshape,[1,3,2,4]);
heatMaps=fft2(yLoTsrampTRTs,lFft,nAng);
heatMaps=heatMaps(isD,:,:,:);

heatMaps=circshift(heatMaps,ceil(size(heatMaps,2)/2),2);
% heatMaps=flip(heatMaps,2);
%% ��������
heatMapsB=filter(0.2,[1,-0.8],heatMaps,0,4);
heatMapsF=abs(heatMaps-heatMapsB);
% heatMapsF=permute(prod(heatMapsF,3),[1,2,4,3]);
heatMapsF=permute(sum(heatMapsF,3),[1,2,4,3]);
% heatMapsF=permute(prod(heatMapsF(:,:,5:8,:),3),[1,2,4,3]);

%% ��ʾ����ת��ǰ���ʷֲ�
if doShowHeatMapsBefore
    hHea=figure('name','�ռ��ȶ�ͼ');
    for iFrame=1:size(heatMapsF,3)
        figure(hHea);
        heatMap=heatMapsF(:,:,iFrame);
        heatMap=heatMap./max(max(heatMap));
        imagesc(angs,dsC,heatMap);
        set(gca, 'XDir','normal', 'YDir','normal');
        title(['��' num2str(ts(iFrame)) 's �Ŀռ��ȶ�ͼ']);
        ylabel('y(m)');
        xlabel('angle(��)');
        pause(0.01);
    end
end

%% ��ʾ����ת�����ʷֲ�
if doShowHeatMapsAfter
    % ������ת��
    zsCoor=single(-1:0.2:3);
    ysCoor=single(dMi:0.2:dMa);
    
    [xsMesh,ysMesh]=meshgrid(zsCoor,ysCoor);
    heatMapsCarF=zeros(length(ysCoor),length(zsCoor),length(ts),'single');
    
    % ��������ӳ�����
    dsPo2Car=sqrt(xsMesh.^2+ysMesh.^2);
    angsPo2Car=atand(xsMesh./ysMesh);
    angsPo2Car(isnan(angsPo2Car))=0;
    
    for iFrame=1:length(ts)
        heatMapsCarF(:,:,iFrame)=interp2(angs,dsC,heatMapsF(:,:,iFrame),angsPo2Car,dsPo2Car,'linear',0);
    end
    
    % ��ʾ���ʷֲ�
    hHea=figure('name','�ռ��ȶ�ͼ');
    for iFrame=1:size(heatMapsCarF,3)
        figure(hHea);
        heatMap=heatMapsCarF(:,:,iFrame);
        heatMap=heatMap./max(max(heatMap));
        imagesc(zsCoor,ysCoor,heatMap);
        set(gca, 'XDir','normal', 'YDir','normal');
        title(['��' num2str(ts(iFrame)) 's �Ŀռ��ȶ�ͼ']);
        ylabel('y(m)');
        xlabel('z(m)');
        pause(0.01);
    end
end