%% ����
close all;
%% �������ݡ�����
load '../data/dataSim_200kHz_7500pf_1t3r_static.mat'

ys=log2array(logsout,'dataSim');

%% ��ȡ��·�ź�
iSam=3;
ysLo=real(ys);
ysTr=imag(ys);
ts=0:1/fS:1/fS*(size(ysLo,2)-1);
figure;
plot(ts,ysLo(iSam,:));
hold on
plot(ts,ysTr(iSam,:));
hold off

%% �����ź�֡
figure;
subplot(1,2,1);
imshow(ysLo,[]);
subplot(1,2,2);
imshow(ysTr,[]);
