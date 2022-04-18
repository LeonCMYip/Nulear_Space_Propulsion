function [y3_ship,tf,y3_prop] = marsArrival45(u0,y2_ship,consts)

%Setup with M propagation steps & 10 control nodes

tof3_max = consts(13);

tof3 = u0(1) * tof3_max;
u3 = u0(2:end);
N3 = length(u3)/2;
control3 = u3(1:N3); %Force
alpha3 = u3(N3+1:end);
t3 = linspace(0,tof3,N3);
% tspan3 = [0 tof3];
tspan3 = linspace(0,tof3,601);

opts = odeset('Reltol',1e-10,'AbsTol',1e-10);
[tf,y3_prop] = ode45(@(t,y2_ship) marsMotion(t,y2_ship,consts,t3,control3,alpha3), tspan3, y2_ship);

y3_ship = y3_prop(end,1:7);


end
