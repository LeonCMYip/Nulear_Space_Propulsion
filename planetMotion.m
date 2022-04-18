function ydot = planetMotion(t,fy,u) %Input state vector of ship plus forces | Output rate of change of vector
mu = u(1);
rx = fy(1);
ry = fy(2);
rz = fy(3);
dx = fy(4);
dy = fy(5);
dz = fy(6);
r_norm = norm([rx ry rz]);
v_norm = norm([dx dy dz]);
d2x = -mu*rx/r_norm^3;
d2y = -mu*ry/r_norm^3;
d2z = -mu*rz/r_norm^3;
ydot = [dx dy dz d2x d2y d2z];
end