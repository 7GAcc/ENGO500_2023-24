clear all; close all;
%% Set variables
plotting=0;
NN_type="FF";
sensor_select=[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];
% sensor_select=[1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0];
%sensor_select=[AccX,AccY,AccZ,GravX,GravY,GravZ,GyroX,GyroY,GyroZ,BarRelativeAltitude,BarPressure,QuatRoll,QuatPitch,QuatYaw,QuatW,QuatX,QuatY,QuatZ]
hidden_layers=14;
%% 
datasets.classes=["Static";
    "Walking";
    "Jogging";
    "BarbellSquat";
    "Deadlift";
    "Pullups";
    "BenchPress";
    "Situps"
    ];
call_gyro_x_data=[];
call_accel_y_data=[];
% datasets.list=[
%     "Processed Data\PROCESSED_S22_Static_OnTable_FacingCeiling_30s-2023-11-18_01-44-21";
%     "Processed Data\PROCESSED_S22_Josh_OO_Walking_RA_15min-2023-11-22_17-14-21.mat";
%     "Processed Data\PROCESSED_S22_Raya_OO_Walking_RA_15min-2023-11-22_17-33-11.mat";
%     "Processed Data\PROCESSED_S22_Selena_OO_Walking_RA_15min-2023-11-22_17-51-15.mat";
%     "Processed Data\PROCESSED_S22_Zian_OO_Walking_RA_15min-2023-11-22_18-13-26.mat";
%     "Processed Data\PROCESSED_S22_Zian_Jogging_OO_200Steps-2024-02-05_20-39-58.mat";
%     "Processed Data\PROCESSED_S22_Zian_Deadlift_15Reps-2024-02-03_23-57-56.mat";
%     ];

%v0.1 feedforward, v0.2 feedforward 20 hidden layers
% datasets.list=["Processed Data\PROCESSED_S22_Josh_BenchPress_OO_10Reps_V-undefined-undefined-2024-03-19_17-10-40.mat"
% "Processed Data\PROCESSED_S22_Josh_OO_Walking_RA_15min-2023-11-22_17-14-21.mat"
% "Processed Data\PROCESSED_S22_Josh_Pullups_OO_7Reps_V-undefined-undefined-2024-03-19_17-30-02.mat"
% "Processed Data\PROCESSED_S22_Raya_BarbellSquat_20Reps-undefined-undefined-2024-03-19_17-18-45.mat"
% "Processed Data\PROCESSED_S22_Raya_BenchPress_OO_20Reps-undefined-undefined-2024-03-19_16-58-48.mat"
% "Processed Data\PROCESSED_S22_Raya_Jogging_OO_UnknownSteps-undefined-undefined-2024-03-19_16-53-48.mat"
% "Processed Data\PROCESSED_S22_Raya_OO_Walking_RA_15min-2023-11-22_17-33-11.mat"
% "Processed Data\PROCESSED_S22_Raya_Pullups_OO_7Reps-undefined-undefined-2024-03-19_17-27-07.mat"
% "Processed Data\PROCESSED_S22_Selena_BenchPress_OO_8Reps-undefined-undefined-2024-03-20_11-25-08.mat"
% "Processed Data\PROCESSED_S22_Selena_Jogging_OO_200Steps-undefined-undefined-2024-03-20_10-43-03.mat"
% "Processed Data\PROCESSED_S22_Selena_OO_Walking_RA_15min-2023-11-22_17-51-15.mat"
% "Processed Data\PROCESSED_S22_Selena_Situps_OO_UnknownReps_V-undefined-undefined-2024-03-20_11-00-22.mat"
% "Processed Data\PROCESSED_S22_Static_OnTable_FacingCeiling_30s-2023-11-18_01-44-21.mat"
% "Processed Data\PROCESSED_S22_Zian_BenchPress_OO_15Reps-undefined-undefined-2024-03-19_17-03-16.mat"
% "Processed Data\PROCESSED_S22_Zian_Deadlift_15Reps-2024-02-03_23-57-56.mat"
% "Processed Data\PROCESSED_S22_Zian_Jogging_OO_200Steps-2024-02-05_20-39-58.mat"
% "Processed Data\PROCESSED_S22_Zian_Jogging_OO_300Steps-undefined-undefined-2024-03-19_16-45-41.mat"
% "Processed Data\PROCESSED_S22_Zian_OO_Walking_RA_15min-2023-11-22_18-13-26.mat"
% "Processed Data\PROCESSED_S22_Zian_Situps_OO_20Reps-undefined-undefined-2024-03-20_11-08-46.mat"];

