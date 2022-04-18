function [y1_ship,tf,y1_prop] = earthDeparture(u0,y0_ship,consts)

%Setup with M propagation steps & 10 control nodes
M1 = 250; %No propagation steps %Formerly 200

% tof1_max = consts(11);
% 
% tof1 = u0(1) * tof1_max;
% u1 = u0(2:end);
% N1 = length(u1)/2;
% control1 = u1(1:N1); %Force
% alpha1 = u1(N1+1:end);
% t1 = linspace(0,tof1,N1);
% tspan1 = linspace(0,tof1,M1);

% [tf,y1_prop] = ode45(@(t,y0_ship) earthMotion(t,y0_ship,consts,t1,control1,alpha1), tspan1, y0_ship);
tof_max = consts(11);
[y1_prop,tf] = rk4(@earthMotion,y0_ship,M1,consts,u0,tof_max); 
y1_ship = y1_prop(end,1:7);

end