function DriveCodeJckDesign(inputFile)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main script: DriveCodeJckDesign.m (offshore wind jacket preliminary design)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
projRoot = fileparts(mfilename('fullpath'));
modelRoot = fullfile(fileparts(projRoot), 'Validations', 'model');
if exist(modelRoot, 'dir') ~= 7
    mkdir(modelRoot);
end
%% Load input file and initialize workspace
if nargin < 1 || isempty(inputFile)
    inputFile = strtrim(input('Enter input data file path (relative or absolute): ', 's'));
    if isempty(inputFile)
        error('DriveCodeJckDesign:InputFileRequired', 'Input file path is required.');
    end
end
fileName = resolve_input_path(inputFile, modelRoot);
dataStruct = readData(fileName);
cfg = build_design_config(dataStruct);
% Map scalar fields into global structs used downstream
global Hydro;
global Wave;
global Current;
%% Initialize globals %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Wind field
k_weibull = dataStruct.k_weibull;     % Weibull scale parameter
s_weibull = dataStruct.s_weibull;     % Weibull shape parameter
air_density = dataStruct.air_density; % Air density
Lk = dataStruct.Lk;                   % Integral length scale
I_ref = dataStruct.I_ref;             % Reference turbulence intensity at U_r = 11.4 m/s
Lambda = dataStruct.Lambda;           % Turbulence length scale parameter
U_ref = dataStruct.U_ref;             % Class I 10-min mean reference wind speed
% Material
steel_density = dataStruct.steel_density; % Steel density
E = dataStruct.E;                     % Young's modulus of tower material
% Turbine / RNA
U_r = dataStruct.U_r;                 % Mean wind speed at hub height
Ar = dataStruct.Ar;                   % Rotor swept area
n_min = dataStruct.n_min;             % Wind turbine minimum speed
n_max = dataStruct.n_max;             % Wind turbine maximum speed
M_rna = dataStruct.M_rna;             % Total mass of wind turbine engine compartment
% Tower
D_Tower_top = dataStruct.D_Tower_top; % Tower top diameter
D_Tower_bottom = dataStruct.D_Tower_bottom; % Tower bottom diameter
m_t = dataStruct.m_t;                 % Total mass of tower
Mtp = dataStruct.Mtp;                 % Conversion platform mass
h_Tower = dataStruct.h_Tower;         % Height of the tower
z_hub = dataStruct.z_hub;             % Hub height
% Jacket
av = dataStruct.av;                   % Inclination angle of the main limb of the jacket
Num_floor = dataStruct.Num_floor;     % Number of layers in the jacket
Num_pile = dataStruct.Num_pile;       % Number of piles (multi-pile jacket)
L_top = dataStruct.L_top;             % Platform width on the jacket
% Waves and current
water_depth = dataStruct.water_depth; % Water depth
Hs50 = dataStruct.Hs50;               % 50-year characteristic wave height
Hm50 = dataStruct.Hm50;               % 50-year extreme wave height
Hs2 = dataStruct.Hs2;                 % Hs2 for EOG sea state (placeholder 10 if not set)
Hydro.density = dataStruct.density;   % Sea water density
Hydro.cd = dataStruct.cd;             % Drag coefficient
Hydro.cm = dataStruct.cm;             % Inertia coefficient
Wave.S = dataStruct.S;                % Auxiliary wave metadata
Wave.beta_propagation = 0;            % Step 4: wave direction beta_2 (deg); default +X
Current.U_ss0 = dataStruct.U_ss0;     % Steady current speed
Current.U_ns0 = dataStruct.U_ns0;     % Non-steady current speed
Current.h_ref = dataStruct.h_ref;     % Reference height for current profile
% Soil / foundation
L_pile = dataStruct.L_pile;           % Pile length (see also leg OD prompts below)
wgh_soil = dataStruct.wgh_soil; 
fs_limit = dataStruct.fs_limit;
% Echo configuration
disp('Loaded configuration:');
disp(dataStruct);
fprintf('Directional load mode: %s (load_direction_mode=%d)\n', cfg.mode_name, cfg.load_direction_mode);
disp('Normalized design config (cfg):');
disp(cfg);
% Equivalent tower mass per unit length
m_tower_eq = m_t / h_Tower;  % kg/m
% Rough tower mass estimate
MTower = h_Tower * 3730;      % kg (empirical factor)
% Deck / platform elevation
Zplatform = water_depth + Hm50 + 0.2 * Hs50;   % m MSL
% Print Step-1 summary
fprintf('Tower mass per unit length (kg/m): %.2f\n', m_tower_eq);
fprintf('Tower mass estimate (kg): %.2f\n', MTower);
fprintf('Platform Z (m): %.2f\n', Zplatform);
fprintf('Step 1: input parameters -- finished.\n\n');
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 2: Jacket global geometry %%%%%%%%%%%%%%%%%%%%%%%%
% Set bay heights/widths from design practice.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Step 2: jacket global geometry.\n');
% Global Member: bar end coordinates, D, t
global Member;                                              % struct: X0,Y0,Z0, Xt,Yt,Zt, D, t, L, ...
% Derived jacket geometry
Zplatform=water_depth+Hm50+0.2*Hs50;                        % computed mudline-related elevation
h_Jacket=ceil(Zplatform);                                   % jacket height (ceiled)
L_bottom=L_top+sqrt(2)*h_Jacket*tand(av);                   % jacket width at mudline
m=(L_bottom/L_top)^(1/Num_floor);                           % geometric ratio m > 1
h1=h_Jacket*((m-1)/(m^Num_floor-1));                        % first bay height
l1=m*L_top;                                                 % first bay bottom width
sitah=atan(sqrt(1+0.5*(tand(av)^2))/(L_top/h1-(sqrt(2)/2)*tand(av)));		% brace angle (use tand for degrees)
% Bay layout from Num_floor
if Num_floor==3
    disp('      Mode: 3-bay jacket');
        [h2, h3, l2, l3]=height_wd_jac_floor_3f(Num_floor, h1, l1, m);
        if (l3-L_bottom>0.05)
        error('DriveCodeJckDesign:Geometry3Bay', 'Bottom width mismatch (3-bay). Check l3 vs L_bottom.');
        end
elseif Num_floor==4
    disp('      Mode: 4-bay jacket');
        [h2, h3, h4, l2, l3, l4]=height_wd_jac_floor_4f(Num_floor, h1, l1, m);
        if (l4-L_bottom>0.05)
        error('DriveCodeJckDesign:Geometry4Bay', 'Bottom width mismatch (4-bay). Check l4 vs L_bottom.');
        end
else
    disp('      Error: invalid Num_floor');
    error('DriveCodeJckDesign:NumFloor', 'Num_floor must be 3 or 4.');
