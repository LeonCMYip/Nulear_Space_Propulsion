function [J,c,y1_prop,y2_prop,y3_prop,y_mars_end] = computeEverything(u0,ui,R_earth,m_ship,N0,consts,y_earth_data,y_mars_data,t2_planets)

%Constrain initial ship state to Earth at departure
%Constrain final ship position to Mars' position after time of lfight

%%Targets
r_earth_soi = 9e5; %in km
r_mars_soi = 0.0042; %in AU 0.0042 in km 6.28e5
v_mars_entry_target = 0.003; %AU/days
r_mars_orbit_insertion = 150000; %km
v_mars_circular_veloicty = 0.6; %km/s
min_end_mass = 80000; %kg

%Unpack control variables and "unnormalise" them
tof1_max = consts(11);tof2_max = consts(12);tof3_max = consts(13);

% N1 = N0(1);N2 = N0(2); N3 = N0(3);
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

%Set starting location
y0_ship = setCircularOrbit(R_earth, theta_earth,mu_earth);
y0_ship(7) = m_start; 

%Propagate Earth Departure
% (y1_ship = state at end of propagation; y1_prop = all propagation data)
[y1_ship,t1,y1_prop] = earthDeparture(u1,y0_ship,consts);

%Convert from km into AU for heliocentric frame
y1_ship_converted(1:3) = y_earth_data(1,1:3) + y1_ship(1:3)./AU;
y1_ship_converted(4:6) = y_earth_data(1,4:6) + y1_ship(4:6)*v_convert;
y1_ship_converted(7) = y1_ship(7);

%Propagate Heliocentric orbit
% (y2_ship = state at end of propagation; y2_prop = all propagation data)
[y2_ship,t2,y2_prop] = helioTransfer(u2,y1_ship_converted,consts);

%Calculate Mars end position
y_mars_end = pchip(t2_planets,y_mars_data',tof2)';

%Convert AU back into km
y2_ship_converted(1:3) = (y2_ship(1:3) -  y_mars_end(1:3)).*AU;
y2_ship_converted(4:6) = (y2_ship(4:6) -  y_mars_end(4:6))./v_convert;
y2_ship_converted(7) = y2_ship(7);

%Propagate Mars arrival
% (y3_ship = state at end of propagation; y3_prop = all propagation data)    
[y3_ship,t3,y3_prop] = marsArrival(u3,y2_ship_converted,consts);

%Calculate end conditions
r1_ship_norm = norm(y1_ship(1:3)); %Earth departure position

% r2_ship = [y2_ship(1:3)];
% r2_mars = [y_mars_end(1:3)];
r2_ship_mars = y_mars_end(1:3)-y2_ship(1:3);
r2_ship_mars_norm = norm(r2_ship_mars); %Mars intercept position

v2_ship = [y2_ship(4:6)];
v2_mars = [y_mars_end(4:6)];
v2_ship_mars = v2_mars-v2_ship;
v2_ship_mars_norm = norm(v2_ship_mars); %Mars intercept velocity

r3_ship = y3_ship(1:3);
v3_ship = y3_ship(4:6);
r3_ship_norm = norm(y3_ship(1:3)); %Mars circularisation position
v3_ship_norm = norm(y3_ship(4:6)); %Mars circularisation veloicty

%Keplerian elements calculations
h3 = cross(r3_ship,v3_ship);
% v_tan  = norm(h)/r3_ship_norm;
C3 = cross(v3_ship,h3)-mu_mars*(r3_ship/r3_ship_norm); %Laplace vector
e3_vec = C3./mu_mars; %Eccentricity vector
e3 = norm(e3_vec);

true_anomaly3 = acos((dot(e3_vec,r3_ship))/(e3*r3_ship_norm));
% vr = (mu_mars/norm(h))*e*sin(true_anomaly);

f_angle = atan( (e3*sin(true_anomaly3))/(1+e3*cos(true_anomaly3)) );

% E = ((v3_ship_norm^2)/2)-(mu_mars/r3_ship_norm);
% a = -(mu_mars)/(2*E);
% rp = a*(1-e);
% ra = a*(1+e);

% h2 = cross(r2_ship_mars,v2_ship_mars);
% % v_tan  = norm(h)/r3_ship_norm;
% C2 = cross(v3_ship,h3)-mu_mars*(r2_ship_mars/r2_ship_mars_norm); %Laplace vector
% e2_vec = C2./mu_mars; %Eccentricity vector
% e2 = norm(e2_vec);

% turn_angle = pi-2*acos(1/e2);
% rp_init = (mu_mars/(v2_ship_mars_norm^2))*((1/(cos((pi-turn_angle)/2)))-1);

%circular velocity
% v_cir = sqrt(1.5*(mu_mars)/r3_ship_norm);

c(1) = (-r1_ship_norm+0.9*r_earth_soi)*1e-6; %Earth SOI min
c(2) = (r1_ship_norm-1.1*r_earth_soi)*1e-6; %Earth SOI max
c(3) = (r2_ship_mars_norm-1.2*r_mars_soi)*1e1; %Mars Intercept min
c(4) = (-r2_ship_mars_norm+0.8*r_mars_soi)*1e1; %Mars Intercept max
c(5) = (v2_ship_mars_norm-v_mars_entry_target)*1e1;  %Mars Intercept Velocity
c(6) = (-v2_ship_mars_norm+0.0001)*1e2; %Mars Intercept Velocity
c(7) = (r3_ship_norm-r_mars_orbit_insertion)*1e-5; %Mars Orbit Insertion
c(8) = (-r3_ship_norm+30000)*1e-5; %Mars Orbit Insertion
c(9) = (v3_ship_norm-v_mars_circular_veloicty); %Mars Orbit Insertion Velocity
c(10) = (-v3_ship_norm+0.4*v_mars_circular_veloicty); %Mars Orbit Insertion Velocity changed
c(11) = (-y3_ship(7)+min_end_mass)*1e-5;
c(12) = f_angle-0.6;

ceq = [];
% for i = (1:size(y3_prop,1))
%     R(i) = norm(y3_prop(i,1:3));
%     V(i) = norm(y3_prop(i,4:6));
%     c(13+i) = (-R(i)+8000)*1e-6;
%     c(13+size(y3_prop,1)+i) = (V(i)-6)*1e-1;
%     c(13+i) = (-V(i)+0.2);
% end


J = t1(end)/86400+t2(end)+t3(end)/86400; %Minimise time of flight  

end