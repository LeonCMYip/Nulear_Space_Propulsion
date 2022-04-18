function [y1_prop,y2_prop,y3_prop] = verifyResults(u0,ui,R_earth,m_ship,N0,consts,JD1,y1_prop_opt,y2_prop_opt,y3_prop_opt,y4_prop_opt)
%Propagates orbits using ODE78 and plots results


%Unpack control variables and "unnormalise" them
tof1_max = consts(11);tof2_max = consts(12);tof3_max = consts(13);

N1 = N0(1);N2 = N0(2); N3 = N0(3);
m_start = u0(1)*m_ship;
theta_earth = u0(2)*2*pi;
tof1 = u0(ui(3,1):ui(3,2))*tof1_max; tof2 = u0(ui(6,1):ui(6,2))*tof2_max; tof3 = u0(ui(9,1):ui(9,2))*tof3_max;
%Split control into legs
u1 = [u0(ui(3,1):ui(3,2)) u0(ui(4,1):ui(4,2)) u0(ui(5,1):ui(5,2))]; 
u2 = [u0(ui(6,1):ui(6,2)) u0(ui(7,1):ui(7,2)) u0(ui(8,1):ui(8,2))]; 
u3 = [u0(ui(9,1):ui(9,2)) u0(ui(10,1):ui(10,2)) u0(ui(11,1):ui(11,2))]; 
mu_earth = consts(1);
mu_mars = consts(3);

AU = consts(15);
v_convert = consts(16);

control1 = u0(ui(4,1):ui(4,2));
control2 = u0(ui(7,1):ui(7,2));
control3 = u0(ui(10,1):ui(10,2));

%%Propagate Intial Guess

%Set starting location
y0_ship = setCircularOrbit(R_earth, theta_earth,mu_earth);
y0_ship(7) = m_start; 

%Planet Dynamics
[y_earth_data,y_mars_data] = planetDynamics(JD1,500,5000);
t2_planets = linspace(0,500,5000);

%Propagate Earth Departure
[y1_ship,t1,y1_prop] = earthDeparture45(u1,y0_ship,consts);

%Convert from km into AU for heliocentric frame
y1_ship_converted(1:3) = y_earth_data(1,1:3) + y1_prop(end,1:3)./AU;
y1_ship_converted(4:6) = y_earth_data(1,4:6) + y1_prop(end,4:6)*v_convert;
y1_ship_converted(7) = y1_prop(end,7);

%Propagate Heliocentric orbit
[y2_ship,t2,y2_prop] = helioTransfer45(u2,y1_ship_converted,consts);

%Calculate Mars end position
y_mars_end = pchip(t2_planets,y_mars_data',tof2)';

%Convert AU back into km
y2_ship_converted(1:3) = (y2_ship(1:3) -  y_mars_end(1:3)).*AU;
y2_ship_converted(4:6) = (y2_ship(4:6) -  y_mars_end(4:6))./v_convert;
y2_ship_converted(7) = y2_ship(7);

%Propagate Mars arrival
[y3_ship,t3,y3_prop] = marsArrival45(u3,y2_ship_converted,consts);

%Set extra propagation control variables
u4(1) = 2;
u4(2:202) =0;
u4(203:403) =0.5;

%Propagate orbit further for demonstration purposes
[y4_ship,t4,y4_prop] = marsArrival45(u4,y3_ship,consts);

r1_ship_norm = norm(y1_ship(1:3))

r2_ship = [y2_ship(1:3)];
r2_mars = [y_mars_end(1:3)];
r2_ship_mars = r2_mars-r2_ship;
r2_ship_mars_norm = norm(r2_ship_mars)

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


%Intial Guess Plot
figure3=figure('Position', [1000, 0, 720, 480]);
earth_soi_plot(u1,y1_prop,true);
hold on 
earth_soi_plot(u1,y1_prop_opt,false);

saveas(gcf,"NERVA2029/VEarthSOI.png");
figure4=figure('Position', [1000, 0, 720, 480]);
p1 = plot(t1,throttle1); xlabel("Time (Days)"); ylabel('Throttle');
p1.LineWidth = 1.5;
hold on
p1_u = plot(tof1_lin,control1,'o');
p1_u.LineWidth = 1.5;
p1_u.Color = [0 0.4470 0.7410];
axis([0 tof1_lin(end) 0 1]); 
title("Earth Control Optimised",'FontSize',15) ;set(gca,'fontname','Segoe UI Semibold');set(gca,'FontSize',12)
saveas(gcf,"NERVA2029/VEarthControl.png");
figure5=figure('Position', [1000, 0, 720, 480]);
sun_soi_plot(u2,y2_prop,y_earth_data,y_mars_data,t2_planets,consts,"Heliocentric Transfer",true);
hold on 
sun_soi_plot(u2,y2_prop_opt,y_earth_data,y_mars_data,t2_planets,consts,"Heliocentric Transfer",false);
saveas(gcf,"NERVA2029/VSolarSOI.png");
figure6=figure('Position', [1000, 0, 720, 480]);
p2 = plot(t2,throttle2); xlabel("Time (Days)"); ylabel('Throttle');
p2.LineWidth = 1.5;
hold on
p2_u = plot(tof2_lin,control2,'o');
p2_u.LineWidth = 1.5;
p2_u.Color = [0 0.4470 0.7410];
axis([0 tof2_lin(end) 0 1]); 
title("Sun Control Optimised",'FontSize',15) ;set(gca,'fontname','Segoe UI Semibold');set(gca,'FontSize',12)
saveas(gcf,"NERVA2029/VSolarControl.png");
figure7=figure('Position', [1000, 0, 720, 480]);
mars_soi_plot(y4_prop_opt,true,false);
mars_soi_plot(y4_prop,true,true);
mars_soi_plot(y3_prop,false,true);
mars_soi_plot(y3_prop_opt,false,false);
saveas(gcf,"NERVA2029/VMarsSOI.png");
figure8=figure('Position', [1000, 0, 720, 480]);
p3 = plot(t3,throttle3); xlabel("Time (Days)"); ylabel('Throttle');
p3.LineWidth = 1.5;
hold on
p3_u = plot(tof3_lin,control3,'o');
p3_u.LineWidth = 1.5;
p3_u.Color = [0 0.4470 0.7410];
axis([0 tof3_lin(end) 0 1]); 
title("Mars Control Optimised",'FontSize',15); set(gca,'fontname','Segoe UI Semibold');set(gca,'FontSize',12)
saveas(gcf,"NERVA2029/VMarsControl.png");

end