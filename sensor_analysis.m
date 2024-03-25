close; clear all; clc;

% adding all subfolders to our path so we can load files easier
folder = fileparts(which(mfilename)); 
addpath(genpath(folder));

% This File serves to test each of the different sensors for there ability
% to correctly detect steps and how accurate they are using the walking
% data we have.

%This is done using our zero crossing algorithm on data with either
%pedometer data or known step counts to process the data.

% First all walking data was organized into a single folder allowing us to
% iterate through it and call each .mat file of walking data.

files = dir('Data/Walking_data/*.mat');
emptyStruct = struct;
% This loop simply iterates through each file in our walking data file
% folder, which we can then use to load that data 
for file = files'
    data = load((file.folder+"/"+file.name));
    fields = fieldnames(data);

    %removing non sensor fields
    fields = setdiff(fields,{'dataset_name','start_path','target_path','steps'});

    [name, exercise, rep] = extract_exercise(file.name);
    figurepath = "Figures/"+name+"/"+exercise+'/';
    if ~exist(figurepath, 'dir')
       mkdir(figurepath)
    end


    save(figurepath+'/'+file.name(:,1:length(file.name)-4)+"_difference","-struct","emptyStruct")


    for sensor = 1:length(fields)
        
        analysis = zero_cross_visualizer(data,fields{sensor},0,rep,name,file.name(:,1:length(file.name)-4));
        
    end

end