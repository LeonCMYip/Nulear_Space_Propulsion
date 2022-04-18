function [y3_ship,tf,y3_prop] = marsArrival(u0,y2_ship,consts)

%Setup with M propagation steps & 10 control nodes
M3 = 300; %No propagation steps %Formerly 300

% tof3_max = consts(13);
% 
% tof3 = u0(1) * tof3_max;
% u3 = u0(2:end);
% N3 = length(u3)/2;
% control3 = u3(1:N3); %Force
% alpha3 = u3(N3+1:end);
% t3 = linspace(0,tof3,N3);
% tspan3 = linspace(0,tof3,M3);

% [tf,y3_prop] = ode45(@(t,y2_ship) marsMotion(t,y2_ship,consts,t3,control3,alpha3), tspan3, y2_ship);
tof3_max = consts(13);
[y3_prop,tf] = rk4(@marsMotion,y2_ship,M3,consts,u0,tof3_max);

y3_ship = y3_prop(end,1:7);

end