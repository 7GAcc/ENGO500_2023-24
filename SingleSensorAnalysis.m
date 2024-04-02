% This script is to perform analysis of a single set of 
% sensor data without having to iterate through the entire range of data
close; clear all; clc;

% adding all subfolders to our path so we can load files easier
folder = fileparts(which(mfilename)); 
addpath(genpath(folder));
 
%[files.name,files.folder] = uigetfile('Data/*.mat');
%files = dir('Processed Data/*.mat');
files = dir('Data/*.mat');

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

    if ~exist(reportpath,"file")

       import mlreportgen.report.* 
        import mlreportgen.dom.*
        rpt = report_initializer(reportpath);

       % initializing a place to save the data too
        save(figurepath+"/Repcount_Stats","-struct","emptyStruct")
        writetable(table(),figurepath+"/Repcount_stats.csv")

        
        Stat_analysis = [];
        %iterate through each sensor in the data
        for sensor = 1:length(fields)

            %perform analysis and figure generation

            [analysis,rpt] = zero_cross_visualizer(data,fields{sensor},steps,rep,name,file.name(:,1:length(file.name)-4),rpt);

            %fig = mlreportgen.report.Figure(raw_fig);
            %fig.Snapshot.Caption = '3-D shaded surface plot';
            %fig.Snapshot.Height = '5in';

            %add(rpt,fig);

            

            %fig = mlreportgen.report.Figure(downsample_fig);

            %add(rpt,fig);

            close all;
            
            sensor_stats = struct2array(analysis);
    
            axis = sensor_title_table.(fields{sensor})';
            [smallest_err, idx] = (min(abs(sensor_stats(:))));
            [smallest_axis,smallest_method] = ind2sub(size(sensor_stats),idx);
            bestAxis = axis(smallest_axis(:,1));
            method = fieldnames(analysis);
            bestmethod = method{smallest_method};
    
            Stat_analysis = [Stat_analysis; fields{sensor},bestAxis, bestmethod ,min(abs(sensor_stats(:)))];
        end
        Stat_analysis = cell2table(Stat_analysis);
        Stat_analysis.Properties.VariableNames = ["Sensor","Sensor Axis","Method","Error"];

        % Create a section for the table
        section = Section();
        
        % Add the table to the paragraph
        add(section, Table(Stat_analysis));

        add(rpt, section);

        save(figurepath+"Best_Sensors.mat","Stat_analysis")
    

        close(rpt)

    else
        continue
    end


end