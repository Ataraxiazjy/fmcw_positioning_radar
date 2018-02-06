%% ���в�������
doJoggleTest_firstRampTime=1;
doShiftTest_firstRampTime=0;

%% ����
close all;

%% �������ݡ�����
load '../data/dataSim_200kHz_400rps_5rpf_1t3r_static.mat'

ys=log2array(logsout,'dataSim');
lRamp=fS/fTr;%length ramp
lF=size(ys,2);


%% ��ȡ��·�ź�
ysLo=real(ys);%ys local
ysTr=imag(ys);%ys triger

%% ��ʾʾ��֡���������������firstRampTime����
% ��ȡʾ��֡
iSam=3;
ts=0:1/fS:1/fS*(size(ysLo,2)-1);
ysLoSam=ysLo(iSam,:);
ysTrSam=ysTr(iSam,:);
% ���㴥����ƽ
trThres=(max(ysTrSam)+min(ysTrSam))/2;%triger threshold
trThres=(mean(ysTrSam(ysTrSam>trThres))+mean(ysTrSam(ysTrSam<trThres)))/2;
% �����ź�
figure;
plot(ts,ysLoSam);
hold on
plot(ts,ysTrSam);
plot([ts(1),ts(end)],[trThres,trThres]);
% ����firstRampTime����
tFramp=firstRampTime(ysTrSam,fS,fTr,tPul,nPul,0,trThres);%time Ramp
plot(tFramp,trThres,'o');
title(['��' num2str(iSam) '֡��ͬ���źź���Ƶ�ź�']);
xlabel('t(s)');
legend('��Ƶ�ź�','ͬ���ź�','������ƽ','��һ��ͬ���źŴ�����');
hold off

%% ����firstRampTime��Ч�ʺͶ���
if doJoggleTest_firstRampTime
    tsFramp=zeros(size(ys,1),1);
    for iF=1:size(ys,1)
        tsFramp(iF)=firstRampTime(ysTr(iF,:),fS,fTr,tPul,3,0,trThres);%time Ramp
    end
    figure;
    % ��������£������ź�ʱ��Ӧ�����Ա仯�������ڴ����صķ����ԡ������㲻���ܼ����Կ��ܴ�����λ����
    % ͨ�����ƴ����ź�ʱ�������Ķ��������Լ򵥵ع���firstRampTime�������ܴ�������λ����
    tsDeltaInc=detrend(tsFramp(2:end)-tsFramp(1:end-1));%times delta increment
    plot(tsDeltaInc);
    title('firstRampTime�������ܴ�������λ����');
    ylabel('t(s)');
    xlabel('֡');
    disp(['�����ź�ʱ�������Ķ���������Ϊ' num2str(std(tsDeltaInc))]);
end

%% ͨ��ѭ��λ������֡ģ���˳�ʱ������ʱ���ܴ����ı߽�����
if doShiftTest_firstRampTime
    hV=figure;
    tsFramp=zeros(size(ys,2),1);
    for iShift=1:lRamp*nRx
        ysTrShift=circshift(ysTrSam,iShift);
        tsFramp(iShift)=firstRampTime(ysTrShift,fS,fTr,tPul,3,0,trThres);%time Ramp
        %���ƴ����źźʹ�����
        figure(hV);
        plot(ts,ysTrShift);
        hold on;
        plot(tsFramp(iShift),trThres,'o');
        hold off
        pause(0.001);
    end
end

