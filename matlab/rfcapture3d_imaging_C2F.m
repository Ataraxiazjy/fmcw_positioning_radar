%% ����
clear;
close all;

%% ���в�������
doShow2DHeatmap=0;
doShowTarcoor=0;
doShowPsBProject=0;
doTestC2F=0;
doTestC2F2=1;
tShowPsProject=0;
doSavePsProject=0;
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

C2Fw=3;
C2Fn=2;
C2Fratio=0.5;

preciFac=C2Fw.^(C2Fn-1);
xsB=single(xMi:dxC/preciFac:xMa);
ysB=single(yMi:dyC/preciFac:yMa);
zsB=single(zMi:dzC/preciFac:zMa);

xsB2=xsB;
ysB2=ysB;
[xssB2,yssB2]=meshgrid(xsB2,ysB2);

%% fft2d����
heatMapsFft=fft2(yLoReshape,lFftDis,lFftAng);
heatMapsFft=heatMapsFft(isDval,:,:,:);

heatMapsFft=circshift(heatMapsFft,ceil(size(heatMapsFft,2)/2),2);
heatMapsFft=flip(heatMapsFft,2);

% ��������
heatMapsBFft=filter(0.2,[1,-0.8],heatMapsFft,0,4);
heatMapsFFft=abs(heatMapsFft-heatMapsBFft);
heatMapsFFft=permute(prod(heatMapsFFft,3),[1,2,4,3]);

% ������ת��
heatMapsCarFFft=zeros(length(ysB2),length(xsB2),length(ts),'single');

% ��������ӳ�����
dsPo2Car=sqrt(xssB2.^2+yssB2.^2);
angsPo2Car=atand(xssB2./yssB2);
angsPo2Car(isnan(angsPo2Car))=0;

for iFrame=1:length(ts)
    heatMapsCarFFft(:,:,iFrame)=interp2(angs,dsVal,heatMapsFFft(:,:,iFrame),angsPo2Car,dsPo2Car,'linear',0);
end

%% �Ƚ�Ŀ������
[isYTarFft,isXTarFft]=iMax2d(heatMapsCarFFft);
[isDTarPoFft,isATarPoFft]=iMax2d(heatMapsFFft);

xsTarCarFft=xsB2(isXTarFft);
ysTarCarFft=ysB2(isYTarFft);

coorTarPoFft=zeros(length(isATarPoFft),2);
for i=1:length(isATarPoFft)
    coorTarPoFft(i,:)=isPo2coor([isDTarPoFft(i),isATarPoFft(i)], dsVal, angs);
end
xsTarPoFft=coorTarPoFft(:,1);
ysTarPoFft=coorTarPoFft(:,2);

psWcen=zeros(length(isATarPoFft),3);
for i=1:length(coorTarPoFft)
    psWcen(i,:) = getPsWcen(coorTarPoFft(i,:),xsB, ysB, [1,0,3]);
end

if doShowTarcoor
    hCoor=figure('name','�Ƚ����ַ�������Ŀ������');
    subplot(1,2,1);
    plot(ts,xsTarCarFft,ts,xsTarPoFft,ts,psWcen(:,1));
    legend('xsTarFft','xsTarPoFft','psWcenX');
    title('ͼ��ӳ��ͼ�����ת������Ŀ��x����');
    xlabel('t(s)');
    ylabel('x(m)');
    
    subplot(1,2,2);
    plot(ts,ysTarCarFft,ts,ysTarPoFft,ts,psWcen(:,2));
    legend('ysTarFft','ysTarPoFft','psWcenY');
    title('ͼ��ӳ��ͼ�����ת������Ŀ��y����');
    xlabel('t(s)');
    ylabel('y(m)');
    
    pause(0.2);
end

%% ��ʾ���ʷֲ�
if doShow2DHeatmap
    hHea=figure('name','�ռ��ȶ�ͼ');
    for iFrame=1:length(ts)
        figure(hHea);
        
        heatMapsFFftScaled=heatMapsCarFFft(:,:,iFrame)/max(max(heatMapsCarFFft(:,:,iFrame)));
        heatMapsFFftTar=insertShape(gather(heatMapsFFftScaled),'circle',[isXTarFft(iFrame) isYTarFft(iFrame) 5],'LineWidth',2);
        imagesc(xsB2,ysB2,heatMapsFFftTar);
        set(gca, 'XDir','normal', 'YDir','normal');
        title(['��' num2str(ts(iFrame)) 's ��fft2d�ռ��ȶ�ͼ']);
        xlabel('x(m)');
        ylabel('y(m)');
        
        pause(0.02);
    end
end

%% ���㱳��
if ~exist('psB','var')
    [xssB,yssB,zssB]=meshgrid(xsB,ysB,zsB);
    
    psBcoor=[xssB(:),yssB(:),zssB(:)];
    
    if useGPU
        psB=zeros(size(psBcoor,1),1,'single','gpuArray');
    else
        psB=zeros(size(psBcoor,1),1,'single');
    end
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
            fTsrampRTZ=rfcaptureCo2F(psBcoor(isBlock,:),rxCoor,txCoor,dCa,tsRamp,fBw,fRamp,dLambda,useGPU);
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
psWl=single([lxW,lyW,lzW]);
psWdC=single([dxC,dyC,dzC]);

