%% ����
clear;
close all;

%% ���в�������
doShowHeatmaps=0;
doShowTarcoor=0;
doShowPsSlice=0;
doShowPsXZsum=1;
doSavePsXZsum=1;
doShowPsZsum=1;
lBlock=1000;

%% ����/��ȡ���ݡ�����
load '../data/yLoCut_200kHz_800rps_1rpf_4t12r_ztest_stand_squat.mat'

yLoCut=log2array(logsout,'yLoCutSim');
yLoReshape=reshape(yLoCut,size(yLoCut,1),nRx,nTx,size(yLoCut,3));

ts=linspace(0,size(yLoCut,3)/fF,size(yLoCut,3));

iTVal=ts>5 & ts<15;
ts=ts(iTVal);
yLoReshape=yLoReshape(:,:,:,iTVal);

%% ��������
dx=0.1;
dy=0.1;
xsCoor=single(-4:dx:4);
ysCoor=single(1:dy:8);

%% rfcapture2d����
[xsMesh,ysMesh]=meshgrid(xsCoor,ysCoor);
pointCoor=[reshape(xsMesh,numel(xsMesh),1),reshape(ysMesh,numel(ysMesh),1),zeros(numel(xsMesh),1)];

% Ӳ�㹦�ʷֲ�
heatMapsCap=zeros(length(ysCoor),length(xsCoor),nTx,length(ts),'single','gpuArray');
fTsrampRTZ=zeros(length(tsRamp),nRx,1,numel(xsMesh),nTx,'single','gpuArray');
for iTx=1:nTx
    fTsrampRTZ(:,:,:,:,iTx)=rfcaptureCo2F(pointCoor, ...
        [antCoor(1:nRx,:);antCoor(iTx+nRx,:)], ...
        nRx,1,dCa,tsRamp,fBw,fTr,dLambda,1);
end
tic;
for iFrame=1:length(ts)
    for iTx=1:nTx
        ps=rfcaptureF2ps(fTsrampRTZ(:,:,:,:,iTx),yLoReshape(:,:,iTx,iFrame),1);
        heatMapsCap(:,:,iTx,iFrame)=reshape(ps,length(ysCoor),length(xsCoor));
    end
    
    if mod(iFrame,10)==0
        disp(['��' num2str(iFrame) '֡' num2str(iFrame/length(ts)*100,'%.1f') ...
            '% ��ʱ' num2str(toc/60,'%.2f') 'min ' ...
            'ʣ��' num2str(toc/iFrame*(length(ts)-iFrame)/60,'%.2f') 'min']);
    end
end

% ��������
heatMapsBCap=filter(0.2,[1,-0.8],heatMapsCap,0,4);
heatMapsFCap=abs(heatMapsCap-heatMapsBCap);
heatMapsFCap=permute(prod(heatMapsFCap,3),[1,2,4,3]);

%% fft2d����
heatMapsFft=fft2(yLoReshape,lFft,nAng);
heatMapsFft=heatMapsFft(isD,:,:,:);

heatMapsFft=circshift(heatMapsFft,floor(size(heatMapsFft,2)/2)+1,2);
heatMapsFft=flip(heatMapsFft,2);

% ��������
heatMapsBFft=filter(0.2,[1,-0.8],heatMapsFft,0,4);
heatMapsFFft=abs(heatMapsFft-heatMapsBFft);
heatMapsFFft=permute(prod(heatMapsFFft,3),[1,2,4,3]);

% ������ת��
heatMapsCarFFft=zeros(length(ysCoor),length(xsCoor),length(ts),'single');

% ��������ӳ�����
dsPo2Car=sqrt(xsMesh.^2+ysMesh.^2);
angsPo2Car=atand(xsMesh./ysMesh);
angsPo2Car(isnan(angsPo2Car))=0;

for iFrame=1:length(ts)
    heatMapsCarFFft(:,:,iFrame)=interp2(angs,dsC,heatMapsFFft(:,:,iFrame),angsPo2Car,dsPo2Car,'linear',0);
end
heatMapsFFft=heatMapsCarFFft;

