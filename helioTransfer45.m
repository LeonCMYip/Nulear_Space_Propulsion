function [y2_ship,tf2,y2_prop] = helioTransfer45(u0,y1_ship,consts)

tof2_max = consts(12);

tof2 = u0(1) * tof2_max;
u2 = u0(2:end);
N2 = length(u2)/2;
control2 = u2(1:N2); %Force
alpha2 = u2(N2+1:end);
t2 = linspace(0,tof2,N2);
% tspan2 = [0 tof2];
tspan2 = linspace(0,tof2,151);

opts = odeset('Reltol',1e-10,'AbsTol',1e-10);
[tf2,y2_prop] = ode45(@(t,y1_ship) solarMotion(t,y1_ship,consts,t2,control2,alpha2), tspan2, y1_ship);
y2_ship = y2_prop(end,1:7);

end

