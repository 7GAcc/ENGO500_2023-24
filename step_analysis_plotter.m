function h = step_analysis_plotter(steps,sensor_data,sensor,name)
   % Create a figure
    h = gcf;

    load("sensor_title_table.mat");
    
    Title = name +sensor;
    set(0, 'CurrentFigure', h(1));
    clf reset;
    time = sensor_data(:,2);

    idx = round(size(sensor_data,1)/4);
    xlower = sensor_data(idx,2);
    xupper = xlower+30;

    % start at 3 as all of our data has time for the first 2 columns
    for i = 3:size(sensor_data,2)

        % Plot the first subplot
        ax1=subplot(size(sensor_data,2)-2,1,i-2);
        plot(time, sensor_data(:,i), 'LineWidth', 2);

        title(Title);
        fontsize = 30;
        xlim([xlower,xupper]);
        ylabel(sensor_title_table.(sensor){i-2});
        grid on;
        axis 'auto y'

        if max(steps(:)) ~=0 
           % disp(time(steps(:,i-2)));
           %s xline(time(steps(:,i-2)),'r')
        end

    end

end