%% �Ƚ�Ŀ������
[isYTarCap,isXTarCap]=iMax2d(heatMapsFCap);
[isYTarFft,isXTarFft]=iMax2d(heatMapsCarFFft);

isXTarCap=gather(isXTarCap);
isYTarCap=gather(isYTarCap);
isXTarFft=gather(isXTarFft);
isYTarFft=gather(isYTarFft);

xsTarCap=xsCoor(isXTarCap);
ysTarCap=ysCoor(isYTarCap);
xsTarFft=xsCoor(isXTarFft);
ysTarFft=ysCoor(isYTarFft);

if doShowTarcoor
    hCoor=figure('name','�Ƚ����ַ�������Ŀ������');
    subplot(1,2,1);
    plot(ts,xsTarCap,ts,xsTarFft);
    legend('xsTarCap','xsTarFft');
    title('�Ƚ����ַ�������Ŀ��x����');
    xlabel('t(s)');
    ylabel('x(m)');
    
    subplot(1,2,2);
    plot(ts,ysTarCap,ts,ysTarFft);
    legend('ysTarCap','ysTarFft');
    title('�Ƚ����ַ�������Ŀ��y����');
    xlabel('t(s)');
    ylabel('y(m)');
end

%% ��ʾ���ʷֲ�
if doShowHeatmaps
    hHea=figure('name','�ռ��ȶ�ͼ');
    for iFrame=1:length(ts)
        figure(hHea);
        subplot(1,2,1);
        heatMapsFCapScaled=heatMapsFCap(:,:,iFrame)/max(max(heatMapsFCap(:,:,iFrame)));
        heatMapsFCapTar=insertShape(gather(heatMapsFCapScaled),'circle',[isXTarCap(iFrame) isYTarCap(iFrame) 5],'LineWidth',2);
        imagesc(xsCoor,ysCoor,heatMapsFCapTar);
        set(gca, 'XDir','normal', 'YDir','normal');
        title(['��' num2str(ts(iFrame)) 's ��rfcapture2d�ռ��ȶ�ͼ']);
        xlabel('x(m)');
        ylabel('y(m)');
        
        subplot(1,2,2);
        heatMapsFFftScaled=heatMapsFFft(:,:,iFrame)/max(max(heatMapsFFft(:,:,iFrame)));
        heatMapsFFftTar=insertShape(gather(heatMapsFFftScaled),'circle',[isXTarFft(iFrame) isYTarFft(iFrame) 5],'LineWidth',2);
        imagesc(xsCoor,ysCoor,heatMapsFFftTar);
        set(gca, 'XDir','normal', 'YDir','normal');
        title(['��' num2str(ts(iFrame)) 's ��fft2d�ռ��ȶ�ͼ']);
        xlabel('x(m)');
        ylabel('y(m)');
        
        pause(0.05);
    end
end

%% �����������ڣ�׼��rfcaptureCo2F
dx=0.05;
dy=0.15;
dz=0.1;
lx=1;
ly=0.5;
lz=2.5;
sz=-1.5;

xsWin=single(-lx/2:dx:lx/2);
ysWin=single(-ly/2:dy:ly/2);
zsWin=single(sz:dx:sz+lz);
[xss,yss,zss]=meshgrid(xsWin,ysWin,zsWin);
xsV=reshape(xss,numel(xss),1);
ysV=reshape(yss,numel(yss),1);
zsV=reshape(zss,numel(zss),1);
pointCoorWin=[xsV,ysV,zsV];

xsTarCapMean=mean(xsTarCap);
ysTarCapMean=mean(ysTarCap);
pointCoor=pointCoorWin+repmat([xsTarCapMean,ysTarCapMean,0],size(pointCoorWin,1),1);

fTsrampRTZ=zeros(length(tsRamp),nRx,nTx,size(pointCoor,1),'single');
isS=1:lBlock:size(pointCoor,1);
for iS=isS
    iBlock=(iS-1)/lBlock+1;
    if iS+lBlock-1<size(pointCoor,1)
        isBlock=iS:iS+lBlock-1;
    else
        isBlock=iS:size(pointCoor,1);
    end
    fTsrampRTZ(:,:,:,isBlock)=gather(rfcaptureCo2F(pointCoor(isBlock,:),antCoor,nRx,nTx,dCa,tsRamp,fBw,fTr,dLambda,1));
