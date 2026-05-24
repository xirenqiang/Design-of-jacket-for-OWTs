function Diameter_thickness_update(index_floor,legindex_per_floor, braceindex_per_floor, D_leg, D_brace, t_leg, t_brace)
% �ú������ڳ�ʼ�����ܼܸ��˼�ֱ�����ں��뺯��Diameter_thickness_ini����Ҫ�����ǣ��ô��������index_floor�㼰���²�˼��Ľ���ߴ磻
% ���������
% - index_floor����ǰ��ı�ţ�
% - legindex_per_floor����ά���飬���ܼܸ���leg��ţ��б�Ϊ���ܼܲ������б�Ϊ���˼��ֲ���ţ�
% - braceindex_per_floor����ά���飬���ܼܸ���leg��ţ��б�Ϊ���ܼܲ������б�Ϊ���˼��ֲ���ţ�
% - D_leg����ǰ��leg������ֱ����
% - D_brace����ǰ��brace������ֱ����
% - t_leg����ǰ��leg�����±ں�
% - t_brace����ǰ��brace�����±ں�
% ����������ú���ֱ�ӽ�ִ�н�����ݸ�ȫ�ֱ���Member���������������
global debug;
global Member;
if debug==1
    if index_floor<0
        error('D_leg0Diameter_thickness_updateindex_floor');
    end
    if D_leg<0
        error('D_leg0Diameter_thickness_updateD_leg');
    end
    if D_brace<0
        error('D_brace0Diameter_thickness_updateD_brace');
    end
    if t_leg<0
        error('t_leg0Diameter_thickness_updatet_leg');
    end
    if t_brace<0
        error('t_brace0Diameter_thickness_updatet_brace');
    end
end
% ��������
[rows_leg, cols_leg] = size(legindex_per_floor);                            % ��ȡlegindex_per_floor���������������
[rows_brace, cols_brace] = size(braceindex_per_floor);                      % ��ȡbraceindex_per_floor���������������
if debug==1
    if rows_leg<0
        error('rows_leg0Diameter_thickness_updatelegindex_per_floor');
    end
    if cols_leg<0
        error('cols_leg0Diameter_thickness_updatelegindex_per_floor');
    end
    if rows_brace<0
        error('rows_brace0Diameter_thickness_updatebraceindex_per_floor');
    end
    if cols_brace<0
        error('cols_brace0Diameter_thickness_updatebraceindex_per_floor');
    end
end
% ���µ�ǰ��(i)����ײ�˼�ֱ��Member.D�ͱں�Member.t��
for i=index_floor:rows_leg
    % ����i������leg����ߴ磬
    for j=1:cols_leg
        Member.D(legindex_per_floor(i,j))=D_leg;
        Member.t(legindex_per_floor(i,j))=t_leg;
    end
    % ����i������brace����ߴ磬
    for j=1:cols_brace
        Member.D(braceindex_per_floor(i,j))=D_brace;
        Member.t(braceindex_per_floor(i,j))=t_brace;
    end
end
end
