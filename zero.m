
zian = load("Data/S22_Zian_OO_Walking_RA_15min-2023-11-22_18-13-26.mat");
raya = load("Data/S22_Raya_OO_Walking_RA_15min-2023-11-22_17-33-11.mat");
selena = load("Data/S22_Selena_OO_Walking_RA_15min-2023-11-22_17-51-15.mat");
josh = load("Data/S22_Josh_OO_Walking_RA_15min-2023-11-22_17-14-21.mat");

zian_steps = readmatrix("Data/S22_Zian_OO_Walking_RA_15min-2023-11-22_18-13-26/Pedometer.csv");
raya_steps = readmatrix("Data/S22_Raya_OO_Walking_RA_15min-2023-11-22_17-33-11/Pedometer.csv");
selena_steps = readmatrix("Data/S22_Selena_OO_Walking_RA_15min-2023-11-22_17-51-15/Pedometer.csv");
josh_steps = readmatrix("Data/S22_Josh_OO_Walking_RA_15min-2023-11-22_17-14-21/Pedometer.csv");

zero_cross_visualizer(zian,zian_steps)














%Since this code is working we can functionize it for easier viewing
function ax = zero_cross_visualizer(test_data,steps)

    % step from IMU motion, comparing to an existing applications pedometer
    % readouts
    clc

    close all;
    % First load in two datasets, our calibration data is imu data taken with
    % the phone immobile for 15 minutes and used to calibrate the imu
    % test data is one of the datasets acquired from us walking
    calibration_data = load("Data/S22_Static_OnTable_FacingCeiling_30s-2023-11-18_01-44-21.mat","accel_data");
    %test_data = load("Data/S22_Selena_OO_Walking_RA_15min-2023-11-22_17-51-15.mat");
    %steps = readmatrix("Data/S22_Selena_OO_Walking_RA_15min-2023-11-22_17-51-15/Pedometer.csv");
    
    stepcount= steps(end,end);
    
    %% Attempts with the Accelerometer
    close all;
    % First to calibrate the imu we find the min and max range 
    % Finding min and max ranges of the accelerometer calibration data 
    
    maximum = max(calibration_data.accel_data);
    minimum = min(calibration_data.accel_data);
    
    positive_data = test_data.accel_data .* double(test_data.accel_data > maximum);
    negative_data = test_data.accel_data .* double(test_data.accel_data < minimum);
    
    calibrated_data = positive_data + negative_data;
    
    % For visualization We can plot steps when they were recorded to data to
    % look for trends, I created a personalized plotting function for this
    % purpose
    
    step_analysis_plotter(steps(1:150,:),calibrated_data(1:3000,:),"Raya's Accelerometer Data")
    
    % From the step anaylsis plotter, it can be seen a clear bias towards the y
    % axis of the phone for most consistently lining up with the peaks of the
    % data signal. the x and z axises are much more inconsistnet, although
    % peaks in there signal do also have a similar trend. 
    
    %Another way to interpret the data is saying that a step occurs with two
    %zero crossings, one as the accelerometer shoots upwards as the body rises,
    %and a second zero crossing as the body starts to lower down towards the
    %next step. So tracking the positive peaks, or detecting zero crosses/2
    %could be an efficient method of tracking steps.
    
    % So with that in mind, we can most strongly use the peaks of the data as
    % our way of detecting steps
    
    [attempted_stepcount,t] = findpeaks(calibrated_data(:,4));
    
    difference = stepcount - size(attempted_stepcount,1)
    
    % Okay, so its not that easy, matlabs findpeaks function also looks at minimum peaks
    % So trying with a minimum of zero lets see what we can get
    
    difference = stepcount - sum(attempted_stepcount>0)
    
    % Hey! still way off now, but we are getting closer, the issue is that the
    % current findpeaks function hits all local peaks, so small up down
    % inconsistencies count as peaks anyways and result in a positive match. To
    % avoid this we can simply run the findpeaks function again and assess the
    % results
    
    
    difference = stepcount - sum(findpeaks(attempted_stepcount)>0)
    
    % Now we are cooking with GAS. a difference of 66 steps is pretty good
    % compared to over 3000, lets see how zero crossing does, first though to
    % handle any small bounces around the zero line we can buffer our data by
    % removing any motion +- some constant around the zero line
    
    % create an arbitrary offset value, from visual analyis of the graph, +-1
    % seems like a good starting bet as a blackout range
    
    zero_crossing_buffer = 3;
    
    aboveZ = test_data.accel_data .* double(test_data.accel_data > zero_crossing_buffer);
    belowZ = test_data.accel_data .* double(test_data.accel_data < -zero_crossing_buffer);
    
    zero_crossing_data = aboveZ + belowZ;
    
    [rate,stepcount_zero,idx] = zerocrossrate(zero_crossing_data);
    stepcount_zero = stepcount_zero(:,4)/2;
    
    difference = stepcount - stepcount_zero
    
    %% Okay lets evaluate these detections and see where there might be some
    % discrepencies
    
    [ax1,ax2,ax3] = step_analysis_plotter(steps(1:150,:),calibrated_data(1:3000,:),"Raya's Accelerometer Data");
    
    zero_crossing_time = test_data.accel_data(:,2);
    zero_crossing_time = zero_crossing_time(idx(:,:,4)');
    zero_crossing_time = zero_crossing_time(:,1);
    
    
    step_analysis_plotter(steps(1:150,:),zero_crossing_data(1:3000,:),"Raya's Accelerometer Data");
end
function [ax1,ax2,ax3] = step_analysis_plotter(steps,sensor_data,Title)
   % Create a figure
    figure;
    time = sensor_data(:,2);

    % Plot the first subplot
    ax1=subplot(3,1,1);
    plot(time, sensor_data(:,3), 'LineWidth', 2);
    xline(steps(:,2),"red")
    title(Title);
    fontsize = 30;
    ylabel('z');
    grid on;
    axis 'auto y'
    
    % Plot the second subplot
    ax2=subplot(3,1,2);
    plot(time, sensor_data(:,4), 'LineWidth', 2);
    ylabel('y');
    xline(steps(:,2),"red")
    grid on;
    axis 'auto y'
    
    % Plot the third subplot
    ax3=subplot(3,1,3);
    plot(time, sensor_data(:,5), 'LineWidth', 2);
    xline(steps(:,2),"red")
    ylabel('x')
    xlabel('Time s');
    grid on;
    
    axis 'auto y'
    legend(Title,"steps")

end

