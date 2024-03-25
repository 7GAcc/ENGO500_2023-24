
clear all; clc;
%% Load Data
%Load data being tested
testdatafile="Data/S22_Zian_Walking_OO_300Steps-2024-02-05_20-26-28";

%Load Neural Network Data
load("C:\Users\zianz\Repos\ENGO500_2023-24\NN Directory\PatternNet\PatternNet_version0_1.mat");

clearvars call_gyro_x_data call_gyro_y_data plotting t x;

testdata=load(testdatafile);
%% Classification




%% Zero-Crossing




%% Final outputs


disp("Done!")