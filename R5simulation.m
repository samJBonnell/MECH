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

% Load excel data into program
elevationData = readtable("elevationProfile.xlsx", VariableNamingRule="preserve");
elevationData = table2array(elevationData); % Elevation, Slope (%), Distance (km), distance_interval (m)
elevationData(:, 2) = atan(elevationData(:,2)/100); % Convert slope percent into an angle (radians)

stopBound = 0.05;   % Within 10 metres, the stop will be applied
stops = [0.43, 1.07, 1.61, 3.26, 4.78, 5.69, 7.00, 7.85, 8.66, 9.64, 10.32, 11.12, 12.32, 16.04, 17.10]; % A list of the stop locations in km from the start of the track

% Define constants for simulation

Mass = 20000;   % kg
C_d = 1;        % unitless
A = 9;          % m^2
rho_air = 1.2;  % kg/m^3
V_max = 60/3.6; % m/s
a_max = 0.7;    % m/s^2
C_r = 0.0075;   % unitless
g = 9.81;       % m/s^2
startTime = 1;  % s
accF = 0.8;     % Factor applied to the length term of the acceleration to increase the resolution of the acceleration data. Determined by comparing simulation acceleration data to theoretical acceleration results

% Configure Initial Conditions for Simulation
N = size(elevationData, 1);
M = 5;
timeSteps = zeros(N,M); % velocity, energy, total energy, power, time
stopIndex = 1;  % Represents the stops that

% Compute the energy requirements of running from Burrard to SFU

for index = 1:size(elevationData, 1) - 1 % For each point along the route...
    h_0 = elevationData(index, 1);
    h_1 = elevationData(index + 1, 1);
    x_0 = elevationData(index, 4);
    theta_0 = elevationData(index, 2);
    d_0 = elevationData(index, 3);

    % Corrected length for height energy calculation
    l_0 = sqrt((x_0)^2 + (h_1 - h_0)^2);

    if timeSteps(index, 1) == 0
        timeSteps(index, 1) = startTime*a_max;
    end

    % Compute the velocity at the next point of the mesh
    tempAcc = a_max;
    if sqrt(timeSteps(index, 1)^2 + 2*tempAcc*l_0) > V_max
        timeSteps(index + 1, 1) = timeSteps(index, 1);
    else
        timeSteps(index + 1, 1) = sqrt(timeSteps(index, 1)^2 + 2*tempAcc*l_0);
    end
    
    % Compute the energy required to reach the next step
    timeSteps(index, 2) = (1/2)*rho_air*(timeSteps(index, 1)^2)*C_d*A*l_0 + C_r*Mass*g*cos(theta_0)*l_0 + Mass*g*sin(theta_0)*l_0 + (1/2)*Mass*(timeSteps(index + 1, 1)^2 - timeSteps(index, 1)^2);

    % Compute power required to reach the next step
    timeSteps(index, 4) = (timeSteps(index, 2)*(1/2)*(timeSteps(index + 1, 1) + timeSteps(index, 1)))/(l_0);

    % Add time per step
    timeSteps(index, 5) = (l_0^accF)/timeSteps(index, 1);

    % Check for the "stop" condition that resets the velocity for each stop
    % defined in the stops() matrix
    if stopIndex ~= size(stops,2)
        if (stops(stopIndex) < d_0 + stopBound && stops(stopIndex) > d_0 - stopBound) % A stop has been found
            timeSteps(index + 1, 1) = 0; % Reset the velocity
            timeSteps(index, 2) = (1/2)*rho_air*((timeSteps(index, 1)/2)^2)*C_d*A*l_0 + C_r*Mass*g*cos(theta_0)*l_0 + Mass*g*sin(theta_0)*l_0;
            stopIndex = stopIndex + 1; % Check for next stop in matrix
        end
    end

    % Remove negative energy as we are not employing regenerative braking
    if timeSteps(index, 2) < 0
        timeSteps(index, 2) = 0;
        timeSteps(index, 4) = 0;
    end

    % If we have more than one point, start summing the total energy
    if index > 1
        timeSteps(index, 3) = timeSteps(index, 2) + timeSteps(index - 1, 3);
    end
end

% Compute energy for the final step of the process
timeSteps(end, 2) = (1/2)*rho_air*(timeSteps(index, 1)^2)*C_d*A*l_0 + C_r*Mass*g*cos(theta_0)*l_0 + Mass*g*sin(theta_0)*l_0 + (1/2)*Mass*(timeSteps(index + 1, 1)^2 - timeSteps(index, 1)^2);
if timeSteps(end, 2) < 0
    timeSteps(end, 2) = 0;
end
timeSteps(end, 3) = timeSteps(end, 2) + timeSteps(end - 1, 3);

totals = sum(timeSteps, 1);
totalEnergy = totals(1,2);
distance = elevationData(:,3); %
elevation = elevationData(:,1);
insEnergy = timeSteps(:,2);
totEnergy = (1/3600)*timeSteps(:,3);
power = (1/1000)*timeSteps(:,4);
avgPower = movmean(power, 5);

fprintf("\nTotal Energy Consumption: %.3f J -> %.3f Wh\n", totalEnergy, totalEnergy/3600);
fprintf("Maximum Power: %.3f kW\n", max(avgPower));
fprintf("Average Power: %.3f kW\n", mean(avgPower));



% Plot total required energy vs. distance
figure;
hold on;
title("Energy Use Across Trip (Wh)");
xlabel('Distance (km)');
yyaxis left
ylabel('Elevation (m)');
plot(distance, elevation, 'color', "#0072BD");
yyaxis right
ylabel('Total Energy Consumption (Wh)');
plot(distance, totEnergy, 'magenta');
ax = gca;
ax.YAxis(1).Color = 'k';
ax.YAxis(2).Color = 'k';
plot(stops, 0, 'color', 'r', 'Marker', '+');

legend("Elevation", "Total Energy", "Stop Locations", 'Location', 'northeastoutside');

hold off;

% Plot required power vs. distance
figure;
hold on;
title("Power (kW) vs. Distance (km)");
xlabel('Distance (km)');
ylabel('Power (kW)');
plot(distance, power, 'color', "#0072BD");
legend("Power", 'Location', 'northeastoutside');
hold off;

% Plot average required power vs. distance
figure;
hold on;
title("5-Wide Rolling Mean Power (kW) vs. Distance (km)");
xlabel('Distance (km)');
ylabel('5-Wide Rolling Mean Power (kW)');
plot(distance, avgPower, 'color', "#0072BD");
legend("Power", 'Location', 'northeastoutside');
hold off;