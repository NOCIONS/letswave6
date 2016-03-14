function numIC = ILW_PICA_numdim(header,data,method)
% LW_probdim
% Returns the estimated number of ICs using the pca_dim function
%
% Inputs
% - header : LW6 header
% - data : LW6 data
% - method : 'rrn'
%
% Outputs
% - outheader : LW6 header
% - outdata : LW6 data
%
% Dependencies : pca_dim
%
% Author : 
% André Mouraux
% Institute of Neurosciences (IONS)
% Université catholique de louvain (UCL)
% Belgium
% 
% Contact : andre.mouraux@uclouvain.be
% This function is part of Letswave 5
% See http://nocions.webnode.com/letswave for additional information
%

%horzcat data
tpdata=zeros(size(data,2),size(data,6)*size(data,1));
for epochpos=1:size(data,1);
    tpdata=horzcat(tpdata,squeeze(data(epochpos,:,1,1,1,:)));
end;

%dimprob
dimprob=pca_dim(tpdata);

%methods={'LAP','BIC','RRN','AIC','MDL'};
if strcmpi(method,'lap');
  [tp,numIC]=max(dimprob.lap);    
end;
if strcmpi(method,'bic');
  [tp,numIC]=max(dimprob.bic);    
end;
if strcmpi(method,'rrn');
  [tp,numIC]=max(dimprob.rrn);    
end;
if strcmpi(method,'aic');
  [tp,numIC]=max(dimprob.aic);    
end;
if strcmpi(method,'mdl');
  [tp,numIC]=max(dimprob.mdl);    
end;



end

