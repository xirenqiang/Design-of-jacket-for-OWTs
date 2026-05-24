function checkbarnumber(Numberofbar,Leg_index_Perfloor,Brace_index_Perfloor)
% �ú��������ж�Numberofbar�Ƿ����Leg_index_Perfloor��Brace_index_Perfloor������������ĸ˼�������
% ���������
% - Numberofbar���ṹ�ܸ˼�������
% - Leg_index_Perfloor����ά���飬���ܼܸ���leg��ţ��б�Ϊ���ܼܲ������б�Ϊ���˼��ֲ���ţ�
% - Brace_index_Perfloor����ά���飬���ܼܸ���leg��ţ��б�Ϊ���ܼܲ������б�Ϊ���˼��ֲ���ţ�
% ��������
global debug;
[rows_leg, cols_leg] = size(Leg_index_Perfloor);                            % ��ȡLeg_index_Perfloor���������������
[rows_brace, cols_brace] = size(Brace_index_Perfloor);                      % ��ȡBrace_index_Perfloor���������������
if debug==1
    if Numberofbar<0
        error('Numberofbar0checkbarnumberNumberofbar');
    end
    if rows_leg<0
        error('Leg_index_Perfloorrows_leg0checkbarnumberLeg_index_Perfloor');
    end
    if cols_leg<0
        error('Leg_index_Perfloorcols_leg0checkbarnumberLeg_index_Perfloor');
    end
    if rows_brace<0
        error('Brace_index_Perfloorrows_brace0checkbarnumberBrace_index_Perfloor');
    end
    if cols_brace<0
        error('Brace_index_Perfloorcols_brace0checkbarnumberBrace_index_Perfloor');
    end
end
% ���㵼�ܼ�leg�˼�����barnumber_leg��
barnumber_leg=rows_leg*cols_leg;
% ���㵼�ܼ�brace�˼�����barnumber_brace��
barnumber_brace=rows_brace*cols_brace;
% ���㵼�ܼ��ܸ˼�����barnumber_from_2_matrices��
barnumber_from_2_matrices=barnumber_leg+barnumber_brace;
% �ж����ַ����õ��ĵ��ܼ��ܸ˼���Numberofbar��barnumber_from_2_matrices�Ƿ���ȣ�
if debug==1
    if Numberofbar~=barnumber_from_2_matrices
        error('Num_bar');
    end
end
end
