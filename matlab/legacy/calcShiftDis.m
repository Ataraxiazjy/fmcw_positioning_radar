%% ͨ��������š�ʱ��ƫ�Ƽ���ѭ����λλ����
% dis: λ����
% iAnt: ������ţ���1��ʼ
% tFramp: ��һ�������ź�ʱ��
% fS: ������
% nRx: ��������
function dis=calcShiftDis(iAnt,tFramp,lRamp,fS,nRx)
    dis=-((nRx+1-iAnt)*lRamp+(tFramp*fS));
end
