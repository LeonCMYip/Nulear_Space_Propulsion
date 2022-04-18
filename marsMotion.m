    function ydot = marsMotion(t,fy,consts,t3,control3,alpha3) %Input state vector of ship plus forces | Output rate of change of vector

    if(t >= t3(end))
        throttle = control3(end);
        alpha = alpha3(end);
    else
        throttle = pchip(t3,control3,t);
        alpha = pchip(t3,alpha3,t);
    end

    mu_mars = consts(3); g = consts(6); Isp = consts(7); F3_max = consts(10); alpha_max=consts(14);

    %Unpack control
    F = throttle * F3_max;
    alpha = (alpha - 0.5)* 2 * alpha_max;

    rx = fy(1);
    ry = fy(2);
    rz = fy(3);
    dx = fy(4);
    dy = fy(5);
%     dz = fy(6);
    m = fy(7);
    r_norm = norm([rx ry rz]);
    v_norm = norm([dx dy]);

%     if(v_norm < 0.2)
%         F = 0;
%     end


    [velocity_direction] = cart2pol(dx,dy);
    force_direction = velocity_direction+pi+alpha; %Opposite direction to veloity + alpha
    Fx = F*cos(force_direction);
    Fy = F*sin(force_direction);

    d2x = -mu_mars*rx/r_norm^3 + Fx/m;
    d2y = -mu_mars*ry/r_norm^3 + Fy/m;
%     d2z = -mu_mars*rz/r_norm^3 + 0;%will add z component back in

%     P = P*(F/F3_max);
%     m_dot = -(2*n*P)/((g*Isp)^2);

    m_dot =  -F*(1e3)/(Isp*g);

    ydot = [dx; dy; 0; d2x; d2y; 0; m_dot];
%     ydot = [dx dy 0 d2x d2y 0 m_dot];

    end