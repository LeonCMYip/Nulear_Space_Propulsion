function [y1_ship,tf,y1_prop] = earthDeparture45(u0,y0_ship,consts)

tof1_max = consts(11);

tof1 = u0(1) * tof1_max;
u1 = u0(2:end);
N1 = length(u1)/2;
control1 = u1(1:N1); %Force
alpha1 = u1(N1+1:end);
t1 = linspace(0,tof1,N1);
% tspan1 = [0 tof1];
tspan1 = linspace(0,tof1,501);

opts = odeset('Reltol',1e-10,'AbsTol',1e-10);
[tf,y1_prop] = ode45(@(t,y0_ship) earthMotion(t,y0_ship,consts,t1,control1,alpha1), tspan1, y0_ship);

y1_ship = y1_prop(end,1:7);

end
