%% ����
clear;
close all;

%% ���в�������
doShowXYs=0;
doShowSamTsRsZ=0;
doShowSamFTsrampRTZ=1;
% useGPU=1;

%% ����/��ȡ���ݡ�����
load '../data/yLoCut_200kHz_800rps_1rpf_4t12r_ztest.mat'

yLoCut=log2array(logsout,'yLoCutSim');
heatMap=log2array(logsout,'heatMapSim');
coorPolRaw=log2array(logsout,'coorPolRawSim');
coorPolFil=log2array(logsout,'coorPolFilSim');
yLoReshape=reshape(yLoCut,size(yLoCut,1),nRx,nTx,size(yLoCut,3));

ts=linspace(0,size(yLoCut,3)/fF,size(yLoCut,3));
tsRamp=(0:size(yLoCut,1)-1)/fS*fftDownFac;

% iTsVal=(ts>5&ts<50);
iTsVal=true(length(ts),1);

%% ���괦��
dsPol=single(interp1(ds,shiftdim(single(coorPolFil(:,1,:)))));
angsPol=single(-interp1(angs,shiftdim(single(coorPolFil(:,2,:)))));
zs=single(-2:0.05:2);
xs=dsPol.*sind(angsPol);
ys=dsPol.*cosd(angsPol);
xs(isnan(xs))=0;
ys(isnan(ys))=0;
if doShowXYs
    hCor=figure('name','Ŀ�������');
    plot(ts,xs,ts,ys);
    hold on;
end
% xs=filter(0.1,[1,-0.9],xs,0,1);
% ys=filter(0.1,[1,-0.9],ys,0,1);
xs=medfilt1(xs,16,[],1);
ys=medfilt1(ys,16,[],1);
zsTs=repmat(zs',1,length(ts));
xsTs=repmat(xs',length(zs),1);
ysTs=repmat(ys',length(zs),1);
if doShowXYs
    figure(hCor);
    plot(ts,xs,ts,ys);
    title('Ŀ�������');
    legend('x�˲�ǰ','y�˲�ǰ','x�˲���','y�˲���');
    xlabel('t(s)');
    ylabel('(m)');
    hold off;
    pause(0.1);
end

%% ���㹦��
psZ=zeros(length(zs),length(ts),'single','gpuArray');
tic;
for iFrame=1:length(ts)
    pointCoor=[xsTs(:,iFrame),ysTs(:,iFrame),zsTs(:,iFrame)];
    fTsrampRTZ=rfcaptureCo2F(pointCoor,antCoor,nRx,nTx,dCa,tsRamp,fBw,fTr,dLambda,1);
    psZ(:,iFrame)=abs(rfcaptureF2ps(fTsrampRTZ,yLoReshape(:,:,:,iFrame),1));
    
    if mod(iFrame,10)==0
    disp(['��' num2str(iFrame) '֡' num2str(iFrame/length(ts)*100,'%.1f') ...
        '% ��ʱ' num2str(toc/60,'%.2f') 'min ' ...
        'ʣ��' num2str(toc/iFrame*(length(ts)-iFrame)/60,'%.2f') 'min']);
    end
end
psZ(isnan(psZ))=0;
psZ=gather(psZ);

%% ��������
psZF=filter(0.2,[1,-0.8],abs(psZ),0,2);
% psZF=psZ-psZB;

%% ����Ŀ��� z�����ϸ���Ĺ�����ʱ��仯��ϵͼ
psZAmp=abs(psZF(:,iTsVal));
psZAmp=psZAmp./repmat(max(psZAmp),length(zs),1);
hpsZ=figure('name','Ŀ��� z�����ϸ���Ĺ�����ʱ��仯��ϵͼ');
imagesc(ts(iTsVal),zs,psZAmp);
set(gca, 'XDir','normal', 'YDir','normal');
title('Ŀ��� z�����ϸ���Ĺ�����ʱ��仯��ϵͼ');
xlabel('t(s)');
ylabel('z(m)');

