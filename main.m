clear all; clc;
%% Set parameters
%Set window for number of sequences
buffer_size=50*3;%50Hz Updates, 1.5 second buffer
buffer_size=999999;%Full dataset(no buffer)
rolling_buffer=0;
user_weight=70;%kg
user_height=172;%cm
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
% "Processed Data/Test Data/PROCESSED_S22_Gaurav_BenchPress_11Reps-undefined-undefined-2024-03-26_20-46-30.mat"
% "Processed Data/Test Data/PROCESSED_S22_Muaz_BenchPress_10Reps_V-undefined-undefined-2024-03-21_20-06-26.mat"
% "Processed Data/Test Data/PROCESSED_S22_Muaz_PullupsUnA_9Reps_V-undefined-undefined-2024-03-21_19-55-13.mat"
% "Processed Data/Test Data/PROCESSED_S22_Muaz_Pullups_15Reps_V-undefined-undefined-2024-03-21_19-59-43.mat"
% "Processed Data/Test Data/PROCESSED_S22_Muaz_Situps_10Reps_V-undefined-undefined-2024-03-21_20-10-57.mat"
"Processed Data/Test Data/PROCESSED_S22_Muaz_Walking_15Steps-undefined-undefined-2024-03-21_20-15-54.mat"
% "Processed Data/Test Data/PROCESSED_S22_Raya_BarbellSquats_OO_10Reps-undefined-undefined-2024-03-19_17-41-14.mat"
% "Processed Data/Test Data/PROCESSED_S22_Raya_BenchPress_OO_10Reps_V-undefined-undefined-2024-03-19_17-13-05.mat"
% "Processed Data/Test Data/PROCESSED_S22_Raya_Jogging_OO_300Steps-undefined-undefined-2024-03-19_16-49-43.mat"
% "Processed Data/Test Data/PROCESSED_S22_Raya_Pullups_OO_7Reps-undefined-undefined-2024-03-19_17-32-35.mat"
% "Processed Data/Test Data/PROCESSED_S22_Raya_Walking_OO_300Steps-undefined-undefined-2024-03-19_16-39-27.mat"
% "Processed Data/Test Data/PROCESSED_S22_Selena_BarbellSquats_10Reps-undefined-undefined-2024-03-27_8-47-49.mat"
% "Processed Data/Test Data/PROCESSED_S22_Selena_BenchPress_OO_8Reps-undefined-undefined-2024-03-20_11-25-08.mat"
% "Processed Data/Test Data/PROCESSED_S22_Selena_Jogging_OO_200Steps-undefined-undefined-2024-03-20_10-43-03.mat"
% "Processed Data/Test Data/PROCESSED_S22_Selena_Pullups_10Reps-undefined-undefined-2024-03-27_9-06-33.mat"
% "Processed Data/Test Data/PROCESSED_S22_Zian_BarbellSquat_OO_10Reps_V-undefined-undefined-2024-03-20_12-01-30.mat"
% "Processed Data/Test Data/PROCESSED_S22_Zian_BarbellSquats_8Reps_plate25-undefined-undefined-2024-03-27_8-35-31.mat"
% "Processed Data/Test Data/PROCESSED_S22_Zian_BenchPress_6Reps-undefined-undefined-2024-03-25_21-11-48.mat"
% "Processed Data/Test Data/PROCESSED_S22_Zian_Deadlift_OO_10Reps-undefined-undefined-2024-03-20_11-42-53.mat"
% "Processed Data/Test Data/PROCESSED_S22_Zian_Jogging_OO_40Steps-undefined-undefined-2024-03-20_10-48-02.mat"
% "Processed Data/Test Data/PROCESSED_S22_Zian_Pullups_15Reps_V-undefined-undefined-2024-03-21_20-02-05.mat"
% "Processed Data/Test Data/PROCESSED_S22_Zian_Situps_OO_12Reps_V-undefined-undefined-2024-03-20_11-12-47.mat"
    ];

