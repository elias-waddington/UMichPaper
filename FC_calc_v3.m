	function [Pnet,Eff_net,Qdot,Pcompressor,mdot_air,FC_eff,Vcell,Id,Pgross, eo] = FC_calc_v3(fc,altitude, mdot_fuel,M)	
% Constants
R = 8.314; %J/mol-K, const
F = 96485.33; %C/mol, const
cO2 = 0.21; %const, atmospheric
h_lh2 = 1.1993e8; %LHV of LH2. Update with more accurate num. Const
Cp = 1006; %j/kg-k, const.
gamma = 1.4;

% Transmissibility values, unsure of what kind of constant these are. Little effect.
% m = 3e-5; %v
% n = 2e-4; %m^2/A
m = fc.m;
n = fc.n;

% stack current paremters for stack pressure
c0 = fc.c0;
c1 = fc.c1;

% Air pressure calc
P0 = airpressure(0);
P_ambient = airpressure(altitude);
P_bar = P_ambient/P0;

%isentropic stagnation due to air speed
isen_P = (1+(gamma-1)/2*M^2)^(gamma/(gamma-1))*P_bar;

% [T, ~, ~, ~] = atmosisa(altitude/3.3);
T = air_temp(altitude);
% cO2 = cO2/P_bar^2;

Tt_inf =  T*(1+(gamma-1)/2*M^2);
% T_operating = Tt_inf+fc.OpT;
% Tt_inf = 288;
T_operating = fc.OpT+273;
% T_operating = Tt_inf + 160; 
% fc.deltagf = (-285.8+.4011/2*T_operating)*1000;

%% Calculation
%Gibbs FE relation

% h = -228600; %j/gmole
% S = (188.7*2-130.6*2-205)/2; %j/moleK
% G = h-T_operating*S/1000;
% G = h-(S*(T_operating))
% eo = -G/2/F;
eo = 1.229;

I_int = 2*F*mdot_fuel/fc.Ncells*1000/(2*1.0079); %amps, internal current

%Ideal Cell Currents
I = I_int*fc.mu; % mu assumption
Id = I/fc.A;

% Find stack pressure by this relationship from Chellappa
P_comp = c0 + c1*(I/(fc.A*10000))^2;
P_stack = P_comp + isen_P;
% P_stack
% P_stack/P_bar
% P_stack = 3;
% Pressure_ratio = P_stack; %/P_bar; %over ambient air, for BoP compressor


% Nernst Voltage
eNern = eo + R*T_operating/2/F*log(fc.Pfuel*sqrt(cO2)/sqrt(P_stack*0.9));

% Qohm = (Id*A)^2*r*Ncells; %Ohmic losses
deltaVohm = Id*fc.r; %ohmic voltage loss

fc.Ido  = 2*F*fc.k*cO2*P_stack/fc.A;
% Ido = fc.Ido
% Ido = 1e-4; % <- can keep as an input
deltaVact = R*T_operating/(2*fc.alpha*F)*log(Id/fc.Ido);

%First two loss mechanisms seem very off - ASW

deltaVtrans = m*exp(Id*n);
% deltaVtrans = 0;

%Compression Voltage Boost
% C = 0.05; %V
% deltaVgain = C*log(Pressure_ratio);
deltaVgain = 0;

Vcell = eNern - deltaVohm - deltaVact - deltaVtrans + deltaVgain - fc.deg;
Vstack = Vcell*fc.Ncells;

Pgross = I*Vstack; %Gross power, wats

FC_eff = Pgross/h_lh2/mdot_fuel; %fuel cell eff, %

QFC = Pgross*(1-FC_eff);
Qact = deltaVact*fc.Ncells*Id*fc.A;
Qohm = Id^2*fc.A*fc.r*fc.Ncells;

Qdot = max(Qact+Qohm,QFC);

%% Balance of plant
mdot_air = I*fc.Ncells/F*28.97/4/1000/.21*1.5; % 1.5 50% more than stoic-needed
Pparasite = fc.xpara*Pgross;
Pcompressor = mdot_air*Cp*Tt_inf*((P_stack/isen_P)^((0.4/1.4))-1)/fc.Comp_eff; % Compressor power
% Pcompressor
%% Summation
Plosses = Pcompressor + Pparasite; 
Pnet = Pgross - Plosses;
P_data = P_comp/P_bar;

Eff_net = Pnet/h_lh2/mdot_fuel;

end