%v0.3 feedforward, v0.4 feedforward 20 hidden layers, v0.5-v0.7
% datasets.list=["Processed Data\PROCESSED_S22_Josh_BenchPress_OO_10Reps_V-undefined-undefined-2024-03-19_17-10-40.mat";
% "Processed Data\PROCESSED_S22_Josh_OO_Walking_RA_15min-2023-11-22_17-14-21.mat";
% "Processed Data\PROCESSED_S22_Josh_Pullups_OO_7Reps_V-undefined-undefined-2024-03-19_17-30-02.mat";
% "Processed Data\PROCESSED_S22_Raya_BarbellSquat_20Reps-undefined-undefined-2024-03-19_17-18-45.mat";
% "Processed Data\PROCESSED_S22_Raya_BenchPress_OO_20Reps-undefined-undefined-2024-03-19_16-58-48.mat";
% "Processed Data\PROCESSED_S22_Raya_Jogging_OO_300Steps-undefined-undefined-2024-03-19_16-49-43.mat";
% "Processed Data\PROCESSED_S22_Raya_Jogging_OO_UnknownSteps-undefined-undefined-2024-03-19_16-53-48.mat";
% "Processed Data\PROCESSED_S22_Raya_OO_Walking_RA_15min-2023-11-22_17-33-11.mat";
% "Processed Data\PROCESSED_S22_Raya_Pullups_OO_7Reps-undefined-undefined-2024-03-19_17-27-07.mat";
% "Processed Data\PROCESSED_S22_Raya_BarbellSquats_OO_10Reps-undefined-undefined-2024-03-19_17-41-14.mat";
% "Processed Data\PROCESSED_S22_Selena_BarbellSquat_OO_8Reps_ImpactLastRep-undefined-undefined-2024-03-20_11-57-34.mat";
% "Processed Data\PROCESSED_S22_Selena_BarbellSquats_10Reps-undefined-undefined-2024-03-27_8-41-47.mat";
% "Processed Data\PROCESSED_S22_Selena_BenchPress_10Reps-undefined-undefined-2024-03-27_8-53-13.mat";
% "Processed Data\PROCESSED_S22_Selena_BenchPress_10Reps_Training-undefined-undefined-2024-03-27_8-55-50.mat";
% "Processed Data\PROCESSED_S22_Selena_Jogging_OO_310Steps-undefined-undefined-2024-03-27_9-22-50.mat";
% "Processed Data\PROCESSED_S22_Selena_OO_Walking_RA_15min-2023-11-22_17-51-15.mat";
% "Processed Data\PROCESSED_S22_Selena_Pullups_10+Reps-undefined-undefined-2024-03-27_9-14-45.mat";
% "Processed Data\PROCESSED_S22_Selena_Situps_OO_UnknownReps_V-undefined-undefined-2024-03-20_11-00-22.mat";
% "Processed Data\PROCESSED_S22_Static_OnTable_FacingCeiling_30s-2023-11-18_01-44-21.mat";
% "Processed Data\PROCESSED_S22_Zian_BarbellSquats_12Reps_1Plate-undefined-undefined-2024-03-27_8-28-34.mat";
% "Processed Data\PROCESSED_S22_Zian_BarbellSquats_12Reps_BarOnly-undefined-undefined-2024-03-27_8-23-08.mat";
% "Processed Data\PROCESSED_S22_Zian_BarbellSquats_16+Reps-undefined-undefined-2024-03-26_21-04-39.mat";
% "Processed Data\PROCESSED_S22_Zian_BarbellSquats_8Reps_-undefined-undefined-2024-03-26_21-09-08.mat";
% "Processed Data\PROCESSED_S22_Zian_BenchPress_25Reps-undefined-undefined-2024-03-25_21-02-45.mat";
% "Processed Data\PROCESSED_S22_Zian_BenchPress_8Reps-undefined-undefined-2024-03-25_21-07-24.mat";
% "Processed Data\PROCESSED_S22_Zian_BenchPress_OO_15Reps-undefined-undefined-2024-03-19_17-03-16.mat";
% "Processed Data\PROCESSED_S22_Zian_Deadlift_15Reps-2024-02-03_23-57-56.mat";
% "Processed Data\PROCESSED_S22_Zian_Deadlift_OO_10Reps-undefined-undefined-2024-03-20_11-42-53.mat";
% "Processed Data\PROCESSED_S22_Zian_Jogging_OO_200Steps-2024-02-05_20-39-58.mat";
% "Processed Data\PROCESSED_S22_Zian_Jogging_OO_300Steps-undefined-undefined-2024-03-19_16-45-41.mat";
% "Processed Data\PROCESSED_S22_Zian_Jogging_UnknownSteps_V-undefined-undefined-2024-03-27_9-32-42.mat";
% "Processed Data\PROCESSED_S22_Zian_OO_Walking_RA_15min-2023-11-22_18-13-26.mat";
% "Processed Data\PROCESSED_S22_Zian_Pullups_16Reps-undefined-undefined-2024-03-27_9-08-44.mat";
% "Processed Data\PROCESSED_S22_Zian_Situps_OO_20Reps-undefined-undefined-2024-03-20_11-08-46.mat"];

