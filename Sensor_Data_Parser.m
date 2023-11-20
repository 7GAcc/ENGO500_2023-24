% ENGO500 Sensor data Log Parser

function Log_Parser_v1_0(data_directory)
% Cycles through directory and stores data in .mat files
log_parser_v1_0_directory=pwd;
directorylist=dir(data_directory);
%Go through each folder with data and store it somewhere
for datadir_i=directorylist'
cd(data_directory);
    if contains(datadir_i.name,'.') % Avoid filenames containing '.'
        continue;
    end
    cd(datadir_i.name)
    collect_data(datadir_i.name,data_directory)
end
cd(log_parser_v1_0_directory);
end

function collect_data(dataset_name,target_path)
    start_path=pwd;
    if isfile("Accelerometer.csv")
        accel_data=readmatrix("Accelerometer.csv");
    end
    if isfile("Barometer.csv")
        bar_data=readmatrix("Barometer.csv");
    end
    if isfile("Gyroscope.csv")
        gyro_data=readmatrix("Gyroscope.csv");
    end
    if isfile("Orientation.csv")
        orient_data=readmatrix("Orientation.csv");
    end
    if isfile("Gravity.csv")
        grav_data=readmatrix("Gravity.csv");
    end
    cd(target_path)
    save(dataset_name)
    cd(start_path);
end