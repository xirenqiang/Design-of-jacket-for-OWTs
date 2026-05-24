function [braceindex_per_floor]=set_brace_ID_per_floor(Num_of_floor,Num_of_pile)
% �ú�������ȷ�����ܼܸ���leg��ţ�
% ���������
% - Num_of_floor�����ܼܲ�����
% - Num_of_pile����׮���ܼ�׮����
% ���������
% - braceindex_per_floor����ά���飬���ܼܸ���leg��ţ��б�Ϊ���ܼܲ������б�Ϊ���˼��ֲ���ţ�
% ��������б�
global debug;
if debug==1
    if Num_of_floor<0
        error('Num_of_floor0set_brace_ID_per_floorNum_of_floor');
    end
    if Num_of_pile<0
        error('Num_of_pile0set_brace_ID_per_floorNum_of_pile');
    end
    if Num_of_pile ~= 4
        error('4set_brace_ID_per_floorNum_of_floor');
    end
end
% ��������
brcnumPf=Num_of_pile*2;                                     %���ܼܸ���֧������
braceindex_per_floor=zeros(Num_of_floor,brcnumPf);
for i=1:Num_of_floor
    for j=1:brcnumPf
        braceindex_per_floor(i,j)=Num_of_floor*Num_of_pile+(i-1)*Num_of_pile*2+j;		% ������֫�˼���ţ����ϵ���
    end
end
end
