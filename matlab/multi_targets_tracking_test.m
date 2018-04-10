%% ����
clear;
close all;

%% ����/��ȡ���ݡ�����
sFileData='../data/heatMap_200kHz_2000rps_4rpf_4t12r_two_targets.mat';
load(sFileData)

heatMapPo=log2array(logsout,'heatMapPoSim');
ts=linspace(0,size(heatMapPo,3)/fF,size(heatMapPo,3));

%% ��ʾ���ʷֲ�
hHea=figure('name','��ά���ʷֲ�ͼ');
for iFrame=1:length(ts)
    figure(hHea);
    
    heatMap=heatMapPo(:,:,iFrame);
    [iDTar,iATar]=iMax2d(heatMap);
    heatMapShape=sum(insertShape(heatMap,'circle', ...
        [iATar iDTar 5],'LineWidth',1, ...
        'Color',repmat(max(heatMap(:)),1,3)),3);
    
    subplot(1,2,1);
    imagesc(angs,dsVal,heatMapShape);
    set(gca, 'XDir','normal', 'YDir','normal');
    title(['��' num2str(ts(iFrame)) 's �Ķ�ά���ʷֲ�ͼ']);
    xlabel('angle(��)');
    ylabel('dis(m)');
    
    subplot(1,2,2);
    imagesc(angs,dsVal,log(heatMapShape));
    set(gca, 'XDir','normal', 'YDir','normal');
    title(['��' num2str(ts(iFrame)) 's �Ķ�ά���ʷֲ�ͼ']);
    xlabel('angle(��)');
    ylabel('dis(m)');

    drawnow
end


