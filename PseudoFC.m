%% a few functions required


function [SizedFuelCellSystem] = SizeFC(MaxPower, AirDensity, FlightSpeed, etc)

% Weight
SizedFuelCellSystem.Weight = EliasWeightModelValue(MaxPower,etc);

% On Design Performance
SizedFuelCellSystem.Performance = LH2_Consumption(MaxPower, etc);

% Anything else your off-design function might need
SizedFuelCellSystem.OtherParameters = AsNeeded;

end


function [OffDesignFC] = FuelCellPerformance(SizedFuelCellSystem,CurrentPower,AirDensity,FlightSpeed, etc)

% changes in efficiency based on off design performance
delta_eta = function_of(MaxPower,CurrentPower,etc);

% Fuel Consumption
OffDesignFC.Performance = LH2_Consumption(SizedFuelCellSystem, CurrentPower, delta_eta);

end


function [TankWeight] = EstimateTankWeight(Total_LH2_Weight, etc)

% define scaling factor as a function of Entry-to-service or whatever
% parameters you deem necessary
scalefactor = function_of(etc);

% estimate tank weight as a function of LH2 weight and some scaling factor?
TankWeight = Total_LH2_Weight * scalefactor;

end









