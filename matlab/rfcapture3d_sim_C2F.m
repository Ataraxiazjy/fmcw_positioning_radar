%% ����
clear;
close all;

%% ���в�������
doShowLo=0;
tShowPsProject=0.2;
doTestC2F=1;
doTestC2F2=1;
useGPU=1;

%% ����/��ȡ���ݡ�����
nTx=4;
nRx=12;
rxCoor=[linspace(-0.053*(nRx/2-0.5),0.053*(nRx/2-0.5),nRx)',zeros(nRx,2)];
txCoor=[zeros(nTx,2),linspace(-0.138-0.053*(nTx-1),-0.138,nTx)'];
fCen=3.2e9;
fBw=1e9;
fSdown=200e3;
fRamp=800;
lRampDown=fSdown/fRamp;
lFft=512;
dLambda=3e8/fCen;
dMa=10;
dMi=1;
dCa=0;

fPm=fBw*fRamp/3e8;%frequency per meter

tsRamp=single((0:lRampDown-1)/fSdown);

tarCoor=[2,4,0.5];%target coordinate

%% ����Ŀ��㷴��ز��±�Ƶ����Ƶ�ź�
% ����Ŀ�굽�����߼�ľ���
dsRT=zeros(nRx,nTx,'single');
for iTx=1:nTx
    for iRx=1:nRx
        dsRT(iRx,iTx)=pdist([tarCoor;rxCoor(iRx,:)])+pdist([tarCoor;txCoor(iTx,:)]);
    end
end

yLoReshape=zeros(lRampDown,nRx,nTx,'single');
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

%% �ɴֵ�ϸ�㷨׼��
xMi=-3;
xMa=3;
yMi=1;
yMa=5;
zMi=-1.5;
zMa=1.5;
dxC=0.5;
dyC=0.5;
dzC=0.5;

C2Fw=3;
C2Fn=3;
C2Fratio=0.5;


preciFac=C2Fw^(C2Fn-1);
xsB=single(xMi:dxC/preciFac:xMa);
ysB=single(yMi:dyC/preciFac:yMa);
zsB=single(zMi:dzC/preciFac:zMa);
[xssB,yssB,zssB]=meshgrid(xsB,ysB,zsB);
if useGPU
    psB=zeros(size(xssB),'single','gpuArray');
else
    psB=zeros(size(xssB),'single');
end

% ׼����������
psWcen=single([(xMa+xMi)/2,(yMa+yMi)/2,(zMa+zMi)/2]);
psWl=single([xMa-xMi,yMa-yMi,zMa-zMi]);
psWdC=single([dxC,dyC,dzC]);

%% ��ʼ����
if doTestC2F
    if tShowPsProject
        hPs=figure('name','ps��xyͶӰͼ');
    else
        hPs=[];
    end
    psF=rfcaptureC2F(psWcen,psWl,psWdC, ...
        xssB,yssB,zssB,psB,C2Fratio,C2Fw,C2Fn,tShowPsProject,hPs, ...
        yLoReshape,rxCoor,txCoor,dCa,tsRamp,fBw,fRamp,dLambda,useGPU);
end

%% ����rfcaptureC2F2

% ׼����������
psWcen=single([(xMa+xMi)/2,tarCoor(2),(zMa+zMi)/2]);
psWl=single([xMa-xMi,0,zMa-zMi]);
psWdC=single([dxC,dyC,dzC]);

%% ��ʼ����

if doTestC2F2
    if tShowPsProject
        hPs=figure('name','ps��xyͶӰͼ');
    else
        hPs=[];
    end
    psF=rfcaptureC2F2(psWcen,psWl,psWdC, ...
        xssB,yssB,zssB,psB,C2Fratio,C2Fw,C2Fn,tShowPsProject,hPs, ...
        yLoReshape,rxCoor,txCoor,dCa,tsRamp,fBw,fRamp,dLambda,useGPU);
end
