function plotJacketStructureEnhanced(Member)
    % 计算构件数量
    numMembers = numel(Member.X0);
    
    % 创建图形
    figure;
    hold on;
    grid on;
    axis equal;
    
    % 设置观察视角，同时尝试保持三维效果和y轴向上的感觉
    view(5,45); % 方位角为30度，仰角为35度，这个视角尝试平衡三维视觉效果与y轴向上的视觉效果
    
    % 绘制每一个构件
    colors = lines(numMembers); % 生成颜色
    for i = 1:numMembers
        % 提取起点和终点坐标
        x = [Member.X0(i), Member.Xt(i)];
        y = [Member.Y0(i), Member.Yt(i)];
        z = [Member.Z0(i), Member.Zt(i)];
        
        % 绘制构件
        plot3(x, y, z, 'LineWidth', 2, 'Color', colors(i,:));
        
        % 标记起点和终点
        scatter3(x, y, z, 36, 'filled', 'MarkerEdgeColor', colors(i,:), 'MarkerFaceColor', colors(i,:));
    end
    
    % 添加光照效果
    light('Position', [1 1 1], 'Style', 'infinite'); % 调整光源位置以增强三维效果
    lighting gouraud;
    material shiny;
    
    % 设置坐标轴标签和标题
    xlabel('X');
    ylabel('Y'); % 保持原有标签，因为没有交换y轴和z轴的数据
    zlabel('Z');
    title('Jacket Structure Visualization with Enhanced 3D Effect');
    
    hold off;
end
