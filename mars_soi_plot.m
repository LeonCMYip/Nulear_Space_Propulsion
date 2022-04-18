function mars_soi_plot(y3_prop,extraProp,validate)

        r2_ship = norm(y3_prop(1,1:3));

        marsPlot = nsidedpoly(200, 'Center', [0 0], 'Radius', 3376.2);
        plot(marsPlot, 'FaceColor', 'r','DisplayName','Mars');
        hold on

        if(extraProp && validate)
            orbitPlot = plot(y3_prop(1:end,1),y3_prop(1:end,2),'--');
        elseif(extraProp && validate == false)
            orbitPlot = plot(y3_prop(1:end,1),y3_prop(1:end,2),'--');
        elseif(extraProp == false && validate == true)
            orbitPlot = plot(y3_prop(1:end,1),y3_prop(1:end,2),'-.');
            endPlot = plot(y3_prop(end,1),y3_prop(end,2), '.','MarkerSize', 10);
            endPlot.Color = [1 0 0];
        else
            orbitPlot = plot(y3_prop(1:end,1),y3_prop(1:end,2));
            endPlot = plot(y3_prop(end,1),y3_prop(end,2), '.','MarkerSize', 10);
            endPlot.Color = [1 0 0];
        end


        set(orbitPlot(1),'Color',[0 0 0],'DisplayName','Orbit');
        orbitPlot.LineWidth = 1;
        axis([-1e6 1e6 -1e6 1e6]);
%         axis([min(y3_prop(1:end,1))-20e3 max(y3_prop(1:end,1))+20e3 min(y3_prop(1:end,2))-20e3 max(y3_prop(1:end,2))+20e3]);
        title("Mars Capture",'FontSize',15)
        xlabel('Position (km)')
        axis equal
        grid on
        set(gca,'fontname','Segoe UI Semibold');set(gca,'FontSize',12)
end