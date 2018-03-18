%% ����
clear;
close all;

%% ���в�������
doShowHeatmaps=0;
doShowTarcoor=0;
doShowPsBProject=0;
tShowPsProject=0;
doSavePsBProject=1;
doShowPsZsum=1;
lBlock=1000;
useGPU=1;

%% ����/��ȡ���ݡ�����
load '../data/yLoCut_200kHz_800rps_1rpf_4t12r_ztest_circle_reflector.mat'

yLoCut=log2array(logsout,'yLoCutSim');
yLoReshape=reshape(yLoCut,size(yLoCut,1),nRx,nTx,size(yLoCut,3));

ts=linspace(0,size(yLoCut,3)/fF,size(yLoCut,3));

if exist('iTVal','var')
    % iTVal=ts>5 & ts<16;
    ts=ts(iTVal);
    yLoReshape=yLoReshape(:,:,:,iTVal);
end

% ������������
xMi=-3;
xMa=3;
yMi=1;
yMa=5;
zMi=-1.5;
zMa=1.5;
dxC=0.5;
dyC=0.5;
dzC=0.5;

lSampleB=50;

C2Ffac=3;
nC2F=2;
C2Fratio=0.5;

preciFac=C2Ffac.^(nC2F-1);
xsB=single(xMi:dxC/preciFac:xMa);
ysB=single(yMi:dyC/preciFac:yMa);
zsB=single(zMi:dzC/preciFac:zMa);

xs2D=xsB;
ys2D=ysB;
[xss2D,yss2D]=meshgrid(xs2D,ys2D);

%% fft2d����
heatMapsFft=fft2(yLoReshape,lFftDis,lFftAng);
heatMapsFft=heatMapsFft(isDval,:,:,:);

heatMapsFft=circshift(heatMapsFft,floor(size(heatMapsFft,2)/2)+1,2);
heatMapsFft=flip(heatMapsFft,2);

% ��������
heatMapsBFft=filter(0.2,[1,-0.8],heatMapsFft,0,4);
heatMapsFFft=abs(heatMapsFft-heatMapsBFft);
heatMapsFFft=permute(prod(heatMapsFFft,3),[1,2,4,3]);

% ������ת��
heatMapsCarFFft=zeros(length(ys2D),length(xs2D),length(ts),'single');

% ��������ӳ�����
dsPo2Car=sqrt(xss2D.^2+yss2D.^2);
angsPo2Car=atand(xss2D./yss2D);
angsPo2Car(isnan(angsPo2Car))=0;

for iFrame=1:length(ts)
    heatMapsCarFFft(:,:,iFrame)=interp2(angs,dsVal,heatMapsFFft(:,:,iFrame),angsPo2Car,dsPo2Car,'linear',0);
end
heatMapsFFft=heatMapsCarFFft;

%% �Ƚ�Ŀ������
[isYTarFft,isXTarFft]=iMax2d(heatMapsCarFFft);

isXTarFft=gather(isXTarFft);
isYTarFft=gather(isYTarFft);

xsTarFft=xs2D(isXTarFft);
ysTarFft=ys2D(isYTarFft);


if doShowTarcoor
    hCoor=figure('name','�Ƚ����ַ�������Ŀ������');
    subplot(1,2,1);
    plot(ts,xsTarFft);
    legend('xsTarFft');
    title('FFT2D����Ŀ��x����');
    xlabel('t(s)');
    ylabel('x(m)');
    
    subplot(1,2,2);
    plot(ts,ysTarFft);
    legend('ysTarFft');
    title('FFT2D����Ŀ��y����');
    xlabel('t(s)');
    ylabel('y(m)');
    
    pause(0.2);
end

%% ��ʾ���ʷֲ�
if doShowHeatmaps
    hHea=figure('name','�ռ��ȶ�ͼ');
    for iFrame=1:length(ts)
        figure(hHea);

        heatMapsFFftScaled=heatMapsFFft(:,:,iFrame)/max(max(heatMapsFFft(:,:,iFrame)));
        heatMapsFFftTar=insertShape(gather(heatMapsFFftScaled),'circle',[isXTarFft(iFrame) isYTarFft(iFrame) 5],'LineWidth',2);
        imagesc(xs2D,ys2D,heatMapsFFftTar);
        set(gca, 'XDir','normal', 'YDir','normal');
        title(['��' num2str(ts(iFrame)) 's ��fft2d�ռ��ȶ�ͼ']);
        xlabel('x(m)');
        ylabel('y(m)');
        
        pause(0.5);
    end
end

