%% ����
clear;
close all;

%% ����/��ȡ���ݡ�����
sFileData='../data/heatMap_200kHz_2000rps_4rpf_4t12r_two_targets.mat';
load(sFileData)

heatMapPo=log2array(logsout,'heatMapPoSim');
ts=linspace(0,size(heatMapPo,3)/fF,size(heatMapPo,3));

%% ����˥������
facD=repmat((dsVal.^4)',1,size(heatMapPo,2));

%% ��ʾ��ά���ʷֲ�
% hHea=figure('name','��ά���ʷֲ�ͼ');
% for iFrame=1:length(ts)
%     figure(hHea);
%     
%     heatMap=heatMapPo(:,:,iFrame).*facD;
%     imagesc(angs,dsVal,heatMap);
%     set(gca, 'XDir','normal', 'YDir','normal');
%     title(['��' num2str(ts(iFrame)) 's �Ķ�ά���ʷֲ�ͼ']);
%     xlabel('angle(��)');
%     ylabel('dis(m)');
%     drawnow
% end

% hHea=figure('name','��ά���ʷֲ�ͼ');
% for iFrame=1:length(ts)
%     figure(hHea);
%     
%     heatMap=heatMapPo(:,:,iFrame).*facD;
%     subplot(1,3,1);
%     imagesc(angs,dsVal,heatMap);
%     set(gca, 'XDir','normal', 'YDir','normal');
%     title(['��' num2str(ts(iFrame)) 's �Ķ�ά���ʷֲ�ͼ']);
%     xlabel('angle(��)');
%     ylabel('dis(m)');
%     
%     subplot(1,3,2);
%     imagesc(angs,dsVal,heatMapPo(:,:,iFrame));
%     set(gca, 'XDir','normal', 'YDir','normal');
%     title(['��' num2str(ts(iFrame)) 's �Ķ�ά���ʷֲ�ͼ']);
%     xlabel('angle(��)');
%     ylabel('dis(m)');
%     
%     subplot(1,3,3);
%     imagesc(angs,dsVal,facD);
%     set(gca, 'XDir','normal', 'YDir','normal');
%     title(['��' num2str(ts(iFrame)) 's �Ķ�ά���ʷֲ�ͼ']);
%     xlabel('angle(��)');
%     ylabel('dis(m)');
%     
%     drawnow
% end
% 
% hHea=figure('name','��ά���ʷֲ�ͼ');
% for iFrame=1:length(ts)
%     figure(hHea);
%     
%     heatMap=heatMapPo(:,:,iFrame).*facD;
%     
%     subplot(1,2,1);
%     imagesc(angs,dsVal,heatMap);
%     set(gca, 'XDir','normal', 'YDir','normal');
%     title(['��' num2str(ts(iFrame)) 's �Ķ�ά���ʷֲ�ͼ']);
%     xlabel('angle(��)');
%     ylabel('dis(m)');
%     
%     L = watershed(1-heatMap);
%     rgb = label2rgb(L,'jet',[.5 .5 .5]);
%     
%     subplot(1,2,2);
%     imagesc(angs,dsVal,rgb);
%     set(gca, 'XDir','normal', 'YDir','normal');
%     title(['��' num2str(ts(iFrame)) 's �Ķ�ά���ʷֲ�ͼ']);
%     xlabel('angle(��)');
%     ylabel('dis(m)');
%     
%     drawnow
% end

%% ��ȡĿ������
hHea=figure('name','��ά���ʷֲ�ͼ');
for iFrame=1:length(ts)
    figure(hHea);
    
    heatMap=heatMapPo(:,:,iFrame).*facD;
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
%     coor = isPo2coor([iDTar,iATar], dsVal, angs);
    imagesc(angs,dsVal,log(heatMapShape));
    set(gca, 'XDir','normal', 'YDir','normal');
    title(['��' num2str(ts(iFrame)) 's �Ķ�ά���ʷֲ�ͼ']);
    xlabel('angle(��)');
    ylabel('dis(m)');

    drawnow
end


function coor = isPo2coor(is, dsVal, angs)
coor=zeros(1,2,'single');
d=dsVal(is(1));
ang=angs(is(2));
coor(1)=d*sind(ang);
coor(2)=d*cosd(ang);
end