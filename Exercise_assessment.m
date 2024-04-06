% this scfript is designed to iterate through all of the excerise data to
% determine best sensors and axis to use for data assessment of different
% exercises
close; clear all; clc;
import mlreportgen.report.* 
import mlreportgen.dom.*
report = report_initializer('exercise_data_report');
setDefaultNumberFormat("%0.3f");
report.Layout.Landscape = true;

% adding all subfolders to our path so we can load files easier
folder = fileparts(which(mfilename)); 
addpath(genpath(folder));

% FOlders follow a pattern in the figures directory of
% Figures/name/exercise

% Getting all of the exercise names (Zian has the most currently)
exercise_names = dir("Figures/Zian/*");



for ex = 1:length(exercise_names)
    
    if or(exercise_names(ex).name == '.', exercise_names(ex).name == "..")
        continue
    end
    name = (exercise_names(ex).name);
    %name = 'walking'
    exercise_data = exercise_loader(name);
    [bestSensorMethods,method] = best_sensor_finder(exercise_data);

    bestSensorMethods(:,[4,5]) = abs(bestSensorMethods(:,[4,5]));
    bestSensorMethods = sortrows(bestSensorMethods,[4,5]);

    % Find the two lowest sensors
    bestAxis =grpstats(exercise_data,["Sensor","Axis"],{'mean','std'},'DataVars',["findpeaks","findpeaks_above_zero","double_findpeaks","zero_cross"]);
    

    avgErrorBySensorAxis = grpstats(exercise_data, 'Axis', {'mean','std'}, 'DataVars', ["findpeaks","findpeaks_above_zero","double_findpeaks","zero_cross"]);
    
    best_sensors = unique(bestSensorMethods.Sensor,'stable');
    best_axis = [];
    
    for i = 1:length(best_sensors)    
        ascending_axis = (bestSensorMethods(bestSensorMethods.Sensor == string(best_sensors{i}),2));
        best_axis = [best_axis, (table2cell(ascending_axis(1,1)))];

    end

    exercise_imu_specifications.(exercise_names(ex).name).best_sensors = best_sensors(1);
    exercise_imu_specifications.(exercise_names(ex).name).best_axis = best_axis(1);
    exercise_imu_specifications.(exercise_names(ex).name).method = method;


    ch = Chapter;
    ch.Title = name;
    
    % Add section for Method with lowest average error
    sec1= Section;
    sec1.Title = "Average Error by Sensor";


    tbl = Table(bestSensorMethods);
    add(sec1,tbl)
    
    
   % Add section for SensorAxis with lowest average error
   %axisSection = Section;
   %axisSection.Title = 'Average Error Axis of Sensor';
%
%
   %
   %axisTable = Table(bestAxis);
   %add(axisSection, axisTable);
   %add(sec1,axisSection)
    add(ch,sec1)
    
    % Add sections to the report
    add(report, ch);
    % Save report as PDF

end

save('exercise_imu_settings.mat',"exercise_imu_specifications",'-mat')
rptview(report)
% Save report as PDF

