function [y1_prop,y2_prop,y3_prop,y4_prop] = processResults(u,ui,R_earth,m_ship,N0,consts,y_earth_data,y_mars_data,t2_planets)
%Takes optimal control, propagates it across all three legs and plots results

%%Optimal Results Propagation
%Process Data
%Unpack control variables and "unnormalise" them
tof1_max = consts(11);tof2_max = consts(12);tof3_max = consts(13);

N1 = N0(1);N2 = N0(2); N3 = N0(3);
% m_start = u(1)*m_ship;
theta = u(2)*2*pi;
tof1 = u(ui(3,1):ui(3,2))*tof1_max; tof2 = u(ui(6,1):ui(6,2))*tof2_max; tof3 = u(ui(9,1):ui(9,2))*tof3_max;
%Split control into legs
u1 = [u(ui(3,1):ui(3,2)) u(ui(4,1):ui(4,2)) u(ui(5,1):ui(5,2))]; 
u2 = [u(ui(6,1):ui(6,2)) u(ui(7,1):ui(7,2)) u(ui(8,1):ui(8,2))]; 
u3 = [u(ui(9,1):ui(9,2)) u(ui(10,1):ui(10,2)) u(ui(11,1):ui(11,2))]; 
mu_earth = consts(1);
mu_mars = consts(3);

AU = consts(15);
v_convert = consts(16);

control1 = u(ui(4,1):ui(4,2));
control2 = u(ui(7,1):ui(7,2));
control3 = u(ui(10,1):ui(10,2));

[J,c,y1_prop,y2_prop,y3_prop,y_mars_end] = computeEverything(u,ui,R_earth,m_ship,N0,consts,y_earth_data,y_mars_data,t2_planets);

y1_ship = y1_prop(end,1:7);
y2_ship = y2_prop(end,1:7);
y3_ship = y3_prop(end,1:7);

%Set extra propagation control variables
u4(1) = 12;
u4(2:202) =0;
u4(203:403) =0.5;

%Propagate orbit further for demonstration purposes
[y4_ship,t4,y4_prop] = marsArrival(u4,y3_ship,consts);

r1_ship_norm = norm(y1_ship(1:3))

r2_ship = [y2_ship(1:3)];
r2_mars = [y_mars_end(1:3)];
r2_ship_mars = r2_mars-r2_ship;
r2_ship_mars_norm = norm(r2_ship_mars(1:3))

v2_ship = [y2_ship(4:6)];
v2_mars = [y_mars_end(4:6)];
v2_ship_mars = v2_mars-v2_ship;
v2_ship_mars_norm = norm(v2_ship_mars)
v2_ship_mars_norm_converted = v2_ship_mars_norm/v_convert

r3_ship = y3_ship(1:3);
v3_ship = y3_ship(4:6);
r3_ship_norm = norm(y3_ship(1:3))
v3_ship_norm = norm(y3_ship(4:6))

h = cross(r3_ship,v3_ship);
v_tan  = norm(h)/r3_ship_norm; % correct
C = cross(v3_ship,h)-mu_mars*(r3_ship/r3_ship_norm); %Laplace vector
e_vec = C./mu_mars; %Eccentricity vector
e = norm(e_vec)

true_anomaly = acos((dot(e_vec,r3_ship))/(e*r3_ship_norm))
vr = (mu_earth/norm(h))*e*sin(true_anomaly)

f_angle = atan( (e*sin(true_anomaly))/(1+e*cos(true_anomaly)) )

E = ((v3_ship_norm^2)/2)-(mu_mars/r3_ship_norm);
a = -(mu_mars)/(2*E);
rp = a*(1-e)
ra = a*(1+e)


%Timespace
tof1_lin = linspace(0,tof1,length(control1))/86400;
tof2_lin = linspace(0,tof2,length(control2));
tof3_lin = linspace(0,tof3,length(control3))/86400;

t1 = linspace(0,tof1,400)/86400;
t2 = linspace(0,tof2,400);
t3 = linspace(0,tof3,400)/86400;

for i = 1:400

    throttle1(i) = pchip(tof1_lin,control1,t1(i));
    throttle2(i) = pchip(tof2_lin,control2,t2(i));
    throttle3(i) = pchip(tof3_lin,control3,t3(i));

end

%Plot optimised results
figure2=figure('Name','Optimised Results Propagation','Position', [1000, 0, 1024, 1200]);

% figure3=figure('Position', [1000, 0, 640, 420]);
subplot(3,2,1);
earth_soi_plot(u1,y1_prop,false);
% saveas(gcf,"EarthSOI.png");
subplot(3,2,2);
% figure4=figure('Position', [1000, 0, 640, 420]);
p1 = plot(t1,throttle1); xlabel("Time (Days)"); ylabel('Throttle');
p1.LineWidth = 1;
hold on
p1_u = plot(tof1_lin,control1,'o');
p1_u.LineWidth = 1.5;
p1_u.Color = [0 0.4470 0.7410];
axis([0 tof1_lin(end) 0 1]); 
title("Earth Control Optimised",'FontSize',15) ;set(gca,'fontname','Segoe UI Semibold');set(gca,'FontSize',12)
% saveas(gcf,"NERVA2029/EarthControl.png");
% figure5=figure('Position', [1000, 0, 640, 420]);
subplot(3,2,3);
sun_soi_plot(u2,y2_prop,y_earth_data,y_mars_data,t2_planets,consts,"Heliocentric Transfer",false);
% saveas(gcf,"NERVA2029/SolarSOI.png");
% figure6=figure('Position', [1000, 0, 640, 420]);
subplot(3,2,4);
p2 = plot(t2,throttle2); xlabel("Time (Days)"); ylabel('Throttle');
p2.LineWidth = 1.5;
hold on
p2_u = plot(tof2_lin,control2,'o');
p2_u.LineWidth = 1.5;
p2_u.Color = [0 0.4470 0.7410];
axis([0 tof2_lin(end) 0 1]); 
title("Sun Control Optimised",'FontSize',15) ;set(gca,'fontname','Segoe UI Semibold');set(gca,'FontSize',12)
% saveas(gcf,"NERVA2029/SolarControl.png");
% figure7=figure('Position', [1000, 0, 640, 420]);
subplot(3,2,5);
mars_soi_plot(y4_prop,true,false);
mars_soi_plot(y3_prop,false,false);
% bonk = [y3_prop(1:end,1); y4_prop(1:end,1); y3_prop(1:end,2); y4_prop(1:end,2)];
% axis([min(bonk)-20e3 max(bonk)+20e3 min(bonk)-20e3 max(bonk)+20e3]);
% saveas(gcf,"NERVA2029/MarsSOI.png");
% figure8=figure('Position', [1000, 0, 640, 420]);
subplot(3,2,6);
p3 = plot(t3,throttle3); xlabel("Time (Days)"); ylabel('Throttle');
p3.LineWidth = 1.5;
hold on
p3_u = plot(tof3_lin,control3,'o');
p3_u.LineWidth = 1.5;
p3_u.Color = [0 0.4470 0.7410];
axis([0 tof3_lin(end) 0 1]); 
title("Mars Control Optimised",'FontSize',15); set(gca,'fontname','Segoe UI Semibold');set(gca,'FontSize',12)
% saveas(gcf,"NERVA2029/MarsControl.png");

end