datasets.list=["Processed Data\PROCESSED_S22_Josh_BenchPress_OO_10Reps_V-undefined-undefined-2024-03-19_17-10-40.mat"
"Processed Data\PROCESSED_S22_Josh_OO_Walking_RA_15min-2023-11-22_17-14-21.mat"
"Processed Data\PROCESSED_S22_Josh_Pullups_OO_7Reps_V-undefined-undefined-2024-03-19_17-30-02.mat"
"Processed Data\PROCESSED_S22_Raya_BarbellSquat_20Reps-undefined-undefined-2024-03-19_17-18-45.mat"
"Processed Data\PROCESSED_S22_Raya_BarbellSquat_OO_10Reps-undefined-undefined-2024-03-19_17-41-14.mat"
"Processed Data\PROCESSED_S22_Raya_BarbellSquats_OO_10Reps-undefined-undefined-2024-03-19_17-41-14.mat"
"Processed Data\PROCESSED_S22_Raya_BenchPress_OO_10Reps_V-undefined-undefined-2024-03-19_17-13-05.mat"
"Processed Data\PROCESSED_S22_Raya_BenchPress_OO_20Reps-undefined-undefined-2024-03-19_16-58-48.mat"
"Processed Data\PROCESSED_S22_Raya_Jogging_OO_300Steps-undefined-undefined-2024-03-19_16-49-43.mat"
"Processed Data\PROCESSED_S22_Raya_Jogging_OO_UnknownSteps-undefined-undefined-2024-03-19_16-53-48.mat"
"Processed Data\PROCESSED_S22_Raya_OO_Walking_RA_15min-2023-11-22_17-33-11.mat"
"Processed Data\PROCESSED_S22_Raya_Pullups_OO_7Reps-undefined-undefined-2024-03-19_17-27-07.mat"
"Processed Data\PROCESSED_S22_Raya_Pullups_OO_7Reps-undefined-undefined-2024-03-19_17-32-35.mat"
"Processed Data\PROCESSED_S22_Raya_Walking_OO_300Steps-undefined-undefined-2024-03-19_16-39-27.mat"
"Processed Data\PROCESSED_S22_Selena_BarbellSquat_OO_8Reps_ImpactLastRep-undefined-undefined-2024-03-20_11-57-34.mat"
"Processed Data\PROCESSED_S22_Selena_BarbellSquats_10Reps-undefined-undefined-2024-03-27_8-41-47.mat"
"Processed Data\PROCESSED_S22_Selena_BenchPress_10Reps-undefined-undefined-2024-03-27_8-53-13.mat"
"Processed Data\PROCESSED_S22_Selena_BenchPress_10Reps_Training-undefined-undefined-2024-03-27_8-55-50.mat"
"Processed Data\PROCESSED_S22_Selena_BenchPress_OO_8Reps-undefined-undefined-2024-03-20_11-25-08.mat"
"Processed Data\PROCESSED_S22_Selena_Jogging_OO_200Steps-undefined-undefined-2024-03-20_10-43-03.mat"
"Processed Data\PROCESSED_S22_Selena_Jogging_OO_310Steps-undefined-undefined-2024-03-27_9-22-50.mat"
"Processed Data\PROCESSED_S22_Selena_OO_Walking_RA_15min-2023-11-22_17-51-15.mat"
"Processed Data\PROCESSED_S22_Selena_Pullups_10+Reps-undefined-undefined-2024-03-27_9-14-45.mat"
"Processed Data\PROCESSED_S22_Selena_Situps_OO_UnknownReps_V-undefined-undefined-2024-03-20_11-00-22.mat"
"Processed Data\PROCESSED_S22_Static_OnTable_FacingCeiling_30s-2023-11-18_01-44-21.mat"
"Processed Data\PROCESSED_S22_Zian_BarbellSquat_OO_10Reps_V-undefined-undefined-2024-03-20_12-01-30.mat"
"Processed Data\PROCESSED_S22_Zian_BarbellSquats_12Reps_1Plate-undefined-undefined-2024-03-27_8-28-34.mat"
"Processed Data\PROCESSED_S22_Zian_BarbellSquats_12Reps_BarOnly-undefined-undefined-2024-03-27_8-23-08.mat"
"Processed Data\PROCESSED_S22_Zian_BarbellSquats_16+Reps-undefined-undefined-2024-03-26_21-04-39.mat"
"Processed Data\PROCESSED_S22_Zian_BarbellSquats_8Reps_-undefined-undefined-2024-03-26_21-09-08.mat"
"Processed Data\PROCESSED_S22_Zian_BenchPress_25Reps-undefined-undefined-2024-03-25_21-02-45.mat"
"Processed Data\PROCESSED_S22_Zian_BenchPress_8Reps-undefined-undefined-2024-03-25_21-07-24.mat"
"Processed Data\PROCESSED_S22_Zian_BenchPress_OO_15Reps-undefined-undefined-2024-03-19_17-03-16.mat"
"Processed Data\PROCESSED_S22_Zian_Deadlift_15Reps-2024-02-03_23-57-56.mat"
"Processed Data\PROCESSED_S22_Zian_Deadlift_OO_10Reps-undefined-undefined-2024-03-20_11-42-53.mat"
"Processed Data\PROCESSED_S22_Zian_Jogging_OO_200Steps-2024-02-05_20-39-58.mat"
"Processed Data\PROCESSED_S22_Zian_Jogging_OO_300Steps-undefined-undefined-2024-03-19_16-45-41.mat"
"Processed Data\PROCESSED_S22_Zian_Jogging_OO_40Steps-undefined-undefined-2024-03-20_10-48-02.mat"
"Processed Data\PROCESSED_S22_Zian_Jogging_UnknownSteps_V-undefined-undefined-2024-03-27_9-32-42.mat"
"Processed Data\PROCESSED_S22_Zian_OO_Walking_RA_15min-2023-11-22_18-13-26.mat"
"Processed Data\PROCESSED_S22_Zian_Pullups_16Reps-undefined-undefined-2024-03-27_9-08-44.mat"
"Processed Data\PROCESSED_S22_Zian_Pullups_OO_5Reps-undefined-undefined-2024-03-19_17-25-01.mat"
"Processed Data\PROCESSED_S22_Zian_Pullups_OO_8Reps-undefined-undefined-2024-03-20_11-31-16.mat"
"Processed Data\PROCESSED_S22_Zian_Pullups_OO_8Reps_Meh_V-undefined-undefined-2024-03-19_17-35-10.mat"
"Processed Data\PROCESSED_S22_Zian_Situps_OO_12Reps_V-undefined-undefined-2024-03-20_11-12-47.mat"
"Processed Data\PROCESSED_S22_Zian_Situps_OO_20Reps-undefined-undefined-2024-03-20_11-08-46.mat"];

