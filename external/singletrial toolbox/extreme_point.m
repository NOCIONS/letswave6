function [tmax tmin vmax vmin]=extreme_point(signal);
v = signal;
t = 0:length(v)-1;
Lmax = diff(sign(diff(v)))== -2; % logic vector for the local max value
Lmin = diff(sign(diff(v)))== 2; % logic vector for the local min value
% match the logic vector to the original vecor to have the same length
if size(Lmax,1)==1
    Lmax = [false, Lmax, false];
    Lmin =  [false, Lmin, false];
else
    Lmax=Lmax';
    Lmin=Lmin';
    v=v';
    Lmax = [false, Lmax, false];
    Lmin =  [false, Lmin, false];
end

tmax = t (Lmax); % locations of the local max elements
tmin = t (Lmin); % locations of the local min elements
vmax = v (Lmax); % values of the local max elements
vmin = v (Lmin); % values of the local min elements
 
