%This function takes in the data of an entire file
%and returns the pressure at trailing edge

function trail = getTrailPressure(data)
n = length(data);

%% Allocate port data
%top ports
SVport8 = data(:,14); 
SVport9 = data(:,15); 
%bottom ports
SVport10 = data(:,16); 
SVport11 = data(:,18);  

port8_x = 2.1;
port9_x = 2.8;
port10_x = 2.8;
port11_x = 2.1;

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

trail = final_approximation;
end