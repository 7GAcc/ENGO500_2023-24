function [x,t]=gather_data_NNFormat_LSTM(datasets,trainmode,sensor_toggle)
    x={};
    if nargin<3
        sensor_toggle=diag([1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0]);   
        %[AccX,AccY,AccZ,GravX,GravY,GravZ,GyroX,GyroY,GyroZ,BarRelativeAltitude,BarPressure,QuatRoll,QuatPitch,QuatYaw,QuatW,QuatX,QuatY,QuatZ]
        %Barometer and Orientation data excluded by default
    end
    num_sensors=sum(diag(sensor_toggle));
    if nargin==1
        trainmode=1;
    end

    % if trainmode
    %     datasets.className=[]; % Stores numerical value for class to each data file
    % end

    for i=1:length(datasets.list)
        xi=[];
        datai=load(datasets.list(i));
        % Gather data from file
        % if sensor_toggle(10,1
        Acci=sensor_toggle(1:3,1:3)*datai.accel_data(:,[5,4,3])';
        Gravi=sensor_toggle(4:6,4:6)*datai.grav_data(:,[5,4,3])';
        Gyroi=sensor_toggle(7:9,7:9)*datai.gyro_data(:,[5,4,3])';
        Bari=sensor_toggle(10:11,10:11)*datai.bar_data(:,[3,4])';% Disabled until interpolation function added
        % Bari=zeros(2,length(Gyroi(1,:)));
        Orienti=sensor_toggle(12:18,12:18)*datai.orient_data(:,[7,8,9,6,5,4,3])';
        % Determine numerical class value for file using its name
        if trainmode
            for classNum=1:length(datasets.classes)
                if contains(datasets.list(i),datasets.classes(classNum))
                    ti=datasets.classes(classNum);
                end
            end
        end
        % Compile data in format for NN for this file
        xi=[Acci;
            Gravi;
            Gyroi;
            Bari;
            Orienti];
        rem_row=[];
        for m=1:length(xi(:,1))
            if sum(xi(m,:).^2)==0
                rem_row=[rem_row,m];
            end
        end
        xi(rem_row,:)=[];

        % Compile class values in format for NN for this file
        if ~trainmode
            ti=0;
        end
        %Update output variables
        t(i,1)=ti;
        x{i,1}=xi';
        seq_length(i)=length(xi(1,:));
        %If class name is not present, display warning
        if trainmode
            if ti==""
                fprintf("WARNING: Unidentified Class from Training Data. Storing as class 0. Filename: %s\n",datasets.list(i))
            end
        end
    end
    [~,seq_length_sort]=sort(seq_length);
    t=categorical(t(seq_length_sort));
    x=x(seq_length_sort);
end