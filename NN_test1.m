clear all; close all;
plotting=0;
call_gyro_x_data=[];
call_accel_y_data=[];
datasets.classes=["Static";
    "Walking";
    "Jogging";
    % "BarbellSquat";
    "Deadlift";
    % "Pullups";
    % "BenchPress";
    % "Situps"
    ];
datasets.list=[
    "Processed Data\PROCESSED_S22_Static_OnTable_FacingCeiling_30s-2023-11-18_01-44-21";
    "Processed Data\PROCESSED_S22_Josh_OO_Walking_RA_15min-2023-11-22_17-14-21.mat";
    "Processed Data\PROCESSED_S22_Raya_OO_Walking_RA_15min-2023-11-22_17-33-11.mat";
    "Processed Data\PROCESSED_S22_Selena_OO_Walking_RA_15min-2023-11-22_17-51-15.mat";
    "Processed Data\PROCESSED_S22_Zian_OO_Walking_RA_15min-2023-11-22_18-13-26.mat";
    "Processed Data\PROCESSED_S22_Zian_Jogging_OO_200Steps-2024-02-05_20-39-58.mat";
    "Processed Data\PROCESSED_S22_Zian_Deadlift_15Reps-2024-02-03_23-57-56.mat";
    % "Processed Data\PROCESSED_.mat";
    % "Processed Data\PROCESSED_.mat";
    % "Processed Data\PROCESSED_.mat";
    ];
% datasets=[
%     "Data\S22_Zian_Walking_OO_100steps-2024-02-05_20-18-43.mat";
%     "Data\S22_Zian_Jogging_OO_200Steps-2024-02-05_20-39-58.mat";
%     "Data\S22_Zian_BarbellSquat_25Reps-2024-02-03_00-12-56.mat";
%     "Data\S22_Zian_Pullups_20Reps-2024-02-03_00-23-52.mat";
%     "Data\S22_Zian_UofC_BenchPress_25reps-2024-02-03_23-28-44.mat";
%     "Data\S22_Zian_Deadlift_15Reps-2024-02-03_23-57-56.mat"
%     ];
labels=["Walking","Jogging"];
% gyrox=gather_data(datasets.list,2,1);
% gyroy=gather_data(datasets.list,2,2);
% gyroz=gather_data(datasets.list,2,3);
[x,t]=gather_data_NNFormat(datasets);
% x=x(1:9,:);
% t=t([1,2,3,5],:);
% gyrox=gyrox(500:5400,:);
% aidata(1).label="Walking";
% aidata(2).label="Jogging";
% aidata(1).data=gyrox(:,1);
% aidata(2).data=gyrox(:,2);
% if plotting
%     figure
%     plot(gyrox,'DisplayName','gyroy');
%     % legend("Walking","Jogging","BarbellSquat","Deadlift");
%     legend("Walking","Jogging");
% end
% 

disp('Done');
disp('Running NN');

% Create a feedforward neural network
% hiddenLayerSizes = [50]; % Adjust as needed
% net = feedforwardnet(hiddenLayerSizes);
% net.layers{end}.transferFcn = 'softmax'; % Set softmax activation

net=patternnet(10);
net=train(net,x,t);
% view(net)
% net.layers{1}
% net.layers{2}
% lweights=net.LW
% biases=net.b
net.divideParam.trainRatio=70/100;
net.divideParam.valRatio=15/100;
net.divideParam.testRatio=15/100;

% xTrain=[aidata(1).data,aidata(2).data,aidata(1).data,aidata(1).data];
yTrain=zeros(length(gyrox(:,1)),length(gyrox(1,:)));
yTrain=yTrain+[0,1];

%% Test 1
% Define LSTM network architecture
% numSamplesPerClass = length(gyrox(:,1));
% classLabels = categorical({'walking', 'jogging'});
% yTrain = repmat(classLabels, numSamplesPerClass, 1);
% layers = [
%     sequenceInputLayer(size(gyrox, 2))  % Input layer for sequence
%     lstmLayer(64, 'OutputMode', 'last')  % LSTM layer with 64 neurons
%     fullyConnectedLayer(2)  % Output layer with 4 neurons (4 classes)
%     softmaxLayer  % Softmax activation for classification
%     classificationLayer  % Classification layer
% ];
% 
% % Specify training options
% options = trainingOptions('adam', ...
%     'MaxEpochs', 50, ...
%     'MiniBatchSize', 64, ...
%     'Plots', 'training-progress', ...
%     'Verbose', true);
% 
% % Train the LSTM network using trainNetwork
% net = trainNetwork(gyrox', yTrain', layers, options);

