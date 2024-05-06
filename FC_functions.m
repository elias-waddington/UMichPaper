%% a few functions required

MaxPower = 20e6; %power, W
h = 35000; %altitude, feet
M = 0.75; % Mach
FC_type = 1; %1 for HTPEM, 2 for LTPEM
Oversizing_Factor = 1.3; % You want 30% more power available than your sizing point

function [SizedFuelCellSystem] = SizeFC(MaxPower, h, M, FC_type)

%initialize fuel cell
FC_init(FC_type)
load('FC_data.mat')

maxpower_per_lb = interp2(MP_h_rng,MP_M_rng,MP_Wlb_mat,h,M); % max power @ sizing criteria

FuelCell_Weight = MaxPower*Oversizing_Factor/maxpower_per_lb; % FC weight in lbs 
SizedFuelCellSystem.Weight = FuelCell_Weight/2.2; %weight in KG

% HEX Credit

% HEXdrag = interp2(MP_h_rng,MP_M_rng,MP_Drag_mat,h,M)*FuelCell_Weight;
% v = speedofsound(h)*M;
% HEXPower = 1.3558179 * v * HEXdrag; %power in Watts

% On Design Performance
SizedFuelCellSystem.Performance = interp2(MP_h_rng,MP_M_rng,MP_Eff_mat,h,M)*FuelCell_Weight;


% Alternative on-design perfomance with HEX credit
% FCeff = interp3D_V003(FCmap_eff,1,(MaxPower + HEXPower)/FuelCell_Weight,M,h,'n');

% LH2_Consumption = (MaxPower + HEXPower)/FCeff/119930040; % consumption in KG/SEC

end


function [OffDesignFC] = FuelCellPerformance(SizedFuelCellSystem,CurrentPower,h,M)

% changes in efficiency based on off design performance
% delta_eta = function_of(MaxPower,CurrentPower,etc); % Hope this isn't
% needed for you

% load FC data
load('FC_data.mat')


% Fuel Consumption
% OffDesignFC.Performance = LH2_Consumption(SizedFuelCellSystem, CurrentPower, delta_eta);
FuelCell_Weight = SizedFuelCellSystem.Weight*2.2; % weight from KG to LB

FCeff = interp3D_V003(FCmap_eff,1,CurrentPower/FuelCell_Weight,M,h,'n');

% Drag caused by HEX, not currently used
% drag = interp3D_V003(FCmap_drag,1,CurrentPower/FuelCell_Weight,M,h,'n')*FuelCell_Weight;

% Magnitude of heat rejection, Watts.
heat = interp3D_V003(FCmap_heat,1,CurrentPower/FuelCell_Weight,M,h,'n')*FuelCell_Weight; % heat, watts

LH2_Consumption = CurrentPower/FCeff/119930040; % consumption in KG/SEC



end


function [TankWeight] = EstimateTankWeight(Total_LH2_Weight)

% define scaling factor as a function of Entry-to-service or whatever
% parameters you deem necessary
% scalefactor = function_of(etc);

% estimate tank weight as a function of LH2 weight and some scaling factor?
TankWeight = Total_LH2_Weight * 0.65; % between 0.65 (future tanks) to ~1.3 (contemp. tanks). CHEETA used 0.65.

end









