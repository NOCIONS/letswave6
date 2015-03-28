function [data, colmean, rowmean, stddevs ] = pica_preproc(data,vn);
%
%--------------------------------
%
% This function performs re-shaping, de-meanimg,
% variance-normalisation on a 4D data file
%
% INPUT   data: 2D or 4D data file
%         vn:   for switching off variance-normalisation
%
% OUTPUT  data: pre-processed data
%         colmean: column mean
%         rowmean: row mean
%         stddev: estimated variance
%
%--------------------------------
%
% (c) 2005 C.F. Beckmann
%


if(length(size(data))==4)
  data=reshape(data,size(data,1)*size(data,2)*size(data,3), ...
               size(data,4))';
end;

if nargin>1
  vn = 0;
else
  vn = 1;
end;

colmean = mean(data);
data = remmean(data')';
stdevs=std(data);
if (vn>0)
  [E,D]=empca(remmean(data),min(50,size(data,1)-1));
  [ws,wm,dwm]=hyv_ica(remmean(data),'only','white','verbose','off','pcaD',diag(D),'pcaE',E);
  ws(ws<1.6)=0;
  stddevs=std(data-dwm*ws);
  data=data./(ones(size(data,1),1)*stddevs);
end;
 
rowmean=mean(data');
data=remmean(data);



