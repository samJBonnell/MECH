function printResults(energy,totalEnergy,power,reserveEnergy,regenBool,regenEfficiency, Name)
    energy = sum(energy);
    power = (1/1000)*power;
    avgPower = movmean(power, 5);

    fprintf("\n" + Name + "\n");
    
    fprintf("Initial Energy: %.3f kWh\n", reserveEnergy(1,1)/1000);
    fprintf("Required Energy: %.3f kWh\n", energy/(3600*1000));
    fprintf("Available Energy @ Terminus: %.3f kWh\n", reserveEnergy(end,1)/1000);
    fprintf("SoC @ Terminus: %.3f%%\n", 100*reserveEnergy(end,1)/reserveEnergy(1,1));
    fprintf("Maximum Power: %.3f kW\n", max(avgPower));
    fprintf("Average Power: %.3f kW\n", mean(avgPower));
    fprintf("Regeneration State: %i\n", regenBool);
    fprintf("Regeneration Efficiency: %.3f\n", regenEfficiency);
end