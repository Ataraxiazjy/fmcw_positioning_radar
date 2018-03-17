%% ����
clear;
close all;

%% ���в�������
doShowLo=0;
doShowPsProject=1;
useGPU=1;

%% ����/��ȡ���ݡ�����
nTx=4;
nRx=12;
rxCoor=[linspace(-0.053*(nRx/2-0.5),0.053*(nRx/2-0.5),nRx)',zeros(nRx,2)];
txCoor=[zeros(nTx,2),linspace(-0.138-0.053*(nTx-1),-0.138,nTx)'];
fCen=3.2e9;
fBw=1e9;
fSDown=200e3;
fRamp=800;
lRampDown=fSDown/fRamp;
lFft=512;
dLambda=3e8/fCen;
dMa=10;
dMi=1;
dCa=0;

fPm=fBw*fRamp/3e8;%frequency per meter

tsRamp=(0:lRampDown-1)/fSDown;

tarCoor=[2,4,0.5];%target coordinate

%% ����Ŀ��㷴��ز��±�Ƶ����Ƶ�ź�
% ����Ŀ�굽�����߼�ľ���
dsRT=zeros(nRx,nTx);
for iTx=1:nTx
    for iRx=1:nRx
        dsRT(iRx,iTx)=pdist([tarCoor;rxCoor(iRx,:)])+pdist([tarCoor;txCoor(iTx,:)]);
    end
end

yLoReshape=zeros(lRampDown,nRx,nTx);
for iTx=1:nTx
    for iRx=1:nRx
        yLoReshape(:,iRx,iTx)=cos(2*pi*fPm*dsRT(iRx,iTx)*tsRamp+2*pi*dsRT(iRx,iTx)/dLambda);
    end
end
if doShowLo
    figure('name','yLo');
    yLo=reshape(yLoReshape,lRampDown,nRx*nTx);
    imagesc(1:nRx*nTx,tsRamp*1e6,yLo);
    set(gca, 'XDir','normal', 'YDir','normal');
    title('yLo');
    xlabel('���߱��');
    ylabel('tsRamp(us)');
end

%% �ɴֵ�ϸ�㷨
dxIn=1;
dyIn=1;
dzIn=1;
C2Ffac=3;
nC2F=2;
C2Fratio=0.1;

% ���һ��
% ��ʼ��
xs=single(-3:dxIn:3);
ys=single(1:dyIn:5);
zs=single(-1.5:dzIn:1.5);
[xss,yss,zss]=meshgrid(xs,ys,zs);
xsV=reshape(xss,numel(xss),1);
ysV=reshape(yss,numel(yss),1);
zsV=reshape(zss,numel(zss),1);
pointCoor=[xsV,ysV,zsV];

fTsrampRTZ=rfcaptureCo2F(pointCoor,rxCoor,txCoor,nRx,nTx,0,tsRamp,fBw,fRamp,dLambda,1);
psH=abs(rfcaptureF2ps(fTsrampRTZ,yLoReshape,1));
ps=reshape(psH,size(xss));
isHLog=true(size(xss));

if doShowPsProject
hPs=figure('name','ps��xyͶӰͼ');
showProjectedHeatmaps(hPs,ps,xs,ys,zs);
pause(0.5);
end

for i=1:nC2F
    [xssC,yssC,zssC]=meshgrid(xs,ys,zs);
%     isXc=ceil(C2Ffac/2):C2Ffac:length(xs)*C2Ffac-floor(C2Ffac/2);
%     isYc=ceil(C2Ffac/2):C2Ffac:length(ys)*C2Ffac-floor(C2Ffac/2);
%     isZc=ceil(C2Ffac/2):C2Ffac:length(zs)*C2Ffac-floor(C2Ffac/2);
%     isXf=1:length(xs)*C2Ffac;
%     isYf=1:length(ys)*C2Ffac;
%     isZf=1:length(zs)*C2Ffac;
    isXc=0:C2Ffac:(length(xs)-1)*C2Ffac;
    isYc=0:C2Ffac:(length(ys)-1)*C2Ffac;
    isZc=0:C2Ffac:(length(zs)-1)*C2Ffac;
    isXf=0:(length(xs)-1)*C2Ffac;
    isYf=0:(length(ys)-1)*C2Ffac;
    isZf=0:(length(zs)-1)*C2Ffac;
    
    xs=interp1(isXc,xs,isXf,'linear','extrap');
    ys=interp1(isYc,ys,isYf,'linear','extrap');
    zs=interp1(isZc,zs,isZf,'linear','extrap');
    [xssF,yssF,zssF]=meshgrid(xs,ys,zs);
    xsFv=reshape(xssF,numel(xssF),1);
    ysFv=reshape(yssF,numel(yssF),1);
    zsFv=reshape(zssF,numel(zssF),1);
    pointCoor=[xsFv,ysFv,zsFv];
    
    
    ps=interp3(xssC,yssC,zssC, ...
        ps,xssF,yssF,zssF,'linear',0);
    isHLog=interp3(xssC,yssC,zssC, ...
        isHLog,xssF,yssF,zssF,'nearest',0);
    
    % ���ݹ���ѡȡ�����
    psHold=ps(isHLog);
    [~,isHnum]=sort(psHold,'descend');
    isHnum=isHnum(1:floor(numel(psHold)*C2Fratio));
    isHLog=false(size(isHLog));
    isHLog(isHnum)=1;
        
    
    
    % Ӳ��ѡȡ��
    fTsrampRTZ=rfcaptureCo2F(pointCoor(isHLog(:),:),rxCoor,txCoor,nRx,nTx,dCa,tsRamp,fBw,fRamp,dLambda,useGPU);
    psH=abs(rfcaptureF2ps(fTsrampRTZ,yLoReshape,1));
    ps(isHLog)=psH;
    
    % ��ʾ���ʷֲ�
    if doShowPsProject
    showProjectedHeatmaps(hPs,ps,xs,ys,zs);
    pause(0.5);
    end
    
end

function showProjectedHeatmaps(hPs,ps,xs,ys,zs)
hPs=figure(hPs);
psYXsum=sum(ps,3);
figure(hPs);
subplot(1,2,1);
imagesc(xs,ys,psYXsum);
set(gca, 'XDir','normal', 'YDir','normal');
title('ps��xyͶӰͼ');
xlabel('x(m)');
ylabel('y(m)');

psXZsum=permute(sum(ps,1),[3,2,1]);
figure(hPs);
subplot(1,2,2);
imagesc(xs,zs,psXZsum);
set(gca, 'XDir','normal', 'YDir','normal');
title('ps��xzͶӰͼ');
xlabel('x(m)');
ylabel('z(m)');
end