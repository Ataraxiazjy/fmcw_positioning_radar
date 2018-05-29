close all;
sSavePath='../images';
sLoadPath='../../fmcw_positioning_radar_large';
load(fullfile(sLoadPath,'yLo.mat'));
if ~exist('angs','var')
    load(fullfile(sLoadPath,'params.mat'));
end

%% gifԭʼ�����ź�
yLoGif(tsFrame,yLoRawSim,'ԭʼ�����ź�','ʱ��(s)','����',fullfile(sSavePath,'yLoRaw.gif'),fF);
%% gifͬ��������ź�
yLoGif(tsFrame,yLoSyncSim,'ͬ��������ź�','ʱ��(s)','����',fullfile(sSavePath,'yLoSync.gif'),fF);
%% gif�и������ź�
yLoGif(tsRamp,yLoCutSim,'�и������ź�','ʱ��(s)','����',fullfile(sSavePath,'yLoCut.gif'),fF);

%% gif����
function yLoGif(ts,yLo,sTitle,sXlabel,sYlabel,sSave,fF)
currFig=figure('Name',sTitle);
for iFrame=1:10:size(yLo,3)
    figure(currFig);
    plot(ts,yLo(:,:,iFrame));
    set(currFig, 'position', [0 0 800 600]);
    title(sTitle);
    xlabel(sXlabel);
    ylabel(sYlabel);
    set(gca,'FontSize',20,'FontName','����')
    pause(0);
    
    framwWrite=getframe(currFig);
    framwWrite = frame2im(framwWrite); 
    [I,map]=rgb2ind(framwWrite,256);
    if iFrame == 1
    imwrite(I,map,sSave,'gif','Loopcount',inf,'DelayTime',1/fF);
    else
    imwrite(I,map,sSave,'gif','WriteMode','append','DelayTime',1/fF);
    end
end
close(currFig);
end