end
% Total bar count
Num_bar=Bar_num_determine(Num_floor, Num_pile);                       % total structural bars
% Member end coordinates
if Num_floor==3
    disp('      Building 3-bay member node coordinates');
        Geometry_jacket_3f(Num_floor, L_bottom, L_top, h_Jacket, h1, m);
elseif Num_floor==4
    disp('      Building 4-bay member node coordinates');
        Geometry_jacket_4f(Num_floor, L_bottom, L_top, h_Jacket, h1, m);
else
    disp('Error: invalid Num_floor');
    error('DriveCodeJckDesign:NumFloor', 'Preliminary driver: 3- or 4-bay four-leg jacket only.');
end
fprintf('Step 2: jacket global geometry -- finished.\n\n');
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 3: Initial member cross-sections %%%%%%%%%%%%%%%%%
% Size members from target support-structure frequency.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Step 3: initial member cross-sections.\n');
% Frequency targets
f_3p_min=3*n_min*2*3.14/60*0.9/(2*3.14);
f_1p_max=n_max*2*3.14/60*1.1/(2*3.14);
f_fb_target=n_max*2*3.14/60*1.1/(2*3.14);                   % target support-structure frequency (Hz)
fprintf('      Target system frequency (Hz): %f\n',f_fb_target);
m_JT_eq=m_tower_eq;                                         % equivalent distributed mass (init = tower), kg/m
fai=h_Jacket/h_Tower;                                       % jacket / tower height ratio
Dt_Tower=(D_Tower_top+D_Tower_bottom)/2;                    % mean tower diameter
t_tower=(m_t/(steel_density*pi*h_Tower*Dt_Tower));          % equivalent tower wall thickness
h_total=h_Jacket+h_Tower;                                   % total support height (jacket + tower)
I_Tower_top=(pi*(D_Tower_top^3)*t_tower)/8;                 % tower top inertia (thin-wall approx.)
q=D_Tower_bottom/D_Tower_top;                               % tower diameter ratio
fq=((2*q^2*(q-1)^3)/(q^2*(2*log(q)-3)+4*q-1))/3;
EI_tower=E*I_Tower_top*fq;                                  % tower bending stiffness
EI_tj_target=(((f_fb_target*2*pi)^2)*((0.243*m_JT_eq*h_total+M_rna)*(h_total)^3))/3; % target combined stiffness
kai=(1/(EI_tj_target/(((h_Jacket+h_Tower)/h_Tower)^3*EI_tower))-1)/((1+fai)^3-1); % tower/jacket stiffness ratio
EI_Jacket=EI_tower/kai;                                     % jacket bending stiffness (split)
m_BtoT=L_bottom/L_top;                                      % jacket bottom/top width ratio
fm1=m_BtoT*(m_BtoT-1)^3/(m_BtoT^2-2*m_BtoT*log(m_BtoT)-1)/3;
Itopj=EI_Jacket/(fm1*E);                                    % jacket equivalent stiffness scalar
% Initial leg/brace areas from frequency target
Aleg=Itopj/(L_top)^2;                                       % equivalent leg area
Abrace=0.2*Aleg;                                            % brace area fraction
D_leg_ini=4*Aleg/(3.14*(1-23^2/25^2));                      % initial leg OD (m)
t_leg_ini=D_leg_ini/25;
fprintf('      Initial leg OD D_leg_ini = %f, wall t_leg_ini = %f\n',D_leg_ini,t_leg_ini);
if usejava('desktop')
    prompt='      Enter initial jacket leg OD D_leg = ';
    D_leg=input(prompt);
    prompt='      Enter initial jacket leg wall thickness t_leg = ';
    t_leg=input(prompt);
else
    D_leg=D_leg_ini;
    t_leg=t_leg_ini;
    fprintf('      Non-interactive mode: using D_leg=%f, t_leg=%f\n', D_leg, t_leg);
end
D_brace_ini=0.4*D_leg_ini;
t_brace_ini=Abrace/(3.14*D_brace_ini);
fprintf('      Initial brace OD D_brace_ini = %f, wall t_brace_ini = %f\n',D_brace_ini,t_brace_ini);
if usejava('desktop')
    prompt='      Enter initial jacket brace OD D_brace = ';
    D_brace=input(prompt);
    prompt='      Enter initial jacket brace wall thickness t_brace = ';
    t_brace=input(prompt);
else
    D_brace=D_brace_ini;
    t_brace=t_brace_ini;
    fprintf('      Non-interactive mode: using D_brace=%f, t_brace=%f\n', D_brace, t_brace);
