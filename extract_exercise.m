function [subject, exercise, repcount] = extract_exercise(filename)

% Regular expression pattern to extract exercise name

pattern = '_([^_-]+)';
matches = regexp(filename, pattern, 'tokens');

subject = matches{1};
exercise = matches{2};

if exercise == "OO"
    exercise =matches{3};
end

if matches{3} == "OO"
    repcount =  str2double(extract(matches{4}, digitsPattern));
else
    repcount =  str2double(extract(matches{3}, digitsPattern));
end
