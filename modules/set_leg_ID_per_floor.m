function [legindex_per_floor]=set_leg_ID_per_floor(Num_of_floor,Num_of_pile)
% �ú�������ȷ�����ܼܸ���leg��ţ�
% ���������
% - Num_of_floor�����ܼܲ�����
% - Num_of_pile����׮���ܼ�׮����
% ���������
% - legindex_per_floor����ά���飬���ܼܸ���leg��ţ��б�Ϊ���ܼܲ������б�Ϊ���˼��ֲ���ţ�
% ��������б�
global debug;
if debug==1
    if Num_of_floor<0
        error('Num_of_floor0set_leg_ID_per_floorNum_of_floor');
    end
    if Num_of_pile<0
        error('Num_of_pile0set_leg_ID_per_floorNum_of_pile');
    end
    if Num_of_pile ~= 4
        error('4');
    end
end
% ��������
legindex_per_floor=zeros(Num_of_floor,Num_of_pile);
for i=1:Num_of_floor		% �����б꣬���ܼܲ��
    for j=1:Num_of_pile		% �����б꣬���ܼ�׮��
        legindex_per_floor(i,j)=(i-1)*Num_of_pile+j;
    end
end
end
