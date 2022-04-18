function [r,v] = ephemeris(p,JD)

%Keplerian elements table from https://ssd.jpl.nasa.gov/planets/approx_pos.html

AU = 149597870.7;
mu_sun = 1.32712440018e11;

if p == 1 % 1 for Earth
    J2k_a = 1.00000261;
    J2k_arate = 0.00000562;
    J2k = 0.01671123;
    J2krate = -0.00004392;
    J2k_i = -0.00001531;
    J2k_irate = -0.01294668;
    J2k_L = 100.46457166;
    J2k_Lrate = 35999.37244981;
    J2k_wbar = 102.93768193;
    J2k_wbarrate = 0.32327364;
    J2k_o = 0;
    J2k_orate = 0;
elseif p == 2 % 2 for Mars
    J2k_a = 1.52371034;
    J2k_arate = 0.0001847;
    J2k = 0.09339410;
    J2krate = 0.00007882;
    J2k_i = 1.84969142;
    J2k_irate = -0.00813131;
    J2k_L = -4.55343205;
    J2k_Lrate =  19140.30268499;
    J2k_wbar = -23.94362959;
    J2k_wbarrate = 0.44441088;
    J2k_o =  49.55953891;
    J2k_orate = -0.29257343;
else
    disp("Planets not chosen")
    return;
end


%Step 1: Calculate Julian Day No.
% J0 = 367 * year - fix((7*(2003+fix((month + 9)/12)))/4) +fix((275*month)/9)+day + 1721013.5;
% 
% JD = J0 + hr/24;

%Step 2: Calculate number of centuries between J200 and current year
T0 = (JD - 2451545)/36525;

%Step 3 calculate current keplerian elements

a = calcElement(J2k_a,J2k_arate,T0) * AU;
e = calcElement(J2k,J2krate,T0);
i = rem(calcElement(J2k_i,J2k_irate,T0),360);
o = rem(calcElement(J2k_o,J2k_orate,T0),360);
wbar = rem(calcElement(J2k_wbar,J2k_wbarrate,T0),360);
L = rem(calcElement(J2k_L,J2k_Lrate,T0),360);

if(i < 0)
i = i + 360;
end
if(o < 0)
o = o + 360;
end
if(wbar < 0)
wbar = wbar + 360;
end
if(i < 0)
L = L + 360;
end

i = (pi/180)* i;
o = (pi/180)* o;
wbar = (pi/180)* wbar;
L = (pi/180)* L;

%Step 4: Calculate Angular Momentum h

h = sqrt(mu_sun * a * (1- e^2));

%Step 5: find argument of perihelion w and mean anomaly M

w = wbar - o;
M = L - wbar;

if(w < 0)
w = w + 2*pi;
end
if(M < 0)
M = M + 2*pi;
end

%Step 6 solve Kepler's equation for eccentric anomaly E

E = kepler_E(e,M); %recheck


if(E < 0)
E = E + 2 *  pi;
end

%Step 7: find true anomaly theta

theta = 2*atan( sqrt( (1+e)/(1-e) )*(tan(E/2)));

if(theta < 0)
theta = theta + 2*pi;
end

%Step 8: use algorithm 4.5 from 'OMfE'

rxbar = (((h^2)/mu_sun)*(1/(1+e*cos(theta)))).*[cos(theta),sin(theta),0]';

vxbar = (mu_sun/h)*[-sin(theta),(e+cos(theta)),0]';

Qbar = [-sin(o)*cos(i)*sin(w)+cos(o)*cos(w) , -sin(o)*cos(i)*cos(w)-cos(o)*sin(w) , sin(o)*sin(i);
                 cos(o)*cos(i)*sin(w)+sin(o)*cos(w) , cos(o)*cos(i)*cos(w)-sin(o)*sin(w) , -cos(o)*sin(i);
                 sin(i)*sin(w) , sin(i)*cos(w) , cos(i)];


r = Qbar * rxbar;
r = r';
v = Qbar * vxbar;
v = v';
function Q = calcElement(Q0,Qdot,T0)

Q = Q0 + Qdot * T0;

end

end