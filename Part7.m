close all
clear all
clc

%% Input Data
files = dir('2002 Aero Lab 2 - Group Data\');
n_f = length(files);

r = randi([3,n_f - 2]);
lname = strcat(files(r).folder,'\',files(r).name);
data = load(lname);
n = length(data);

Air_density = data(:,3);
Airspeed = data(:,4);

%% Allocate port data
SVportLE = data(:,7);
%top ports
SVport2 = data(:,8);
SVport3 = data(:,9);
SVport4 = data(:,10);
SVport5 = data(:,11);
SVport6 = data(:,12);
SVport7 = data(:,13);
SVport8 = data(:,14); 
SVport9 = data(:,15); 
%bottom ports
SVport10 = data(:,16); 
SVport11 = data(:,18); 
SVport12 = data(:,19); 
SVport13 = data(:,20); 
SVport14 = data(:,21); 
SVport15 = data(:,22); 
SVport16 = data(:,23); 


port8_x = 2.1;
port9_x = 2.8;
port10_x = 2.8;
port11_x = 2.1;

port8_y = 0.38325;
port9_y = 0.21875;
port10_y = 0;
port11_y = 0;

%% Pressure Calculations
pressure_diff_top = SVport8 - SVport9;
pressure_diff_bottom = SVport11 - SVport10;
x_diff_top = abs(port8_x - port9_x);
x_diff_bottom = abs(port11_x - port10_x);
m_top = pressure_diff_top ./ x_diff_top;
m_bottom = pressure_diff_bottom ./ x_diff_bottom;

%Use closest port to trailing edge as reference point
%y=mx+b so b=y-mx
b_top = SVport9 - (m_top .* port9_x);
b_bottom = SVport10 - (m_bottom .* port10_x);

top_approximation = zeros(n,1);
bottom_approximation = zeros(n,1);
%Approximate the pressure at x = 3.5 now with y=mx+b
for i = 1:n
    top_approximation(i) = (m_top(i) .* 3.5) + b_top(i);
    bottom_approximation(i) = (m_bottom(i) .* 3.5) + b_bottom(i);
end

%Average top and bottom approximations
final_approximation = zeros(1,n);
for i = 1:n
    final_approximation(i) = (bottom_approximation(i) + top_approximation(i)) / 2;
end

portTrailing = final_approximation;

%% Calculating Coefficient of Pressure
q_infinity = 0.5*Air_density*Airspeed^2;
Cp_portLE = SVportLE./q_infinity;
Cp_port2 = SVport2./q_infinity;
Cp_port3 = SVport3./q_infinity;
Cp_port4 = SVport4./q_infinity;
Cp_port5 = SVport5./q_infinity;
Cp_port6 = SVport6./q_infinity;
Cp_port7 = SVport7./q_infinity;
Cp_port8 = SVport8./q_infinity;
Cp_port9 = SVport9./q_infinity;
Cp_port10 = SVport10./q_infinity;
Cp_port11 = SVport11./q_infinity;
Cp_port12 = SVport12./q_infinity;
Cp_port13 = SVport13./q_infinity;
Cp_port14 = SVport14./q_infinity;
Cp_port15 = SVport15./q_infinity;
Cp_port16 = SVport16./q_infinity;
    
%% Plots
t = linspace(1,n,n);
figure(1);
plot(t,SVport8,'k');
hold on
plot(t,SVport9,'r');
legend('SVport8','SVport9');
title('Top Ports');
xlabel('Time')
ylabel('Pressure')
hold off
figure(2);
plot(t,SVport10,'k');
hold on
plot(t,SVport11,'r');
legend('SVport10','SVport11');
title('Bottom Ports');
xlabel('Time')
ylabel('Pressure')
hold off

figure(3);
plot(t,final_approximation,'k');
title('Trailing Edge Pressure');
xlabel('Time')
ylabel('Pressure')