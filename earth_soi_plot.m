function earth_soi_plot(u0,y1_prop,validate)


        earthPlot = nsidedpoly(200, 'Center', [0 0], 'Radius', 6378);
        plot(earthPlot, 'FaceColor', 'b','DisplayName','Earth');
        
        hold on

        if(validate == true)
            orbitPlot = plot(y1_prop(1:end,1),y1_prop(1:end,2),'-.');
            endPlot = plot(y1_prop(end,1),y1_prop(end,2), '.','MarkerSize', 20);
            set(endPlot(1),'Color',[1 0 0],'DisplayName','Ship');
        else
            orbitPlot = plot(y1_prop(1:end,1),y1_prop(1:end,2));
            endPlot = plot(y1_prop(end,1),y1_prop(end,2), '.','MarkerSize', 20);
            set(endPlot(1),'Color',[1 0 0],'DisplayName','Ship');
        end

        orbitPlot.LineWidth = 1;
        set(orbitPlot(1),'Color',[0 0 0],'DisplayName','Orbit');


        axis([min(y1_prop(1:end,1))-20e3 max(y1_prop(1:end,1))+20e3 min(y1_prop(1:end,2))-20e3 max(y1_prop(1:end,2))+20e3]);
        title("Earth Departure",'FontSize',15)
        xlabel('Position (km)')
        axis equal
        grid on
        set(gca,'fontname','Segoe UI Semibold');set(gca,'FontSize',12)

end



%     tof1_max = consts(11);    
%     tof1 = u0(1) * tof1_max;
%     u1 = u0(2:end);
%     N1 = length(u1)/2;
%     control1 = u1(1:N1); %Force
%     alpha1 = u1(N1+1:end);
%     t1 = linspace(0,tof1,N1);
%     t = linspace(0,tof1,size(y1_prop,1));
%     alpha_max=consts(14);
%     F1_max = consts(8);

%     X = y1_prop(1:4:end-1,1);
%     Y = y1_prop(1:4:end-1,2);
%     for i = 1:4:size(y1_prop,1)-1
%         
%         alpha = pchip(t1,alpha1,t(i));
%         throttle = pchip(t1,control1,t(i));
%         F = throttle * F1_max;
%         alpha = (alpha - 0.5)* 2 * alpha_max;
%         [velocity_direction] = cart2pol(y1_prop(i,4),y1_prop(i,5));
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


%         q = quiver(X,Y,U,V);
%         q.MaxHeadSize = 0.05;
%         q.AutoScaleFactor = 0.5;