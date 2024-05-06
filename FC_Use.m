%% Example Setup


% Initailize fuel cell. Inputs are:
% 1 - HT PEM, 2050 EIS, 2.7 KW/KG
% 2 - LT PEM, 2020 EIS, 1 KW/KG
FC_init(1)

% Find maximum power per stack at cruise conditions
h = 35000; % ft
M = 0.75; % mach no.
maxpower_per_lb = interp2(MP_h_rng,MP_M_rng,MP_Wlb_mat,h,M)

Pow_Reqd_Max = 20e6; % Watts of peak sizing power
Oversizing_Factor = 1.3; % You want 30% more power available than your sizing point

FuelCell_Weight = Pow_Reqd_Max*Oversizing_Factor/maxpower_per_lb % FC weight in lbs

% For any set of conditions:

% define power required, watts
Pow_Reqd = 10e6; % 10 MW required load

% find fuel cell efficiency
FCeff = interp3D_V003(FCmap_eff,1,Pow_Reqd/FuelCell_Weight,M,h,'n')

% estimate fuel flow in KG/SEC
H2_KG_SEC = Pow_Reqd/FCeff/119930040; 

% Drag caused by HEX, method 1 (doesn't work for how FC is configured right
% now). Assumes HEX waste heat dumped by radiator, not utilization. 
drag_per_lb = interp3D_V003(FCmap_drag,1,Pow_Reqd/FuelCell_Weight,M,h,'n') % for HEX_type < 10

% Drag caused by HEX, method 2 (currently works, but requires specifics of
% HEX system). Assumes utilization of waste heat per White et al 2022
heat = interp3D_V003(FCmap_heat,1,Pow_Reqd/FuelCell_Weight,M,h,'n')*FuelCell_Weight; % heat, watts

ac.HEX.ar = 8.5986;
ac.prop.num = 9;
ac.HEX.length_ratio = 5;

Total_Drag = IsolatedHEXdrag(ac,M,h,heat)