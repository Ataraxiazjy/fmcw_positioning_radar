close all;
sSavePath='../images';
sLoadPath='../../fmcw_positioning_radar_large';
if ~exist('angs','var')
    load(fullfile(sLoadPath,'params.mat'));
end
%% ͼƬ���ʲ���ϵ��
currFig=figure('Name','���ʲ���ϵ��');
imagesc(angs,ds,facD);
colorbar
title('���ʲ���ϵ��');
xlabel('�Ƕ�(��)');
ylabel('����(m)');
set(currFig, 'position', [0 0 800 600]);
set(gca,'FontSize',20,'FontName','����')
imWrite=getframe(currFig);
imWrite=frame2im(imWrite);
imwrite(imWrite,fullfile(sSavePath,'facD.jpg'),'jpg');
close(currFig);


%% ͼƬ������ת��
currFig=figure('Name','������ת���Ƕ�');

subplot(1,2,1)
imagesc(xs,ys,angsPo2Car);
c=colorbar;
c.Label.String='������ϵ�µĽǶ�ang(��)';
title('������ת���Ƕ�ӳ�����');
xlabel('x(m)');
ylabel('y(m)');
set(gca,'FontSize',20,'FontName','����')

subplot(1,2,2)
imagesc(xs,ys,dsPo2Car);
c=colorbar;
c.Label.String='������ϵ�µľ���d(m)';
title('������ת������ӳ�����');
xlabel('x(m)');
ylabel('y(m)');
set(gca,'FontSize',20,'FontName','����')

set(currFig, 'position', [0 0 1600 600]);
imWrite=getframe(currFig);
imWrite=frame2im(imWrite);
imwrite(imWrite,fullfile(sSavePath,'angsPo2Car.jpg'),'jpg');
close(currFig);

%% gif
tBegin=70;
tLength=8;
tEnd=tBegin+tLength;

%% gif�����ź�
cutShowSave(fullfile(sLoadPath,'yLoCut.avi'),tBegin,tEnd, ...
    [],tsRamp, ...
    '�����ź�','���߶�','ʱ��(s)', ...
    0,fullfile(sSavePath,'yLoCut.gif'));

%% gifԭʼ�ȶ�ͼ
cutShowSave(fullfile(sLoadPath,'heatMapPoAll.avi'),tBegin,tEnd, ...
    angs,ds, ...
    'ԭʼ�ȶ�ͼ','�Ƕ�(��)','����(m)', ...
    1,fullfile(sSavePath,'heatMapPoAll.gif'));

%% gif�ȶ�ͼ����
cutShowSave(fullfile(sLoadPath,'heatMapPoBac.avi'),tBegin,tEnd, ...
    angs,ds, ...
    '�ȶ�ͼ����','�Ƕ�(��)','����(m)', ...
    1,fullfile(sSavePath,'heatMapPoBac.gif'));

%% gif�ȶ�ͼǰ��
cutShowSave(fullfile(sLoadPath,'heatMapPoFor.avi'),tBegin,tEnd, ...
    angs,ds, ...
    '�ȶ�ͼǰ��','�Ƕ�(��)','����(m)', ...
    1,fullfile(sSavePath,'heatMapPoFor.gif'));

%% gifʱ���ͨ�˲�����ȶ�ͼ
cutShowSave(fullfile(sLoadPath,'heatMapPoMultiRemove.avi'),tBegin,tEnd, ...
    angs,ds, ...
    'ʱ���ͨ�˲�����ȶ�ͼ','�Ƕ�(��)','����(m)', ...
    1,fullfile(sSavePath,'heatMapPoMultiRemove.gif'));

%% gif������ֵ�˲�����ȶ�ͼ
cutShowSave(fullfile(sLoadPath,'heatMapPoFil.avi'),tBegin,tEnd, ...
    angs,ds, ...
    '������ֵ�˲�����ȶ�ͼ','�Ƕ�(��)','����(m)', ...
    1,fullfile(sSavePath,'heatMapPoFil.gif'));

%% gif��ֵ������ȶ�ͼ
cutShowSave(fullfile(sLoadPath,'heatMapPoBw.avi'),tBegin,tEnd, ...
    angs,ds, ...
    '��ֵ������ȶ�ͼ','�Ƕ�(��)','����(m)', ...
    1,fullfile(sSavePath,'heatMapPoBw.gif'));

%% gif�ȶ�ͼĿ����
cutShowSave(fullfile(sLoadPath,'heatMapTarget.avi'),tBegin+40,tEnd+40, ...
    angs,ds, ...
    '�ȶ�ͼĿ����','�Ƕ�(��)','����(m)', ...
    1,fullfile(sSavePath,'heatMapTarget.gif'));

%% gif����
function cutShowSave(sFile,tBegin,tEnd, ...
    xs,ys, ...
    sTitle,sXlabel,sYlabel, ...
    doSc,sSave)
v=VideoReader(sFile);
v.CurrentTime=tBegin;

currFig=figure('Name',sTitle);
iFrame=0;
while v.CurrentTime<tEnd
    iFrame=iFrame+1;
    for j=1:3
        frameRead=readFrame(v);
    end
    if doSc
        frameRead=rgb2gray(frameRead);
    end
    figure(currFig);
    imagesc(xs,ys,frameRead);
%     if doSc
%         colorbar
%     end
    %     imshow(frame, 'Parent', currAxes);
    
    %     set(gca, 'XDir','normal', 'YDir','normal');
%     axis image;

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
    imwrite(I,map,sSave,'gif','Loopcount',inf,'DelayTime',1/v.FrameRate);
    else
    imwrite(I,map,sSave,'gif','WriteMode','append','DelayTime',1/v.FrameRate);
    end
end
close(currFig);
end