% datasettest.list=datasets.list(1);
% x=gather_data_NNFormat(datasettest,0);
switch NN_type
    case "FF"
    [x,t]=gather_data_NNFormat(datasets,1,diag(sensor_select));
    case "FF_Stats"
    [x,t]=gather_data_NNFormat_stats(datasets,1,diag(sensor_select));
    case "LSTM"
    [x,t]=gather_data_NNFormat_LSTM(datasets,1,diag(sensor_select));
end

disp('Done');

disp('Running NN');

switch NN_type
    case "FF"
        net=patternnet(hidden_layers);
        net=train(net,x,t);
    case "FF_Stats"
        net=patternnet(hidden_layers);
        net=train(net,x,t);
    case "LSTM"

        numHiddenUnits = 250;
        miniBatchSize = 1000;
        maxEpochs = 250;
        gradientThreshold = 2;
        executionEnvironment = 'cpu';

        layers = [
            sequenceInputLayer(sum(sensor_select));
            bilstmLayer(numHiddenUnits,OutputMode="last")
            fullyConnectedLayer(length(datasets.classes))
            softmaxLayer];
        options = trainingOptions("adam", ...
            MaxEpochs=500, ...
            InitialLearnRate=0.002,...
            GradientThreshold=1, ...
            Shuffle="never", ...
            Plots="training-progress", ...
            Metrics="accuracy", ...
            Verbose=false);
        net = trainnet(x,t,layers,"crossentropy",options);
        % layers = [ ...
        %     % input layer
        %     sequenceInputLayer(sum(sensor_select))
        %     % recurrent layers:
        %     % numHiddenUnits indicates number of hidden layers
        %     % OutputMode = 'sequence' indicates that the net must classify each
        %     % time instant of the streaming
        %     lstmLayer(numHiddenUnits,'OutputMode','sequence')
        %     % decision layer
        %     fullyConnectedLayer(length(datasets.classes))
        %     softmaxLayer
        %     % output layer
        %     classificationLayer];
        % options = trainingOptions(...
        %     'adam', ...
        %     'MiniBatchSize',miniBatchSize, ...
        %     'MaxEpochs',maxEpochs, ...
        %     'GradientThreshold', gradientThreshold, ...
        %     'Verbose', 0, ...
        %     'Plots','none', ...
        %     'ExecutionEnvironment', executionEnvironment);
        % net = trainnet(x,t,layers,options);
        y=minibatchpredict(net,x);
