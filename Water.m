clc; close all; clear;
waterM = xlsread('VelocityVoltageData/water.xlsx');
pp = waterM(1:15,3:end);
VT = waterM(16:26,3:end);