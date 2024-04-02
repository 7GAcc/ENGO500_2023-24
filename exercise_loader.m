function exerciseData = exercise_loader(exercise)
%This function serves to load all of the data of a speciifed exercise type

% Inputs:
%       - exercise: a character string of an exercise name, that should
%       match one of the exercise names in the figures directory
%
% Outputs:
%       - exerciseData: a table of all of the exercise method errors
%       concatanated together into one big table that can be used for error
%       analysis.

% Define the main directory where all the subdirectories are located
mainDir = 'Figures';

% Get a list of all directories in the main directory
directories = dir(mainDir);
directories = directories([directories.isdir]); % Keep only directories, excluding '.' and '..'

% Initialize a cell array to store loaded data
exerciseData = cell(1, numel(directories));
combinedTable = table();

% Loop through each directory
for i = 1:numel(directories)
    % Get the current directory name
    currentDir = directories(i).name;
    
    % Skip '.' and '..'
    if strcmp(currentDir, '.') || strcmp(currentDir, '..')
        continue;
    end
    
    % Construct the full path to the exercise directory
    exerciseDir = fullfile(mainDir, currentDir, exercise);

    
    % Check if the exercise directory exists
    if exist(exerciseDir, 'dir')
        data_dir = dir(exerciseDir);
        data_dir = data_dir([data_dir.isdir]);

        for i = 1:length(data_dir)
                % Skip '.' and '..'
            if strcmp(data_dir(i).name, '.') || strcmp(data_dir(i).name, '..')
                continue;
            end

            finalDir = fullfile(exerciseDir,data_dir(i).name);
             % Get a list of all .mat files in the exercise directory
            csvFiles = dir(fullfile(finalDir, '*.csv'));
            
            
               % Loop through each .csv file
            for j = 1:numel(csvFiles)
                % Load the data from the current .mat file
                data = readtable(fullfile(finalDir, csvFiles(j).name));
                

                
                % Concatenate the current table with the combined table
                combinedTable = [combinedTable; data];
            end
        end
       
    else
        fprintf('Exercise directory not found in %s\n', currentDir);
    end
end


% Now exerciseData contains the loaded data from each directory
exerciseData = combinedTable;
end

