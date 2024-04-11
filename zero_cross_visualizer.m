

function [difference,rpt] = zero_cross_visualizer(test_data,sensor,steps,stepcount,name,filename,rpt)
% This code serves as the primarily analysis and method assessment code, it
% takes in test data of a particular sensor and performs different attempts
% to estimate a step/repcount from it and compares it to a known value

% It then takes the statistics and the figures generated and saves them to
% reports and designated directories based on the name of the user and what
% exercise was performed

    % Inputs : 
    %       - test_data, an array of size [r 2+s] where the rows have no
    %       set amount, and columns are [time, time (s), {sensor axis})
    %       where sensor axis can range depending on what sensor the test
    %       data is
    % 
    %       - sensor, a string of the sensor name input, used to call the
    %       sensor axis data from calibration and used in generating report
    %       tites

    %       - steps, check if a steps value exists in the test_data from
    %       pedometer, if it doesnt defaults to stepcount for steps/reps
    %
    %       -stepcount, estimated steps/reps of an exercise, used to
    %       compute the error from the different methods

    %       -filename, name of the file the data was laoded from, used to
    %       generate names nad organize data
    %
    %       - rpt, report handle that the data generated here is appended too
    
    % Outputs:
    %       - difference : struct of the error for each different method on
    %       each axis of the sensor data

    %       - rpt : report handle with data figures appended to it.


    % step from IMU motion, comparing to an existing applications pedometer
    % readouts
    clc

    load('sensor_title_table.mat') % table of sensor names and there associated axis

    [name, exercise, rep] = extract_exercise(filename); % extract the name and exercise and repcount to generate 
    % a directory if it doesnt exist, or simply a figurepath if it does

    figurepath = "Figures/"+name+"/"+exercise+'/';
    if ~exist(figurepath, 'dir')
       mkdir(figurepath)
    end

    % First load in two datasets, our calibration data is imu data taken with
    % the phone immobile for 15 minutes and used to calibrate the imu
    % test data is one of the datasets acquired from us walking

    calibration_data = load("S22_Static_OnTable_FacingCeiling_30s-2023-11-18_01-44-21.mat");

  
    if stepcount == 0
        stepcount= steps(end,end);
    end

    if isempty(stepcount)
        stepcount =0;
    end


    % Create a buffer range for the zero crossing method from the standard
    % deviation of the data, this helps remove any noise that can exist
    % around the 0 axis and cause false flags
    test_data.(sensor) = rmmissing(test_data.(sensor));
    zero_crossing_buffer = std(test_data.(sensor));

    % Downsample the data to 1/3d its original size. Tests show that we
    % really only care about the peaks of data for step/rep count and so
    % downsampling reduces false flags and increases processing time. 

    test_data.(sensor) = downsample(test_data.(sensor),3);

    % store the time value so that its not shifted by any of the processing
    % of data
    time = test_data.(sensor)(:,2);

    % Normalize the sensor data around 0, this allows the zero crossing
    % method to be employed for certain sensors that collect data around a
    % non zero axis.
    test_data.(sensor) = normalize(test_data.(sensor),'center','mean');

    % Reset the time variable for the sensor data.
    test_data.(sensor)(:,2) = time;

    
    %% Attempts with the Accelerometer
    % First to calibrate the imu we find the min and max range 
    % Finding min and max ranges of the accelerometer calibration data 
    
    maximum = max(calibration_data.(sensor));
    minimum = min(calibration_data.(sensor));
    
    positive_data = test_data.(sensor) .* double(test_data.(sensor) > maximum);
    negative_data = test_data.(sensor) .* double(test_data.(sensor) < minimum);
    
    calibrated_data = positive_data + negative_data; % combine the positive and negative calibrated data
    calibrated_data(:,2) = test_data.(sensor)(:,2); % reset time after calibration


    % Find the start and end time indexes from the 5 second stop 
    [start_time,end_time] = time_range_finder(test_data.accel_data);

    % find the index values of those start and stop times and extract them
    % from the calibrated data
    idx = find(calibrated_data(:,2)>start_time & calibrated_data(:,2)<end_time);
    calibrated_data = calibrated_data(idx,:);
    
    % For visualization We can plot steps when they were recorded to data to
    % look for trends, I created a personalized plotting function for this
    % purpose

    figure('Visible','off') % turn this to on if you want to see the matlab figs, otherwise view them in the report
    raw_fig = step_analysis_plotter(0,calibrated_data(:,:),sensor,name+ " ");
    raw_fig.Position(3:4) = raw_fig.Position(3:4).*1.35;

    centerFigure(raw_fig,rpt);

    savefig(raw_fig,figurepath +"/"+filename+"/"+ sensor + "_"+stepcount+"_reps.fig",'compact');
    
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
    attempted_stepcount = [];
    attempted_stepcount_above_zero = [];
    attempted_double_find_peaks =[];

    for i = 3: size(calibrated_data,2) % for each sensor
        [est_stepcount,t] = findpeaks(calibrated_data(:,i)); % First see how close stepcount we get simply counting the peaks

        attempted_stepcount = [attempted_stepcount,size(est_stepcount,1)]; % store value in a matrix

        attempted_stepcount_above_zero = [attempted_stepcount_above_zero,sum(est_stepcount>0)]; % now see how close our stepcount gets removing all negative values

        if isempty(est_stepcount)
            continue
        else
            attempted_double_find_peaks = [attempted_double_find_peaks,sum(findpeaks(est_stepcount)>0)]; % Call findpeaks twice and sum the values above zero
        end

    end

    difference.Axis = sensor_title_table.(sensor)'; % Store the axis names in a struct
    
    difference.(("findpeaks")) = stepcount - attempted_stepcount'; % Store the findpeaks difference as a struct
    
    % Okay, so its not that easy, matlabs findpeaks function also looks at minimum peaks
    % So trying with a minimum of zero lets see what we can get
    
    difference.(("findpeaks_above_zero")) = stepcount - attempted_stepcount_above_zero'; % Store the findpeaks above zero to the struct
    
    % Hey! still way off now, but we are getting closer, the issue is that the
    % current findpeaks function hits all local peaks, so small up down
    % inconsistencies count as peaks anyways and result in a positive match. To
    % avoid this we can simply run the findpeaks function again and assess the
    % results
    
    
    difference.(("double_findpeaks")) = stepcount - attempted_double_find_peaks'; % Store the double findpeaks above zero to the struct
    
    % Now we are cooking with GAS. a difference of 66 steps is pretty good
    % compared to over 3000, lets see how zero crossing does, first though to
    % handle any small bounces around the zero line we can buffer our data by
    % removing any motion +- some constant around the zero line
    
    % This is where the zero crossing buffer we created at the start comes
    % in, as a simgple one sigma standard deviation buffer to remove any
    % values around the zero line. 

    % This process follows similar procedure to the calibration analysis.

    aboveZ = test_data.(sensor) .* double(test_data.(sensor) > zero_crossing_buffer);
    belowZ = test_data.(sensor) .* double(test_data.(sensor) < -zero_crossing_buffer);
    
    zero_crossing_data = aboveZ + belowZ;
    zero_crossing_data(:,2) = test_data.(sensor)(:,2);
    zero_crossing_data = zero_crossing_data(idx,:);
    
    [rate,stepcount_zero,idx] = zerocrossrate(zero_crossing_data);
    stepcount_zero = stepcount_zero(:,3:end)/2; % since zero crossing our data tends to cross twice, dividing the count in half returns our true vale

    estimated_count_time = permute(idx(:,:,3:end),[2,3,1]);
    
    difference.(("zero_cross")) = stepcount - stepcount_zero'; % Store this value to a struct.

    sensor_array = repmat(sensor,size(difference.Axis,1),1); % Creat a matrix of the name of the sensor to append with the data for later processing


    difference.Sensor = sensor_array;
    
    % Visuzliae the data after zero crossing calbiration has occured to
    % assist in seeing if anything went wrong.
    downsample_fig = step_analysis_plotter(estimated_count_time,zero_crossing_data(:,:), sensor,name +" Zero Cross ");
    centerFigure(downsample_fig,rpt); % add the figure to the report

    % Save figures to there respective places
    savefig(downsample_fig,figurepath +"/"+filename+"/"+ sensor + "_"+stepcount+"_reps_zero_cross.fig","compact");
    total_data.((sensor+"_difference")) = difference;

    save(figurepath+filename+"/Repcount_Stats.mat","-struct","total_data","-append")
    
    if isempty(readmatrix(figurepath+filename+"/Repcount_Stats.csv"))
        writetable(struct2table(difference),figurepath+filename+"/Repcount_Stats.csv",'WriteMode','Append','WriteVariableNames',true,'WriteRowNames',true)
    else
        writetable(struct2table(difference),figurepath+filename+"/Repcount_Stats.csv",'WriteMode','Append','WriteVariableNames',false,'WriteRowNames',true)
    end
    
    % add the figures to the report that will be cycled through this
    % function again for each sensor to compile one big report
    add(rpt, mlreportgen.report.BaseTable(struct2table(difference)));

    % remove the cell array values from the structure so when they are
    % returned they can be analyzed in a different way
    difference = rmfield(difference,'Axis');
    difference = rmfield(difference,'Sensor');


end


