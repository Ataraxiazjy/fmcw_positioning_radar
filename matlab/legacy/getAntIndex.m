%% �жϴ���ʱ���Ӧͬ���źŵ����߱��
% iAnt: ���߱��
% ysTr: һ֡triger�ź�
% tRamp: б�¿�ʼʱ�䣬�Ե�һ��������Ϊ�ο�ʱ��0
% fS: ������
% tPul: ����/���ؿ��
% trThres: ������ƽ
% antBits: ���߱��
function iAnt=getAntNum(ysTr, tRamp, fS, tPul, trThres, antBits)
if isnan(tRamp)
    iAnt=nan;
    return
end
%% ׼������
lPul=fS*tPul;%length pulse

%% ��ȡ���߱�ŵı��ص�ƽ
iBit1=ceil((tRamp+1.5*tPul)*fS)+1;
isBits=linspace(iBit1,iBit1+lPul*(size(antBits,2)-1),size(antBits,2));

ysBits=ysTr(isBits);
isAnt=find(all(~xor(antBits,repmat((ysBits>trThres),size(antBits,1),1)),2),1);
if isempty(isAnt)
    iAnt=nan;
    return
end
iAnt=isAnt(1);%Ϊsimulink����iAnt��С�ṩ����

end
