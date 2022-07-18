function refTable = readRefFile(refFile)
% read reference table or ground truth------------------------------------%
refTable = readtable(refFile, 'ReadVariableNames', true);
refHeader = {'ROSTime', 'week', 'time','rover_lat', 'rover_long', ...
    'rover_alt', 'v_east', 'v_north', 'v_up', 'roll', 'pitch', 'heading'};
refTable.Properties.VariableNames = refHeader;
end