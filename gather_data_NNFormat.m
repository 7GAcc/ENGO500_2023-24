function [x,t]=gather_data_NNFormat(datasets,trainmode,sensor_toggle)
    x=[];
    t=[];
    if nargin<3
        sensor_toggle=diag([1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0]);   %[AccX,AccY,AccZ,GravX,GravY,GravZ,GyroX,GyroY,GyroZ,BarRelativeAltitude,BarPressure,QuatRoll,QuatPitch,QuatYaw,QuatW,QuatX,QuatY,QuatZ]
        %Barometer and Orientation data excluded by default
    end
    if nargin==1
        trainmode=1;
    end

    if trainmode
        datasets.classVals=zeros(length(datasets.list),1); % Stores numerical value for class to each data file
    end

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
                    datasets.classVals(i)=classNum;
                end
            end
        end
        % Compile data in format for NN for this file
        xi=[Acci;
            Gravi;
            Gyroi;
            Bari;
            Orienti];


        % Compile class values in format for NN for this file
        if trainmode
            ti=zeros(length(datasets.classes),length(Acci(1,:)));
            ti(datasets.classVals(i),:)=1;
        else
            ti=0;
        end
        %Update output variables
        t=[t,ti];
        x=[x,xi];

        %If class name is not present, display warning
        if trainmode
            if datasets.classVals(i)==0
                fprintf("WARNING: Unidentified Class from Training Data. Storing as class 0. Filename: %s\n",datasets.list(i))
            end
        end
    end
end