end
% Leg and brace ID maps per floor
LegidPfloor=set_leg_ID_per_floor(Num_floor, Num_pile);
BraceidPfloor=set_brace_ID_per_floor(Num_floor, Num_pile);
% Check bar count vs Num_bar
checkbarnumber(Num_bar, LegidPfloor, BraceidPfloor);
% Assign initial D, t to all members
[Member.D, Member.t]=Diameter_thickness_ini(LegidPfloor, BraceidPfloor, D_leg, D_brace, t_leg, t_brace);
fprintf('Step 3: initial member cross-sections -- finished.\n\n');
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 4: Extreme wind and wave setup %%%%%%%%%%%%%%%%%%%%%%
% Extreme environmental loads for jacket design.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Session log file
outputFile = fullfile(modelRoot, 'session_output.txt');
% Truncate log and start diary
fclose(fopen(outputFile, 'w'));  % truncate log
diary(outputFile);  % start diary
% Wind case 1: ETM
fprintf('Step 4: extreme wind loads and wave setup.\n');
Ct=3.5*(2*U_r+3.5)/U_r^2;                                   % thrust coefficient
f1p_max=n_max/60;                                           % 1P frequency (Hz)
c=2;                                                        % auxiliary constant
sigmau_etm=c*I_ref*(0.072*(U_r/c+3)*(U_r/c-4)+10);          % std dev
sigmau_etmfdayu1p=sigmau_etm*sqrt(1/(((6*Lk*f1p_max)/U_r+1)^(2/3))); % std dev above 1P
u_etm=2*sigmau_etmfdayu1p;                                  % ETM turbulence component
F_etm=air_density*Ar*Ct*(U_r+u_etm).^2/2;                    % ETM thrust
% M_etm: mudline moment (layer moments computed separately in loop)
% Wind case 2: EOG
D_rotor=sqrt(4*Ar/pi); 
sigmau_eog=I_ref*(0.75*U_r+5.6);
z_1=90;
% U_e50 and U_e1
U_e50=U_ref*(z_1/z_hub)^0.11;
U_e1=0.8*U_e50;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% u_eog (verify against IEC 61400-1 if needed)
u_eog=min(1.35*abs(U_e1-U_r),3.33*sigmau_eog/(1+0.1*D_rotor/Lambda));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
F_eog=air_density*Ar*Ct*(U_r+u_eog)^2/2;	% conservative gust formulation (differs from IEC wording)
% M_eog: mudline moment
% Wind case 3: EWM
Ct1=0.052;
F_ewm_6_1=air_density*Ar*Ct1*(U_r+U_e50)^2/2;
F_ewm_6_3=air_density*Ar*Ct1*(U_r+U_e1)^2/2;
fprintf('      Wind: ETM, EOG, EWM aerodynamic loads computed.\n');
fprintf('      Wave beta_propagation (deg): %g\n', Wave.beta_propagation);
% Wave hydrodynamics
fprintf('      Wave loads: 1-yr and 50-yr sea states.\n');
% Hs2 for ETM/EOG sea state
g=9.81;
Ts2=11.1*sqrt(Hs2/g);
N2=3600/(Ts2);
Hm2=Hs2*sqrt(log(N2)/2); 
Tm2=11.1*sqrt(Hm2/g); 
DAF2=1/(sqrt((1-1/(Tm2*f_fb_target)^2)^2+(2*0.05*1/(Tm2*f_fb_target)))); 
% 1-yr and 50-yr extreme wave heights
g=9.81;                                                     % gravity
Hs1=0.8*Hs50;                                               % 1-yr significant wave height
Ts1=11.1*sqrt(Hs1/g);                                       % 1-yr wave period
N1=10800/(Ts1);
Hm1=Hs1*sqrt(log(N1)/2);                                    % 1-yr extreme wave height
Tm1=11.1*sqrt(Hm1/g);                                       % 1-yr extreme wave period
Tm50=11.1*sqrt(Hm50/g);                                     % 50-yr extreme wave period
DAF1=1/(sqrt((1-1/(Tm1*f_fb_target)^2)^2+(2*0.05*1/(Tm1*f_fb_target))));                % DAF 1-yr
DAF50=1/(sqrt((1-1/(Tm50*f_fb_target)^2)^2+(2*0.05*1/(Tm50*f_fb_target))));             % DAF 50-yr
% Step 3: structure azimuth from cfg (psi_site in paper modes, pesai_legacy in legacy mode).
% Full directional beta_wind/beta_wave coupling is wired in Steps 4-5.
pesai = resolve_structure_azimuth(cfg);
if pesai>=90
    error('DriveCodeJckDesign:PesaiRange', 'Use jacket azimuth 0-45 deg (90 deg has a known bug).');
end
global Hydro;
global Wave;
global Current;
global Discrete;
global dL_ele_target;
dL_ele_target=3.0;
Coord_trans_bar_discrete(pesai, Num_bar);
Num_total_element=0;
for i=1:Num_bar                                             % accumulate hydrodynamic elements
        Num_total_element=Num_total_element+Discrete.Num_ele(i);
end
fprintf('      Total hydrodynamic elements: %d\n',Num_total_element);
fprintf('Step 4: extreme wind and wave loads -- finished.\n\n');
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 5: Member strength (ULS) %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Factored wind + wave loads per floor; resize D/t if needed.
% Step 8 mode split:
%   - legacy_pesai: scalar inline loop (regression only).
%   - auto_envelope / single_direction:
%       direction_scenarios -> run_step5_directional_floor -> uls_floor_envelope
% Brace demand formulas:
%   - legacy_pesai: Fb = H/cos(sitah)/cosd(pesai) (regression only).
%   - paper modes: FNb = Fsx/cos(sitah) via uls_member_demands (no pesai).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Step 5: member strength checks.\n');
step5Path = resolve_step5_uls_path(cfg);
useLegacyStep5 = strcmp(step5Path, 'legacy_pesai');
V4 = 0;
ulsFloorRecords = struct( ...
    'floor_id', {}, 'direction_case', {}, 'environment_case', {}, ...
    'beta_wind', {}, 'beta_wave', {}, 'controls', {}, ...
    'leg_ratio', {}, 'brace_ratio', {}, 'member_type', {}, ...
    'demand', {}, 'capacity', {}, 'member_id', {});
if useLegacyStep5
    fprintf('      Step 5 ULS path: legacy_pesai (scalar).\n');
    fprintf('      Brace formula: H/cos(sitah)/cosd(pesai) for regression.\n');
else
    fprintf('      Step 5 ULS path: directional envelope (%s).\n', cfg.mode_name);
    fprintf('      Brace formula: Eq. (52) Fsx/cos(sitah) via uls_member_demands.\n');
    directionalScenarios = direction_scenarios(cfg);
    fprintf('      Direction scenarios for envelope: %d paper case(s).\n', ...
        count_paper_direction_scenarios(directionalScenarios));
