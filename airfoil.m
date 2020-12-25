clear variables; close all; clc;

% Constants
chord = 3.5; % [in]

files = dir('2002 Aero Lab 2 - Group Data/');
n_f = length(files);

r = 18; %randi([3,n_f - 2]);
lname = strcat(files(r).folder,'/',files(r).name);
data = load(lname);

pressure_trail = getTrailPressure(data).';

airspeed = data(:,4);
angle = data(:,23);

% Pressure ports
for i=7:22
    ports(:,i-6) = data(:,i);
end

upper_ports = [ports(:,1:9) pressure_trail];
lower_ports = [ports(:,1) fliplr(ports(:,10:16)) pressure_trail];

% Locations of ports including trailing edge at end
port_x_locations = [0 0.175 0.35 0.7 1.05 1.4 1.75 2.1 2.8 2.8 2.1 1.4 1.05 0.7 0.35 0.175 3.5];
port_y_locations = [0.14665 0.33075 0.4018 0.476 0.49 0.4774 0.4403 0.38325 0.21875 0 0 0 0 0 0.0014 0.0175 0.03885 0.14665];

upper_x = [port_x_locations(1:9) port_x_locations(end)];
lower_x = [port_x_locations(1) fliplr(port_x_locations(10:16)) port_x_locations(end)];

% Free-stream dynamic pressure
q_infinity = data(:,5);
p_infinity = data(:,6);

% Pressure coefficient of each port
for i=1:9
    upper_Cp(:,i) = (upper_ports(:,i)-p_infinity)./q_infinity;
    lower_Cp(:,i) = (lower_ports(:,i)-p_infinity)./q_infinity;
end
upper_Cp(:,10) = (upper_ports(:,10)-p_infinity)./q_infinity;

% Average each 20 rows of data
for i=1:20:221
    temp_Cp_upper(1+(i-1)/20,:) = mean(upper_Cp(i:i+19,:));
    temp_Cp_lower(1+(i-1)/20,:) = mean(lower_Cp(i:i+19,:));
    temp_airspeed(1+(i-1)/20,:) = mean(airspeed(i:i+19,:));
    temp_angle(1+(i-1)/20,:) = mean(angle(i:i+19,:));
end
upper_Cp = temp_Cp_upper;
lower_Cp = temp_Cp_lower;
airspeed = temp_airspeed;
angle = temp_angle;
clearvars temp_angle temp_airspeed temp_Cp_lower temp_Cp_upper

% Rearrange Cp, x and y for integration
Cp_new = [upper_Cp fliplr(lower_Cp(:,1:end-1))];
x_new = [upper_x fliplr(lower_x(1:end-1))];
y_new = port_y_locations;

% Integrate to find other coefficients
Cn = zeros(12,1);
Ca = zeros(12,1);
for i=2:18
    Cn = Cn-((Cp_new(:,i-1)+Cp_new(:,i)).*(x_new(i)-x_new(i-1))./(2*chord));
    Ca = Ca+((Cp_new(:,i-1)+Cp_new(:,i)).*(y_new(i)-y_new(i-1))./(2*chord));
end
Cl = Cn.*cos(deg2rad(angle))-Ca.*sin(deg2rad(angle));
Cd = Cn.*sin(deg2rad(angle))+Ca.*cos(deg2rad(angle));

% Plot result
for i=1:3:12
    figure((i-1)/3+1);
    for j=i:i+2
        subplot(3,1,j-i+1);
        hold on;
        grid minor;
        title(strcat("Airspeed: ",num2str(airspeed(j)),"  Angle: ",num2str(angle(j)),"  Cl: ",num2str(Cl(j)),"  Cd: ",num2str(Cd(j))));
        plot(upper_x./chord,upper_Cp(j,:),"LineWidth",3);
        plot(lower_x./chord,lower_Cp(j,:),"LineWidth",3);
        set(gca,'YDir','reverse');
        patch([lower_x./chord fliplr(upper_x./chord)],[lower_Cp(j,:) fliplr(upper_Cp(j,:))],[0.7 0.8 1]);
        xlabel("normalized chord length");
        ylabel("Cp");
        legend("upper","lower");
    end
end

% Coefficient vs angle
NACA = xlsread("ClarkY14_NACA_TR628.xlsx");

angle_v_Cl = sort([angle Cl]);
angle_v_Cd = sort([angle Cd]);
Cl_9 = [Cl(1) Cl(4) Cl(7) Cl(10)];
Cl_16 = [Cl(2) Cl(5) Cl(8) Cl(11)];
Cl_33 = [Cl(3) Cl(6) Cl(9) Cl(12)];
Cd_9 = [Cd(1) Cd(4) Cd(7) Cd(10)];
Cd_16 = [Cd(2) Cd(5) Cd(8) Cd(11)];
Cd_33 = [Cd(3) Cd(6) Cd(9) Cd(12)];
angle_new = [angle(1) angle(4) angle(7) angle(10)];
figure(5);
title("coefficient vs angle");
grid minor;
hold on;
xlabel("angle [deg]");
ylabel("coefficient of lift/drag");
plot(angle_new,Cl_9,'--',"LineWidth",2);
plot(angle_new,Cl_16,'--',"LineWidth",2);
plot(angle_new,Cl_33,'--',"LineWidth",2);
plot(angle_new,Cd_9,'--',"LineWidth",2);
plot(angle_new,Cd_16,'--',"LineWidth",2);
plot(angle_new,Cd_33,'--',"LineWidth",2);
plot(NACA(:,1),NACA(:,2),"LineWidth",2);
plot(NACA(:,1),NACA(:,3),"LineWidth",2);
legend("Cl @9.24","Cl @16.93","Cl @33.93","Cd @9.24","Cd @16.93","Cd @33.93","NACA Cl","NACA Cd");