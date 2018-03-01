%% ����
clear;
close all;

%% ���в�������
doShowSampleFtnyx=1;
doShowDsYXN=1;
useGPU=1;

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

% %% ��ȡ��Чʱ��
% tMi=5;
% tMa=38;
% valT=ts>=tMi & ts<=tMa;
% 
% yLoCut=yLoCut(:,:,valT);
% ts=ts(valT);

%% ΪӲ�㹫ʽ׼������
xsCoor=single(-8:0.2:8);
ysCoor=single(0:0.2:10);

[xsMesh,ysMesh]=meshgrid(xsCoor,ysCoor);
dsYXN=zeros(length(ysCoor),length(xsCoor),nRx);
for iRx=1:nRx
    dsYXN(:,:,iRx)=sqrt((xsMesh-antCoor(iRx,1)).^2+(ysMesh-antCoor(iRx,2)).^2) ...
        +sqrt((xsMesh-antCoor(end,1)).^2+(ysMesh-antCoor(end,2)).^2) ...
        +dCa;
end

fxytn=single(zeros(length(ysCoor),length(xsCoor),lFft,nRx));
for iRx=1:nRx
    for iT=1:lFft
        fxytn(:,:,iT,iRx)=single(exp(j*2*pi*fBw*fTr*dsYXN(:,:,iRx)/3e8*tsRamp(iT))...
            .*exp(j*2*pi*dsYXN(:,:,iRx)/dLambda));
    end
end
ftnyx=permute(fxytn,[3,4,1,2]);

%% ���ӻ������ߵ�ƽ���������ؾ���
if doShowDsYXN
    hSample=figure('name','�����ߵ�ƽ���������ؾ���');
    for iRx=1:nRx
        figure(hSample);
        imagesc(dsYXN(:,:,iRx));
        title(['Rx' num2str(iRx) '��ƽ���������ؾ���']);
        pause(0.2);
    end
end

%% ���ӻ�ĳƽ����x��ֱ���ϸ����ߵ�Ƶ�ʺ���λ
if doShowSampleFtnyx
    ySample=0;
    iYSample=find(ySample<=ysCoor,1);
    hSample=figure('name',['y=' num2str(ySample) 'ֱ���ϸ����ߵ�Ƶ�ʺ���λ']);
    for iXSample=1:size(ftnyx,4)
        figure(hSample);
        imagesc(angle(ftnyx(:,:,iYSample,iXSample)));
        title(['x=' num2str(xsCoor(iXSample)) ', y=' num2str(ySample) '���ϸ����ߵ�Ƶ�ʺ���λ']);
        pause(0.1);
    end
end

%% ���ӻ�ĳƽ����y��ֱ���ϸ����ߵ�Ƶ�ʺ���λ
if doShowSampleFtnyx
    xSample=0;
    iXSample=find(xSample<=xsCoor,1);
    hSample=figure('name',['x=' num2str(xSample) 'ֱ���ϸ����ߵ�Ƶ�ʺ���λ']);
    for iYSample=1:size(ftnyx,3)
        figure(hSample);
        imagesc(angle(ftnyx(:,:,iYSample,iXSample)));
        title(['x=' num2str(xSample) ', y=' num2str(ysCoor(iYSample)) '���ϸ����ߵ�Ƶ�ʺ���λ']);
        pause(0.1);
    end
end

%% Ӳ�㹦�ʷֲ�
if useGPU
    ftnyxGPU=gpuArray(ftnyx);
    yLoCutGPU=gpuArray(yLoCut);
    heatMapsGPU=zeros(length(ysCoor),length(xsCoor),length(ts),'single','gpuArray');
    tic;
    for iFrame=1:length(ts)
        yLoRe=repmat(yLoCutGPU(:,:,iFrame),1,1,length(ysCoor),length(xsCoor));
        sf=sum(sum(yLoRe.*ftnyxGPU,1),2);
        heatMapsGPU(:,:,iFrame)=permute(sf,[3,4,1,2]);
        
        disp(['��' num2str(iFrame) '֡' num2str(iFrame/length(ts)*100,'%.1f') ...
            '% ��ʱ' num2str(toc/60,'%.2f') 'min ' ...
            'ʣ��' num2str(toc/iFrame*(length(ts)-iFrame)/60,'%.2f') 'min']);
    end
    heatMaps=gather(heatMapsGPU);
else
    heatMaps=zeros(length(ysCoor),length(xsCoor),length(ts),'single');
    tic;
    for iFrame=1:length(ts)
        yLoRe=repmat(yLoCut(:,:,iFrame),1,1,length(ysCoor),length(xsCoor));
        sf=sum(sum(yLoRe.*ftnyx,1),2);
        heatMaps(:,:,iFrame)=permute(sf,[3,4,1,2]);
        
        disp(['��' num2str(iFrame) '֡' num2str(iFrame/length(ts)*100,'%.1f') ...
            '% ��ʱ' num2str(toc/60,'%.2f') 'min ' ...
            'ʣ��' num2str(toc/iFrame*(length(ts)-iFrame)/60,'%.2f') 'min']);
    end
end

%% ��������
heatMapsB=filter(0.2,[1,-0.8],heatMaps,0,3);
heatMapsF=abs(heatMaps-heatMapsB);

%% ��ʾ���ʷֲ�
hHea=figure('name','�ռ��ȶ�ͼ');
for iFrame=1:length(ts)
    figure(hHea);
    imagesc(xsCoor,ysCoor,heatMapsF(:,:,iFrame));
    set(gca, 'XDir','normal', 'YDir','normal');
    title(['��' num2str(ts(iFrame)) 's �Ŀռ��ȶ�ͼ']);
    xlabel('x(m)');
    ylabel('y(m)');
    pause(0.01)
end
