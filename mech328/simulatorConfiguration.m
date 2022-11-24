%{
    MECH 328 R5 Electrification Energy Simulation
    
    The purpose of this program is to better simulate the energy
    requirements of the R5 electric bus pilot project. This file employs a
    numerical integration scheme developed to be used with a dataset of
    elevation and slope.

    dE_i = (1/2)*rho*(V_i^2)*C_d*A*l_0 + C_r*Mass*g*cos(theta_i)*l_0 + Mass*g*sin(theta_i)*l_0 + (1/2)*Mass*(V_i+1^2 - V_i^2);

    Elevation and slope data are loaded from an external excel file for the
    route and a discretized energy method sums the individual sections
    including rolling resistance, drag, gravitational effects from angled
    slopes, and (potentially) energy loss in the form of heat.

    Parameters to configure the method are found at the top of this
    document.

    Sam Bonnell
    2022-11-21
%}
close all;
clc;

% Define constants for ALL simulations
Mass = 20000;               % kg
C_d = 1;                    % unitless
A = 9;                      % m^2
rho_air = 1.2;              % kg/m^3
V_max = 55/3.6;             % m/s
a_max = 0.7;                % m/s^2
C_r = 0.0075;               % unitless
g = 9.81;                   % m/s^2
startTime = 1;              % s
stopBound = 0.05;           % Within 10 metres, the stop will be applied
startingE = 140000;         % Total energy available in Wh 

regenBool = 1;              % sets if simulation tracks regeneration energy
regenEfficiency = 0.60;     % acceptable range between 60 - 70%

plotBool = 1;               % Set true if you want to plot results

% Load R5 program data
R5elevationData = readtable("R5.xlsx", VariableNamingRule="preserve");
R5elevationData = table2array(R5elevationData);             % Elevation, Slope (%), Distance (km), distance_interval (m)
R5elevationData(:, 2) = atan(R5elevationData(:,2)/100);     % Convert slope percent into an angle (radians)

R5stops = [0.43, 1.07, 1.61, 3.26, 4.78, 5.69, 7.00, 7.85, 8.66, 9.64, 10.32, 11.12, 12.32, 16.04, 17.10]; % A list of the stop locations in km from the start of the track

% Load R4 program data
R4elevationData = readtable("R4.xlsx", VariableNamingRule="preserve");
R4elevationData = table2array(R4elevationData);             % Elevation, Slope (%), Distance (km), distance_interval (m)
R4elevationData(:, 2) = atan(R4elevationData(:,2)/100);     % Convert slope percent into an angle (radians)

R4stops = [0.77, 1.96, 7.64, 8.56, 9.83, 10.92, 11.77, 13.76, 14.56, 15.51, 16.39, 17.15, 18.09, 18.58, 19.15]; % A list of the stop locations in km from the start of the track

% Load 25 program data
B25elevationData = readtable("25.xlsx", VariableNamingRule="preserve");
B25elevationData = table2array(B25elevationData);             % Elevation, Slope (%), Distance (km), distance_interval (m)
B25elevationData(:, 2) = atan(B25elevationData(:,2)/100);     % Convert slope percent into an angle (radians)

B25stops = [0.61,1.08,1.56,1.92,2.97,3.43,3.65,4.09,4.80,5.02,5.42,5.61,6.09,6.60,7.03,7.46,7.87,8.24,8.51,8.71,8.96,9.15,9.39,9.70,9.93,10.15,10.44,10.94,11.32,11.91,12.57,12.86,13.23,13.67,14.02,14.27,14.73,15.06,15.28,15.59,15.84,16.22,16.22,16.51,17.03,17.77,18.16,18.53,18.90,19.12,19.53,19.59,20.14,20.49,21.02,21.30,21.79,22.12,22.91,23.20,23.75]; % A list of the stop locations in km from the start of the track

% Simulation Loop - to be added of course
[R5_energy, R5_totalEnergy, R5_power, R5_reserveEnergy] = simulator(R5elevationData,R5stops,stopBound,startingE,Mass,C_d,A,rho_air,V_max,a_max,C_r,g,startTime,regenBool,regenEfficiency);
[R4_energy, R4_totalEnergy, R4_power, R4_reserveEnergy] = simulator(R4elevationData,R4stops,stopBound,startingE,Mass,C_d,A,rho_air,V_max,a_max,C_r,g,startTime,regenBool,regenEfficiency);
[B25_energy, B25_totalEnergy, B25_power, B25_reserveEnergy] = simulator(B25elevationData,B25stops,stopBound,startingE,Mass,C_d,A,rho_air,V_max,a_max,C_r,g,startTime,regenBool,regenEfficiency);

% Print Results
printResults(R5_energy, R5_totalEnergy, R5_power, R5_reserveEnergy,regenBool,regenEfficiency, "R5");
printResults(R4_energy, R4_totalEnergy, R4_power, R4_reserveEnergy,regenBool,regenEfficiency, "R4");
printResults(B25_energy, B25_totalEnergy, B25_power, B25_reserveEnergy,regenBool,regenEfficiency, "25");

% Plot Results
if plotBool ~= 0
    plotResults(R5elevationData, R5stops, R5_energy, R5_totalEnergy, R5_power, R5_reserveEnergy, "R5");
    plotResults(R4elevationData, R4stops, R4_energy, R4_totalEnergy, R4_power, R4_reserveEnergy, "R4");
    plotResults(B25elevationData, B25stops, B25_energy, B25_totalEnergy, B25_power, B25_reserveEnergy, "25");
end
