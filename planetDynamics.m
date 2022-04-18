function [y_earth_data,y_mars_data] = planetDynamics(JD,T,N)

% G = 6.6742e-20;
G = 1.488e-34; %AU^3/kg.Days^2
AU = 149597870.7; %in km
m_earth = 5.974e24;
m_mars = 5.974e24;
m_sun = 1.9885e30;
m_ship = 100000;

mu_earth = G*m_earth;
mu_sun = G*m_sun;

v_convert = (1/AU)/(1/86400); %Convert m/s into AU/Day

t = linspace(JD,JD+T,N);

%Heliocentric Transfer Leg
for i = 1:N

    datetime(t(i),'convertfrom','juliandate');
    [r_earth,v_earth] = ephemeris(1,t(i));
    [r_mars,v_mars] = ephemeris(2,t(i));
    
    r_earth = r_earth./AU;
    r_mars = r_mars./AU;
    v_earth = v_earth.*v_convert;
    v_mars = v_mars.*v_convert;
    
    y_earth_data(i,1:6) = [r_earth v_earth];
    y_mars_data(i,1:6) = [r_mars v_mars];


%     t_span_2 = [0 T];
%     h = T/N;
%     t = linspace(0,T,N+1);
%     u_sun = zeros(N+1,6);
%     u_sun(1:N+1,1) = mu_sun;
%     
%     [y_earth_data] = rk4(@planetMotion,y0_earth,N,T,u_sun);
%     [y_mars_data] = rk4(@planetMotion,y0_mars,N,T,u_sun);


end

    y_earth_data(:,3) = 0;    y_earth_data(:,6) = 0;
    y_mars_data(:,3) = 0;    y_mars_data(:,6) = 0;

end

