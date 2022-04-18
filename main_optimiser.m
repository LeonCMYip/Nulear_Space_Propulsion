%&Nuclear Propulsion Trajectory Optimisation Model
clc
clear
close all
tic
%Get planetary data for departure and arrival date
JD1 = 2461333; %datetime(2458999,'convertfrom','juliandate') =    29-May-2020 12:00:00 %2462126 2029


%%Setup
%Physical Constants
G1 = 6.6742e-20; %km^3/kg.s^2
G2 = 1.488e-34; %AU^3/kg.Days^2
AU = 149597870.7; %in km
g = 9.81; %m/s^2
v_convert = 5.77548e-04; 
m_earth = 5.974e24;
m_mars = 0.64171e24;
m_sun = 1.9885e30;
alpha_max = 0.1745;

mu_earth = 3.98717e+05;
mu_sun = 2.95889e-04;
mu_mars = 4.28290e+04;

%Ship Properties
%Select Propulsion Model
%1 - 100x VASIMR engines
%2 - NERVA
%3 - 68kN NRE
%4 - BNL Concept
%5 - NSTAR
%7 - MITEE
%8 - Gas core
filename = 'ship_models.csv';
ship_models = readmatrix(filename);
ship_no = 1;
m_ship = ship_models(ship_no,1); n = ship_models(ship_no,2); P = ship_models(ship_no,3); Isp = ship_models(ship_no,4); F = ship_models(ship_no,5);

%Intial Guess Earth
R_earth = 6371+400; %Recommended AIAA - 80000km; NERVA - 6500

tof1_max = 5e5; %VASIMR 5e6 %AIAA 14e7; %NTP 5e5 %MITEE1e6
N1 = 24;%no steps
tof2_max = 500;
N2 = 48; %Steps
tof3_max = 0.8e6;
N3 = 24;%no steps

N0 = [N1 N2 N3];
u0 = readmatrix("InitialGuess.csv");
%Indexing system
u0_lengths = readmatrix("InitialGuessIndex.csv");
ui = u0_sort(u0_lengths);

consts = [mu_earth mu_sun mu_mars n P g Isp F F*49.9 F tof1_max tof2_max tof3_max alpha_max AU v_convert];

M_U = calcualteFuelMass(P, 1e17,0.0072);

% for JD1 = 2462116:5:2462121

% close all

%Planet Dynamics
[y_earth_data,y_mars_data] = planetDynamics(JD1,500,5000);
t2_planets = linspace(0,500,5000);

%%Main Body
[y1_prop_init,y2_prop_init,y3_prop_init] = processResults(u0,ui,R_earth,m_ship,N0,consts,y_earth_data,y_mars_data,t2_planets);
% r1 = norm([y1_prop_init(end,1) y1_prop_init(end,2)]);
% v2_end = norm([ y2_prop_init(end,4) y2_prop_init(end,5)]);
% [y1_prop_init_ver,y2_prop_init_ver,y3_prop_init_ver] = verifyResults(u0,ui,R_earth,m_ship,N0,consts,JD1); 
%Initial Guess Verification (Sucessful 28/2/22)

[u_opt,FVAL,history,searchdir,EXITFLAG] = runfmincon(u0,ui,R_earth,m_ship,N0,consts,y_earth_data,y_mars_data,t2_planets);

%%Process Results
[y1_prop_opt,y2_prop_opt,y3_prop_opt,y4_prop_opt] = processResults(u_opt,ui,R_earth,m_ship,N0,consts,y_earth_data,y_mars_data,t2_planets);
% subplot(3,2,5);
% mars_soi_plot(y4_prop_opt,true);
% [y1_prop_v,y2_prop_v,y3_prop_v] = verifyResults(u_opt,ui,R_earth,m_ship,N0,consts,JD1,y1_prop_opt,y2_prop_opt,y3_prop_opt,y4_prop_opt); 

%Write history to file
outputString = "PBR/Simulation-" + datestr(datetime('now'),30) + ".csv";
writematrix(history.x,outputString);

v1_ship_norm = norm(y1_prop_opt(end,1:3))
tof1_opt = u_opt(ui(3,1):ui(3,2))*tof1_max
tof2_opt = u_opt(ui(6,1):ui(6,2))*tof2_max
tof3_opt = u_opt(ui(9,1):ui(9,2))*tof3_max

%Write optimium results
u_read = readmatrix("PBR/PBR.csv");
u_read = [u_read; [JD1 EXITFLAG FVAL u_opt]];
writematrix(u_read,"PBR/PBR.csv");

% end
runtime = toc
% u_read = [JD1 EXITFLAG FVAL u_opt];
% writematrix(u_read,"VASIMR_SIM/AIAA_VASIMR5.csv");
% toc