end
t0=0;
t1=100;
dt=0.1;
D_legs=[];
t_legs=[];
D_braces=[];
t_braces=[];
% Result buffers
F_2_all=zeros(Num_floor, 1);                                % ETM/EOG hydrodynamic base shear (max)
M_2_all=zeros(Num_floor, 1);
F_1y_all=zeros(Num_floor, 1);                               % 1-yr wave amplified shear
M_1y_all=zeros(Num_floor, 1);
F_50y_all=zeros(Num_floor, 1);                              % 50-yr wave amplified shear
M_50y_all=zeros(Num_floor, 1);
% Bar index list per floor (see get_bar_array_for_floor)
Y0_position=zeros(Num_floor,1);
Width=zeros(Num_floor,1);
for i = step5_floor_indices(Num_floor)
    fprintf('\nFloor %d -- member sizing pass\n',i);
                Num_bar_array = get_bar_array_for_floor(i, LegidPfloor, BraceidPfloor);                         % bar IDs on floor i
        if Num_floor==4
        fprintf('Floor %d: load reference elevation (4-bay)\n',i);
                                Y0_position(i)=get_center_hydro_load_for_floor_4f(h2, h3, h4, i);                              % reduction point for hydrodynamics
                Width(i)= get_width_of_floor_4f(i,l1,l2,l3,l4);
        elseif Num_floor==3
        fprintf('Floor %d: load reference elevation (3-bay)',i);
                Y0_position(i)=get_center_hydro_load_for_floor_3f(h2, h3, i);
                Width(i)= get_width_of_floor_3f(i,l1,l2,l3);
        else
        disp('      Error: invalid Num_floor');
        error('DriveCodeJckDesign:NumFloor', 'Num_floor must be 3 or 4.');
        end
    % Wind moments about hydrodynamic reference height
                M_etm=Moment_Jac_wind(F_etm,h_Tower,h_Jacket,Y0_position(i));                           % wind moment (ETM)
                M_eog=Moment_Jac_wind(F_eog,h_Tower,h_Jacket,Y0_position(i));                           % wind moment (EOG)
        M_ewm_6_1=Moment_Jac_wind(F_ewm_6_1,h_Tower,h_Jacket,Y0_position(i));
        M_ewm_6_3=Moment_Jac_wind(F_ewm_6_3,h_Tower,h_Jacket,Y0_position(i));

    if useLegacyStep5
    % ETM/EOG hydrodynamic time history
        Wave.T=Tm2;
        Wave.h=Hm2;
                Wave.k=wave_number(Wave.T, Wave.h);                     % wave number
        [Ftx_2, Fty_2, Ftz_2, Mtx_2, Mtz_2,t]=Hydro_load_timehistory(t0, t1, dt, Num_bar_array, Y0_position(i));
        if size(Ftx_2)~=size(t)
        error('DriveCodeJckDesign:HydroTHMismatch', 'Ftx_2 and t length differ. Check Hydro_load_timehistory.');
        end
        [Ftx_2_max, Fty_2_max, Ftz_2_max, Mtx_2_max, Mtz_2_max]=Hydro_load_max(Ftx_2, Fty_2, Ftz_2, Mtx_2, Mtz_2);
    % Store ETM/EOG maxima
        F_2_all(i)=Ftx_2_max;
        M_2_all(i)=Mtz_2_max;
    
    % 1-yr hydrodynamic time history
                Wave.T=Tm1;                                            % 1-yr wave period
                Wave.h=Hm1;                                            % 1-yr wave height
        Wave.k=wave_number(Wave.T,Wave.h); 
        [Ftx_1y, Fty_1y, Ftz_1y, Mtx_1y, Mtz_1y,t]=Hydro_load_timehistory(t0, t1, dt, Num_bar_array, Y0_position(i));
        if size(Ftx_1y)~=size(t)
        error('DriveCodeJckDesign:HydroTHMismatch', 'Ftx_1y and t length differ. Check Hydro_load_timehistory.');
        end
        [Ftx_1y_max, Fty_1y_max, Ftz_1y_max, Mtx_1y_max, Mtz_1y_max]=Hydro_load_max(Ftx_1y, Fty_1y, Ftz_1y, Mtx_1y, Mtz_1y);
    % Store 1-yr amplified
        F_1y_all(i)=DAF1*Ftx_1y_max;
        M_1y_all(i)=DAF1*Mtz_1y_max;
   
    % 50-yr hydrodynamic time history
                Wave.T=Tm50;                                            % 50-yr wave period
                Wave.h=Hm50;                                            % 50-yr wave height
                Wave.k=wave_number(Wave.T,Wave.h);                      % wave number
        [Ftx_50y, Fty_50y, Ftz_50y, Mtx_50y, Mtz_50y,t] = Hydro_load_timehistory(t0, t1, dt, Num_bar_array, Y0_position(i));
        if size(Ftx_50y)~=size(t)
        error('DriveCodeJckDesign:HydroTHMismatch', 'Ftx_50y and t length differ. Check Hydro_load_timehistory.');
        end
        [Ftx_50y_max, Fty_50y_max, Ftz_50y_max, Mtx_50y_max, Mtz_50y_max] = Hydro_load_max(Ftx_50y, Fty_50y, Ftz_50y, Mtx_50y, Mtz_50y);
     % Store 50-yr amplified
        F_50y_all(i)=DAF50*Ftx_50y_max;
        M_50y_all(i)=DAF50*Mtz_50y_max;
    fprintf('      1-yr and 50-yr wave load maxima computed.\n');
    end

    % Leg axial capacity
        leg_id_i_floor=LegidPfloor(i,1);
                L_leg=Member.L(leg_id_i_floor);                         % leg length
        D_leg=Member.D(leg_id_i_floor);
        t_leg=Member.t(leg_id_i_floor);
                k_leg=1.0;                                   % effective length factor (leg)
        A_leg=1/4*3.14*(D_leg^2-(D_leg-2*t_leg)^2);
        I_leg=1/64*3.14*(D_leg^4-(D_leg-2*t_leg)^4);
        ir_leg=sqrt(I_leg/A_leg);
	fprintf('Leg capacity check.\n');
				F_allowable_leg=sigma_allowable(k_leg, L_leg, ir_leg, A_leg);% leg allowable axial load
    % Brace axial capacity
        brace_id_i_floor=BraceidPfloor(i,1);
    
                L_brace=Member.L(brace_id_i_floor);              % brace length
    
        D_brace=Member.D(brace_id_i_floor);
        t_brace=Member.t(brace_id_i_floor);
                k_brace=0.8;                                            % effective length factor (brace)
        A_brace=1/4*3.14*(D_brace^2-(D_brace-2*t_brace)^2);
        I_brace=1/64*3.14*(D_brace^4-(D_brace-2*t_brace)^4);
        ir_brace=sqrt(I_brace/A_brace);
                F_allowable_brace=sigma_allowable(k_brace, L_brace, ir_brace, A_brace);% brace allowable axial load

    fprintf('L_brace = %f\n',L_brace);
    fprintf('A_brace = %f\n',A_brace);
    fprintf('k_brace*L_brace/ir_brace = %f\n',k_brace*L_brace/ir_brace);
    fprintf('ir_brace = %f\n',ir_brace);
    fprintf('12*pi^2*210000/(23*(k_brace*L_brace/ir_brace)^2) = %f\n',12*pi^2*210000/(23*(k_brace*L_brace/ir_brace)^2));
    fprintf('L_leg = %f\n',L_leg);
    fprintf('A_leg = %f\n',A_leg);
    fprintf('k_leg*L_leg/ir_leg = %f\n',k_leg*L_leg/ir_leg);
    fprintf('ir_leg = %f\n',ir_leg);
    fprintf('12*pi^2*210000/(23*(k_leg*L_leg/ir_leg)^2) = %f\n',12*pi^2*210000/(23*(k_leg*L_leg/ir_leg)^2));
    fprintf('Brace max axial capacity F_allowable_brace = %f\n',F_allowable_brace);
    fprintf('Leg/brace compression capacity summary.\n');
    % M_rna=350000;% RNA mass; legacy call fixed 250406
        W_jk=Weight_jacket(Num_bar_array,steel_density,Hydro.density,Y0_position(i));
                Wnet=W_jk+(Mtp+MTower+M_rna)*g;                         % total weight (deck+tower+RNA)

    if useLegacyStep5
    % Hydro_load_1and50yrs: verify inputs if results look wrong
        [F1,M1,F50,M50,F2,M2]=Hydro_load_1and50yrs(Hm2, Tm2, DAF2, Hm50, Tm50, DAF50, Hm1, Tm1, DAF1, t0, t1, dt, Num_bar_array, Y0_position(i));
    % M = 1.3 * max(max(max(M_etm + M2, M_eog + M2), max(M_ewm_6_1 + M50, M_ewm_6_3 + M1)), [], 'all'); % optional max over all cases
                M = 1.3 * max(max(M_etm + M2, M_eog + M2), max(M_ewm_6_1 + M50, M_ewm_6_3 + M1)); % governing factored moment
                V1=(1/Width(i))*(M/sqrt(2))+1.3*Wnet/4;                 % leg 1 axial compression (sizing)
    fprintf('M = %f\n',M);
    fprintf('V1 = %f\n',V1);
    fprintf('Width(i) = %f\n',Width(i));
    fprintf('Wnet = %f\n',Wnet);
    fprintf('F_etm = %f\n',F_etm);
    fprintf('F_eog = %f\n',F_eog);
    fprintf('F_ewm_6_1 = %f\n',F_ewm_6_1);
    fprintf('F_ewm_6_3 = %f\n',F_ewm_6_3);
    fprintf('M_etm = %f\n',M_etm);
    fprintf('M_eog = %f\n',M_eog);
    fprintf('M_ewm_6_1 = %f\n',M_ewm_6_1);
    fprintf('M_ewm_6_3 = %f\n',M_ewm_6_3);
    fprintf('F2 = %f\n',F2);
    fprintf('F1 = %f\n',F1);
    fprintf('F50 = %f\n',F50);
    fprintf('M2 = %f\n',M2);
    fprintf('M1 = %f\n',M1);
    fprintf('M50 = %f\n',M50);
    fprintf('Leg max axial V1 = %f\n',V1);
    fprintf('Leg allowable F_allowable_leg = %f\n',F_allowable_leg);
    fprintf('M = %f\n',M);
        if i==Num_floor
                                V4=(1/L_bottom)*(M/sqrt(2))-0.9*Wnet/4;                 % bottom-floor leg tension for pile design
        end
        label_bar1='leg';
    fprintf('Axial design value for %s computed.\n',label_bar1);
                H = 1.3 * max(max((F_etm + F2) / 4, (F_eog + F2) / 4), max((F_ewm_6_1 + F50) / 4, (F_ewm_6_3 + F1) / 4));% max horizontal per leg (factored)
                Fb=H/cos(sitah)/cosd(pesai);% legacy brace axial (Step 7: pesai term allowed here only)
    fprintf('L_bottom = %f\n',L_bottom);
    fprintf('H = %f\n',H);
    fprintf('Fb = %f\n',Fb);
        label_bar2='brace';
    fprintf('Axial design value for %s computed.\n',label_bar2);
        count_leg=0;
        count_brace=0;
        if (V1 <= F_allowable_leg) && (Fb <= F_allowable_brace)
        fprintf('      %s satisfies ULS without iteration.\n',label_bar1);
        fprintf('      %s satisfies ULS without iteration.\n',label_bar2);
        else
                while (V1 > F_allowable_leg) || (Fb > F_allowable_brace)
                        if V1>F_allowable_leg
                                count_leg=count_leg+1;
                %D_leg=D_leg+0.1; % leg OD (m)
                %t_leg=D_leg/20; % wall thickness
                                D_leg=1.2;
                                t_leg=t_leg+0.005;
                                A_leg=1/4*3.14*(D_leg^2-(D_leg-2*t_leg)^2);
                                I_leg=1/64*3.14*(D_leg^4-(D_leg-2*t_leg)^4);
                                ir_leg=sqrt(I_leg/A_leg);
                                                                F_allowable_leg=sigma_allowable(k_leg,L_leg,ir_leg,A_leg);% leg allowable
                                                                F_allowable_brace=sigma_allowable(k_brace, L_brace, ir_brace, A_brace);% brace allowable
                                Diameter_thickness_update(i,LegidPfloor, BraceidPfloor, D_leg, D_brace, t_leg, t_brace);
                % legacy call used Hm2 twice; corrected
                                [F1,M1,F50,M50,F2,M2]=Hydro_load_1and50yrs(Hm2, Tm2, DAF2, Hm50, Tm50, DAF50, Hm1, Tm1, DAF1, t0, t1, dt, Num_bar_array, Y0_position(i));
				fprintf('      Leg iter %d: M1 = %f\n',count_leg,M1);
                fprintf('      Leg iter %d: M50 = %f\n',count_leg,M50);
                fprintf('      M2 = %f\n',M2);
																M = 1.3 * max(max(M_etm + M2, M_eog + M2), max(M_ewm_6_1 + M50, M_ewm_6_3 + M1));% governing moment
                                W_jk=Weight_jacket(Num_bar_array,steel_density, Hydro.density,Y0_position(i));
                                                                Wnet=W_jk+(Mtp+MTower+M_rna)*g;% total weight
                fprintf('      Floor %d design M = %f\n',i,M);
                                                                V1=(1/Width(i))*(M/sqrt(2))+1.3*Wnet/4;% leg 1 axial
				fprintf('      W_jk = %f\n',W_jk);
				fprintf('      Wnet = %f\n',Wnet);
				fprintf('      Width = %f\n',Width(i));
                fprintf('      Leg iter %d: axial = %f, capacity = %f\n',count_leg,V1,F_allowable_leg);
                                if i==Num_floor
                                                                                V4=(1/L_bottom)*(M/sqrt(2))-0.9*Wnet/4;                 % bottom-floor leg tension (piles)
                                end
                                                                H = 1.3 *max(max((F_etm + F2) / 4, (F_eog + F2) / 4), max((F_ewm_6_1 + F50) / 4, (F_ewm_6_3 + F1) / 4));% horizontal per leg
                                                                Fb=H/cos(sitah)/cosd(pesai);% legacy brace axial (Step 7: pesai term allowed here only)
                        elseif Fb>F_allowable_brace
                                count_brace=count_brace+1;
                %D_brace=D_brace+0.06;
                %t_brace=D_brace/30;
                                D_brace=0.6;
                                t_brace=t_brace+0.01;
                                A_brace=1/4*3.14*(D_brace^2-(D_brace-2*t_brace)^2);
                                I_brace=1/64*3.14*(D_brace^4-(D_brace-2*t_brace)^4);
                                ir_brace=sqrt(I_brace/A_brace);
                                                                F_allowable_leg=sigma_allowable(k_leg,L_leg,ir_leg,A_leg);% leg allowable
                                                                F_allowable_brace=sigma_allowable(k_brace, L_brace, ir_brace, A_brace);% brace allowable
                                Diameter_thickness_update(i,LegidPfloor, BraceidPfloor, D_leg, D_brace, t_leg, t_brace);
                                [F1,M1,F50,M50,F2,M2]=Hydro_load_1and50yrs(Hm2, Tm2, DAF2, Hm50, Tm50, DAF50, Hm1, Tm1, DAF1, t0, t1, dt, Num_bar_array, Y0_position(i));
                fprintf('      Brace iter %d: M1 = %f\n',count_brace,M1);
                fprintf('      Brace iter %d: M50 = %f\n',count_brace,M50);
                                                                H = 1.3 * max(max((F_etm + F2) / 4, (F_eog + F2) / 4), max((F_ewm_6_1 + F50) / 4, (F_ewm_6_3 + F1) / 4));% horizontal per leg
                                                                Fb=H/cos(sitah)/cosd(pesai);% legacy brace axial (Step 7: pesai term allowed here only)
                                                                M = 1.3 * max(max(M_etm + M2, M_eog + M2), max(M_ewm_6_1 + M50, M_ewm_6_3 + M1));% governing moment
                fprintf('      Floor %d design M = %f\n',i,M);
                                W_jk=Weight_jacket(Num_bar_array,steel_density, Hydro.density,Y0_position(i));
                                                                Wnet=W_jk+(Mtp+MTower+M_rna)*g;% total weight
				fprintf('W_jk = %f\n',W_jk);
				fprintf('Wnet = %f\n',Wnet);
				fprintf('Width = %f\n',Width(i));
                                                                V1=(1/Width(i))*(M/sqrt(2))+1.3*Wnet/4;% leg 1 axial
                fprintf('      Leg iter %d: axial = %f, capacity = %f\n',count_leg,V1,F_allowable_leg);
                                if i==Num_floor
                                                                                V4=(1/L_bottom)*(M/sqrt(2))-0.9*Wnet/4;                 % bottom-floor leg tension
                                end
                        else
                fprintf('      Leg and brace satisfy ULS without further iteration.\n');
                        end
                end
        end
        if F_allowable_leg>V1
        fprintf('      Floor %d M_etm = %f\n',i,M_etm);
        fprintf('      Floor %d M_eog = %f\n',i,M_eog);
        fprintf('      Floor %d M = %f\n',i,M);
        fprintf('      After %d iterations, floor %d %s meets capacity.\n',count_leg,i,label_bar1);
        fprintf('      Floor %d %s axial = %f, capacity = %f\n',i,label_bar1,V1,F_allowable_leg);
        end
        if F_allowable_brace>Fb
        fprintf('      After %d iterations, floor %d %s meets capacity.\n',count_brace,i,label_bar2);
        fprintf('      Floor %d %s axial = %f, capacity = %f\n',i,label_bar2,Fb,F_allowable_brace);
        end
    else
        floorCtx = struct( ...
            'floor_id', i, ...
            'Num_bar_array', Num_bar_array, ...
            'Y0_position', Y0_position(i), ...
            'Width_i', Width(i), ...
            'Wnet', Wnet, ...
            'sitah', sitah, ...
            'brace_ids', brace_id_i_floor, ...
            'F_allowable_leg', F_allowable_leg, ...
            'F_allowable_brace', F_allowable_brace, ...
            'D_leg', D_leg, ...
            't_leg', t_leg, ...
            'D_brace', D_brace, ...
            't_brace', t_brace, ...
            'L_leg', L_leg, ...
            'L_brace', L_brace, ...
            't0', t0, ...
            't1', t1, ...
            'dt', dt, ...
            'F_etm', F_etm, ...
            'M_etm', M_etm, ...
            'F_eog', F_eog, ...
            'M_eog', M_eog, ...
            'F_ewm_50', F_ewm_6_1, ...
            'M_ewm_50', M_ewm_6_1, ...
            'F_ewm_1', F_ewm_6_3, ...
            'M_ewm_1', M_ewm_6_3, ...
            'Hm2', Hm2, ...
            'Tm2', Tm2, ...
            'DAF2', DAF2, ...
            'Hm50', Hm50, ...
            'Tm50', Tm50, ...
            'DAF50', DAF50, ...
            'Hm1', Hm1, ...
            'Tm1', Tm1, ...
            'DAF1', DAF1, ...
            'steel_density', steel_density, ...
            'hydro_density', Hydro.density, ...
            'deck_weight', (Mtp+MTower+M_rna)*g);
        [D_leg, t_leg, D_brace, t_brace, V4_tension, floorEnvelope] = run_step5_directional_floor( ...
            floorCtx, directionalScenarios, cfg, LegidPfloor, BraceidPfloor, i);
        [V4, pileTensionAssigned] = select_bottom_floor_pile_tension(i, Num_floor, V4_tension, V4);
        if pileTensionAssigned
            fprintf('      Bottom floor %d pile tension input V4 = %g (leg id %g)\n', ...
                i, V4, floorEnvelope.demands.tension_leg_id);
        end
        fprintf('      Floor %d governing: %s / %s (leg ratio=%.3f, brace ratio=%.3f)\n', ...
            i, floorEnvelope.direction_case, floorEnvelope.environment_case, ...
            floorEnvelope.leg_ratio, floorEnvelope.brace_ratio);
        ulsFloorRecords(end + 1) = uls_record_from_floor_envelope(floorEnvelope); %#ok<AGROW>
    end
    fprintf('      Floor %d: leg OD = %f m, t = %f m; brace OD = %f m, t = %f m\n',i,D_leg,t_leg,D_brace,t_brace);
        D_legs(i)=D_leg;
        t_legs(i)=t_leg;
        D_braces(i)=D_brace;
        t_braces(i)=t_brace;

