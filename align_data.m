function align_data(filenames,overwrite)
if nargin==1
    overwrite=0;
end
for datai=filenames'
    fprintf("Processing %s...\n",datai);
    load(datai);
    sizes=[length(accel_data(:,1)),length(grav_data(:,1)),length(gyro_data(:,1)),length(orient_data(:,1))];
    size=min(sizes);
    accel_data=accel_data(1:size,:);
    grav_data=grav_data(1:size,:);
    gyro_data=gyro_data(1:size,:);
    orient_data=orient_data(1:size,:);

    bar_data_interp(:,1)=interp1(bar_data(:,2),bar_data(:,3),accel_data(:,2));
    bar_data_interp(:,2)=interp1(bar_data(:,2),bar_data(:,4),accel_data(:,2));


    bar_data=[accel_data(:,1),accel_data(:,2),bar_data_interp(:,1),bar_data_interp(:,2)];

    if overwrite
        save(datai)
    end
    bar_data_interp=[];
end
end

