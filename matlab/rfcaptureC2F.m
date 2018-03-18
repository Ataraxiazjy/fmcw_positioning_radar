%% rfcapture coarse to fine �������ɴֵ�ϸ���㹦�ʷֲ�
function [psF,xsF,ysF,zsF]=rfcaptureC2F(dxC,dyC,dzC,xsC,ysC,zsC,psBcoor,psB, ...
    nC2F,C2Fratio,C2Ffac,tShowPsProject,hPs, ...
    yLoReshape,rxCoor,txCoor,nRx,nTx,dCa,tsRamp,fBw,fRamp,dLambda,useGPU)
% % ��ʼ��
% tCutCen=floor(length(tsRamp)/2);

% ���һ��
[xssC,yssC,zssC]=meshgrid(xsC,ysC,zsC);
psWcoor=[xssC(:),yssC(:),zssC(:)];

if useGPU
    psF=zeros(size(xssC),'single','gpuArray');
else
    psF=zeros(size(xssC),'single');
end

for i=1:nC2F
    % ��ȡ������
    isPsB=zeros(size(psWcoor,1),1);
    for j=1:size(psWcoor,1)
        isPsB(j)=find(all(abs(psWcoor(j,:)-psBcoor)<0.001,2));
    end
    psBH=psB(isPsB);
    
    
    % ���ݼ���ֱ��ʳ�ȡ���ߺ�ʱ���źţ����ټ�����
%     % ����y����ֱ��ʼ����ȡʱ���źų���
%     lYLoCut=min(fSdown/fPm/dxC,length(tsRamp));
%     isYLoCut=1:length(tsRamp)<=lYLoCut;
%     % Ӳ��ѡȡ��
%     fTsrampRTZ=rfcaptureCo2F(psWcoor,rxCoor,txCoor,nRx,nTx,dCa,tsRamp(isYLoCut),fBw,fRamp,dLambda,useGPU);
%     psH=abs(rfcaptureF2ps(fTsrampRTZ,yLoReshape(isYLoCut,:,:),useGPU)-psBH);
    % �������������ʱ���źŽ�ȡ�����ܷ������͡�
    % �Ƕȷֱ����ϣ�����ʵ��ʹ���в���Ҫ�����Ŀǰ�ܴﵽ�ֱ��ʸ��͵ķֱ��ʣ���˲���Ҫ��ȡ��������

    % Ӳ��ѡȡ��
    fTsrampRTZ=rfcaptureCo2F(psWcoor,rxCoor,txCoor,nRx,nTx,dCa,tsRamp,fBw,fRamp,dLambda,useGPU);
    psH=abs(rfcaptureF2ps(fTsrampRTZ,yLoReshape,useGPU)-psBH);
    if i==1
        psF(:)=psH;
    else
        psF(isHLog)=psH;
    end
    
    % ��ʾ���ʷֲ�
    if tShowPsProject
        showProjectedHeatmaps(hPs,psF,xsC,ysC,zsC);
        pause(tShowPsProject);
    end
    
    if i>=nC2F
        break;
    end
    
    % ��չpsF��isHLog����
    [xssC,yssC,zssC]=meshgrid(xsC,ysC,zsC);
    
    dxC=dxC/C2Ffac;
    dyC=dyC/C2Ffac;
    dzC=dzC/C2Ffac;
    xsC=xsC(1):dxC:xsC(end);
    ysC=ysC(1):dyC:ysC(end);
    zsC=zsC(1):dzC:zsC(end);
    [xssF,yssF,zssF]=meshgrid(xsC,ysC,zsC);
    psWcoor=[xssF(:),yssF(:),zssF(:)];
    
    psF=interp3(xssC,yssC,zssC, ...
        psF,xssF,yssF,zssF,'linear',0);
    
    % ���ݹ���ѡȡ�����
    isHLog=psF>max(max(max(psF)))*(1-C2Fratio);
    psWcoor=psWcoor(isHLog(:),:);
end
xsF=xsC;
ysF=ysC;
zsF=zsC;

end