function dataStruct = readData(fileName)
    % 功能：读取配置文件并解析为结构体
    % 输入：fileName - 文件路径
    % 输出：dataStruct - 包含文件数据的结构体
    
    % 打开文件
    fileID = fopen(fileName, 'r');
    if fileID == -1
        error('无法打开文件: %s', fileName);
    end
    
    % 初始化结构体
    dataStruct = struct();
    
    % 跳过第一行（注释�?
    fgetl(fileID);
    
    % 按行读取文件内容
    while ~feof(fileID)
        line = strtrim(fgetl(fileID));
        
        % 跳过空行
        if isempty(line)
            continue;
        end
        
        % 使用正则表达式提取�?��?�变量名和注�?
        tokens = regexp(line, '^([\d\.\-eE]+)\s+(\w+)\s+#(.*)$', 'tokens');
        if ~isempty(tokens)
            % 提取值�?�变量名和注�?
            value = str2double(tokens{1}{1});
            name = tokens{1}{2};
            % 将�?�存储到结构体中
            dataStruct.(name) = value;
        else
            warning('未能解析行：%s', line);
        end
    end
    
    % 关闭文件
    fclose(fileID);
end