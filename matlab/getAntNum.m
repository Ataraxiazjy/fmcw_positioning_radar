%% �жϴ���ʱ���Ӧͬ���źŵ����߱��
% nAnt: ���߱��
% ysTr: һ֡triger�ź�
% tRamp: б�¿�ʼʱ�䣬�Ե�һ��������Ϊ�ο�ʱ��0
% fS: ������
% tPul: ����/���ؿ��
% trThres: ������ƽ
% antBits: ���߱��
function nAnt=getAntNum(ysTr, tRamp, fS, tPul, trThres, antBits)
%% ׼������
lPul=fS*tPul;%length pulse

%% ��ȡ���߱�ŵı��ص�ƽ
iBit1=ceil((tRamp+1.5*tPul)*fS)+1;
isBits=iBit1:lPul:iBit1+lPul*(size(antBits,2)-1);

ysBits=ysTr(isBits);
nAnt=find(all(~xor(antBits,(ysBits>trThres)),2),1);

end
