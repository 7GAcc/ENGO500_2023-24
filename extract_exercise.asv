function [subject, exercise, repcount] = extract_exercise(filename)

% Regular expression pattern to extract exercise name, name of the test
% subject and the repcount form the title. It also has some additional
% checks to 

pattern = '_([^_-]+)';
matches = regexp(filename, pattern, 'tokens');
strIndex = 1;

if matches{1} == "GAPS"
    strIndex = strIndex +2;
    subject = matches{strIndex};
elseif matches{1} == "S22"
    strIndex = strIndex +1;
    subject = matches{strIndex};
else
    subject = matches{strIndex};
end

if matches{strIndex+1} == "OO"
    strIndex = strIndex +2;
    exercise = matches{strIndex};
else
    strIndex = strIndex +1;
    exercise = matches{strIndex};
end

if matches{strIndex+1} == "OO"
    repcount =  str2double(extract(matches{strIndex+2}, digitsPattern));
else
    repcount =  str2double(extract(matches{strIndex+1}, digitsPattern));
end
