function sun_soi_plot(u0,y2_prop,y2_earth_data,y2_mars_data,t2_planets,consts,inputTitle,validate)
    tof2_max = consts(12);    
    tof2 = u0(1) * tof2_max;
    u2 = u0(2:end);
    N2 = length(u2)/2;
    control2 = u2(1:N2); %Force
    alpha2 = u2(N2+1:end);
    t2 = linspace(0,tof2,N2);
    t = linspace(0,tof2,size(y2_prop,1));
    alpha_max=consts(14);
    F2_max = consts(9);

    %Check for tof2<1
    if(tof2>=1)
        N2_ = round(length(t2_planets)*tof2/t2_planets(end));
    else
        N2_ = 1;
    end
% 
%     X = y2_prop(1:end,1);
%     Y = y2_prop(1:end,2);
%     for i = 1:size(y2_prop,1)
%         
%         alpha = pchip(t2,alpha2,t(i));
%         throttle = pchip(t2,control2,t(i));
%         F = throttle * F2_max;
%         alpha = (alpha - 0.5)* 2 * alpha_max;
%         [velocity_direction] = cart2pol(y2_prop(i,4),y2_prop(i,5));
%         force_direction = velocity_direction+alpha;
%         Fx = F*cos(force_direction);
%         Fy = F*sin(force_direction);
% 
%         if(i == 1)
%             U = Fx;
%             V=Fy;
%         else
%         U = [U; Fx];
%         V = [V;Fy];
%         end
% 
%     end


    sunPlot = plot(0, 0, '.','MarkerSize', 40);
    set(sunPlot(1),'Color',[1 0.6 0],'DisplayName','Sun');
    hold on
%     quiver(X,Y,U,V);
    earthPlot = plot(y2_earth_data(N2_,1),y2_earth_data(N2_,2), '.','MarkerSize', 20);
    set(earthPlot(1),'Color',[0 0.2 1],'DisplayName','Earth');
    earthOrbitPlot = plot(y2_earth_data(1:N2_,1),y2_earth_data(1:N2_,2));
    set(earthOrbitPlot(1),'Color',[0 0.2 1],'DisplayName','Earth Orbit');
    earthOrbitPlot.LineWidth = 1;
    marsOrbitPlot = plot(y2_mars_data(1:N2_,1),y2_mars_data(1:N2_,2));
    marsOrbitPlot.LineWidth = 1;
    set(marsOrbitPlot(1),'Color',[1 0 0],'DisplayName','Mars Orbit');
    marsPlot = plot(y2_mars_data(N2_,1),y2_mars_data(N2_,2), '.','MarkerSize', 20);
    set(marsPlot(1),'Color',[1 0 0],'DisplayName','Mars');

    if (validate == false)
        shipOrbitPlot = plot(y2_prop(1:end,1),y2_prop(1:end,2));
    else
        shipOrbitPlot = plot(y2_prop(1:end,1),y2_prop(1:end,2),'-.');
    end

    shipOrbitPlot.LineWidth = 1;
    set(shipOrbitPlot(1),'Color',[0 0 0],'DisplayName','Ship Orbit');
    shipPlot = plot(y2_prop(end,1),y2_prop(end,2), '.','MarkerSize', 10);
    set(shipPlot(1),'Color',[1 0 0],'DisplayName','Ship');

    axis([-2 2 -2 2]); %in AU
    xlabel('Position (AU)')
    axis equal
    grid on
    title(inputTitle,'FontSize',15)
    set(gca,'fontname','Segoe UI Semibold');set(gca,'FontSize',12)

end
