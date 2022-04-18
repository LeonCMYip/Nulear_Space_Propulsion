    function ydot = earthMotion(t,fy,consts,t1,control1,alpha1) %Input state vector of ship plus forces | Output rate of change of vector

    if(t >= t1(end))
        throttle = control1(end);
        alpha = alpha1(end);
    else
        throttle = pchip(t1,control1,t);
        alpha = pchip(t1,alpha1,t);
    end

%     throttle = pchip(t1,control1,t);
%     alpha = pchip(t1,alpha1,t);

    mu_earth = consts(1); g = consts(6); Isp = consts(7); F1_max = consts(8); alpha_max=consts(14);
    
    %Unpack control
    F = throttle * F1_max;
    alpha = (alpha - 0.5)* 2 * alpha_max;
    rx = fy(1);
    ry = fy(2);
    rz = fy(3);
    dx = fy(4);
    dy = fy(5);
%     dz = fy(6);
    m = fy(7);
    r_norm = norm([rx ry rz]);

%Calculate Force direction
%Force direction = velocity direction + alpha;
    [velocity_direction] = cart2pol(dx,dy);
    force_direction = velocity_direction+alpha;
    Fx = F*cos(force_direction);
    Fy = F*sin(force_direction);

    d2x = -mu_earth*rx/r_norm^3 + Fx/m;
    d2y = -mu_earth*ry/r_norm^3 + Fy/m;
%     d2z = -mu_earth*rz/r_norm^3 + 0; %Will add z component

%     P = P*(F/F1_max);
%     m_dot = -(2*n*P)/((g*Isp)^2);

    m_dot =  -F*(1e3)/(Isp*g);

    ydot = [dx ;dy ;0 ;d2x ;d2y ;0 ;m_dot];
%     ydot = [dx dy 0 d2x d2y 0 m_dot];

    end