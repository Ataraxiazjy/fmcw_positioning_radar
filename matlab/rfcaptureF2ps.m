%% ����rfcapture���ĵ�Ӳ�㹫ʽ����ָ�������ϵĹ��ʴ�С
% ps: ��Ӧ�㹦�ʣ�����
% fTsrampRTZ: Ӳ�㹫ʽ���м�ֵf(n,m,zs,ts,tsRamp)����tsΪ��ʱ��,tsRampΪ��ʱ�䣩
% yLoCut: ��Ƶ�ź�, ��С[lFrame,nRx,nTx]
function ps=rfcaptureF2ps(fTsrampRTZ,yLoReshape,useGPU)
if useGPU
    if ~isa(fTsrampRTZ,'gpuArray')
        fTsrampRTZ=gpuArray(fTsrampRTZ);
    end
    if ~isa(yLoReshape,'gpuArray')
        yLoReshape=gpuArray(yLoReshape);
    end
end
ps=shiftdim(sum(sum(sum(fTsrampRTZ.*repmat(yLoReshape,1,1,1,size(fTsrampRTZ,4)),1),2),3));
    
end