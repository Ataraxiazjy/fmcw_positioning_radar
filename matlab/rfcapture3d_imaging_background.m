%% ����
clear;
close all;

%% ���в�������
doShowPsBProject=1;
lBlock=1000;
useGPU=1;

%% ����/��ȡ���ݡ�����
filename='../data/yLoCut_200kHz_800rps_1rpf_4t12r_background.mat';
load(filename)

yLoCut=log2array(logsout,'yLoCutSim');
yLoReshape=reshape(yLoCut,size(yLoCut,1),nRx,nTx,size(yLoCut,3));

ts=linspace(0,size(yLoCut,3)/fF,size(yLoCut,3));

%% ��ȡ��lBackCut֡���뽨ģ
lBackCut=50;
if length(ts)>lBackCut
    yLoReshape=yLoReshape(:,:,:,end-lBackCut+1:end);
    ts=ts(end-lBackCut+1:end);
end

%% ���㱳��
if ~exist('psB','var')
    preciFac=C2Fw.^(C2Fn-1);
    xsB=single(xMi:dxC/preciFac:xMa);
    ysB=single(yMi:dyC/preciFac:yMa);
    zsB=single(zMi:dzC/preciFac:zMa);
    [xssB,yssB,zssB]=meshgrid(xsB,ysB,zsB);
    psBcoor=[xssB(:),yssB(:),zssB(:)];
    
    if useGPU
        psB=zeros(size(psBcoor,1),1,'single','gpuArray');
    else
        psB=zeros(size(psBcoor,1),1,'single');
    end
    
    isS=1:lBlock:size(psBcoor,1);
    tic;
    for iFrame=1:length(ts)
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
            disp(['��' num2str(iFrame) '֡' num2str(iFrame/length(ts)*100,'%.1f') ...
                '% ��ʱ' num2str(toc/60,'%.2f') 'min ' ...
                'ʣ��' num2str(toc/iFrame*(length(ts)-iFrame)/60,'%.2f') 'min']);
        end
    end
    
    psB=gather(reshape(psB,size(xssB))/length(ts));
    save(filename,'xsB','ysB','zsB','xssB','yssB','zssB','psBcoor','psB','-append');
end

%% ��ʾ�����Ĺ��ʷֲ�ͶӰͼ
if doShowPsBProject
    hPs=figure('name','psB��ͶӰͼ');
    showProjectedHeatmaps(hPs,log(abs(psB)),xsB,ysB,zsB);
    pause(0.5);
else
    hPs=[];
end
