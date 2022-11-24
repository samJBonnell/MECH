function [invertedData, invertedStops] = invertElevationData(elevationData, stops)
    invertedData = flip(elevationData,1);
    invertedData(:,2) = -invertedData(:,2);
    invertedStops = invertedData(1,3) - stops;
end