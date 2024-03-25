% ENGO500 Sensor data Log Parser
preprocess_mode=1;
data_dir="C:\Users\zianz\Repos\ENGO500_2023-24\Data";
processed_data_dir="C:\Users\zianz\Repos\ENGO500_2023-24\Processed Data";

if preprocess_mode
    preprocess_data(data_dir,processed_data_dir);
else
    Log_Parser_v1_0(data_dir);
end



function Log_Parser_v1_0(data_directory)
% Cycles through directory and stores data in .mat files
log_parser_v1_0_directory=pwd;
directorylist=dir(data_directory);
%Go through each folder with data and store it somewhere
for datadir_i=directorylist'
cd(data_directory);
    if contains(datadir_i.name,'.') % Avoid things that aren't folders
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
    % TBC: Add remaining files if exist
    cd(target_path)
    save(dataset_name)
    cd(start_path);
end

function preprocess_data(data_directory,output_directory)
    % Cycles through directory and stores data in .mat files
output_prefix="PROCESSED_";
output_prefix2="PROCESSED_GAPS_";
origin_directory=pwd;
cd(data_directory);
directorylist=dir(fullfile(data_directory,'*.mat'));
%Note files that have already been processed
processed_directorylist=dir(fullfile(output_directory,'*.mat'));
a=struct2cell(processed_directorylist);
a=string(a(1,:)');
%Go through each file
for i=1:length(directorylist)
    datafile_i=directorylist(i);
    load(datafile_i.name);
    output_file=output_prefix+datafile_i.name;

    %If processed data for file already exist, move on to next file
    %Processed files with gaps will currently not be skipped
    if sum(contains(a,output_file))>0
        continue;
    end


    figure;hold on;
    plot(accel_data(:,2),accel_data(:,3));
    plot(accel_data(:,2),accel_data(:,4));
    plot(accel_data(:,2),accel_data(:,5));
    legend("Accel X","Accel Y","Accel Z");hold off;

    figure;hold on;
    plot(gyro_data(:,2),gyro_data(:,3));
    plot(gyro_data(:,2),gyro_data(:,4));
    plot(gyro_data(:,2),gyro_data(:,5));
    legend("Gyro X","Gyro Y","Gyro Z");hold off;
    
    fprintf("\n PREPROCESSING %s\n",datafile_i.name);
    ts0=input("Input Start Timestamp [s]: ");
    tsn=input("Input End Timestamp [s]: ");
    if isempty(ts0) || isempty(tsn)
        fprintf("\nSkipping File: %s",datafile_i.name);
        close all;
        continue;
    end

    accel_data=accel_data(accel_data(:,2)>ts0-0.001 & accel_data(:,2)<tsn+0.001,:);
    bar_data=bar_data(bar_data(:,2)>ts0-0.001 & bar_data(:,2)<tsn+0.001,:);
    grav_data=grav_data(grav_data(:,2)>ts0-0.001 & grav_data(:,2)<tsn+0.001,:);
    gyro_data=gyro_data(gyro_data(:,2)>ts0-0.001 & gyro_data(:,2)<tsn+0.001,:);
    orient_data=orient_data(orient_data(:,2)>ts0-0.001 & orient_data(:,2)<tsn+0.001,:);
    
    %Check lengths of data
    close all;


    figure;hold on;
    plot(accel_data(:,2),accel_data(:,3));
    plot(accel_data(:,2),accel_data(:,4));
    plot(accel_data(:,2),accel_data(:,5));
    legend("Accel X","Accel Y","Accel Z");hold off;


    figure;hold on;
    plot(gyro_data(:,2),gyro_data(:,3));
    plot(gyro_data(:,2),gyro_data(:,4));
    plot(gyro_data(:,2),gyro_data(:,5));
    legend("Gyro X","Gyro Y","Gyro Z");hold off;

    IMU_gaps=input("Are there large gaps in the data? (y/n): ","s");
    if IMU_gaps=='y'
        output_file=output_prefix2+datafile_i.name;
    end
    verified_good=input("Are these changes acceptable? (y/n): ","s");
    if isempty(verified_good)
        verified_good='y';
    end
    if verified_good=='n'
        fprintf("\nSkipping File (Unaccepted): %s",datafile_i.name);
        close all;
        continue;
    end
    
    close all;
    cd(output_directory)
    save(output_file);
    cd(data_directory);

end


cd(origin_directory)
end