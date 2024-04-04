clear all; clc;
%% Set parameters
%Set window for number of sequences
buffer_size=50*3;%50Hz Updates, 1.5 second buffer
% buffer_size=999999;%Full dataset
rolling_buffer=0;

%% Load Data
testdata.classes=["Static";
    "Walking";
    "Jogging";
    "BarbellSquat";
    "Deadlift";
    "Pullups";
    "BenchPress";
    "Situps"
    ];
%Load data being tested
testdata.list=[
"Processed Data/Test Data/PROCESSED_S22_Gaurav_BenchPress_11Reps-undefined-undefined-2024-03-26_20-46-30.mat"
"Processed Data/Test Data/PROCESSED_S22_Muaz_BenchPress_10Reps_V-undefined-undefined-2024-03-21_20-06-26.mat"
"Processed Data/Test Data/PROCESSED_S22_Muaz_PullupsUnA_9Reps_V-undefined-undefined-2024-03-21_19-55-13.mat"
"Processed Data/Test Data/PROCESSED_S22_Muaz_Pullups_15Reps_V-undefined-undefined-2024-03-21_19-59-43.mat"
"Processed Data/Test Data/PROCESSED_S22_Muaz_Situps_10Reps_V-undefined-undefined-2024-03-21_20-10-57.mat"
"Processed Data/Test Data/PROCESSED_S22_Muaz_Walking_15Steps-undefined-undefined-2024-03-21_20-15-54.mat"
"Processed Data/Test Data/PROCESSED_S22_Raya_BarbellSquats_OO_10Reps-undefined-undefined-2024-03-19_17-41-14.mat"
"Processed Data/Test Data/PROCESSED_S22_Raya_BenchPress_OO_10Reps_V-undefined-undefined-2024-03-19_17-13-05.mat"
"Processed Data/Test Data/PROCESSED_S22_Raya_Jogging_OO_300Steps-undefined-undefined-2024-03-19_16-49-43.mat"
"Processed Data/Test Data/PROCESSED_S22_Raya_Pullups_OO_7Reps-undefined-undefined-2024-03-19_17-32-35.mat"
"Processed Data/Test Data/PROCESSED_S22_Raya_Walking_OO_300Steps-undefined-undefined-2024-03-19_16-39-27.mat"
"Processed Data/Test Data/PROCESSED_S22_Selena_BarbellSquats_10Reps-undefined-undefined-2024-03-27_8-47-49.mat"
"Processed Data/Test Data/PROCESSED_S22_Selena_BenchPress_OO_8Reps-undefined-undefined-2024-03-20_11-25-08.mat"
"Processed Data/Test Data/PROCESSED_S22_Selena_Jogging_OO_200Steps-undefined-undefined-2024-03-20_10-43-03.mat"
"Processed Data/Test Data/PROCESSED_S22_Selena_Pullups_10Reps-undefined-undefined-2024-03-27_9-06-33.mat"
"Processed Data/Test Data/PROCESSED_S22_Zian_BarbellSquat_OO_10Reps_V-undefined-undefined-2024-03-20_12-01-30.mat"
"Processed Data/Test Data/PROCESSED_S22_Zian_BarbellSquats_8Reps_plate25-undefined-undefined-2024-03-27_8-35-31.mat"
"Processed Data/Test Data/PROCESSED_S22_Zian_BenchPress_6Reps-undefined-undefined-2024-03-25_21-11-48.mat"
"Processed Data/Test Data/PROCESSED_S22_Zian_Deadlift_OO_10Reps-undefined-undefined-2024-03-20_11-42-53.mat"
"Processed Data/Test Data/PROCESSED_S22_Zian_Jogging_OO_40Steps-undefined-undefined-2024-03-20_10-48-02.mat"
"Processed Data/Test Data/PROCESSED_S22_Zian_Pullups_15Reps_V-undefined-undefined-2024-03-21_20-02-05.mat"
"Processed Data/Test Data/PROCESSED_S22_Zian_Situps_OO_12Reps_V-undefined-undefined-2024-03-20_11-12-47.mat"
    ];

%Load Neural Network Data
NNs.versions=[
    % load("C:\Users\zianz\Repos\ENGO500_2023-24\NN Directory\PatternNet\PatternNet_version0_1.mat");
    load("C:\Users\zianz\Repos\ENGO500_2023-24\NN Directory\PatternNet\PatternNet_version0_2_20Hidden.mat");
    ];

clearvars call_gyro_x_data call_gyro_y_data plotting t x;

%% Get sensor data in format for NN
Xtest=gather_data_NNFormat(testdata,0);
%% Select and Run Neural Network Classification
selected_NN=NNs.versions(1).net; %choose NN

NNvals_epoch=[];

if rolling_buffer
    buffer_starts=1:(length(Xtest(1,:))-buffer_size);
    buffer_ends=buffer_starts+buffer_size;
    if buffer_size>length(Xtest(1,:))
        buffer_starts=1;
        buffer_ends=length(Xtest(1,:));
    end
else
    buffer_starts=1:buffer_size:length(Xtest(1,:));
    buffer_ends=buffer_starts+buffer_size;
    buffer_ends(end)=length(Xtest(1,:));
end

for i=1:length(buffer_starts)
    Xtest_buffer=Xtest(:,buffer_starts(i):buffer_ends(i));
    y=selected_NN(Xtest_buffer);

    %Determine classification
    for j=1:length(y(:,1))
        if j==1
            NNvals_epoch(j,end+1)=sum(y(j,:));
        else
            NNvals_epoch(j,end)=sum(y(j,:));
        end
    end
    NNvals_epoch(:,end)=NNvals_epoch(:,end)./sum(NNvals_epoch(:,end))*100;
    
    
end


%% Zero-Crossing




%% Final outputs


disp("Done!")