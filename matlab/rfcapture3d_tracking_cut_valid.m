%% ����
clear;
close all;

%% ����/��ȡ���ݡ�����
filename='../data/yLoCut_200kHz_800rps_1rpf_4t12r_track_stand_squat_difdis.mat';
load(filename)


yLoCut=log2array(logsout,'yLoCutSim');
yLoReshape=reshape(yLoCut,size(yLoCut,1),nRx,nTx,size(yLoCut,3));
coorWcenFilSim=log2array(logsout,'coorWcenFilSim');
coorWcenFilSim=permute(coorWcenFilSim,[3,2,1]);

ts=linspace(0,size(yLoCut,3)/fF,size(yLoCut,3));

%% ��ʾĿ������
psWcen=zeros(length(coorWcenFilSim),3);
for i=1:length(coorWcenFilSim)
    psWcen(i,:) = getPsWcen(coorWcenFilSim(i,:),xsB,ysB,psWl);
end


hCoor=figure('name','��ʾĿ������');
subplot(1,2,1);
plot(ts,coorWcenFilSim(:,1),ts,psWcen(:,1));
legend('xsCoorWcenFilSim','xsPsWcen');
title('Ŀ��x����');
xlabel('t(s)');
ylabel('x(m)');

subplot(1,2,2);
plot(ts,coorWcenFilSim(:,2),ts,psWcen(:,2));
legend('ysCoorWcenFilSim','ysPsWcen');
title('ͼ��ӳ��ͼ�����ת������Ŀ��y����');
xlabel('t(s)');
ylabel('y(m)');

pause(0.2);


%% ѯ�ʽ�ȡ����
if ~exist('iTVal','var')
    tMi=input('������ʼʱ��(s)��');
    tMa=input('������ֹʱ��(s)��');
    if tMi>=tMa
        error('��ʼʱ�����С����ֹʱ��');
    end
    iTVal=ts>tMi & ts<tMa;
    save(filename,'iTVal','-append');
end