function [best_2_sensorMethods, method]= best_sensor_finder(exercise_data)
% This function finds the sensors that have the lowest error, and what
% method was used to find that lowest error and returns there mean and
% standard deviation in a table. 

% Input :
%       - exercise_data; a table of misclosure, with the Sensor, Axis, and
%       4 different methods denote the columns, compiled with all othe
%       other tables of the same exercise type

% Output:
%       - best_2_sensorMethods: a table returning the two sensors with the
%       lowest error and what method had the lowest error.




% group all of the exercise data together, by sensor and axis and compute
% there average for the 4 different methods
methods = {"findpeaks","findpeaks_above_zero","double_findpeaks","zero_cross"};
avgErrorSensor = grpstats(exercise_data,["Sensor","Axis"], {'mean'},'DataVars',["findpeaks","findpeaks_above_zero","double_findpeaks","zero_cross"]);

% Convert the error values of the methods to an array, find there absolute
% average minimum and use that to return an index of the method with the
% lowest error
array_data = table2array(avgErrorSensor(:,[4:7]));
array_data = abs(array_data);
avg_method = mean(array_data,1);
[val, idx] = min(avg_method);
method_idx = idx +1;

% Slice out the lowest method column from the original data, and compute
% the mean and standard deviations of that method in particular

exercise_data_sensor = exercise_data(:,[1,method_idx,6]);
sensor_stats = grpstats(exercise_data_sensor,"Sensor",{'mean','std'},"DataVars",2);

% Perform a similar method of creating an array to find the two lowest
% values of a particular sensor and return that index
sensor_data = abs(table2array(sensor_stats(:,[3,4])));
[val, idx] = mink(sensor_data(:,1),2,1);
sensor = sensor_stats.Sensor(idx);

% using that index extract from the original data the best two sensors and
% what method they fall under and perform statistical analysis on them
% before returning those values.
index = find(contains(exercise_data.Sensor,sensor));

exercise_data_sensor_method = exercise_data(index,[1,method_idx,6]);

method = methods{method_idx-1};
best_2_sensorMethods = grpstats(exercise_data_sensor_method,["Sensor","Axis"],{'mean','std'}) ;
end

