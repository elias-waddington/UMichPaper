function a = speedofsound(h)
%     [T, ~, ~, ~] = atmosisa(h/3.28);
    T = air_temp(h);
    a = 20.05*sqrt(T)*3.28084; %a in fps
end