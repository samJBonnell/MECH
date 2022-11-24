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

% Define constants for simulations
Mass = 20000;       % kg
C_d = 1;            % unitless
A = 9;              % m^2
rho_air = 1.2;      % kg/m^3
V_max = 60/3.6;     % m/s
a_max = 0.7;        % m/s^2
C_r = 0.0075;       % unitless
g = 9.81;           % m/s^2
startTime = 1;      % s
stopBound = 0.05;   % Within 10 metres, the stop will be applied
startingE = 50000;        % Total energy available in Wh 

regenBool = 0;    % sets if simulation tracks regeneration energy
regenEfficiency = 0.75;

plotBool = 1;       % Define if you want to plot results

% Load program data
R5elevationData = readtable("elevationProfile.xlsx", VariableNamingRule="preserve");
R5elevationData = table2array(R5elevationData); % Elevation, Slope (%), Distance (km), distance_interval (m)
R5elevationData(:, 2) = atan(R5elevationData(:,2)/100); % Convert slope percent into an angle (radians)
R5stops = [0.43, 1.07, 1.61, 3.26, 4.78, 5.69, 7.00, 7.85, 8.66, 9.64, 10.32, 11.12, 12.32, 16.04, 17.10]; % A list of the stop locations in km from the start of the track

% Simulation Loop - to be added of course
[R5_energy, R5_totalEnergy, R5_power, R5_reserveEnergy] = simulator(R5elevationData,R5stops,stopBound,startingE,Mass,C_d,A,rho_air,V_max,a_max,C_r,g,startTime,regenBool,regenEfficiency);

% Print Results
printResults(R5_energy, R5_totalEnergy, R5_power, R5_reserveEnergy,regenBool,regenEfficiency);

% Plot Results
if plotBool ~= 0
    plotResults(R5elevationData,R5stops, R5_energy, R5_totalEnergy, R5_power, R5_reserveEnergy);
end
