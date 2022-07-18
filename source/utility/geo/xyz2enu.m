%% ecef to local coordinate transfromation matrix 
% compute ecef to local coordinate transfromation matrix
% args   : rcvPos      I   geodetic position {lat,lon} (rad)
% return : E           O   ecef to local coord transformation matrix (3x3)
% notes  : matirix stored by column-major order (fortran convention)

function E = xyz2enu(rcvPos)
    sinp=sin(rcvPos(1)); cosp=cos(rcvPos(1));
    sinl=sin(rcvPos(2)); cosl=cos(rcvPos(2));
    
    E(1,1)=-sinl;      E(1,2)=cosl;       E(1,3)=0.0;
    E(2,1)=-sinp*cosl; E(2,2)=-sinp*sinl; E(2,3)=cosp;
    E(3,1)=cosp*cosl;  E(3,2)=cosp*sinl;  E(3,3)=sinp;
end