function [start_time, end_time] = time_range_finder(data)
    % This function takes an input data and and returns the start time in
    % seconds and end time in seconds

    delta_accel = diff(data);
    accelNorm = vecnorm(data(:,3:end),2,2);
    delta_norm = diff(accelNorm);
    timer = 0;
    start_time =[];
    end_time = [];

    for i = 1:size(accelNorm,1)/2
        if abs(accelNorm(i))<0.5
            timer = timer+delta_accel(i,2);
        else 
            timer=0;
        end

        if timer>.5
            start_time = [start_time;timer,data(i,2)];
            continue
        end  
    end
    if isempty(start_time)
        start_time = 0;
    else
        idx = find(max(start_time(:,1)));
        start_time = start_time(idx,2);
    end
    % start from the end of the data to find the stop point, to avoid
    % periods of stillness causing accidental early end point finding
    timer = 0;
    for i = size(accelNorm,1)-1:-1:size(accelNorm,1)/2
        if abs(accelNorm(i))<0.5
            timer = timer+delta_accel(i,2);
        else 
            timer=0;
        end

        if timer>.5
            end_time = [end_time;timer,data(i,2)];
            continue
        end  

    end

    if isempty(end_time)
        end_time = data(end,2);
    else
        idx = find(max(end_time(:,1)));
        end_time = end_time(idx,2);
    end

    end