function printResults(energy,totalEnergy,power,reserveEnergy,regenBool,regenEfficiency)
    energy = sum(energy);
    power = (1/1000)*power;
    avgPower = movmean(power, 5);
    
    fprintf("Required Energy: %.3f Wh\n", energy/3600);
    fprintf("Available Energy @ Terminus: %.3f kW\n", reserveEnergy(end,1));
    fprintf("SoC @ Terminus: %.3f%%\n\n", 100*reserveEnergy(end,1)/reserveEnergy(1,1));
    fprintf("Maximum Power: %.3f kW\n", max(avgPower));
    fprintf("Average Power: %.3f kW\n\n", mean(avgPower));
    fprintf("Regeneration State: %i\n", regenBool);
    fprintf("Regeneration Efficiency: %.3f\n", regenEfficiency);
end