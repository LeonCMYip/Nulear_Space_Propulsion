    function ydot = solarMotion(t,fy,consts,t2,control2,alpha2) %Input state vector of ship plus forces | Output rate of change of vector

    if(t >= t2(end))
        throttle = control2(end);
        alpha = alpha2(end);
    else
        throttle = pchip(t2,control2,t);
        alpha = pchip(t2,alpha2,t);
    end
%     t = min(t2(end),t);
% 
%     throttle = pchip(t2,control2,t);
%     alpha = pchip(t2,alpha2,t);

    mu_sun = consts(2); g = consts(6); Isp = consts(7); F2_max = consts(9); alpha_max=consts(14);

    %Unpack
    F = throttle * F2_max;
    alpha = (alpha - 0.5)* 2 * alpha_max;

    rx = fy(1);
    ry = fy(2);
    rz = fy(3);
    dx = fy(4);
    dy = fy(5);
%     dz = fy(6);
    m = fy(7);
    r_norm = norm([rx ry rz]);

    [velocity_direction] = cart2pol(dx,dy);
    force_direction = velocity_direction+alpha;
    Fx = F*cos(force_direction);
    Fy = F*sin(force_direction);

    d2x = -mu_sun*rx/r_norm^3 + Fx/m;
    d2y = -mu_sun*ry/r_norm^3 + Fy/m;
%     d2z = -mu_sun*rz/r_norm^3 + 0;%will add z component back in

%     P = P*86400*(abs(F)/F2_max);
%     m_dot = -(2*n*P)/((g*Isp)^2);

   m_dot =  -(F/(Isp*g))*(1.7314156837e6); %kg/day

    ydot = [dx; dy; 0; d2x; d2y; 0; m_dot];
%     ydot = [dx dy 0 d2x d2y 0 m_dot];
    end