%% ѭ����λ��ͨ�����Բ�ֵʵ��С��λ������λ
% vOut: �������
% vIn: ��������
% dis: ������λ����
function vOut=interpShift(vIn, dis)
    isZeroBased=0:length(vIn)-1;
    if dis>=0
        iShift=floor(dis);
        iAdd=dis-iShift;
    else
        iShift=ceil(dis);
        iAdd=iShift-dis;
    end
    
    isShifted=circshift(isZeroBased,iShift);
    iInterp=isShifted+iAdd;
    vOut=interp1(isZeroBased,vIn,iInterp,'linear','extrap');
end