end 
fprintf('Step 5: member strength -- finished.\n\n');
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 6: Pile sizing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pile OD/wall from bottom-floor max leg tension envelope (Step 6).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Step 6: pile sizing.\n');
interface_angle=29;
K0=1.0;
D_pile=Diameter_pile(V4,L_pile,wgh_soil,fs_limit,interface_angle,K0);
t_pile=D_pile*1000/100+6.35;
t_pile=ceil(t_pile)/1000;
fprintf('Pile: L = %f m, OD = %f m, wall t = %f m\n',L_pile,D_pile,t_pile);
fprintf('Step 6: pile sizing -- finished.\n\n');
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 7: Natural frequency %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% System frequency with pile/soil flexibility.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Step 7: natural frequency check.\n');
%% Natural frequency
% Jacket bending stiffness EI_Jacket
Ac = zeros(4, 1);
for i=1:4
        Ac(i)=1/4*3.14*(D_legs(i)^2-(D_legs(i)-2*t_legs(i))^2);
end
Ac1=Ac(1);
Ac2=Ac(2);
Ac3=Ac(3);
Ac4=Ac(4);
EI_Jacket=-h_Jacket^3/(3*(h3 + h4)*((h_Jacket^2*(log(abs(L_bottom - ((h3 + h4)*(L_bottom - L_top))/h_Jacket)) + L_top/(L_bottom - ((h3 + h4)*(L_bottom - L_top))/h_Jacket)))/(Ac2*E*(L_bottom - L_top)^2) - (h_Jacket^2*(log(abs(L_bottom - ((h3 + h4)*(L_bottom - L_top))/h_Jacket)) + L_top/(L_bottom - ((h3 + h4)*(L_bottom - L_top))/h_Jacket)))/(Ac3*E*(L_bottom - L_top)^2)) + 3*((h_Jacket^2*(log(abs(L_bottom - ((L_bottom - L_top)*(h2 + h3 + h4))/h_Jacket)) + L_top/(L_bottom - ((L_bottom - L_top)*(h2 + h3 + h4))/h_Jacket)))/(Ac1*E*(L_bottom - L_top)^2) - (h_Jacket^2*(log(abs(L_bottom - ((L_bottom - L_top)*(h2 + h3 + h4))/h_Jacket)) + L_top/(L_bottom - ((L_bottom - L_top)*(h2 + h3 + h4))/h_Jacket)))/(Ac2*E*(L_bottom - L_top)^2))*(h2 + h3 + h4) + 3*h4*((h_Jacket^2*(log(abs(L_bottom - (h4*(L_bottom - L_top))/h_Jacket)) + L_top/(L_bottom - (h4*(L_bottom - L_top))/h_Jacket)))/(Ac3*E*(L_bottom - L_top)^2) - (h_Jacket^2*(log(abs(L_bottom - (h4*(L_bottom - L_top))/h_Jacket)) + L_top/(L_bottom - (h4*(L_bottom - L_top))/h_Jacket)))/(Ac4*E*(L_bottom - L_top)^2)) - 3*h_Jacket*((h_Jacket^2*(log(abs(L_bottom - ((h3 + h4)*(L_bottom - L_top))/h_Jacket)) + L_top/(L_bottom - ((h3 + h4)*(L_bottom - L_top))/h_Jacket)))/(Ac2*E*(L_bottom - L_top)^2) - (h_Jacket^2*(log(abs(L_bottom - ((h3 + h4)*(L_bottom - L_top))/h_Jacket)) + L_top/(L_bottom - ((h3 + h4)*(L_bottom - L_top))/h_Jacket)))/(Ac3*E*(L_bottom - L_top)^2) + (h_Jacket^2*(log(abs(L_bottom - (h4*(L_bottom - L_top))/h_Jacket)) + L_top/(L_bottom - (h4*(L_bottom - L_top))/h_Jacket)))/(Ac3*E*(L_bottom - L_top)^2) - (h_Jacket^2*(log(abs(L_bottom - (h4*(L_bottom - L_top))/h_Jacket)) + L_top/(L_bottom - (h4*(L_bottom - L_top))/h_Jacket)))/(Ac4*E*(L_bottom - L_top)^2) + (h_Jacket^2*(log(L_bottom) + L_top/L_bottom))/(Ac4*E*(L_bottom - L_top)^2) + (h_Jacket^2*(log(abs(L_bottom - ((L_bottom - L_top)*(h2 + h3 + h4))/h_Jacket)) + L_top/(L_bottom - ((L_bottom - L_top)*(h2 + h3 + h4))/h_Jacket)))/(Ac1*E*(L_bottom - L_top)^2) - (h_Jacket^2*(log(abs(L_bottom - ((L_bottom - L_top)*(h2 + h3 + h4))/h_Jacket)) + L_top/(L_bottom - ((L_bottom - L_top)*(h2 + h3 + h4))/h_Jacket)))/(Ac2*E*(L_bottom - L_top)^2)) + (3*h_Jacket^3*(log(abs(L_bottom - ((h3 + h4)*(L_bottom - L_top))/h_Jacket))*(L_bottom + L_top - ((h3 + h4)*(L_bottom - L_top))/h_Jacket) - L_bottom + ((h3 + h4)*(L_bottom - L_top))/h_Jacket))/(Ac2*E*(L_bottom - L_top)^3) - (3*h_Jacket^3*(log(abs(L_bottom - ((h3 + h4)*(L_bottom - L_top))/h_Jacket))*(L_bottom + L_top - ((h3 + h4)*(L_bottom - L_top))/h_Jacket) - L_bottom + ((h3 + h4)*(L_bottom - L_top))/h_Jacket))/(Ac3*E*(L_bottom - L_top)^3) + (3*h_Jacket^3*(log(abs(L_bottom - ((L_bottom - L_top)*(h2 + h3 + h4))/h_Jacket))*(L_bottom + L_top - ((L_bottom - L_top)*(h2 + h3 + h4))/h_Jacket) - L_bottom + ((L_bottom - L_top)*(h2 + h3 + h4))/h_Jacket))/(Ac1*E*(L_bottom - L_top)^3) - (3*h_Jacket^3*(log(abs(L_bottom - ((L_bottom - L_top)*(h2 + h3 + h4))/h_Jacket))*(L_bottom + L_top - ((L_bottom - L_top)*(h2 + h3 + h4))/h_Jacket) - L_bottom + ((L_bottom - L_top)*(h2 + h3 + h4))/h_Jacket))/(Ac2*E*(L_bottom - L_top)^3) + (3*h_Jacket^3*(log(L_bottom - (h4*(L_bottom - L_top))/h_Jacket)*(L_bottom + L_top - (h4*(L_bottom - L_top))/h_Jacket) - L_bottom + (h4*(L_bottom - L_top))/h_Jacket))/(Ac3*E*(L_bottom - L_top)^3) - (3*h_Jacket^3*(log(L_bottom - (h4*(L_bottom - L_top))/h_Jacket)*(L_bottom + L_top - (h4*(L_bottom - L_top))/h_Jacket) - L_bottom + (h4*(L_bottom - L_top))/h_Jacket))/(Ac4*E*(L_bottom - L_top)^3) + (3*h_Jacket^3*(L_top - 2*L_top*log(abs(L_top))))/(Ac1*E*(L_bottom - L_top)^3) - (3*h_Jacket^3*(L_bottom - log(L_bottom)*(L_bottom + L_top)))/(Ac4*E*(L_bottom - L_top)^3));
 
