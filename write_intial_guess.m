%Write Initial Guess

theta_earth = 0.2; %Control variable 

m_start  = 1; % = m_ship normalised
tof1 = 0.175;
N1 = 24;%no steps
u1 = zeros(1,N1+1);
u1(1:25) = 1;
% u1(21:23) = 1;
% u1(end-3:end) = 1;
% u1(end) = 0.0;
% u1(1:round(0.1*(N1+1))) = 1;
% u1(round(0.3*(N1+1))+1:N1+1) = 0;
% u1 = [1 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 1 0 0  0 0 0];
alpha1(1:N1+1) = 0.5;

tof2 = 0.534; 
N2 = 24; %Steps
% u2(1:round(0.25*(N2+1))) = 1;
% u2(round(0.25*(N2+1))+1:round(0.85*(N2+1))) = 0;
% u2(round(0.85*(N2+1))+1:N2+1) = 1;
u2 = zeros(1,N2+1);
u2(1) =0.75;
u2(end) =1;
alpha2(1:round(0.4*(N2+1))) = 0.5;
alpha2(round(0.4*(N2+1))+1:round(0.85*(N2+1))) = 0.5;
alpha2(round(0.85*(N2+1))+1:N2+1) = 0.5;


tof3 = 1;%seconds
N3 = 24;%no steps
u3 = zeros(1,N3+1);
u3(1:25) = 1;
% u3(5:23) = 1;
% u3(24) = 0.5;
% u3(16:25) = 1;

% u3(1:round(0.8*(N3+1))) =0;
% u3(round(0.6*(N3+1))+1:N3+1) = 1;
alpha3(1:N3+1) = 0.5;

u0 = [m_start theta_earth tof1 u1 alpha1 tof2 u2 alpha2 tof3 u3 alpha3];
u0_lengths = [length(m_start) length(theta_earth) length(tof1) length(u1) length(alpha1) length(tof2) length(u2) length(alpha2) length(tof3) length(u3) length(alpha3)];

outputString1 = "InitialGuess.csv";
writematrix(u0,outputString1);

outputString2 = "InitialGuessIndex.csv";
writematrix(u0_lengths,outputString2);


