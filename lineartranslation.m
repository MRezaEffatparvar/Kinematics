% Load data
neutral = readtable('n.xlsx');
flexion = readtable('f.xlsx');

% === Custom local frame function ===
function [R, origin] = computeLocalFrame(RC, LC, SP)
    origin = (RC + LC) / 2;
    z = (RC - LC); z = z / norm(z);
    x = (origin - SP); x = x / norm(x);
    y = cross(z, x); y = y / norm(y);
    R = [x' y' z'];
end

% === Helper function to extract frame data ===
function [R, O] = getFrame(table, vertebra)
    row = table(strcmp(table.Vertebre, vertebra), :);
    RC = table2array(row(1, 2:4));
    LC = table2array(row(1, 5:7));
    SP = table2array(row(1, 8:10));
    [R, O] = computeLocalFrame(RC, LC, SP);
end

% === L4 in L5 frame ===
[R_L4_N, O_L4_N] = getFrame(neutral, 'L4');
[R_L4_F, O_L4_F] = getFrame(flexion, 'L4');
[R_L5_N, O_L5_N] = getFrame(neutral, 'L5');
[R_L5_F, O_L5_F] = getFrame(flexion, 'L5');

% Express L4 center in L5 local frame
L4_in_L5_N = R_L5_N' * (O_L4_N - O_L5_N)'; L4_in_L5_N = L4_in_L5_N';
L4_in_L5_F = R_L5_F' * (O_L4_F - O_L5_F)'; L4_in_L5_F = L4_in_L5_F';

% Compute difference
delta_L4_L5 = L4_in_L5_F - L4_in_L5_N;

% Rename for anatomical directions
AP_L4_L5 = delta_L4_L5(1);  % X
SI_L4_L5 = delta_L4_L5(2);  % Y
ML_L4_L5 = delta_L4_L5(3);  % Z

% === L5 in S1 frame ===
[R_L5_N, O_L5_N] = getFrame(neutral, 'L5');
[R_L5_F, O_L5_F] = getFrame(flexion, 'L5');
[R_S_N, O_S_N]   = getFrame(neutral, 'S1');
[R_S_F, O_S_F]   = getFrame(flexion, 'S1');

L5_in_S_N = R_S_N' * (O_L5_N - O_S_N)'; L5_in_S_N = L5_in_S_N';
L5_in_S_F = R_S_F' * (O_L5_F - O_S_F)'; L5_in_S_F = L5_in_S_F';

delta_L5_S = L5_in_S_F - L5_in_S_N;

% Rename for anatomical directions
AP_L5_S = delta_L5_S(1);
SI_L5_S = delta_L5_S(2);
ML_L5_S = delta_L5_S(3);

% === Display results ===
fprintf('\n=== Intervertebral Displacement (L4 in L5) ===\n');
fprintf('AP (X): %.2f mm\n', AP_L4_L5);
fprintf('SI (Y): %.2f mm\n', SI_L4_L5);
fprintf('ML (Z): %.2f mm\n', ML_L4_L5);

fprintf('\n=== Intervertebral Displacement (L5 in S1) ===\n');
fprintf('AP (X): %.2f mm\n', AP_L5_S);
fprintf('SI (Y): %.2f mm\n', SI_L5_S);
fprintf('ML (Z): %.2f mm\n', ML_L5_S);
