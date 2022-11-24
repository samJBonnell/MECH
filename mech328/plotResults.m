function plotResults(elevationData,stops,energy,totalEnergy,power,reserveEnergy, Name)
    distance = elevationData(:,3);
    elevation = elevationData(:,1);
    totEnergy = (1/3600)*totalEnergy;
    power = (1/1000)*power;
    avgPower = movmean(power, 5);

    % Plot total required energy vs. distance
    figure;
    hold on;
    title(Name + " - Energy Use Across Trip (kWh)");
    xlabel('Distance (km)');
    yyaxis left
    ylabel('Elevation (m)');
    plot(distance, elevation, 'color', "#0072BD");
    ylim([0,450]);
    yyaxis right
    ylabel('Total Energy Consumption (kWh)');
    plot(distance, totEnergy/1000, 'red');
    ax = gca;
    ax.YAxis(1).Color = 'k';
    ax.YAxis(2).Color = 'k';
    if isempty(stops) ~= 1
        plot(stops, 0, 'Marker', '+');
    end
    legend("Elevation", "Required Energy", "Stop Locations", 'Location', 'northeastoutside');
    hold off;
    
    %{
    % Plot required power vs. distance
    figure;
    hold on;
    title(Name + " - Power (kW) vs. Distance (km)");
    xlabel('Distance (km)');
    ylabel('Power (kW)');
    plot(distance, power, 'color', "#0072BD");
    legend("Power", 'Location', 'northeastoutside');
    hold off;
    
    % Plot average required power vs. distance
    figure;
    hold on;
    title(Name + " - 5-Wide Rolling Mean Power (kW) vs. Distance (km)");
    xlabel('Distance (km)');
    ylabel('5-Wide Rolling Mean Power (kW)');
    plot(distance, avgPower, 'color', "#0072BD");
    legend("Power", 'Location', 'northeastoutside');
    hold off;
    %}

    % Plot SoC over Distance
    figure;
    hold on;
    title(Name + " - SoC (%) vs. Distance (km)");
    xlabel('Distance (km)');
    ylabel('SoC (%)');
    plot(distance, 100*reserveEnergy/reserveEnergy(1,1), 'color', "#0072BD");
    legend("SoC", 'Location', 'northeastoutside');
    ylim([0 100])
    hold off;
end