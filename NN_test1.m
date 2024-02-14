clear all; close all;
call_gyro_x_data=[];
call_accel_y_data=[];
datasets=[
    "Data\S22_Zian_Walking_OO_100steps-2024-02-05_20-18-43.mat";
    "Data\S22_Zian_Jogging_OO_200Steps-2024-02-05_20-39-58.mat";
    % "Data\S22_Zian_BarbellSquat_25Reps-2024-02-03_00-12-56.mat";
    % "Data\S22_Zian_Deadlift_15Reps-2024-02-03_23-57-56.mat"
    ];
% datasets=[
%     "Data\S22_Zian_Walking_OO_100steps-2024-02-05_20-18-43.mat";
%     "Data\S22_Zian_Jogging_OO_200Steps-2024-02-05_20-39-58.mat";
%     "Data\S22_Zian_BarbellSquat_25Reps-2024-02-03_00-12-56.mat";
%     "Data\S22_Zian_Pullups_20Reps-2024-02-03_00-23-52.mat";
%     "Data\S22_Zian_UofC_BenchPress_25reps-2024-02-03_23-28-44.mat";
%     "Data\S22_Zian_Deadlift_15Reps-2024-02-03_23-57-56.mat"
%     ];
labels=["Walking","Jogging"];
gyrox=gather_data(datasets,2,1);
gyroy=gather_data(datasets,2,2);
gyroz=gather_data(datasets,2,3);


gyroy=gyroy(250:2700,:);
aidata(1).label="Walking";
aidata(2).label="Jogging";
aidata(1).data=gyroy(:,1);
aidata(2).data=gyroy(:,2);

figure
plot(gyroy,'DisplayName','gyroy');
% legend("Walking","Jogging","BarbellSquat","Deadlift");
legend("Walking","Jogging");

disp('Done');
function result=gather_data(datasets,sensor,axis)
    % Each column of result represents one dataset
    % sensor: 1=accel,2=gyro,3=barometer
    % axis: 1=x,2=y,3=z,12=horizontal magnitude, 123=total magnitude
        %if sensor = barometer,axis: 1=relative altitude, 2= pressure
    %NOTE: gyro data output will be in RADIANS
    result=[];
    datalength=0; %track number of samples. function will truncate data to least number of samples
    for i=datasets'
        load(i);
        switch sensor
            case 1
                dataset_i=accel_data;
            case 2
                dataset_i=gyro_data;
            case 3
                dataset_i=bar_data;
            otherwise
                error("Unrecognized sensor")
        end
        if axis<9
            dataset_i=dataset_i(:,axis+2);
        elseif axis==12
            dataset_i=sqrt(dataset_i(:,3).^2+dataset_i(:,4).^2);
        elseif axis==123
            dataset_i=sqrt(dataset_i(:,3).^2+dataset_i(:,4).^2+dataset_i(:,5).^2);
        else
            error("Invalid axis input")
        end

        current_samples=length(dataset_i(:,1));
        if datalength<=current_samples
            if datalength~=0
                result=[result,dataset_i(1:datalength,:)];
            else
                result=dataset_i;
                datalength=current_samples;
            end
        else
            result=[result(1:current_samples,:),dataset_i];
            datalength=length(result(:,1));
        end
    end
end