% Tower stiffness EI_tower (already computed above)
% Combined tower + jacket stiffness EI_JacketTower
kai=EI_tower/EI_Jacket;
EI_JacketTower=EI_tower*(1/(1+(1+fai)^3*kai-kai))*((h_Jacket+h_Tower)/h_Tower)^3;
% Equivalent distributed mass m_JT_eq
lamda1=1.8751;
beta1=-(cos(lamda1)+cosh(lamda1))/(sin(lamda1)+sinh(lamda1));
m_Jacket_eq=Distribute_mass_jacket(Num_bar,steel_density,h_Jacket);
m_JT_eq=(m_Jacket_eq*(intergral_mode_shape(h_Jacket,lamda1,h_Tower,h_Jacket)-intergral_mode_shape(0,lamda1,h_Tower,h_Jacket))+m_tower_eq*(intergral_mode_shape(h_Jacket+h_Tower,lamda1,h_Tower,h_Jacket)-intergral_mode_shape(h_Jacket,lamda1,h_Tower,h_Jacket)))/(intergral_mode_shape(h_Jacket+h_Tower,lamda1,h_Tower,h_Jacket)-intergral_mode_shape(0,lamda1,h_Tower,h_Jacket));
% Target support frequency f_fb
f_fb=1/(2*3.14)*sqrt(3*EI_JacketTower/((0.243*m_JT_eq*h_total+M_rna)*(h_total)^3));
% Soil shear modulus Gs (MPa-scale input)
Gs=15e6;
kexi=4;
k_pile=2*3.14*L_pile*Gs/kexi;
K_v=2*k_pile;
alpha=1;
K_R=K_v*L_bottom^2*(alpha/(1+alpha));
tao=K_R*h_total/EI_JacketTower;
C_J=sqrt(tao/(tao+3));
f_0=C_J*f_fb;
fprintf('Fundamental frequency with soil flexibility: %f Hz\n',f_0);
fprintf('Step 7: natural frequency -- finished.\n\n');
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 8: Frequency sensitivity to soil Gs %%%%%%%%%%%%%%%%
% Scale Gs up/down and report f0.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Gs +30%%
fprintf('Step 8: natural frequency sensitivity to Gs.\n');
factor1=1.30;
Gs1=Gs*factor1;
k_pile1=2*3.14*L_pile*Gs1/kexi;
K_v1=2*k_pile1;
K_R1=K_v1*L_bottom^2*(1/(1+alpha));
tao1=K_R1*h_total/EI_JacketTower;
C_J1=sqrt(tao1/(tao1+3));
f_0_1=C_J1*f_fb;
fprintf('Gs scaled by %f -> f0 = %f Hz\n',factor1,f_0_1);
% Gs -30%%
factor2=0.7;
Gs2=Gs*factor2;
k_pile2=2*3.14*L_pile*Gs2/kexi;
K_v2=2*k_pile2;
K_R2=K_v2*L_bottom^2*(1/(1+alpha));
tao2=K_R2*h_total/EI_JacketTower;
C_J2=sqrt(tao2/(tao2+3));
f_0_2=C_J2*f_fb;
fprintf('Gs scaled by %f -> f0 = %f Hz\n',factor2,f_0_2);
fprintf('Step 8: frequency sensitivity -- finished.\n\n');
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 9: Tower-top deflection (ULS) %%%%%%%%%%%%%%%%%%%%%%
% Wave + wind components for serviceability-style check.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Step 9: tower-top deflection (ULS).\n');
step9Path = resolve_step9_deflection_path(cfg);
useLegacyStep9 = strcmp(step9Path, 'legacy_step9');
deflectionEnvelope = [];
if useLegacyStep9
    fprintf('      Step 9 deflection path: legacy_step9 (single-case).\n');
