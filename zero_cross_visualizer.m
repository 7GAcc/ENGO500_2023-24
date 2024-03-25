

%Since this code is working we can functionize it for easier viewing
function [difference,rpt] = zero_cross_visualizer(test_data,sensor,steps,stepcount,name,filename,rpt)



    % step from IMU motion, comparing to an existing applications pedometer
    % readouts
    clc
    load('sensor_title_table.mat')
    [name, exercise, rep] = extract_exercise(filename);
    figurepath = "Figures/"+name+"/"+exercise+'/';
    if ~exist(figurepath, 'dir')
       mkdir(figurepath)
    end
    % First load in two datasets, our calibration data is imu data taken with
    % the phone immobile for 15 minutes and used to calibrate the imu
    % test data is one of the datasets acquired from us walking
    calibration_data = load("Processed Data/S22_Static_OnTable_FacingCeiling_30s-2023-11-18_01-44-21.mat");
    %test_data = load("Data/S22_Selena_OO_Walking_RA_15min-2023-11-22_17-51-15.mat");
    %steps = readmatrix("Data/S22_Selena_OO_Walking_RA_15min-2023-11-22_17-51-15/Pedometer.csv");
  
    if stepcount == 0
        stepcount= steps(end,end);
    end

    if isempty(stepcount)
        stepcount =0;
    end


    test_data.(sensor) = downsample(test_data.(sensor),3);
    time = test_data.(sensor)(:,2);

    test_data.(sensor) = normalize(test_data.(sensor),'center','mean');
    test_data.(sensor)(:,2) = time;

    
    %% Attempts with the Accelerometer
    % First to calibrate the imu we find the min and max range 
    % Finding min and max ranges of the accelerometer calibration data 
    
    maximum = max(calibration_data.(sensor));
    minimum = min(calibration_data.(sensor));
    
    positive_data = test_data.(sensor) .* double(test_data.(sensor) > maximum);
    negative_data = test_data.(sensor) .* double(test_data.(sensor) < minimum);
    
    calibrated_data = positive_data + negative_data;
    calibrated_data(:,2) = test_data.(sensor)(:,2);

    [start_time,end_time] = time_range_finder(test_data.accel_data);

    idx = find(calibrated_data(:,2)>start_time & calibrated_data(:,2)<end_time);
    calibrated_data = calibrated_data(idx,:);
    
    % For visualization We can plot steps when they were recorded to data to
    % look for trends, I created a personalized plotting function for this
    % purpose




    raw_fig = step_analysis_plotter(0,calibrated_data(:,:),sensor,name+ " ");
    raw_fig.Position(3:4) = raw_fig.Position(3:4).*1.35;

    centerFigure(raw_fig,rpt);
    %if ~exist(figurepath+filename+" Compiled Analysis.pdf", 'file')
    %    exportgraphics(raw_fig,figurepath+filename+" Compiled Analysis.pdf");
    %else
    %    exportgraphics(raw_fig,figurepath+filename+" Compiled Analysis.pdf","Append",true);
    %end

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

    for i = 3: size(calibrated_data,2)
        [est_stepcount,t] = findpeaks(calibrated_data(:,i));

        attempted_stepcount = [attempted_stepcount,size(est_stepcount,1)];
        attempted_stepcount_above_zero = [attempted_stepcount_above_zero,sum(est_stepcount>0)];
        attempted_double_find_peaks = [attempted_double_find_peaks,sum(findpeaks(est_stepcount)>0)];

    end

    difference.Axis = sensor_title_table.(sensor)';
    
    difference.((sensor+"_findpeaks")) = stepcount - attempted_stepcount';
    %disp("Findpeaks Stepcount Estimate: " + difference.((sensor+"_findpeaks")))
    
    % Okay, so its not that easy, matlabs findpeaks function also looks at minimum peaks
    % So trying with a minimum of zero lets see what we can get
    
    difference.((sensor+"_findpeaks_above_zero")) = stepcount - attempted_stepcount_above_zero';
    %disp("Findpeaks above 0 Stepcount Estimate: " + difference.((sensor+"_findpeaks_above_zero")))
    
    % Hey! still way off now, but we are getting closer, the issue is that the
    % current findpeaks function hits all local peaks, so small up down
    % inconsistencies count as peaks anyways and result in a positive match. To
    % avoid this we can simply run the findpeaks function again and assess the
    % results
    
    
    difference.((sensor+"_double_findpeaks")) = stepcount - attempted_double_find_peaks';
    %disp("Findpeaks Called twice above 0 Stepcount Estimate: " + difference.((sensor+"_double_findpeaks")))
    
    % Now we are cooking with GAS. a difference of 66 steps is pretty good
    % compared to over 3000, lets see how zero crossing does, first though to
    % handle any small bounces around the zero line we can buffer our data by
    % removing any motion +- some constant around the zero line
    
    % create an arbitrary offset value, from visual analyis of the graph, +-1
    % seems like a good starting bet as a blackout range
    
    zero_crossing_buffer = std(test_data.(sensor));
    
    aboveZ = test_data.(sensor) .* double(test_data.(sensor) > zero_crossing_buffer);
    belowZ = test_data.(sensor) .* double(test_data.(sensor) < -zero_crossing_buffer);
    
    zero_crossing_data = aboveZ + belowZ;
    zero_crossing_data(:,2) = test_data.(sensor)(:,2);
    zero_crossing_data = zero_crossing_data(idx,:);
    
    [rate,stepcount_zero,idx] = zerocrossrate(zero_crossing_data);
    stepcount_zero = stepcount_zero(:,3:end)/2;

    estimated_count_time = permute(idx(:,:,3:end),[2,3,1]);
    
    difference.((sensor + "_zero_cross")) = stepcount - stepcount_zero';
    
    

    
    %% Okay lets evaluate these detections and see where there might be some
    % discrepencies
    
    %[ax1,ax2,ax3] = step_analysis_plotter(steps(:,:),calibrated_data(:,:),name + " "+ sensor);
    
    %zero_crossing_data(:,2) = test_data.(sensor)(:,2);
    %zero_crossing_time = zero_crossing_time(idx(:,:,4)');
    %zero_crossing_time = zero_crossing_time(:,1);
    

    downsample_fig = step_analysis_plotter(estimated_count_time,zero_crossing_data(:,:), sensor,name +" Zero Cross ");
    centerFigure(downsample_fig,rpt);

    %exportgraphics(downsample_fig,figurepath+filename+" Compiled Analysis.pdf","Append",true);

    savefig(downsample_fig,figurepath +"/"+filename+"/"+ sensor + "_"+stepcount+"_reps_zero_cross.fig","compact");
    total_data.((sensor+"_difference")) = difference;

    save(figurepath+filename+"/Repcount_Stats.mat","-struct","total_data","-append")
    
    add(rpt, mlreportgen.report.BaseTable(struct2table(difference)));
    difference = rmfield(difference,'Axis');


end


