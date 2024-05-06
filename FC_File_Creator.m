function [weight] = FC_File_Creator(fc,set)

% create files to be read
    altitude_rng = [-1,1e4,2e4,3e4,3.75e4];
    mach_rng = [0.24,0.4,0.6,0.81];
    power_rng = linspace(210000,1000000,26); %26 points between 250-1000 kw at stack. second number should be 1e6
    fuel_sweep = linspace(0.0001,0.025,101);
    dataout = zeros(5,(length(altitude_rng)*length(mach_rng)*length(power_rng)));
    dataout_hex = dataout;
    dataout_heat = dataout;
    counter = 0;
    Pstackmax = 0;
    L_sweep = 101;
    Pnet = zeros(L_sweep,1);
    Eff_net = zeros(L_sweep,1);
    Qdot = zeros(L_sweep,1);
    Pcompressor = zeros(L_sweep,1);
    mdot_air = zeros(L_sweep,1);
    FC_eff = zeros(L_sweep,1);
    Vcell = zeros(L_sweep,1);
    Id = zeros(L_sweep,1);
    Total_Drag = zeros(L_sweep,1);

    r = sqrt(fc.Ar*10.76391/pi); %ft, this is the radius of the HEX for 1 stack
    HEX_length = r*5; %estimated 5:1 HEX
    for j = 1:5
        altitude = altitude_rng(j);
%         fc.mu = 1.17 - .17*(altitude/37000);
%         fc.r = 9e-6 - .4e-6*(altitude/37000);
        for k = 1:4
            mach = mach_rng(k);
            for i = 1:26
                counter = counter+1;
                
                Pgross = zeros(101,1);
                for ii = 1:L_sweep
                    mdot_fuel = fuel_sweep(ii);
                    [Pnet(ii),Eff_net(ii),Qdot(ii),Pcompressor(ii),mdot_air(ii),FC_eff(ii),Vcell(ii),Id(ii),Pgross(ii),Pstack] = FC_calc_v3(fc,altitude, mdot_fuel, mach);
%                     Qdot(ii)
                    if Pgross(ii) < max(Pgross)
%                         Pgross(ii) = max(Pgross)+0.01;
                        break
                    end
                    Pstackmax = max(Pstack,Pstackmax);
                    
                    if set.HEXtype == 0
                         Total_Drag(ii) = 0;
                    elseif set.HEXtype == 1
                    
                    [Dcore,v3,v1] = HEXdrag_core(mach,altitude,fc.Ar,Qdot(ii));
%                     Dcore = interp3D_V003(FCmap_drag,1,power_lookingfor/fc.weight,mach,altitude,'n')
%                     Dcore = 0;
                    
                    %External Flow
                    v_cruise = mach*speedofsound(altitude);
                    rho = airdensity(altitude);
%                     viscocity = airviscocity(altitude);
%                     RN = rho*v_cruise*HEX_length/viscocity;
%                     Cf = .455/(log10(RN))^2.58/(1+.144*mach^2)^.65;
%                     surface_area = pi*r*5;
%                     ExDrag = surface_area*Cf*1/2*rho*v_cruise^2;
                    
                    
            
                    %Andrew method
                    CD = 0.040;
%                     area = fc.Ar
                    DNacelle = CD/2*rho*v_cruise^2*(fc.Ar*10.76391)*(v1*3.28)/v_cruise;

                    %Total Drag
                    Total_Drag(ii) = Dcore + DNacelle;