%Load Neural Network Data
NNs.versions=[
    % load("C:\Users\zianz\Repos\ENGO500_2023-24\NN Directory\PatternNet\PatternNet_version0_1.mat");
    % load("C:\Users\zianz\Repos\ENGO500_2023-24\NN Directory\PatternNet\PatternNet_version0_2_20Hidden.mat");
    load("C:\Users\zianz\Repos\ENGO500_2023-24\NN Directory\PatternNet\PatternNet_version0_6_20Hidden_wbar.mat");
    ];

clearvars call_gyro_x_data call_gyro_y_data plotting t x;

%% Get sensor data in format for NN
Xtest=gather_data_NNFormat(testdata,0);
%% Select and Run Neural Network Classification
selected_NN=NNs.versions(1).net; %choose NN

NNvals_epoch=[];
Rep_count=[];
exercise_classes=[];
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
    [current_best_class_confidence,current_best_class]=max(NNvals_epoch(:,end));
    exercise_classes=[exercise_classes;
        testdata.classes(current_best_class),num2str(current_best_class_confidence,4)];
    
end
%% Zero-Crossing
% TBC: Add windowing for repcount and place in above for looop
Rep_count(end+1)=RepCounter(load(testdata.list(1)),(exercise_classes(1,1))); %TBC: find better way to get most likely class
[calories_burned,distance]=calc_calories((exercise_classes(1,1)),Rep_count,user_weight,user_height);




%% Final outputs
fid=fopen("HAM_Output.txt",'w');
fprintf(fid,"Summary of Activity: \n");
fprintf(fid,"Filename: %s\n",testdata.list(1));%Should be in for loop after windowing
fprintf(fid,"Predicted Exercise: %s\nConfidence: %s\n",exercise_classes(1,1),exercise_classes(1,2));
fprintf(fid,"Number of Steps/Reps Detected: %.1f\n",Rep_count);
fprintf(fid,"Estimated Calories Burned: %.1f\n",calories_burned);
fprintf("Summary of Activity: \n");
fprintf("Filename: %s\n",testdata.list(1));%Should be in for loop after windowing
fprintf("Predicted Exercise: %s\nConfidence: %s\n",exercise_classes(1,1),exercise_classes(1,2));
fprintf("Number of Steps/Reps Detected: %.1f\n",Rep_count);
fprintf("Estimated Calories Burned: %.1f\n",calories_burned);
fprintf("Estimated Distance Traveled: %.1f\n",distance);
fclose(fid)
disp("Done!")



%% Functions
function [calories_burned,dist_traveled]=calc_calories(exercise,reps_or_steps,weight,height)
    switch exercise
        case "Walking"
            % calories_burned=reps_or_steps*height*0.415*weight*0.57*2.2/160934.4;
            % dist_traveled=reps_or_steps*height*0.415/100000;
            % calories_burned=weight*reps_or_steps*0.035;
            stridelength=1.35*1.14/2*height;%average in cm
            dist_traveled=stridelength*reps_or_steps/100;
            % dist_traveled=reps_or_steps*0.415*height/100;
            calories_burned=0.5*weight*dist_traveled/1000;
        case "Jogging"
            %Assume Light Jog, MET= 6
            % calories_permin=6*3.5*weight/200;
            % calories_burned=calories_permin/150*reps_or_steps;%average step/min=150 for jogging
            % calories_burned=weight*reps_or_steps*0.045;
            %average walking=5km/h, average jogging=8km/h
            % stridelength=1.14*height;%female
            % stridelength=1.35*height;%male
            stridelength=1.35*1.14/2*height;%average in cm
            dist_traveled=stridelength*reps_or_steps/100*1.1;
            calories_burned=0.75*weight*dist_traveled/1000;
            % dist_traveled=reps_or_steps*0.45*height/100;
        case "BarbellSquat"
            calories_burned=weight*reps_or_steps*0.125;
            dist_traveled=0;
        case "Deadlift"
            calories_burned=weight*reps_or_steps*0.175;
            dist_traveled=0;
        case "Pullups"
            calories_burned=weight*reps_or_steps*0.08;
            dist_traveled=0;
        case "BenchPress"
            calories_burned=weight*reps_or_steps*0.125;
            dist_traveled=0;
        case "Situps"
            calories_burned=weight*reps_or_steps*0.045;
            dist_traveled=0;
        otherwise
            calories_burned=0;
    end
end