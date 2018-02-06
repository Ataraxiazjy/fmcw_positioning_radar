%% ͬ��б���ź���ʼʱ�亯������������б���ź���ʼʱ���
% tFramp: ��һ��б�¿�ʼʱ�䣬��ȷ������ʱ��֮�£��Ե�һ��������Ϊ�ο�ʱ��0
% ysTr: һ֡triger�ź�
% fS: ������
% fTr: �����ź�Ƶ��
% tPul: ����/���ؿ��
% nPul: ����/��������
% trEdge: �����أ�1������ 0�½���
% trThres: ������ƽ
function tFramp=firstRampTime(ysTr, fS, fTr, tPul, nPul, trEdge, trThres)
%% ׼������
lRamp=fS/fTr;%length ramp
lPul=fS*tPul;%length pulse

if(mod(size(ysTr,2),lRamp)~=0)
    error('The length of frame is not integer multiple of the length of ramp .');
end

%% ������һ������б��ͬ���ź�
%��һ������б��ͬ���źŴ�����λ��1:lRamp,Ϊ���ݴ�����Χ��1:lRamp+lPul*nPul
isFramp=1:lRamp+lPul*nPul;%indexs first ramp
ysTrFf=ysTr(isFramp);%ys triger first ramp
iTrF=[];
if trEdge==0
    iTrF=find(ysTrFf(2:end)<trThres & ysTrFf(1:end-1)>trThres)+1;%index triger first
else
    iTrF=find(ysTrFf(2:end)>trThres & ysTrFf(1:end-1)<trThres)+1;
end
iTrF([false iTrF(2:end)-iTrF(1:end-1)<=lPul*nPul])=[];%Ҫ������ͱ�����ʱ��С��б�����ڵ�һ��
if isempty(iTrF)
    tFramp=nan;
    return
else
    iTrF=iTrF(end);%ѡȡ���һ�������ź�
end

%% ���Բ�ֵ���������صľ�ȷʱ��
tFramp=interp1([ysTr(iTrF-1),ysTr(iTrF)],([iTrF-1,iTrF]-1)/fS,trThres);
end
