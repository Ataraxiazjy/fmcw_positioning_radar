%% ���в�������
doJoggleTest_firstRampTime=1;
doShiftTest_firstRampTime=0;

%% ����
close all;

%% �������ݡ�����
load '../data/dataSim_200kHz_400rps_5rpf_1t3r_static.mat'

nRx=size(antBits,1);
ys=log2array(logsout,'dataSim');
lRamp=fS/fTr;%length ramp
lF=size(ys,2);
nCyclePF=lF/lRamp/nRx;

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
figure('name','ʾ��֡�����ؼ��');
plot(ts,ysLoSam);
hold on
plot(ts,ysTrSam);
plot([ts(1),ts(end)],[trThres,trThres]);

% ����firstRampTime����
tFrampSam=firstRampTime(ysTrSam,fS,fTr,tPul,nPul,0,trThres);%time Ramp
plot(tFrampSam,trThres,'o');

% ���鴥����index��Ϊ����circshift׼��
iTrF=ceil(tFrampSam*fS)+1;
plot(ts(iTrF),ysTrSam(iTrF),'o');

% �����������ͼ��
title(['��' num2str(iSam) '֡��ͬ���źź���Ƶ�ź�']);
xlabel('t(s)');
legend('��Ƶ�ź�','ͬ���ź�','������ƽ','��һ��ͬ���źŴ�����','���Ƶõ��Ĵ�����index');

hold off

%% ����firstRampTime��Ч�ʺͶ���
if doJoggleTest_firstRampTime
    tsFramp=zeros(size(ys,1),1);
    for iF=1:size(ys,1)
        tsFramp(iF)=firstRampTime(ysTr(iF,:),fS,fTr,tPul,3,0,trThres);%time Ramp
    end
    figure('name','firstRampTime�Ķ���');
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
    hV=figure('name','��ʱ�����в���firstRampTime');
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
        pause(0.01);
    end
end

%% ��ysTrSam����getAntIndex����
iAnt=getAntIndex(ysTrSam, tFrampSam, fS, tPul, trThres, antBits);
isAnt=zeros(1,lF/lRamp-1);
for iSwitch=1:lF/lRamp-1
    isAnt(iSwitch)=getAntIndex(ysTrSam, tFrampSam+iSwitch/fTr, fS, tPul, trThres, antBits);
end
disp(['����֡�м�⵽�����߱���У�' num2str(isAnt)]);

%% ��ysTrSam����interpShift����������Ƶ�źŽ���ѭ����λ
figure('name','interpShift��λ����');

subplot(1,2,1);
ysTrSamShifted=interpShift(ysTrSam,calcShiftDis(iAnt,tFrampSam,lRamp,fS,nRx));%����һλ���ù�����Ƶ���λ
plot(ts,ysTrSamShifted,ts,ysTrSam);
hold on;
plot(tFrampSam,trThres,'o');
plot(ts(1),ysTrSamShifted(1),'o');
title('��ͬ���źŽ���ѭ����λ');
xlabel('t(s)');
legend('��λǰ��ͬ���ź�','��λ���ͬ���ź�','��λǰ�Ĵ�����','��λ��Ĵ�����');
hold off;

subplot(1,2,2);
ysLoSamShifted=interpShift(ysLoSam,calcShiftDis(iAnt,tFrampSam,lRamp,fS,nRx));
plot(ts,ysLoSamShifted,ts,ysLoSam);
title('����Ƶ�źŽ���ѭ����λ');
xlabel('t(s)');
legend('��λǰ����Ƶ�ź�','��λ�����Ƶ�ź�');

%% reshape��λ�����Ƶ�ź�ysLoSamShifted
ysLoRxi=reshape(ysLoSamShifted,lRamp*nRx,nCyclePF);
figure('name','б�·ָ����');
plot(repmat(ts(1:lRamp*nRx)',1,5),ysLoRxi);
legend([repmat('��',nCyclePF,1),num2str((1:nCyclePF)'),repmat('������',nCyclePF,1)]);
title('����֡�еĸ�����');
xlabel('t(s)');

