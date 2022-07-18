%% transform local vector to ecef coordinate
% transform local tangental coordinate vector to ecef
% args   : rcvPos      I   geodetic position {lat,lon} (rad)
%          enuPos      I   vector in local tangental coordinate {e,n,u}
% return:  ecefPos     O   vector in ecef coordinate {x,y,z}

function ecefPos = venu2vecef(rcvPos, enuPos)

E = xyz2enu(rcvPos);
ecefPos = matmul("TN",3,1,3,1.0,E,enuPos,0.0);
end