else
    fprintf('      Step 9 deflection path: directional envelope (%s).\n', cfg.mode_name);
end
sigmau_ntm=I_ref*(0.75*U_r+5.6); % std dev
sigmau_ntmfdayu1p=sigmau_ntm*sqrt(1/(((6*Lk*f1p_max)/U_r+1)^(2/3))); % std dev above 1P
u_ntm=1.28*sigmau_ntmfdayu1p;% NTM turbulence component
F_ntm=air_density*Ar*Ct*(U_r+u_ntm)^2/2;% NTM thrust
Num_bar_array_step9 = get_bar_array_for_floor(Num_floor, LegidPfloor, BraceidPfloor);
Y0_step9 = Y0_position(Num_floor);
deflectionCtx = struct( ...
    't0', t0, ...
    't1', t1, ...
    'dt', dt, ...
    'Num_bar_array', Num_bar_array_step9, ...
    'Y0_position', Y0_step9, ...
    'Hm1', Hm1, ...
    'Tm1', Tm1, ...
    'h_total', h_total, ...
    'K_R', K_R, ...
    'EI_Jacket', EI_Jacket, ...
    'EI_JacketTower', EI_JacketTower, ...
    'F_ntm', F_ntm, ...
    'environment_case', '1yr_NTM', ...
    'use_directional_hydro', ~useLegacyStep9);
