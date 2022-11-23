% read reftable
% refFilePath = 'E:\Software\dataset\UrbanNav\HongKong\HK_20190428\reference.csv';
[file, path] = uigetfile('*');
refFilePath = fullfile(path, file);
varTypes = {'string', 'double', 'double', 'double', 'string', ...
    'double', 'double', 'datetime', 'datetime', 'double', 'double', 'double'};
varNames = {'stationCode', 'x', 'y', 'z', ...
    'type', 'stdPlanar', 'stdUp', 'startTime', 'endTime', 'vx', 'vy', 'vz'};
if contains(file,'csv')
    refTable = readRefFile(refFilePath);
    CRD = table('Size',[size(refTable,1),length(varTypes)], ...
    'VariableTypes',varTypes,'VariableNames',varNames);
    % CRD{1,:} = {'NAME', 0, 0, 0, Core_Reference_Frame.FLAG_STRING{1}, 0, 0, ...
    % GPS_Time(0).toString('yyyy-mm-dd HH:MM:SS'), ...
    % GPS_Time(datenum('2099/12/31')).toString('yyyy-mm-dd HH:MM:SS'), 0, 0, 0};

    roverPoslla = [pi/180*refTable.rover_lat, ...
        pi/180*refTable.rover_long, refTable.rover_alt];
    roverPosECEF = lla2ecef([refTable.rover_lat, refTable.rover_long, ...
        refTable.rover_alt], 'WGS84');
    Venu = [refTable.v_east, refTable.v_north, refTable.v_up];
    for i = 1: size(roverPoslla,1)
        Vecef(i,:) = venu2vecef(roverPoslla(i,:)', Venu(i,:)')';
    end
    % [x,y,z] = enu2ecef( ...
    %     Venu(:,1), Venu(:,2), Venu(:,3), ...
    %     roverPoslla(:,1), roverPoslla(:,2), roverPoslla(:,3), ...
    %     wgs84Ellipsoid, 'radian');

    % convert unix epoch time to datetime
    % d = datetime(1556456283.92417,'ConvertFrom','epochtime','Format','dd-MMM-yyyy HH:mm:ss.SSSSSSSSS')
    CRD.x = roverPosECEF(:,1);
    CRD.y = roverPosECEF(:,2);
    CRD.z = roverPosECEF(:,3);
    CRD.vx = Vecef(:,1);
    CRD.vy = Vecef(:,2);
    CRD.vz = Vecef(:,3);
    CRD.startTime = datetime(gps2date(refTable.week, refTable.time));
    CRD.endTime = [CRD.startTime(2:end);CRD.startTime(end)+seconds(1)];
    CRD.stationCode(:) = 'COM3';
    CRD.type(:) = Core_Reference_Frame.FLAG_FIXED;
    CRD.stdPlanar(:) = 0;
    CRD.stdUp(:) = 0;
elseif contains(file,'txt')
    refTable = readtable(refFilePath, 'VariableNamesLine',1);
    CRD = table('Size',[size(refTable,1),length(varTypes)], ...
    'VariableTypes',varTypes,'VariableNames',varNames);
    refTable{:,4} = refTable{:,4}+refTable{:,5}/60+refTable{:,6}/3600;
    refTable{:,5} = refTable{:,7}+refTable{:,8}/60+refTable{:,9}/3600;
    refTable{:,6:16} = refTable{:,10:end};
    refTable(:,17:end) = [];

    %     roverPoslla = [pi/180*refTable.Latitude, ...
    %         pi/180*refTable.Longitude, refTable.H_Ell];
    roverPosECEF = lla2ecef([refTable.Latitude, refTable.Longitude, ...
        refTable.H_Ell], 'WGS84');
    CRD.x = roverPosECEF(:,1);
    CRD.y = roverPosECEF(:,2);
    CRD.z = roverPosECEF(:,3);
    CRD.vx = refTable.VelBdyX;
    CRD.vy = refTable.VelBdyX;
    CRD.vz = refTable.VelBdyX;
    CRD.startTime = datetime(gps2date(refTable.Week, refTable.GPSTime));
    CRD.endTime = [CRD.startTime(2:end);CRD.startTime(end)+seconds(1)];
    CRD.stationCode(:) = 'COM3';
    CRD.type(:) = Core_Reference_Frame.FLAG_FIXED;
    CRD.stdPlanar(:) = 0;
    CRD.stdUp(:) = 0;
end




str = '';
for i = 1 : size(CRD, 1)
    str = sprintf('%s%4s %+14.5f %+14.5f %+14.5f %1s %+9.5f %+9.5f %+9.5f %+9.5f %+9.5f  %s %s\n', ...
        str, CRD.stationCode(i), CRD.x(i), CRD.y(i), ...
        CRD.z(i), CRD.type(i), CRD.vx(i), CRD.vy(i), CRD.vz(i),  ...
        CRD.stdPlanar(i),  CRD.stdUp(i),  ...
        datestr(CRD.startTime(i), 'yyyy-mm-dd HH:MM:SS.FFF'), ...
        datestr(CRD.endTime(i), 'yyyy-mm-dd HH:MM:SS.FFF'));
end
% CRDFilePath = 'E:\Software\PPP\goGPS\goGPS_MATLAB\data\project\default_DD\station\CRD\stations.crd';
[file,path] = uiputfile('../data/station/CRD/urbanPos.crd');
CRDFilePath = fullfile(path, file);
fid = fopen(CRDFilePath, 'Wb');
fwrite(fid, str, 'char');
fclose(fid);
