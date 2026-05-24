function [D, t]=Diameter_thickness_ini(legindex_per_floor, braceindex_per_floor, D_leg, D_brace, t_leg, t_brace)
% �ú������ڳ�ʼ�����ܼܸ��˼�ֱ�����ں񣻸ô�����µ��ܼ����и˼��Ľ���ߴ磻
% ���������
% - legindex_per_floor����ά���飬���ܼܸ���leg��ţ��б�Ϊ���ܼܲ������б�Ϊ���˼��ֲ���ţ�
% - braceindex_per_floor����ά���飬���ܼܸ���leg��ţ��б�Ϊ���ܼܲ������б�Ϊ���˼��ֲ���ţ�
% - D_leg�����ܼ�leg��ʼֱ����
% - D_brace�����ܼ�brace��ʼֱ����
% - t_leg�����ܼ�leg��ʼ�ں�
% - t_brace�����ܼ�brace��ʼ�ں�
% ���������
% - D�����ܼܸ��˼�ֱ����
% - t�����ܼܸ��˼��ں�
% �������������
global debug;
if debug==1
    if D_leg<0
        error('D_leg0Diameter_thickness_iniD_leg');
    end
    if D_brace<0
        error('D_brace0Diameter_thickness_iniD_brace');
    end
    if t_leg<0
        error('t_leg0Diameter_thickness_init_leg');
    end
    if t_brace<0
        error('t_brace0Diameter_thickness_init_brace');
    end
end
% ��������
[rows_leg, cols_leg] = size(legindex_per_floor);                            % ��ȡlegindex_per_floor���������������
[rows_brace, cols_brace] = size(braceindex_per_floor);                      % ��ȡbraceindex_per_floor���������������
if debug==1
    if rows_leg<0
        error('rows_leg0Diameter_thickness_inilegindex_per_floor');
    end
    if cols_leg<0
        error('cols_leg0Diameter_thickness_inilegindex_per_floor');
    end
    if rows_brace<0
        error('rows_brace0Diameter_thickness_inibraceindex_per_floor');
    end
    if cols_brace<0
        error('cols_brace0Diameter_thickness_inibraceindex_per_floor');
    end
end
% ��ʼ���������D��t��
Number_of_member=rows_leg*cols_leg+rows_brace*cols_brace;
%D=zeros(Number_of_member,1);
%t=zeros(Number_of_member,1);
D=zeros(1,Number_of_member);
t=zeros(1,Number_of_member);
% Ϊ����leg����ߴ縳ֵ��
for i=1:rows_leg
    for j=1:cols_leg
        D(legindex_per_floor(i,j))=D_leg;
        t(legindex_per_floor(i,j))=t_leg;
    end
end
% Ϊ����brace����ߴ縳ֵ��
for i=1:rows_brace
    for j=1:cols_brace
        D(braceindex_per_floor(i,j))=D_brace;
        t(braceindex_per_floor(i,j))=t_brace;
    end
end
end
