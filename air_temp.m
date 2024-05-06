function [T] = air_temp(h)
%air_temp provides temperature of air in Kelvin on standard day at a given altitude
%in feet
%     if h == 20000
%         T = 248.52;
%     else
    h = h/3.28;
    T0 = 273.15 + 15; % K
    a1 = -0.0065; % K/m
    a2 = 0; % K/m
%     T = piecewise(0<=h<7000,T0+a1*h,7000<=h<=12000,T0+a1*7000+a2*(h-7000))
    if h <= 11000
        T = T0+a1*h;
    end
    
    if h > 11000
        T = T0+a1*7000 + a2*(h-7000);
    end
%     end
end