%% ���㱳��
if ~exist('psB','var')
    [xssB,yssB,zssB]=meshgrid(xsB,ysB,zsB);
    
    psBcoor=[xssB(:),yssB(:),zssB(:)];
    
    
    psB=zeros(size(psBcoor,1),1,'single','gpuArray');
    isS=1:lBlock:size(psBcoor,1);
    tic;
    for iFrame=1:lSampleB
        for iS=isS
            iBlock=(iS-1)/lBlock+1;
            if iS+lBlock-1<size(psBcoor,1)
                isBlock=iS:iS+lBlock-1;
            else
                isBlock=iS:size(psBcoor,1);
            end
            fTsrampRTZ=rfcaptureCo2F(psBcoor(isBlock,:),rxCoor,txCoor,nRx,nTx,dCa,tsRamp,fBw,fRamp,dLambda,useGPU);
            psB(isBlock,1)=psB(isBlock,1)+rfcaptureF2ps(fTsrampRTZ,yLoReshape(:,:,:,iFrame),useGPU);
        end
        if mod(iFrame,1)==0
            disp(['��' num2str(iFrame) '֡' num2str(iFrame/lSampleB*100,'%.1f') ...
                '% ��ʱ' num2str(toc/60,'%.2f') 'min ' ...
                'ʣ��' num2str(toc/iFrame*(lSampleB-iFrame)/60,'%.2f') 'min']);
        end
    end
    
    psB=reshape(psB,size(xssB))/lSampleB;
else
    if useGPU
        psB=gpuArray(psB);
    end
    psBcoor=[xssB(:),yssB(:),zssB(:)];
end

%% ��ʾ�����Ĺ��ʷֲ�ͶӰͼ
if doShowPsBProject
    hPs=figure('name','psB��ͶӰͼ');
    showProjectedHeatmaps(hPs,log(abs(psB)),xsB,ysB,zsB);
    pause(0.5);
else
    hPs=[];
end

%% ������������
% Ҫ��֤d��l�Ĵ�������-lxW/2:dxW:lxW/2�в���0��yͬ��
lxW=1;
lyW=1;
lzW=3;
zWmi=-1.5;

xsTarFftMean=mean(xsTarFft);
ysTarFftMean=mean(ysTarFft);

[~,iXTar]=min(abs(xsB-xsTarFftMean));
[~,iYTar]=min(abs(ysB-ysTarFftMean));
xsTarFftMean=xsB(iXTar);
ysTarFftMean=ysB(iYTar);
psWcen=[xsTarFftMean,ysTarFftMean,0];

% ׼����������
psWcoor=[];
for i=1:nC2F
    xsC=single(-lxW/2:dxC/(C2Ffac^(i-1)):lxW/2);
    ysC=single(-lyW/2:dyC/(C2Ffac^(i-1)):lyW/2);
    zsC=single(zWmi:dxC/(C2Ffac^(i-1)):zWmi+lzW);
    psWcoor(i).xs=xsC;
    psWcoor(i).ys=ysC;
    psWcoor(i).zs=zsC;
    [psWcoor(i).xss,psWcoor(i).yss,psWcoor(i).zss]=meshgrid(xsC,ysC,zsC);
    psWcoor(i).coor=[psWcoor(i).xss(:),psWcoor(i).yss(:),psWcoor(i).zss(:)];
end

%% ����rfcaptureC2F���㴰��ǰ��

tic;
for iFrame=1:length(ts)
    [psF,xsF,ysF,zsF]=rfcaptureC2F(psWcen,psWcoor,psBcoor,psB, ...
        C2Fratio,0,hPs, ...
        yLoReshape(:,:,:,iFrame),rxCoor,txCoor,nRx,nTx,dCa,tsRamp,fBw,fRamp,dLambda,useGPU);
    if iFrame==1
        psFo=zeros([size(psF),length(ts)],'single','gpuArray');
    end
    psFo(:,:,:,iFrame)=psF;
    
    if mod(iFrame,10)==0
        disp(['��' num2str(iFrame) '֡' num2str(iFrame/length(ts)*100,'%.1f') ...
            '% ��ʱ' num2str(toc/60,'%.2f') 'min ' ...
            'ʣ��' num2str(toc/iFrame*(length(ts)-iFrame)/60,'%.2f') 'min']);
    end
end


%% ��ʾ����ͶӰ
if tShowPsProject
    hPs=figure('name','psF��ͶӰͼ');
    if doSavePsBProject
        writerObj=VideoWriter('../../xzProject.mp4','MPEG-4');  %// ����һ����Ƶ�ļ������涯��
        writerObj.FrameRate=fF;
        open(writerObj);                    %// �򿪸���Ƶ�ļ�
    end
    for iFrame=1:length(ts)
        showProjectedHeatmaps(hPs,psFo(:,:,:,iFrame),xsF,ysF,zsF);
        if doSavePsBProject
            writeVideo(writerObj,getframe(gcf));
        end
        pause(tShowPsProject);
    end
    if doSavePsBProject
        close(writerObj); %// �ر���Ƶ�ļ����
    end
end


%% ���Խ���z�Ṧ�ʷֲ�
if doShowPsZsum
    psZsum=permute(sum(sum(psFo,1),2),[3,4,2,1]);
    psZsum=psZsum./repmat(max(psZsum),length(zsF),1);
    hpsZ=figure('name','Ŀ��� z�����ϸ���Ĺ�����ʱ��仯��ϵͼ');
    imagesc(ts,zsF,psZsum);
    set(gca, 'XDir','normal', 'YDir','normal');
    title('Ŀ��� z�����ϸ���Ĺ�����ʱ��仯��ϵͼ');
    xlabel('t(s)');
end
ylabel('z(m)');