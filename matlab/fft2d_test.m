%% ���в�������
doFindpeaksTest_findpeaks=0;
doFindFirstpeakSampleTest_findpeaks=0;
doFindFirstpeakTest_findpeaks=0;

%% ����
close all;

%% ����/��ȡ���ݡ�����
load '../data/yLoCut_1MHz_400rps_1rpf_1t8r_walking.mat'

nRx=size(antBits,1);
yLoCut=log2array(logsout,'yLoCutSim');
lRamp=fS/fTr;%length ramp
lSp=size(yLoCut,1);
fF=fTr/nRx/nCyclePF;

fBw=2e9;%frequency bandwidth
fPm=fBw*fTr/3e8;%frequency per meter
fD=fS/lFft;%frequency delta
dPs=fD/fPm;%distance per sample
fs=linspace(0,fD*(lSp/2-1),floor(lSp/2));
ds=fs/fPm;
ts=linspace(0,size(yLoCut,3)/fF,size(yLoCut,3));

%% ����ÿ�����ߵĲ���
% ���㷢�����ߵ�����������֮��ľ���
dsTxRxi=zeros(nRx,1);%��ʱֻ��һ����������
for iRx=1:nRx
    dsTxRxi(iRx,:)=pdist([antCoor(iRx,:);antCoor(nRx+1,:)]);
end

%% ��ȡ��Чʱ��
tMi=5;
tMa=38;
valT=ts>=tMi & ts<=tMa;

yLoCut=yLoCut(:,:,valT);
ts=ts(valT);

%% 2DFFT

yLoCut=yLoCut...
    .*repmat(hamming(size(yLoCut,2))',size(yLoCut,1),1,size(yLoCut,3))...
    .*repmat(hamming(size(yLoCut,1)),1,size(yLoCut,2),size(yLoCut,3));
heatMaps=fft2(yLoCut,size(yLoCut,1),2^nextpow2(100));

% �ų����³��ȣ���ȡ��Ч����
heatMaps=heatMaps(ds>=dCa,:,:);
ds=ds(ds>=dCa)-dCa;

% ��ȡ��Ч���뷶Χ
dMi=max(dsTxRxi);
dMa=20;
valD=ds>=dMi & ds<=dMa;

heatMaps=heatMaps(valD,:,:);
ds=ds(valD);

heatMaps=flip(heatMaps,2);

% ��ȥ����
heatMapB=filter(0.05,[1,-0.95],heatMaps,0,3);
heatMaps=abs(heatMaps-heatMapB);

hHea=figure('name','�ռ��ȶ�ͼ');
for iFrame=1:size(heatMaps,3)
    figure(hHea);
    heatMap=heatMaps(:,:,iFrame);
    heatMap=circshift(heatMap,ceil(size(heatMap,2)/2),2);
    imagesc(1:size(heatMap,2),ds,heatMap);
    title(['��' num2str(ts(iFrame)) 's �Ŀռ��ȶ�ͼ']);
    pause(0.01);
end
