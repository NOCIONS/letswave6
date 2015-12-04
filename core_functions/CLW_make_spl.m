function header=CLW_make_spl(header)
load('headmodel.mat');
HeadCenter = [0,0,30];
ElectDFac  = 1.06;
transmat   = [0 -10 0 -0.1000 0 -1.600 1100 1100 1100]; % arno

eloc_file=header.chanlocs;
indices = find(~cellfun('isempty', { eloc_file.X }));
Xeori = [ eloc_file(indices).X ]';
Yeori = [ eloc_file(indices).Y ]';
Zeori = [ eloc_file(indices).Z ]';
newcoords = [ Xeori Yeori Zeori ];
newcoords = traditionaldipfit(transmat)*[ newcoords ones(size(newcoords,1),1)]';
newcoords = newcoords(1:3,:)';
newcoordsnorm      = newcoords - ones(size(newcoords,1),1)*HeadCenter;
tmpnorm            = sqrt(sum(newcoordsnorm.^2,2));
Xe = newcoordsnorm(:,1)./tmpnorm;
Ye = newcoordsnorm(:,2)./tmpnorm;
Ze = newcoordsnorm(:,3)./tmpnorm;

enum = length(Xe);
onemat = ones(enum,1);
G = zeros(enum,enum);
for i = 1:enum
    ei = onemat-sqrt((Xe(i)*onemat-Xe).^2 + (Ye(i)*onemat-Ye).^2 + ...
        (Ze(i)*onemat-Ze).^2); % default was /2 and no sqrt
    G(i,:)=calcgx(ei);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project head vertices onto unit sphere
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
spherePOS      = POS-ones(size(POS,1),1)*HeadCenter; % recenter
nPOSnorm       = sqrt(sum(spherePOS.^2,2));
spherePOS(:,1) = spherePOS(:,1)./nPOSnorm;
spherePOS(:,2) = spherePOS(:,2)./nPOSnorm;
spherePOS(:,3) = spherePOS(:,3)./nPOSnorm;
x = spherePOS(:,1);
y = spherePOS(:,2);
z = spherePOS(:,3);

[~,I]=sort(dist([Xe Ye Ze],spherePOS'),2);
center=[0,0,-100];
for k=1:enum
M=mean(POS(I(k,1:20),:))-center;
newElect(k,:)=mean(POS(I(k,1:20),:))+M./norm(M)*5;
end

gx = fastcalcgx(x,y,z,Xe,Ye,Ze);
header.G=G;
header.gx=gx;
header.indices=indices;
header.newElect=newElect;



function [out] = calcgx(in)
out = zeros(size(in));
m = 4;       % 4th degree Legendre polynomial
for n = 1:7  % compute 7 terms
    out = out + ((2*n+1)/(n^m*(n+1)^m))*CLW_legendre(n,in);
end
out = out/(4*pi);


%%%%%%%%%%%%%%%%%%%
function gx = fastcalcgx(x,y,z,Xe,Ye,Ze)
onemat = ones(length(x),length(Xe));
EI = onemat - sqrt((repmat(x,1,length(Xe)) - repmat(Xe',length(x),1)).^2 +...
    (repmat(y,1,length(Xe)) - repmat(Ye',length(x),1)).^2 +...
    (repmat(z,1,length(Xe)) - repmat(Ze',length(x),1)).^2);
%
gx = zeros(length(x),length(Xe));
m = 4;
for n = 1:7
    gx = gx + ((2*n+1)/(n^m*(n+1)^m))*CLW_legendre(n,EI);
end
gx = gx/(4*pi);

