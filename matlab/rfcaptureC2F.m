%% rfcapture coarse to fine �������ɴֵ�ϸ���㹦�ʷֲ�

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

function psF=rfcaptureC2F(psWcen,psWcoor,psBcoor,psB, ...
    C2Fratio,tShowPsProject,hPs, ...
    yLoReshape,rxCoor,txCoor,nRx,nTx,dCa,tsRamp,fBw,fRamp,dLambda,useGPU)
% ��ʼ��
for i=1:length(psWcoor)
    psWcoor(i).xs=psWcoor(i).xs+psWcen(1);
    psWcoor(i).ys=psWcoor(i).ys+psWcen(2);
    psWcoor(i).zs=psWcoor(i).zs+psWcen(3);
    psWcoor(i).xss=psWcoor(i).xss+psWcen(1);
    psWcoor(i).yss=psWcoor(i).yss+psWcen(2);
    psWcoor(i).zss=psWcoor(i).zss+psWcen(3);
    psWcoor(i).coor=psWcoor(i).coor+psWcen;
end

% ���һ��
psHcoor=psWcoor(1).coor;

for i=1:length(psWcoor)
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
        psF=reshape(psH,size(psWcoor(1).xss));
    else
        psF(isHLog)=psH;
    end
    
    % ��ʾ���ʷֲ�
    if tShowPsProject
        showProjectedHeatmaps(hPs,psF,psWcoor(i).xs,psWcoor(i).ys,psWcoor(i).zs);
        pause(tShowPsProject);
    end
    
    if i>=length(psWcoor)
        break;
    end
    
    % ��չpsF��isHLog����
    psF=interp3(psWcoor(i).xss,psWcoor(i).yss,psWcoor(i).zss, ...
        psF,psWcoor(i+1).xss,psWcoor(i+1).yss,psWcoor(i+1).zss,'linear',0);
    
    % ���ݹ���ѡȡ�����
    isHLog=psF>max(psF(:))*(1-C2Fratio);
    psHcoor=psWcoor(i+1).coor(isHLog(:),:);
end
xsF=psWcoor(end).xs;
ysF=psWcoor(end).ys;
zsF=psWcoor(end).zs;

end