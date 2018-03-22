%% rfcapture coarse to fine 2d �������ɴֵ�ϸ���㹦�ʷֲ�

% psF: ���㹦�ʷֲ�, ʵ��

% psWcen: �������ԣ��ṹ�����飬����xyz���ꡢmeshgrid������
% psWcoor: ������������
% psBcoor: ��������
% psB; ��������
% C2Fratio: coarse to fine ������ѡȡC2Fratio*maxPower�ĵ���е���
% tShowPsProject: ��ʾ������ͶӰͼ�ļ��ʱ�䣬Ϊ0ʱ����ʾ
% hPs: ��ʾͶӰͼ��Ŀ�괰�ھ��
% yLoReshape: ��Ƶ�źŴ�С[length(tsRamp),nRx,nTx]
% rxCoor: ������������
% txCoor: ������������
% nRx: ������������
% nTx: ������������
% dCa: Ӧ��ȥ�Ķ����������¾���
% tsRamp: һ��б���ڵ�ʱ������
% fBw: ɨƵ����
% fRamp: б��Ƶ��
% dLambda: ����
% useGPU: �Ƿ�ʹ��GPU

function psF=rfcaptureC2F2sim(psWcen,psWl,psWdC, ...
    psBcoor,psB,C2Fratio,C2Fw,C2Fn, ...
    yLoReshape,rxCoor,txCoor,nRx,nTx,dCa,tsRamp,fBw,fRamp,dLambda,useGPU)

yLoReshape=reshape(yLoReshape,length(tsRamp),nRx,nTx);

% ���һ��
xsC=single(-psWl(1)/2+psWcen(1):psWdC(1):psWl(1)/2+psWcen(1));
zsC=single(-psWl(3)/2+psWcen(3):psWdC(3):psWl(3)/2+psWcen(3));

[xssC,zssC]=meshgrid(xsC,zsC);
psHcoor=[xssC(:),repmat(psWcen(2),numel(xssC),1),zssC(:)];

for i=1:C2Fn

    % ��ȡ������
    isPsB=zeros(size(psHcoor,1),1);
    for j=1:size(psHcoor,1)
        isPsB(j)=find(all(abs(psBcoor-psHcoor(j,:))<0.001,2),1);
    end
    psBH=psB(isPsB);

    % Ӳ��ѡȡ��
    fTsrampRTZ=rfcaptureCo2F(psHcoor,rxCoor,txCoor,nRx,nTx,dCa,tsRamp,fBw,fRamp,dLambda,useGPU);
    psH=abs(rfcaptureF2ps(fTsrampRTZ,yLoReshape,useGPU)-psBH);
    if i==1
        psF=reshape(psH,size(xssC));
    else
        psF(isHLog)=psH;
    end

    if i>=C2Fn
        break;
    end
    
    % ������һ�ε�������
    xsF=single(-psWl(1)/2+psWcen(1):psWdC(1)/(C2Fw^i):psWl(1)/2+psWcen(1));
    zsF=single(-psWl(3)/2+psWcen(3):psWdC(3)/(C2Fw^i):psWl(3)/2+psWcen(3));
    
    [xssF,zssF]=meshgrid(xsF,zsF);
    coorF=[xssF(:),repmat(psWcen(2),numel(xssF),1),zssF(:)];
    
    % ��չpsF��isHLog����
    psF=interp2(xssC,zssC, ...
        psF,xssF,zssF,'linear',0);
    
    % ���ݹ���ѡȡ�����
    isHLog=psF>max(psF(:))*(1-C2Fratio);
    psHcoor=coorF(isHLog(:),:);
    
    xssC=xssF;
    zssC=zssF;
end

psF=gather(double(psF));

end
