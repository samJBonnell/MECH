function [perStepEnergy, totalEnergy, perStepPower, reserveEnergy] = simulator(elevationData,stops,stopBound,startingE,Mass,C_d,A,rho_air,V_max,a_max,C_r, g,startTime,regenBool,regenEfficiency)
    % Configure Initial Conditions for Simulation
    N = size(elevationData, 1);
    velocity = zeros(N,1);
    perStepEnergy = zeros(N,1);
    perStepPower = zeros(N,1);
    totalEnergy = zeros(N,1);
    reserveEnergy = zeros(N,1);

    reserveEnergy(1,1) = startingE;
    stopIndex = 1;  % Represents the index of stop in the stop list
    
    % Compute the energy requirements from the start point to end point
    
    for index = 1:size(elevationData, 1) - 1 % For each point along the route...
        h_0 = elevationData(index, 1);
        h_1 = elevationData(index + 1, 1);
        x_0 = elevationData(index, 4);
        theta_0 = elevationData(index, 2);
        d_0 = elevationData(index, 3);
    
        % Corrected length for height energy calculation
        l_0 = sqrt((x_0)^2 + (h_1 - h_0)^2);
    
        if velocity(index,1) == 0
            velocity(index,1) = startTime*a_max;
        end
    
        % Compute the velocity at the next point of the mesh
        if sqrt(velocity(index, 1)^2 + 2*a_max*l_0) > V_max
            velocity(index + 1, 1) = velocity(index, 1);
        else
            velocity(index + 1, 1) = sqrt(velocity(index, 1)^2 + 2*a_max*l_0);
        end
        
        % Compute the energy required to reach the next step
        tempEnergy = (1/2)*rho_air*(velocity(index, 1)^2)*C_d*A*l_0 + C_r*Mass*g*cos(theta_0)*l_0 + Mass*g*sin(theta_0)*l_0 + (1/2)*Mass*(velocity(index + 1, 1)^2 - velocity(index, 1)^2);

        if tempEnergy < 0 && regenBool == 1
            perStepEnergy(index, 1) = regenEfficiency*tempEnergy;
            perStepPower(index, 1) = 0;
        elseif tempEnergy < 0
            perStepEnergy(index, 1) = 0;
            perStepPower(index, 1) = 0;
        else 
            perStepEnergy(index, 1) = tempEnergy;
            perStepPower(index, 1) = (perStepEnergy(index, 1)*(1/2)*(velocity(index + 1, 1) + velocity(index, 1)))/(l_0);
        end

        % Update SoC based on the energy calculated above
        reserveEnergy(index + 1, 1) = reserveEnergy(index, 1) - (perStepEnergy(index, 1)/3600);
        if reserveEnergy(index + 1,1) > startingE
            reserveEnergy(index + 1,1) = startingE;
        end
        
        % If we have more than one point, start summing the total energy
        if index > 1
            totalEnergy(index, 1) = perStepEnergy(index, 1) + totalEnergy(index - 1, 1);
        end

        % Check for the "stop" condition that resets the velocity for each stop
        % defined in the stops() matrix
        if stopIndex ~= size(stops,2) && isempty(stops) ~= 1
            if (stops(stopIndex) < d_0 + stopBound && stops(stopIndex) > d_0 - stopBound) % A stop has been found
                velocity(index + 1, 1) = 0; % Reset the velocity
                stopIndex = stopIndex + 1; % Check for next stop in matrix
            end
        end
    end
    
    % Compute energy for the final step of the process
    tempEnergy = (1/2)*rho_air*(velocity(end, 1)^2)*C_d*A*l_0 + C_r*Mass*g*cos(theta_0)*l_0 + Mass*g*sin(theta_0)*l_0 + (1/2)*Mass*(velocity(end, 1)^2 - velocity(end, 1)^2);
    if tempEnergy < 0 && regenBool == 1
        perStepEnergy(end, 1) = regenEfficiency*tempEnergy;
        perStepPower(end, 1) = 0;
    elseif tempEnergy < 0
        perStepEnergy(end, 1) = 0;
        perStepPower(end, 1) = 0;
    else 
        perStepEnergy(end, 1) = tempEnergy;
        perStepPower(end, 1) = (perStepEnergy(end, 1)*(1/2)*(velocity(end, 1) + velocity(end, 1)))/(l_0);
    end

    reserveEnergy(end, 1) = reserveEnergy(end, 1) - (perStepEnergy(end, 1)/3600);
    totalEnergy(end, 1) = perStepEnergy(end, 1) + totalEnergy(end - 1, 1);
end