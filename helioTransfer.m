function [y2_ship,tf2,y2_prop] = helioTransfer(u0,y1_ship,consts)

%Setup with M propagation steps & N control nodes
M2 = 150; %No propagation steps

% tof2_max = consts(12);
% 
% tof2 = u0(1) * tof2_max;
% u2 = u0(2:end);
% N2 = length(u2)/2;
% control2 = u2(1:N2); %Force
% alpha2 = u2(N2+1:end);
% t2 = linspace(0,tof2,N2);
% tspan2 = linspace(0,tof2,M2);

% [tf2,y2_prop] = ode45(@(t,y1_ship) solarMotion(t,y1_ship,consts,t2,control2,alpha2), tspan2, y1_ship);
tof2_max = consts(12);
[y2_prop,tf2] = rk4(@solarMotion,y1_ship,M2,consts,u0,tof2_max);
y2_ship = y2_prop(end,1:7);


end