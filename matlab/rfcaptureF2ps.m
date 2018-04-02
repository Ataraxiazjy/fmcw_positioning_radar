%% ����rfcapture���ĵ�Ӳ�㹫ʽ����ָ�������ϵĹ��ʴ�С

% ps: ��Ӧ�㹦�ʣ�����

% fTsrampRTZ: Ӳ�㹫ʽ���м�ֵf(n,m,zs,ts,tsRamp)����tsΪ��ʱ��,tsRampΪ��ʱ�䣩
% yLoReshape: ��Ƶ�ź�, ��С[length(tsRamp),nRx,nTx]
% useGPU: �Ƿ�ʹ��GPU

function ps=rfcaptureF2ps(fTsrampRTZ,yLoReshape,useGPU)
if useGPU
    if ~isa(fTsrampRTZ,'gpuArray')
        fTsrampRTZ=gpuArray(fTsrampRTZ);
    end
    if ~isa(yLoReshape,'gpuArray')
        yLoReshape=gpuArray(yLoReshape);
    end
end
% ps=shiftdim( ...
%     sum( ...
%     reshape( ...
%     fTsrampRTZ.*repmat(yLoReshape,1,1,1,size(fTsrampRTZ,4)), ...
%     size(fTsrampRTZ,1)*size(fTsrampRTZ,2)*size(fTsrampRTZ,3),size(fTsrampRTZ,4) ...
%     ), ...
%     1) ...
%     );
ps=shiftdim(sum(sum(sum(fTsrampRTZ.*repmat(yLoReshape,1,1,1,size(fTsrampRTZ,4)),1),2),3));
end