%% Test 2
% Create a feedforward neural network with LSTM layer
% net = feedforwardnet(64, 'trainlm');
% net.layers{1}.netInputFcn = '';  % Disable net input function for LSTM
% net.layers{1}.transferFcn = 'tansig';  % Change transfer function if needed
% net.trainParam.epochs = 50;
% net.trainParam.showWindow = true;
% 
% % Train the neural network
% net = train(net, gyrox', yTrain');
%% Original
% ytrain2=[[yTrain(:,1);yTrain(:,2)],[yTrain(:,2);yTrain(:,1)]]';
% gyrox2=[gyrox(:,1);gyrox(:,2)]';
% net=train(net,gyrox2,ytrain2);
% view(net);

function result=gather_data(datasets,sensor,axis)
    % Each column of result represents one dataset
    % sensor: 1=accel,2=gyro,3=barometer
    % axis: 1=x,2=y,3=z,12=horizontal magnitude, 123=total magnitude
        %if sensor = barometer,axis: 1=relative altitude, 2= pressure
    %NOTE: gyro data output will be in RADIANS
    result=[];
    datalength=0; %track number of samples. function will truncate data to least number of samples
    for i=datasets'
        load(i);
        switch sensor
            case 1
                dataset_i=accel_data;
            case 2
                dataset_i=gyro_data;
            case 3
                dataset_i=bar_data;
            otherwise
                error("Unrecognized sensor")
        end
        if axis<9
            dataset_i=dataset_i(:,axis+2);
        elseif axis==12
            dataset_i=sqrt(dataset_i(:,3).^2+dataset_i(:,4).^2);
        elseif axis==123
            dataset_i=sqrt(dataset_i(:,3).^2+dataset_i(:,4).^2+dataset_i(:,5).^2);
        else
            error("Invalid axis input")
        end

        current_samples=length(dataset_i(:,1));
        if datalength<=current_samples
            if datalength~=0
                result=[result,dataset_i(1:datalength,:)];
            else
                result=dataset_i;
                datalength=current_samples;
            end
        else
            result=[result(1:current_samples,:),dataset_i];
            datalength=length(result(:,1));
        end
    end
end

function [x,t]=gather_data_NNFormat(datasets,sensor_toggle)
    x=[];
    t=[];
    if nargin==1
        sensor_toggle=diag([1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0]);   %[AccX,AccY,AccZ,GravX,GravY,GravZ,GyroX,GyroY,GyroZ,BarRelativeAltitude,BarPressure,QuatRoll,QuatPitch,QuatYaw,QuatW,QuatX,QuatY,QuatZ]
        %Barometer and Orientation data excluded by default
    end
    datasets.classVals=zeros(length(datasets.list),1); % Stores numerical value for class to each data file
    
    for i=1:length(datasets.list)
        xi=[];
        load(datasets.list(i));
        % Gather data from file
        if sensor_toggle(10,10) || sensor_toggle(11,11) %If barometer data enabled
            %Linear interpolation to make length of bar data same as grav/acc/gyro/orient
            error("Unable to use barometer data (Missing function for interpolating values)")
        end
        Acci=sensor_toggle(1:3,1:3)*accel_data(:,[5,4,3])';
        Gravi=sensor_toggle(4:6,4:6)*grav_data(:,[5,4,3])';
        Gyroi=sensor_toggle(7:9,7:9)*gyro_data(:,[5,4,3])';
        % Bari=sensor_toggle(10:11,10:11)*bar_data(:,[3,4])';% Disabled until interpolation function added
        Bari=zeros(2,length(Gyroi(1,:)));
        Orienti=sensor_toggle(12:18,12:18)*orient_data(:,[7,8,9,6,5,4,3])';
        % Determine numerical class value for file using its name
        for classNum=1:length(datasets.classes)
            if contains(datasets.list(i),datasets.classes(classNum))
                datasets.classVals(i)=classNum;
            end
        end
        
        % Compile data in format for NN for this file
        xi=[Acci;
            Gravi;
            Gyroi;
            Bari;
            Orienti];

        % Compile class values in format for NN for this file
        ti=zeros(length(datasets.classes),length(Acci(1,:)));
        ti(datasets.classVals(i),:)=1;

        %Update output variables
        x=[x,xi];
        t=[t,ti];

        %If class name is not present, display warning
        if datasets.classVals(i)==0
            fprintf("WARNING: Unidentified Class from Training Data. Storing as class 0. Filename: %s\n",datasets.list(i))
        end
    end
end