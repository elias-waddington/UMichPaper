function vis = airviscocity(h)
    T = air_temp(h);
    vis = 3.62e-7*((T*9/5)/518.7)^1.5*((518.7+198.72)/(T+198.72));
end