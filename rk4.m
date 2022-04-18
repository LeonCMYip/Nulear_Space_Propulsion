function [yf,tf] = rk4(odefun,y0_ship,M,consts,u0,tof_max)

tof = u0(1) * tof_max;
u1 = u0(2:end);
N1 = length(u1)/2;
control = u1(1:N1); %Force
alpha = u1(N1+1:end);
t = linspace(0,tof,N1);

h = tof/M;
a = [0 1/2 1/2 1];
b = [ 0 0 0 ;
        1/2 0 0 ;
        0 1/2 0 ;
        0 0 1];
c = [ 1/6 1/3 1/3 1/6];

yi = y0_ship;
yf = zeros(M+1,7);
yf(1,1:7) = y0_ship;

ti = 0;
tf = zeros(1,M+1);

    for i = 1:M
    
        f1 = feval(odefun,ti + a(1) * h, yi,consts,t,control,alpha);
        f2 = feval(odefun,ti + a(2) * h, yi + h .* b(2,1) * f1,consts,t,control,alpha);
        f3 = feval(odefun,ti + a(3) * h, yi + h .*(b(3,1) * f1 + b(3,2) * f2),consts,t,control,alpha);
        f4 = feval(odefun,ti + a(4) * h, yi + h .*(b(4,1) * f1 + b(4,2) * f2 + b(4,3) * f3),consts,t,control,alpha);
    
        ynext = yi + h.*(c(1).*f1 + c(2).*f2 + c(3).*f3 + c(4).*f4);
    
        yf(i+1,1:7) = ynext;
    
        yi = ynext;
    
        ti = ti + h;
        tf(i+1) = ti;
    
    end

end