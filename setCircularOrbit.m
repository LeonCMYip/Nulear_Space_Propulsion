function y0 = setCircularOrbit(r,theta,mu)
    omega = sqrt(mu/(r^3));
    y0 = [r*cos(theta) r*sin(theta) 0 -omega*r*sin(theta) omega*r*cos(theta) 0];
end