end




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

%% From MATLAB

% function varargout = minibatchpredict(net, x, NameValueArgs)
% %
% 
% %   Copyright 2023-2024 The MathWorks, Inc.
% 
% arguments
%     net(1,1) {iValidateNetwork(net)}
% end
% arguments (Repeating)
%     x
% end
% arguments
%     NameValueArgs.MiniBatchSize(1,1) {mustBeInteger, mustBePositive} = 128
%     NameValueArgs.Outputs { deep.internal.util.validateOutputNames(NameValueArgs.Outputs) } = net.OutputNames
%     NameValueArgs.Acceleration(1,1) string { mustBeMember(NameValueArgs.Acceleration, ["none", "auto", "mex"]) } = "auto"
%     NameValueArgs.ExecutionEnvironment(1,1) string { mustBeMember(NameValueArgs.ExecutionEnvironment, ["cpu", "auto", "gpu"]) } = "auto"
%     NameValueArgs.SequenceLength(1,1) string { mustBeMember(NameValueArgs.SequenceLength, ["longest", "shortest"]) } = "longest"
%     NameValueArgs.SequencePaddingValue(1,1) double = 0
%     NameValueArgs.SequencePaddingDirection(1,1) string { mustBeMember(NameValueArgs.SequencePaddingDirection, ["right", "left"]) } = "right"
%     NameValueArgs.InputDataFormats = "auto"
%     NameValueArgs.OutputDataFormats = "auto"
%     NameValueArgs.UniformOutput(1,1) logical = true
% end
% 
% NameValueArgs = iConvertToCanonicalForm(NameValueArgs);
% 
% % Verify number of inputs
% % NB: Multiple inputs only supported for in-memory data
% numInputs = numel(net.InputNames);
% [hasDatastoreInput, hasMinibatchqueueInput] = iHasDatastoreOrMinibatchqueueInput(x);
% hasDatastoreOrMinibatchqueueInput = hasDatastoreInput || hasMinibatchqueueInput;
% if ~hasDatastoreOrMinibatchqueueInput && numel(x) ~= numInputs
%     error(message('nnet_cnn:dlnetwork:WrongNumInputs', numInputs, numel(x)));
% elseif hasDatastoreInput && ~isscalar(x)
%     error(message('deep:train:MultipleDatastoreInputs'));
% elseif hasMinibatchqueueInput && ~isscalar(x)
%     error(message('deep:train:MultipleMinibatchqueueInputs'));
% end
% 
% % Verify number of outputs
% % NB: State outputs not supported, so only support the number of
% % activations requested via the Outputs argument
% numOutputs = numel(NameValueArgs.Outputs);
% numDataOutputs = max(nargout, 1);
% if numDataOutputs > numOutputs
%     error(message('nnet_cnn:minibatchpredict:TooManyOutputs', numOutputs, numDataOutputs));
% end
% 
% % Validate and standardize data formats
% inputDataFormats = iValidateAndStandardizeFormats(NameValueArgs.InputDataFormats, "InputDataFormats");
% outputDataFormats = iValidateAndStandardizeFormats(NameValueArgs.OutputDataFormats, "OutputDataFormats");
% 
% try
%     [varargout{1:numDataOutputs}] = iCallMiniBatchPredict(x, net, inputDataFormats, outputDataFormats, numInputs, numDataOutputs, hasDatastoreOrMinibatchqueueInput, NameValueArgs);
% catch err
%     nnet.internal.cnn.util.rethrowDLExceptions(err);
% end
% end
% 
% function NameValueArgs = iConvertToCanonicalForm(NameValueArgs)
%     NameValueArgs.Outputs = cellstr(NameValueArgs.Outputs);
% end
% 
% function iValidateNetwork(net)
% if ~isa(net, 'dlnetwork') || ~net.Initialized
%     error(message('nnet_cnn:minibatchpredict:InvalidNetwork'));
% end
% end
% 
% function [hasDatastoreInput, hasMinibatchqueueInput] = iHasDatastoreOrMinibatchqueueInput(data)
% hasDatastoreInput = false;
% hasMinibatchqueueInput = false;
% numInputs = numel(data);
% for i = 1:numInputs
%     x = data{i};
%     if matlab.io.datastore.internal.shim.isDatastore(x)
%         hasDatastoreInput = true;
%         break
%     elseif isa(x, 'minibatchqueue')
%         hasMinibatchqueueInput = true;
%         break
%     end
% end
% end
% 
% function formats = iValidateAndStandardizeFormats(formats, formatName)
% formats = deep.internal.util.validateDataFormats(formats);
% 
% % Verify formats has a batch dim
% if ~isempty(formats)
%     for i = 1:numel(formats)
%         if ~contains(formats{i},'B')
%             error(message('nnet_cnn:minibatchpredict:DataFormatDoesNotContainBDim', formatName));
%         end
%     end
% end
% end
% 
% function varargout = iCallMiniBatchPredict(x, net, inputDataFormats, outputDataFormats, numInputs, numDataOutputs, hasDatastoreOrMinibatchqueueInput, NameValueArgs)
% [mbq, metadata] = iCreateMiniBatchQueue(x, net, hasDatastoreOrMinibatchqueueInput, NameValueArgs);
% 
% % Error if gpuArray inputs are provided with CPU execution environment
% if metadata.IsGpuArray && strcmp(NameValueArgs.ExecutionEnvironment, "cpu")
%     error(message('nnet_cnn:minibatchpredict:ExecutionEnvironmentAndGpuArrayInputs'));
% end
% 
% inputBatchDims = iGetBatchDimsFromFormats(mbq.MiniBatchFormat(1:numInputs));
% predictStrategy = deep.internal.util.createMiniBatchPredictStrategy(net, inputBatchDims, numDataOutputs, mbq.OutputEnvironment, NameValueArgs);
% 
% if NameValueArgs.UniformOutput
%     concatenationStrategy = deep.internal.util.NumericArrayConcatenationStrategy(metadata, inputDataFormats, outputDataFormats, inputBatchDims, NameValueArgs.Outputs);
% else
%     concatenationStrategy = deep.internal.util.CellArrayConcatenationStrategy(net, metadata, inputDataFormats, outputDataFormats, inputBatchDims, NameValueArgs.Outputs);
% end
% 
% outputs = cell(0, numDataOutputs);
% while hasdata(mbq)
%     [batchInputs{1:numInputs}] = next(mbq);
%     batchOutputs = predict(predictStrategy, net, batchInputs);
% 
%     [concatenationStrategy, batchOutputs] = postprocessDuringLoop(concatenationStrategy, batchInputs, batchOutputs, net);
%     outputs(end+1,:) = batchOutputs; %#ok<AGROW>
% end
% varargout = postprocessAfterLoop(concatenationStrategy, outputs, net);
% end
% 
% function [mbq, metadata] = iCreateMiniBatchQueue(data, net, hasDatastoreOrMinibatchqueueInput, NameValueArgs)
% inputDataFormats = deep.internal.util.standardizeDataFormats(NameValueArgs.InputDataFormats);
% if hasDatastoreOrMinibatchqueueInput
%     data = data{1};
% end
% [mbq, ~, metadata] = deep.internal.train.createMiniBatchQueue( ...
%     net, data, ...
%     MiniBatchSize = NameValueArgs.MiniBatchSize, ...
%     SequenceLength = NameValueArgs.SequenceLength, ...
%     SequencePaddingValue = NameValueArgs.SequencePaddingValue, ...
%     SequencePaddingDirection = NameValueArgs.SequencePaddingDirection,...
%     InputDataFormats = inputDataFormats, ...
%     OutputEnvironment = NameValueArgs.ExecutionEnvironment, ...
%     IncludeTargets = false);
% 
% % Always set PreprocessingEnvironment to serial because other values cannot
% % guarantee the order of outputs is preserved.
% mbq.PreprocessingEnvironment = "serial";
% end
% 
% function batchDims = iGetBatchDimsFromFormats(formats)
% numFormats = numel(formats);
% batchDims = zeros(1, numFormats);
% for i = 1:numel(formats)
%     sortedFormat = deep.internal.format.orderFormat(formats{i});
%     batchDims(i) = find(sortedFormat=='B');
% end
% end

