%% ����rfcapture���ĵ�Ӳ�㹫ʽ����ָ�������ϵĹ��ʴ�С

% fTsrampRTZ: Ӳ�㹫ʽ���м�ֵf(n,m,zs,ts,tsRamp)����tsΪ��ʱ��,tsRampΪ��ʱ�䣩

% pointCoor: ָ�����꣬n��3��
% rxCoor: ������������
% txCoor: ������������
% nRx: ������������
% nTx: ������������
% dCa: Ӧ��ȥ�Ķ����������¾���
% tsRamp: һ��б���ڵ�ʱ������
% fBw: ɨƵ����
% fRamp: б��Ƶ��
% dLambda: ����
% useGPU: �Ƿ�ʹ��GPU

function fTsrampRTZ=rfcaptureCo2F(pointCoor,rxCoor,txCoor,dCa,tsRamp,fBw,fRamp,dLambda,useGPU)
%% ����r(n,m)(X(ts),Y(ts),z)����tsΪ��ʱ�䣩
nRx=size(rxCoor,1);
nTx=size(txCoor,1);
nPair=nRx*nTx;
nP=size(pointCoor,1);
[isRx,isTx]=meshgrid(1:size(rxCoor,1),1:nTx);
isRx=permute(isRx,[2,1]);
isTx=permute(isTx,[2,1]);
isRxV=reshape(isRx,1,nPair);
isTxV=reshape(isTx,1,nPair);
rsCoRT=sqrt( ...
    (repmat(pointCoor(:,1),1,nPair)-repmat(rxCoor(isRxV,1)',nP,1)).^2 ...
    + (repmat(pointCoor(:,2),1,nPair)-repmat(rxCoor(isRxV,2)',nP,1)).^2 ...
    + (repmat(pointCoor(:,3),1,nPair)-repmat(rxCoor(isRxV,3)',nP,1)).^2 ...
    ) ...
    + sqrt( ...
    (repmat(pointCoor(:,1),1,nPair)-repmat(txCoor(isTxV,1)',nP,1)).^2 ...
    + (repmat(pointCoor(:,2),1,nPair)-repmat(txCoor(isTxV,2)',nP,1)).^2 ...
    + (repmat(pointCoor(:,3),1,nPair)-repmat(txCoor(isTxV,3)',nP,1)).^2 ...
    ) ...
    + dCa;
rsCoRT=reshape(rsCoRT,nP,nRx,nTx);

%% ����f(n,m,zs,ts,tsRamp)����tsΪ��ʱ��,tsRampΪ��ʱ�䣩
if useGPU
    rsCoRT=gpuArray(rsCoRT);
    tsRamp=gpuArray(tsRamp);
end
rsCoRTTsramp=permute(repmat(rsCoRT,1,1,1,length(tsRamp)),[4,2,3,1]);
% persistent  tsCoRTTsramp;
tsCoRTTsramp=repmat(tsRamp',1,size(rsCoRTTsramp,2),size(rsCoRTTsramp,3),size(rsCoRTTsramp,4));
fTsrampRTZ=exp( ...
    1i*2*pi*fBw*fRamp.*rsCoRTTsramp/3e8 ...
    .*tsCoRTTsramp ...
    ) ...
    .*exp( ...
    1i*2*pi*rsCoRTTsramp/dLambda ...
    );
    
end