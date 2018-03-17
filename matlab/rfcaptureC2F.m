%% rfcapture coarse to fine �������ɴֵ�ϸ���㹦�ʷֲ�
function [psF,xsF,ysF,zsF]=rfcaptureC2F(xsC,ysC,zsC,xssB,yssB,zssB,psB, ...
    nC2F,C2Fratio,C2Ffac,tShowPsProject,hPs, ...
    yLoReshape,rxCoor,txCoor,nRx,nTx,dCa,tsRamp,fBw,fRamp,dLambda,useGPU)
% ��ʼ��
psBcoor=[xssB(:),yssB(:),zssB(:)];
dxIn=diff(xsC(1:2));
dyIn=diff(ysC(1:2));
dzIn=diff(zsC(1:2));

% ���һ��
[xssC,yssC,zssC]=meshgrid(xsC,ysC,zsC);
pointCoor=[xssC(:),yssC(:),zssC(:)];

if useGPU
    psF=zeros(size(xssC),'single','gpuArray');
else
    psF=zeros(size(xssC),'single');
end
isHLog=true(size(xssC));

for i=1:nC2F
    % ��ȡ������
    [~,isPsB]=intersect(psBcoor,pointCoor,'rows');
    psBH=psB(isPsB);
    
    % Ӳ��ѡȡ��
    fTsrampRTZ=rfcaptureCo2F(pointCoor,rxCoor,txCoor,nRx,nTx,dCa,tsRamp,fBw,fRamp,dLambda,useGPU);
    psH=abs(rfcaptureF2ps(fTsrampRTZ,yLoReshape,1)-psBH);
    psF(isHLog)=psH;
    
    % ��ʾ���ʷֲ�
    if tShowPsProject
        showProjectedHeatmaps(hPs,psF,xsC,ysC,zsC);
        pause(tShowPsProject);
    end
    
    [xssC,yssC,zssC]=meshgrid(xsC,ysC,zsC);
    
    preciFac=1/C2Ffac.^i;
    xsC=xsC(1):preciFac*dxIn:xsC(end);
    ysC=ysC(1):preciFac*dyIn:ysC(end);
    zsC=zsC(1):preciFac*dzIn:zsC(end);
    [xssF,yssF,zssF]=meshgrid(xsC,ysC,zsC);
    pointCoor=[xssF(:),yssF(:),zssF(:)];
    
    
    psF=interp3(xssC,yssC,zssC, ...
        psF,xssF,yssF,zssF,'linear',0);
    isHLog=interp3(xssC,yssC,zssC, ...
        isHLog,xssF,yssF,zssF,'nearest',0);
    
    % ���ݹ���ѡȡ�����
    psHold=psF(isHLog);
    [~,isHnum]=sort(psHold,'descend');
    isHnum=isHnum(1:floor(numel(psHold)*C2Fratio));
    isHLog=false(size(isHLog));
    isHLog(isHnum)=1;
    pointCoor=pointCoor(isHLog(:),:);
end
xsF=xsC;
ysF=ysC;
zsF=zsC;

end