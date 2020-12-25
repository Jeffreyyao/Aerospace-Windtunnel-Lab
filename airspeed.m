clear variables;close all;clc;
R_air = 287.058; % [J/(kg*K)]

sig_p_atm = 3450; % [Pa]
sig_T_atm = 0.25; % [K]
sig_del_p = 68.95; % [Pa]

%% Calculating Velocity with Pitot 
for i=1:12
    files_PP = dir('VelocityVoltageData/PitotProbeToPressureTransducer/');
    PP(:,:,i) = load(strcat(files_PP(i+2).folder,'/',files_PP(i+2).name));

    for j=1:5
        p_atm = PP(:,1,i);
        p_atm = mean(p_atm((j-1)*500+1:j*500));
        T_atm = PP(:,2,i);
        T_atm = mean(T_atm((j-1)*500+1:j*500));
        del_p = PP(:,3,i);
        del_p = mean(del_p((j-1)*500+1:j*500));
        airspeed_PP(j,i) = sqrt(2*del_p*R_air*T_atm/p_atm);
        voltage_PP(j,i) = PP(j*500,7,i);
        a = sig_del_p*(R_air*T_atm/p_atm)*(1/(sqrt((2*del_p*R_air*T_atm/p_atm))));
        b = sig_T_atm*(R_air*del_p/p_atm)*(1/(sqrt((2*del_p*R_air*T_atm/p_atm))));
        c = sig_p_atm*(-1*R_air*T_atm*del_p/(p_atm)^2)*(1/(sqrt((2*del_p*R_air*T_atm/p_atm))));
        error_PP(j,i) = sqrt(a+b+c);
    end
end

temp_airspeed_PP = [];
temp_voltage_PP = [];
temp_error_PP = [];
for i=1:4
    temp_airspeed_PP = [temp_airspeed_PP,mean([airspeed_PP(:,i),airspeed_PP(:,i+4),airspeed_PP(:,i+8)].')];
    temp_voltage_PP = [temp_voltage_PP,mean([voltage_PP(:,i),voltage_PP(:,i+4),voltage_PP(:,i+8)].')];
    temp_error_PP = [temp_error_PP,mean([error_PP(:,i),error_PP(:,i+4),error_PP(:,i+8)].')];
end

%% Calculating Velocity with Venturi
area_ratio = 1/9.5;
for i=1:12
    files_VT = dir('VelocityVoltageData/VenturiTubeToPressureTransducer/');
    VT(:,:,i) = load(strcat(files_VT(i+2).folder,'/',files_VT(i+2).name));
    
    for j=1:5
        p_atm = VT(:,1,i);
        p_atm = mean(p_atm((j-1)*500+1:j*500));
        T_atm = VT(:,2,i);
        T_atm = mean(T_atm((j-1)*500+1:j*500));
        del_p = VT(:,3,i);
        del_p = mean(del_p((j-1)*500+1:j*500));
        airspeed_VT(j,i) = sqrt(2*del_p*R_air*T_atm/(p_atm.*(1-area_ratio.^2)));
        voltage_VT(j,i) = VT(j*500,7,i);
        a = (R_air * T_atm / (p_atm*(1 - (1/9.5)^2))) * (1/(sqrt((2 * del_p * R_air * T_atm / p_atm))));
        b = (R_air * del_p / (p_atm*(1 - (1/9.5)^2))) * (1/(sqrt((2 * del_p * R_air * T_atm / p_atm))));
        c = (-1 * R_air * T_atm * del_p / (p_atm*(1 - (1/9.5)^2))^2) * (1/(sqrt((2 * del_p * R_air * T_atm / p_atm))));
        error_VT(j,i) = sqrt((a * sig_del_p)^2 + (b * sig_T_atm)^2 + (c * sig_p_atm)^2);
    end
end

temp_airspeed_VT = [];
temp_voltage_VT = [];
temp_error_VT = [];
for i=1:4
    temp_airspeed_VT = [temp_airspeed_VT,mean([airspeed_VT(:,i),airspeed_VT(:,i+4),airspeed_VT(:,i+8)].')];
    temp_voltage_VT = [temp_voltage_VT,mean([voltage_VT(:,i),voltage_VT(:,i+4),voltage_VT(:,i+8)].')];
    temp_error_VT = [temp_error_VT,mean([error_VT(:,i),error_VT(:,i+4),error_VT(:,i+8)].')];
end

%% Fit the line
p_PP = polyfit(temp_voltage_PP,temp_airspeed_PP,1);
p_VT = polyfit(temp_voltage_VT,temp_airspeed_VT,1);

%% Plot Result
ax = gca;
title("Voltage vs Airspeed (Pressure Transducer)");
ax.FontSize = 10;
hold on;
grid minor;
xlabel("Voltage (V)");
ylabel("Airspeed (m/s)");
errorbar(temp_voltage_VT,temp_airspeed_VT,temp_error_VT,"o","LineWidth",1.5);
errorbar(temp_voltage_PP,temp_airspeed_PP,temp_error_PP,"o","LineWidth",1.5);
legend("Venturi Tube","Pitot Probe");
hold off;