end

%% ����Ŀ�귶Χ�ڵĹ��ʷֲ�
ps=zeros(size(xss,1),size(xss,2),size(xss,3),length(ts),'single','gpuArray');
tic;
for iFrame=1:length(ts)
    psF=zeros(size(pointCoor,1),1,'gpuArray');
    for iS=isS
        iBlock=(iS-1)/lBlock+1;
        if iS+lBlock-1<size(pointCoor,1)
            isBlock=iS:iS+lBlock-1;
        else
            isBlock=iS:size(pointCoor,1);
        end
        psF(isBlock,1)=abs(rfcaptureF2ps(fTsrampRTZ(:,:,:,isBlock),yLoReshape(:,:,:,iFrame),1));
    end
    ps(:,:,:,iFrame)=reshape(psF,size(xss,1),size(xss,2),size(xss,3));
    
    if mod(iFrame,10)==0
        disp(['��' num2str(iFrame) '֡' num2str(iFrame/length(ts)*100,'%.1f') ...
            '% ��ʱ' num2str(toc/60,'%.2f') 'min ' ...
            'ʣ��' num2str(toc/iFrame*(length(ts)-iFrame)/60,'%.2f') 'min']);
    end
end

%% ��ʾ��Ƭͼ
if doShowPsSlice
    hPs=figure('name','ps����Ƭͼ');
    for iFrame=1:length(ts)
        figure(hPs);
        slice(xss,yss,zss,ps(:,:,:,iFrame),linspace(xsWin(1),xsWin(length(xsWin)),3),linspace(ysWin(1),ysWin(length(ysWin)),1),linspace(zsWin(1),zsWin(length(zsWin)),3));
        xlabel('x(m)');
        ylabel('y(m)');
        zlabel('z(m)');
        title(['t=',num2str(ts(iFrame)), ...
            ', x=',num2str(xsTarCapFiltered(iFrame)), ...
            ', y=',num2str(ysTarCapFiltered(iFrame)), ...
            'ʱps����Ƭͼ']);
        pause(0.1);
    end
end

%% ��ʾxzͶӰͼ
if doShowPsXZsum
    if doSavePsXZsum
        writerObj=VideoWriter('../../xzProject.mp4','MPEG-4');  %// ����һ����Ƶ�ļ������涯��
        writerObj.FrameRate=fF;
        open(writerObj);                    %// �򿪸���Ƶ�ļ�
    end
    hPs=figure('name','ps��xzͶӰͼ');
    for iFrame=1:length(ts)
        psXZsum=permute(sum(ps(:,:,:,iFrame),1),[3,2,1]);
        psXZsum=gather(psXZsum/max(max(psXZsum)));
        figure(hPs);
        imagesc(xsWin,zsWin,psXZsum);
        axis equal;
        axis([min(xsWin), max(xsWin), min(zsWin), max(zsWin)])
        set(gca, 'XDir','normal', 'YDir','normal');
        title(['t=',num2str(ts(iFrame)), ...
            ', x=',num2str(xsTarCap(iFrame)), ...
            ', y=',num2str(ysTarCap(iFrame)), ...
            'ʱps��xzͶӰͼ']);
        xlabel('x(m)');
        ylabel('z(m)');
        if doSavePsXZsum
            writeVideo(writerObj,getframe(gcf));
        end
        pause(0.05);
    end
    if doSavePsXZsum
        close(writerObj); %// �ر���Ƶ�ļ����
    end
end

%% ���Խ���z�Ṧ�ʷֲ�
if doShowPsZsum
    psZsum=permute(sum(sum(ps,1),2),[3,4,2,1]);
    psZsum=psZsum./repmat(max(psZsum),length(zsWin),1);
    hpsZ=figure('name','Ŀ��� z�����ϸ���Ĺ�����ʱ��仯��ϵͼ');
    imagesc(ts,zsWin,psZsum);
    set(gca, 'XDir','normal', 'YDir','normal');
    title('Ŀ��� z�����ϸ���Ĺ�����ʱ��仯��ϵͼ');
    xlabel('t(s)');
end
ylabel('z(m)');