if useLegacyStep9
    legacyCase = compute_towertop_deflection_case(deflectionCtx, 0, 0);
    delt_towertop = legacyCase.delt_towertop;
    fprintf('ULS tower-top deflection (max): %f m\n', delt_towertop);
else
    if ~exist('directionalScenarios', 'var') || isempty(directionalScenarios)
        directionalScenarios = direction_scenarios(cfg);
    end
    fprintf('      Direction scenarios for Step 9 envelope: %d paper case(s).\n', ...
        count_paper_direction_scenarios(directionalScenarios));
    deflectionEnvelope = directional_deflection_envelope(deflectionCtx, directionalScenarios, cfg);
    delt_towertop = deflectionEnvelope.max_deflection;
    fprintf('ULS tower-top deflection envelope (max): %f m\n', delt_towertop);
    fprintf('      Governing direction case: %s (beta_wind=%g deg, beta_wave=%g deg)\n', ...
        deflectionEnvelope.direction_case, ...
        deflectionEnvelope.beta_wind, ...
        deflectionEnvelope.beta_wave);
    fprintf('      Governing environment case: %s\n', deflectionEnvelope.environment_case);
end
fprintf('Step 9: tower-top deflection -- finished.\n\n');

summaryPath = fullfile(modelRoot, 'directional_summary.txt');
if useLegacyStep5
    summary = build_directional_summary(cfg, [], []);
elseif useLegacyStep9
    summary = build_directional_summary(cfg, ulsFloorRecords, []);
else
    summary = build_directional_summary(cfg, ulsFloorRecords, deflectionEnvelope);
end
write_directional_summary(summaryPath, summary);
fprintf('Directional summary written to %s\n', summaryPath);

% Step 10: Export members/nodes for 3-D (local y/z, mudline z=0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Step 10: export geometry to files.\n');
elementsDat = fullfile(modelRoot, 'jacket_elements.dat');
nodesDat = fullfile(modelRoot, 'node_coordinates.dat');
member_export(elementsDat, Num_bar, water_depth);
node_export(nodesDat, Num_bar, water_depth);
cord_Cal(Num_bar, water_depth);
fprintf('Step 10: export geometry -- finished.\n\n');

end

function resolvedPath = resolve_input_path(inputPath, modelRoot)
if isfile(inputPath)
    resolvedPath = inputPath;
    return;
end

candidateFromModel = fullfile(modelRoot, inputPath);
if isfile(candidateFromModel)
    resolvedPath = candidateFromModel;
    return;
end

error('DriveCodeJckDesign:InputFileNotFound', ...
    'Input file not found. Checked: %s ; %s', inputPath, candidateFromModel);
end
