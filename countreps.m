
% This script is to perform analysis of a single set of 
% sensor data without having to iterate through the entire range of data
close; clear all; clc;

% adding all subfolders to our path so we can load files easier
folder = fileparts(which(mfilename)); 
addpath(genpath(folder));
 
[files.name,files.folder] = uigetfile('Processed Data/*.mat');
%files = dir('Processed Data/*.mat');
%files = dir('Data/*.mat');

emptyStruct = struct;
% This loop simply iterates through each file in our walking data file
% folder, which we can then use to load that data 
for file = files'
    data = load((file.folder+"/"+file.name));
    load('sensor_title_table.mat')
    fields = fieldnames(data);


    
    for i = 1:length(fields)
        if fields{i}=="steps"
            steps = data.steps;
            break
        else
            steps = 0;
        end
    end


    %removing non sensor fields
    fields = {'accel_data','bar_data','gyro_data','grav_data','orient_data'};

    [name, exercise, rep] = extract_exercise(file.name);
    if steps~=0
        rep = steps;
    end

    figurepath = "Figures/"+name+"/"+exercise+'/'+file.name(:,1:length(file.name)-4);
    reportpath = "Figures/"+name+"/"+exercise+'/' + file.name(:,1:length(file.name)-4) + ".pdf";

    %check if this file has been analyzed yet, if not, create a directory
    %and perfor the analysis of the sensors
    if ~exist(figurepath, 'dir')
        %making and adding the directory to the path
       mkdir(figurepath)
       addpath(figurepath);
    end

    load("exercise_imu_settings.mat") % struct of what axis and sensors to look for 
    load("sensor_title_table.mat")
    sens = exercise_imu_specifications.(exercise{1}).best_sensors;
    axi = exercise_imu_specifications.(exercise{1}).best_axis;
    method = exercise_imu_specifications.(exercise{1}).method;
    count = [];


    data_sensor = data.(sens{1});
    axis_col = find(contains(string(sensor_title_table.(sens{1})),axi{1}))+2;

    data_to_analyze = data_sensor(:,[1,2,axis_col]);
    count = RepCounter(data,exercise{1});

end

