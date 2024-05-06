function [Total_Drag] = IsolatedHEXdrag(ac,Mach,altitude,heat)
%IsolatedHEXdrag Calculates isolated HEX drag given aircraft inputs and
%heat

[Dcore,v1,~] = HEXdrag_core(Mach,altitude,ac.HEX.ar/ac.prop.num,heat/ac.prop.num);
% area of one HEX
area = ac.HEX.ar/ac.prop.num;

%radius of one area of one HEX
r = sqrt(area/pi);

HEX_length = ac.HEX.length_ratio*(r*2);

%External Flow
v_cruise = Mach*speedofsound(altitude);
rho = airdensity(altitude);
viscocity = airviscocity(altitude);
% RN = rho*v_cruise*HEX_length/viscocity;
% Cf = .455/(log10(RN))^2.58/(1+.144*Mach^2)^.65;

% Rwf = Rwf_find(Mach,RN);
% 
% lfdf = ac.HEX.length_ratio;
% surface_area = pi*r*HEX_length;
% 
% CDbfus = 0; % no base drag due to thrust/flow thorugh structure
% 
% CDofus = Rwf*Cf*(1+60/(lfdf)^3 + 0.0025 * lfdf) * surface_area/ac.wing.S + CDbfus;
% 
% % CDLfus =  %CDLfus values
% CL = 0.4; % any way to tell this from inputs? don't think so
% CLalpha =  2*pi*(ac.wing.A/(2+sqrt(4+ac.wing.A^2)));
% alpha = (CL-ac.fuse.CLo)/CLalpha; %in radians
% [Min,CDCf] = Cdc_find('fig420.csv');
% cdcf = interp1(Min,CDCf,abs(Mach*sin(alpha)));
% B = sqrt(1-Mach^2);
% nu = ac.wing.Cla/(2*pi/B);
% CDLfus = 2*alpha^2*ac.fuse.Sbfus/ac.wing.S+nu*cdcf*alpha^3*ac.fuse.Splffus/ac.wing.S;
% 
% % ExDrag = surface_area*Cf*1/2*rho*v_cruise^2 * ac.prop.num;
% % ExDrag = 0;
% 
% CD1 = CDLfus + CDofus;
% ExDrag = CD1/2*v_cruise^2*rho*ac.wing.S;
ExDrag = 0;

%Andrew method
CD = 0.040;
DNacelle = CD/2*rho*v_cruise^2*(ac.HEX.ar/ac.prop.num*10.76391)*(v1*3.28)/v_cruise;
% DNacelle = 0;
% area = ac.HEX.ar

% ExDrag-DNacelle

%Total Drag
Total_Drag = (Dcore + ExDrag + DNacelle)*ac.prop.num;
%                     Total_Drag(ii) = Dcore;
end