xsTarFftMean=mean(xsTarCarFft);
ysTarFftMean=mean(ysTarCarFft);

[~,iXTar]=min(abs(xsB-xsTarFftMean));
[~,iYTar]=min(abs(ysB-ysTarFftMean));
xsTarFftMean=xsB(iXTar);
ysTarFftMean=ysB(iYTar);
psWcen=[xsTarFftMean,ysTarFftMean,0];

preciFac=C2Fw^(C2Fn-1);
xsF=single(-psWl(1)/2+psWcen(1):psWdC(1)/preciFac:psWl(1)/2+psWcen(1));
ysF=single(-psWl(2)/2+psWcen(2):psWdC(2)/preciFac:psWl(2)/2+psWcen(2));
zsF=single(-psWl(3)/2+psWcen(3):psWdC(3)/preciFac:psWl(3)/2+psWcen(3));

%% ����rfcaptureC2F���㴰��ǰ��
if doTestC2F
    tic;
    for iFrame=1:length(ts)
        psF=rfcaptureC2F(psWcen,psWl,psWdC, ...
            xssB,yssB,zssB,psB,C2Fratio,C2Fw,C2Fn,0,hPs, ...
            yLoReshape(:,:,:,iFrame),rxCoor,txCoor,dCa,tsRamp,fBw,fRamp,dLambda,useGPU);
        if iFrame==1
            if useGPU
                psFo=zeros([size(psF),length(ts)],'single','gpuArray');
            else
                psFo=zeros([size(psF),length(ts)],'single');
            end
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
        if doSavePsProject
            writerObj=VideoWriter('../../xzProject.mp4','MPEG-4');  %// ����һ����Ƶ�ļ������涯��
            writerObj.FrameRate=fF;
            open(writerObj);                    %// �򿪸���Ƶ�ļ�
        end
        for iFrame=1:length(ts)
            showProjectedHeatmaps(hPs,psFo(:,:,:,iFrame), ...
                xsF,ysF,zsF);
            if doSavePsProject
                writeVideo(writerObj,getframe(gcf));
            end
            pause(tShowPsProject);
        end
        if doSavePsProject
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
        ylabel('z(m)');
    end
end

%% ����rfcaptureC2F2���㴰��ǰ��
if doTestC2F2
    tic;
    for iFrame=1:length(ts)
        psF=rfcaptureC2F2(psWcen,psWl,psWdC, ...
            xssB,yssB,zssB,psB,C2Fratio,C2Fw,C2Fn,0,hPs, ...
            yLoReshape(:,:,:,iFrame),rxCoor,txCoor,dCa,tsRamp,fBw,fRamp,dLambda,useGPU);
        if iFrame==1
            if useGPU
                psFo=zeros([size(psF),length(ts)],'single','gpuArray');
            else
                psFo=zeros([size(psF),length(ts)],'single');
            end
        end
        psFo(:,:,iFrame)=psF;
        
        if mod(iFrame,10)==0
            disp(['��' num2str(iFrame) '֡' num2str(iFrame/length(ts)*100,'%.1f') ...
                '% ��ʱ' num2str(toc/60,'%.2f') 'min ' ...
                'ʣ��' num2str(toc/iFrame*(length(ts)-iFrame)/60,'%.2f') 'min']);
        end
    end
    
    
    %% ��ʾ����ͶӰ
    if tShowPsProject
        hPs=figure('name','psF��ͶӰͼ');
        if doSavePsProject
            writerObj=VideoWriter('../../xzProject.mp4','MPEG-4');  %// ����һ����Ƶ�ļ������涯��
            writerObj.FrameRate=fF;
            open(writerObj);                    %// �򿪸���Ƶ�ļ�
        end
        for iFrame=1:length(ts)
            figure(hPs);
            
            imagesc(xsF,zsF,psFo(:,:,iFrame));
            axis equal;
            axis([min(xsF), max(xsF), min(zsF), max(zsF)]);
            set(gca, 'XDir','normal', 'YDir','normal');
            title('ps��xzͶӰͼ');
            xlabel('x(m)');
            ylabel('z(m)');
            if doSavePsProject
                writeVideo(writerObj,getframe(gcf));
            end
            pause(tShowPsProject);
        end
        if doSavePsProject
            close(writerObj); %// �ر���Ƶ�ļ����
        end
    end
    
    
    %% ���Խ���z�Ṧ�ʷֲ�
    if doShowPsZsum
        psZsum=permute(sum(psFo,2),[1,3,2]);
        psZsum=psZsum./repmat(max(psZsum),length(zsF),1);
        hpsZ=figure('name','Ŀ��� z�����ϸ���Ĺ�����ʱ��仯��ϵͼ');
        imagesc(ts,zsF,psZsum);
        set(gca, 'XDir','normal', 'YDir','normal');
        title('Ŀ��� z�����ϸ���Ĺ�����ʱ��仯��ϵͼ');
        xlabel('t(s)');
        ylabel('z(m)');
    end
end
