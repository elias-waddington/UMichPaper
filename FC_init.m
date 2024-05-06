function FC_init(Wanted_FC)% FC initialization code for new fuel cells for use for GA_perfcode

% Wanted_FC = 1; % 1 for HT, 2 for LT



if Wanted_FC == 1
    
    Wanted_Value = 2.7; %kw/kg
    % % FC Inputs
    fc.OpT = 180; %C, dependent on FC type %Decreasing T increases power?!
    fc.Ncells = 1080; % FC input
    fc.A = 0.0446; %m^2, FC input
    fc.r = 6.2e-6; % ohm/m^2, FC input % main tuning parameter
    fc.alpha = 0.5; % FC input, constant?
    % fc.Ido = 8e-4; % amp-m^2, range from 1e-3 to 1e-4
    fc.xpara = 0.05; % parasitic loss factor, FC input
    fc.Comp_eff = 0.9 ; %compressor efficiency
    fc.Pfuel = 5; %bar, input
    fc.mu =  .96;
    fc.c0 = 1.125;
    fc.c1 = 0.175;
    % fc.k = .20e-7;
    fc.k = 60e-7;
    fc.m = 8e-5;
    fc.n = 2e-4;
    fc.deg = 0.00;
    fc.weight = 363*2.2/1.142; % Multiply this to change weight estimation

elseif Wanted_FC == 2
    
    Wanted_Value = 1; %kw/kg
    % Recovered numbers
    fc.OpT = 60; %C, dependent on FC type %Decreasing T increases power?!
    fc.Ncells = 1080; % FC input
    fc.A = 0.0446; %m^2, FC input
    fc.r = 8e-6; % ohm/m^2, FC input % main tuning parameter
    fc.alpha = 0.5; % FC input, constant?
    % fc.Ido = 8e-4; % amp-m^2, range from 1e-3 to 1e-4
    fc.xpara = 0.05; % parasitic loss factor, FC input
    fc.Comp_eff = 0.9 ; %compressor efficiency
    fc.Pfuel = 5; %bar, input
    fc.mu =  .79;
    fc.c0 = 1.125;
    fc.c1 = 0.175;
    % fc.k = .20e-7;
    fc.k = 60e-7;
    fc.m = 8e-5;
    fc.n = 2e-4;
    fc.deg = 0.0;
    fc.weight = 363*2.2/1.258*3; % Multiply this to change weight estimation

end


fc.Ar = .986;
% % fc.weight = 363*2.2/1.085*1.0582; 

set.FCtype = 4;
set.HEXweight = 0;
set.HEXtype = 11; 

weight = FC_File_Creator(fc,set);
set.HEXweight = weight.nacelle;


FCmap_drag = allloadin_V003('afc_HEX.dat','n');
FCmap_eff = allloadin_V003('afc_eff.dat','n');
FCmap_heat = allloadin_V003('afc_HEAT.dat','n');
load aswhitefc_values.mat
set.LP_Wlb_mat = LP_Wlb_mat;
set.LP_Eff_mat = LP_Eff_mat;
set.LP_Drag_mat = LP_Drag_mat;
set.MP_Wlb_mat = MP_Wlb_mat;
MP_Wlb_mat
set.MP_Eff_mat = MP_Eff_mat;
set.MP_Drag_mat = MP_Drag_mat;
set.MP_M_rng = MP_M_rng;
set.MP_h_rng = MP_h_rng;
set.MP_Heat_mat = MP_Heat_mat;
set.LP_Heat_mat = LP_Heat_mat;

save FC_data

end