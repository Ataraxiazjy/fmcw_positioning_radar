%% rfcapture coarse to fine �������ɴֵ�ϸ���㹦�ʷֲ�
function [psF,xsF,ysF,zsF]=rfcaptureC2F(xsC,ysC,zsC,xssB,yssB,zssB,psB, ...
    nC2F,C2Fratio,C2Ffac,tShowPsProject,hPs, ...
    yLoReshape,rxCoor,txCoor,nRx,nTx,dCa,tsRamp,fBw,fRamp,dLambda,useGPU)
% ��ʼ��
% TODO: ����ʼ���Ϳ�Ԥ�ȼ���Ĵ���ŵ������⣬����Բ�������
psBcoor=[xssB(:),yssB(:),zssB(:)];
dxC=diff(xsC(1:2));
dyC=diff(ysC(1:2));
dzC=diff(zsC(1:2));

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
    isPsB=zeros(size(pointCoor,1),1);
    for j=1:size(pointCoor,1)
        isPsB(j)=find(all(abs(pointCoor(j,:)-psBcoor)<0.001,2));
    end
%     [~,isPsB]=intersect(psBcoor,pointCoor,'rows');
    psBH=psB(isPsB);
    
    % Ӳ��ѡȡ��
    % TODO: ���ݼ���ֱ��ʳ�ȡ���ߺ�ʱ���źţ����ټ�����
    fTsrampRTZ=rfcaptureCo2F(pointCoor,rxCoor,txCoor,nRx,nTx,dCa,tsRamp,fBw,fRamp,dLambda,useGPU);
    psH=abs(rfcaptureF2ps(fTsrampRTZ,yLoReshape,useGPU)-psBH);
    psF(isHLog)=psH;
    
    % ��ʾ���ʷֲ�
    if tShowPsProject
        showProjectedHeatmaps(hPs,psF,xsC,ysC,zsC);
        pause(tShowPsProject);
    end
    
    % ��չpsF��isHLog����
    % TODO: ��sub2ind�����ֶ���ֵ����interp3
    [xssC,yssC,zssC]=meshgrid(xsC,ysC,zsC);
    
    preciFac=C2Ffac.^i;
    xsC=xsC(1):dxC/preciFac:xsC(end);
    ysC=ysC(1):dyC/preciFac:ysC(end);
    zsC=zsC(1):dzC/preciFac:zsC(end);
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