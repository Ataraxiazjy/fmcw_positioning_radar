%% ����
clear;
close all;

%% ���в�������
doShowSamTsRsZ=0;
doShowSamFTsrampRTZ=0;
% useGPU=1;

%% ����/��ȡ���ݡ�����
load '../data/yLoCut_200kHz_800rps_1rpf_4t12r_ztest.mat'

yLoCut=log2array(logsout,'yLoCutSim');
heatMap=log2array(logsout,'heatMapSim');
coorPolRaw=log2array(logsout,'coorPolRawSim');
coorPolFil=log2array(logsout,'coorPolFilSim');
yLoReshape=reshape(yLoCut,size(yLoCut,1),nRx,nTx,size(yLoCut,3));

fF=fTr/nRx/nCyclePF;
ts=linspace(0,size(yLoCut,3)/fF,size(yLoCut,3));
tsRamp=(0:size(yLoCut,1)-1)/fS*fftDownFac;

iTsVal=(ts>2&ts<12);

%% ΪӲ�㹫ʽ׼������
dsPol=single(interp1(ds,shiftdim(coorPolFil(:,1,:))));
angsPol=single(-interp1(angs,shiftdim(coorPolFil(:,2,:))));
zs=single(-3:0.1:3);
xs=dsPol.*sind(angsPol);
ys=dsPol.*cosd(angsPol);
zsTs=repmat(zs,length(ts),1);
xsTs=repmat(xs,1,size(zsTs,2));
ysTs=repmat(ys,1,size(zsTs,2));



%% ����r(n,m)(X(ts),Y(ts),z)����tsΪ��ʱ�䣩
rsTsZRT=zeros(length(ts),size(zsTs,2),nRx,nTx,'single');%r(n,m)(X(ts),Y(ts),z)����tsΪ��ʱ�䣩
for iRx=1:nRx
    for iTx=1:nTx
        rsTsZRT(:,:,iRx,iTx)=sqrt( ...
            (xsTs-repmat(antCoor(iRx,1),length(ts),size(zsTs,2))).^2 ...
            + (ysTs-repmat(antCoor(iRx,2),length(ts),size(zsTs,2))).^2 ...
            + (zsTs-repmat(antCoor(iRx,3),length(ts),size(zsTs,2))).^2 ...
            ) ...
            + sqrt( ...
            (xsTs-repmat(antCoor(iTx+nRx,1),length(ts),size(zsTs,2))).^2 ...
            + (ysTs-repmat(antCoor(iTx+nRx,2),length(ts),size(zsTs,2))).^2 ...
            + (zsTs-repmat(antCoor(iTx+nRx,3),length(ts),size(zsTs,2))).^2 ...
            );
    end
end
%% ���ӻ� ���շ����߶� ����ʱ��Ŀ��� z�����ϸ��� �����ؾ���
if doShowSamTsRsZ
    hSample=figure('name','���շ����߶� ����ʱ��Ŀ��� z�����ϸ��� �����ؾ���');
    for iTx=1:nTx
        for iRx=1:nRx
            figure(hSample);
            samTsRsZ=permute(rsTsZRT(:,:,iRx,iTx),[2,1]);
            imagesc(ts,zs,samTsRsZ);
            set(gca, 'XDir','normal', 'YDir','normal');
            title(['Tx' num2str(iTx) ' Rx' num2str(iRx) ' ���߶� ����ʱ��Ŀ��� z�����ϸ��� �����ؾ���']);
            xlabel('t(s)');
            ylabel('z(m)');
            pause(0.1);
        end
    end
end

%% ����sumsumsum s(n,m,ts,tsRamp)*f(n,m,zs,ts,tsRamp)����tsΪ��ʱ��,tsRampΪ��ʱ�䣩
rsTsZRTGPU=gpuArray(rsTsZRT);
yLoReshapeGPU=gpuArray(yLoReshape);
tsRampGPU=gpuArray(tsRamp);
psZGPU=zeros(length(zs),length(ts),'single','gpuArray');

if doShowSamFTsrampRTZ
    hFTsrampRTZ=figure('name','���ӻ���ʱ��Ŀ��z������ĳ���߶Ե�Ƶ�ʺ���λ');
end
tic;
for iFrame=1:length(ts)
    sTsrampRT=yLoReshapeGPU(:,:,:,iFrame);
    rsTsrampRTZ=repmat(permute(rsTsZRTGPU(iFrame,:,:,:),[1,3,4,2]),length(tsRamp),1);
    fTsrampRTZ=exp( ...
        1i*2*pi*fBw*fTr.*rsTsrampRTZ/3e8 ...
        .*repmat(tsRampGPU',1,size(rsTsrampRTZ,2),size(rsTsrampRTZ,3),size(rsTsrampRTZ,4)) ...
        ) ...
        .*exp( ...
        1i*2*pi*rsTsrampRTZ/dLambda ...
        );
    if doShowSamFTsrampRTZ
        samIR=1;
        samIT=1;
        samFTsrampRTZ=shiftdim(fTsrampRTZ(:,samIR,samIT));
        figure(hFTsrampRTZ);
        imagesc(angle(samFTsrampRTZ));
        title(['Rx' num2str(samIR) ' Tx ' num2str(samIT) '���߶���Ŀ��z�����ϵ�Ƶ�ʺ���λ']);
        pause(0.01);
    end
    pz=shiftdim(sum(sum(sum(fTsrampRTZ,1),2),3));
    psZGPU(:,iFrame)=pz;
    
     disp(['��' num2str(iFrame) '֡' num2str(iFrame/length(ts)*100,'%.1f') ...
            '% ��ʱ' num2str(toc/60,'%.2f') 'min ' ...
            'ʣ��' num2str(toc/iFrame*(length(ts)-iFrame)/60,'%.2f') 'min']);
end
psZ=gather(psZGPU);

%% ����Ŀ��� z�����ϸ���Ĺ�����ʱ��仯��ϵͼ
psZAmp=abs(psZ(:,iTsVal));
psZAmp=psZAmp./repmat(max(psZAmp),length(zs),1);
hpsZ=figure('name','Ŀ��� z�����ϸ���Ĺ�����ʱ��仯��ϵͼ');
imagesc(ts(iTsVal),zs,psZAmp);
set(gca, 'XDir','normal', 'YDir','normal');
title('Ŀ��� z�����ϸ���Ĺ�����ʱ��仯��ϵͼ');
xlabel('t(s)');
ylabel('z(m)');

