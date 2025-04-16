% Load Excel files
neutral = readtable('n.xlsx');
flexion = readtable('f.xlsx');

% === Custom helper to compute local frame ===
function [R, origin] = computeLocalFrame(RC, LC, SP)
    origin = (RC + LC) / 2;

    % Z-axis: RC to LC (medial to lateral)
    z = (RC - LC); z = z / norm(z);

    % X-axis: SP to anterior (SP to midpoint)
    x = (origin - SP); x = x / norm(x);

    % Y-axis: upward (Z × X)
    y = cross(z, x); y = y / norm(y);

    R = [x' y' z'];
end

% === Vertebrae to process ===
levels = {'L4', 'L5', 'S1'};
colors = {'r', 'g', 'b'}; % X, Y, Z
axisLabels = 'XYZ';
scale = 20;

% === Set up 3D plot ===
figure;
hold on;
axis equal;
grid on;
xlabel('X'); ylabel('Y'); zlabel('Z');
title('L4, L5, S1 Local Reference Frames: Neutral vs Flexion');
view(3);

for v = 1:length(levels)
    vertebra = levels{v};

    % Extract rows
    row_N = neutral(strcmp(neutral.Vertebre, vertebra), :);
    row_F = flexion(strcmp(flexion.Vertebre, vertebra), :);

    % Marker positions (neutral)
    RC_N = table2array(row_N(1, 2:4));
    LC_N = table2array(row_N(1, 5:7));
    SP_N = table2array(row_N(1, 8:10));
    [R_N, O_N] = computeLocalFrame(RC_N, LC_N, SP_N);

    % Marker positions (flexion)
    RC_F = table2array(row_F(1, 2:4));
    LC_F = table2array(row_F(1, 5:7));
    SP_F = table2array(row_F(1, 8:10));
    [R_F, O_F] = computeLocalFrame(RC_F, LC_F, SP_F);

    % === Plot reference frame: NEUTRAL ===
    for i = 1:3
        quiver3(O_N(1), O_N(2), O_N(3), ...
                R_N(1,i)*scale, R_N(2,i)*scale, R_N(3,i)*scale, ...
                'Color', colors{i}, 'LineWidth', 2, ...
                'DisplayName', [vertebra ' Neutral ' axisLabels(i)]);
    end
    scatter3(O_N(1), O_N(2), O_N(3), 60, 'b', 'filled', 'DisplayName', [vertebra ' Origin Neutral']);

    % === Plot reference frame: FLEXION ===
    for i = 1:3
        quiver3(O_F(1), O_F(2), O_F(3), ...
                R_F(1,i)*scale, R_F(2,i)*scale, R_F(3,i)*scale, ...
                'Color', colors{i}, 'LineWidth', 2, 'LineStyle', '--', ...
                'DisplayName', [vertebra ' Flexion ' axisLabels(i)]);
    end
    scatter3(O_F(1), O_F(2), O_F(3), 60, 'r', 'filled', 'DisplayName', [vertebra ' Origin Flexion']);

    % === Plot markers and labels: NEUTRAL ===
    scatter3(RC_N(1), RC_N(2), RC_N(3), 30, 'k', 'filled');
    text(RC_N(1), RC_N(2), RC_N(3), [vertebra ' RC_N'], 'FontSize', 9, 'Color', 'k');
    scatter3(LC_N(1), LC_N(2), LC_N(3), 30, 'k', 'filled');
    text(LC_N(1), LC_N(2), LC_N(3), [vertebra ' LC_N'], 'FontSize', 9, 'Color', 'k');
    scatter3(SP_N(1), SP_N(2), SP_N(3), 30, 'k', 'filled');
    text(SP_N(1), SP_N(2), SP_N(3), [vertebra ' SP_N'], 'FontSize', 9, 'Color', 'k');

    % === Plot markers and labels: FLEXION ===
    scatter3(RC_F(1), RC_F(2), RC_F(3), 30, 'm', 'filled');
    text(RC_F(1), RC_F(2), RC_F(3), [vertebra ' RC_F'], 'FontSize', 9, 'Color', 'm');
    scatter3(LC_F(1), LC_F(2), LC_F(3), 30, 'm', 'filled');
    text(LC_F(1), LC_F(2), LC_F(3), [vertebra ' LC_F'], 'FontSize', 9, 'Color', 'm');
    scatter3(SP_F(1), SP_F(2), SP_F(3), 30, 'm', 'filled');
    text(SP_F(1), SP_F(2), SP_F(3), [vertebra ' SP_F'], 'FontSize', 9, 'Color', 'm');
end

legend show;
