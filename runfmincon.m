function [u_opt,FVAL,history,searchdir,EXITFLAG] = runfmincon(u0,ui,R_earth,m_ship,N0,consts,y_earth_data,y_mars_data,t2_planets)

%Upper Lower Bound Values
u_min(ui(1,1):ui(1,2)) = 0; u_max(ui(1,1):ui(1,2)) = 1; %m_start
u_min(ui(2,1):ui(2,2)) = 0; u_max(ui(2,1):ui(2,2)) = 1; %theta_earth
u_min(ui(3,1):ui(3,2)) = 0.001; u_max(ui(3,1):ui(3,2)) = 1; %tof1
u_min(ui(4,1):ui(4,2)) = 0; u_max(ui(4,1):ui(4,2)) = 1;%u1
u_min(ui(5,1):ui(5,2)) = 0; u_max(ui(5,1):ui(5,2)) = 1;%alpha1 
u_min(ui(6,1):ui(6,2)) = 0.001; u_max(ui(6,1):ui(6,2)) = 1;%tof2
u_min(ui(7,1):ui(7,2)) = 0; u_max(ui(7,1):ui(7,2)) = 1;%u2
u_min(ui(8,1):ui(8,2)) = 0; u_max(ui(8,1):ui(8,2)) = 1;%alpha2
u_min(ui(9,1):ui(9,2)) = 0.001; u_max(ui(9,1):ui(9,2)) = 1;%tof3
u_min(ui(10,1):ui(10,2)) = 0; u_max(ui(10,1):ui(10,2)) = 1;%u3
u_min(ui(11,1):ui(11,2)) = 0; u_max(ui(11,1):ui(11,2)) = 1;%alpha3

history.x = [];
history.fval = [];
searchdir = [];

u0Last = []; % Last place computeall was called
myf = []; % Use for objective at xLast
myc = []; % Use for nonlinear inequality constraint

%%FMINCON
FUN = @(u0)cost(u0,ui,R_earth,m_ship,N0,consts,y_earth_data,y_mars_data,t2_planets);
A = []; B = []; Aeq = []; Beq = [];
LB = [u_min];
UB = [u_max];
NONLCON = @(u0)constraints(u0,ui,R_earth,m_ship,N0,consts,y_earth_data,y_mars_data,t2_planets);
OPTIONS = optimoptions('fmincon','OutputFcn',@outfun,'Display','iter','Algorithm','sqp','StepTolerance',1e-6,'ConstraintTolerance',0.001,'MaxFunctionEvaluations', 25000,'UseParallel',true);
[u_opt,FVAL,EXITFLAG]  = fmincon(FUN,u0,A,B,Aeq,Beq,LB,UB,NONLCON,OPTIONS);

function J = cost(u0,ui,R_earth,m_ship,N0,consts,y_earth_data,y_mars_data,t2_planets)
    if ~isequal(u0,u0Last) % Check if computation is necessary
        [myf,myc] = computeEverything(u0,ui,R_earth,m_ship,N0,consts,y_earth_data,y_mars_data,t2_planets);
        u0Last = u0;
    end
    % Now compute objective function
    J = myf;
end

function [c,ceq] = constraints(u0,ui,R_earth,m_ship,N0,consts,y_earth_data,y_mars_data,t2_planets)
    if ~isequal(u0,u0Last) % Check if computation is necessary
        [myf,myc] = computeEverything(u0,ui,R_earth,m_ship,N0,consts,y_earth_data,y_mars_data,t2_planets);
        u0Last = u0;
    end
    % Now compute constraint function
    c = myc; % In this case, the computation is trivial
    ceq = [];
end

function stop = outfun(x,optimValues,state)
    stop = false;

    switch state
        case 'init'
        case 'iter'
            history.fval = [history.fval; optimValues.fval];
            history.x = [history.x;x];
           searchdir = [searchdir;optimValues.searchdirection'];
        case 'done'
        otherwise
    end
    
end

end