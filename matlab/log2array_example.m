%% ����
close all;
%% �������ݡ�����
load '../data/dataSim_200kHz_7500pf_1t3r_static.mat'

y=log2array(logsout,'dataSim');

%% ��ȡ��·�ź�
iSam=3;
yLo=real(y);
yTr=imag(y);
t=0:1/fS:1/fS*(size(yLo,2)-1);
figure;
plot(t,yLo(iSam,:));
hold on
plot(t,yTr(iSam,:));

%% �����ź�֡
figure;
subplot(1,2,1);
imshow(yLo,[]);
subplot(1,2,2);
imshow(yTr,[]);
