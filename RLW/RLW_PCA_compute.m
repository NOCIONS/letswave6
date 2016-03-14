function [matrix,message_string]=RLW_PCA_compute(header,data)
% RLW_PCA_compute
% Perform PCA
%
% Author : 
% Gan Huang
% Institute of Neurosciences (IONS)
% Universite catholique de louvain (UCL)
% Belgium
% 
% Contact : andre.mouraux@uclouvain.be
% This function is part of Letswave 6
% See http://nocions.webnode.com/letswave for additional information

%init message_string
message_string={};
message_string{1}='Computing PCA';
tpdata=zeros(size(data,2),size(data,6)*size(data,1));
for epochpos=1:size(data,1);
    tpdata=horzcat(tpdata,squeeze(data(epochpos,:,1,1,1,:)));
end
C1=tpdata*tpdata';
[V1,D1]=eig(C1);
[a,b]=sort(diag(D1));
V1=V1(:,b);
matrix.ica_mm=V1;
matrix.ica_um=inv(V1);