%                     Total_Drag(ii) = Dcore;

                    elseif set.HEXtype == 2
                        
                    elseif set.HEXtype >= 11
                        Total_Drag(ii) = 0;
                        
                    end

                    
                end
                Pgross = Pgross(1:ii);
                Pnet = Pnet(1:ii);
                Eff_net = Eff_net(1:ii);
                Total_Drag = Total_Drag(1:ii);
                Qdot = Qdot(1:ii);
                
                peak_power = min(max(Pgross),max(power_rng));
                new_power_rng = linspace(210000,peak_power,26);
                power_lookingfor = new_power_rng(i);
                
                dataout(2,counter) = mach;
                dataout(3,counter) = altitude;
                dataout(1,counter) = interp1(Pgross,Pnet,power_lookingfor)/fc.weight; %need to correct for weight
                dataout(4,counter) = interp1(Pgross,Eff_net,power_lookingfor);
                dataout(5,counter) = 1;

                dataout_hex(2,counter) = mach;
                dataout_hex(3,counter) = altitude;
                dataout_hex(1,counter) = interp1(Pgross,Pnet,power_lookingfor)/fc.weight; %need to correct for weight
                dataout_hex(4,counter) = interp1(Pgross,Total_Drag,power_lookingfor)/fc.weight;
                dataout_hex(5,counter) = 1; 

                dataout_heat(2,counter) = mach;
                dataout_heat(3,counter) = altitude;
                dataout_heat(1,counter) = interp1(Pgross,Pnet,power_lookingfor)/fc.weight; %need to correct for weight
                dataout_heat(4,counter) = interp1(Pgross,Qdot,power_lookingfor)/fc.weight;
                dataout_heat(5,counter) = 1; 

                
                if isnan(dataout(1,counter)) == 1
                    disp('bad')
                end
                
                if i == 1
                    LP_Wlb_mat(k,j) = dataout(1,counter);
                    LP_Eff_mat(k,j) = dataout(4,counter);
                    LP_Drag_mat(k,j) = dataout_hex(4,counter);
                    LP_Heat_mat(k,j) = dataout_heat(4,counter);
                end
                if i == 26
                    MP_Wlb_mat(k,j) = dataout(1,counter);
                    MP_Eff_mat(k,j) = dataout(4,counter);
                    MP_Drag_mat(k,j) = dataout_hex(4,counter);
                    MP_Heat_mat(k,j) = dataout_heat(4,counter);
                end
            end
        end
    end
    
   
    if set.HEXtype < 10
        
        weight.nacelle = 3*1*((fc.Ar*10.76391)^.5*HEX_length*Pstack)^.731/fc.weight + 5.02*2.2*fc.Ar*10.76391/fc.weight;
        if set.HEXtype == 0
            weight.nacelle = 0;
        end
    elseif set.HEXtype >= 10
        weight.nacelle = 999999;
    end
    
    
    
    MP_M_rng = mach_rng';

    MP_h_rng = altitude_rng';

    save('aswhitefc_values.mat','MP_M_rng','MP_h_rng','LP_Wlb_mat','LP_Eff_mat','MP_Wlb_mat','MP_Eff_mat','MP_Drag_mat','LP_Drag_mat','LP_Heat_mat','MP_Heat_mat');


    fid = fopen('afc_eff.dat','wt');
    fprintf(fid, 'VARIABLES = "powerdemand", "mach", "altitude", "efficiency", \n');
    fprintf(fid, 'ZONE T = "FCmapR2_Drag", I = 26, J = 4, K = 5 \n');
    fprintf(fid,'%f\t%f\t%i\t%f\t%f\t\n', (dataout));
    fclose(fid)
    
    fid = fopen('afc_HEX.dat','wt');
    fprintf(fid, 'VARIABLES = "powerdemand", "mach", "altitude", "drag", \n');
    fprintf(fid, 'ZONE T = "FCmapR2_Drag", I = 26, J = 4, K = 5 \n');
    fprintf(fid,'%f\t%f\t%i\t%f\t%f\t\n', (dataout_hex));
    fclose(fid)
    
    fid = fopen('afc_HEAT.dat','wt');
    fprintf(fid, 'VARIABLES = "powerdemand", "mach", "altitude", "heat", \n');
    fprintf(fid, 'ZONE T = "FCmapR2_Drag", I = 26, J = 4, K = 5 \n');
    fprintf(fid,'%f\t%f\t%i\t%f\t%f\t\n', (dataout_heat));
    fclose(fid)
end