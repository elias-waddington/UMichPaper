function [Dcore,v3,v1,Dm] = HEXdrag_core(Minf,h,Ar,Hdot)
% Constants
gamma = 1.4;
cp = 1006; %kj/kg-k

%Environemntal (h-dervied)
% [T0, a, Pinf, rhoinf] = atmosisa(h/3.2808399);
T0 = air_temp(h);
a = speedofsound(h)/3.2808399;
rhoinf = airdensity(h)*515.37882;

vinf = Minf*a;
Tt0 = T0*(1+(gamma-1)/2*Minf^2);
dT = 453.15-Tt0; %423 or 396, assume constant, not great

%% Steps

% Step 2. Determine HEX velocity (v1)
Mdot = Hdot/(cp*dT);

%Need to know Ar, rho 1.
rho1 = rhoinf*(1+(gamma-1)/2*Minf^2)^(1/(gamma-1)); % assume stagnation density
v1 = Mdot/Ar/rho1; 

r = sqrt(Ar/pi);

P = 10;

v3 = sqrt((vinf^2-P*v1^2)*(423)/Tt0);

if isreal(v3) == 0
    v3 = 0;
    disp('V3 error')
end


sigkfkh = 10;

Dcore2 = Hdot/vinf*((vinf^2*P*r^(2/3)/(cp*(dT)))*sigkfkh*(v1/vinf)^2-(gamma-1)/2*Minf^2);
Dcore = Dcore2* 0.22480894; % N to lbf





end





