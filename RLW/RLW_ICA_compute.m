function [matrix,message_string]=RLW_ICA_compute(header,data,varargin);
%RLW_ICA_compute
%
%Compute ICA
%
%header
%data
%
%varargin
%'num_ICs' (0) 0 : square mixing matrix (or PICA); >0: constrained ICA
%'ICA_algorithm' ('runica') : 'runica','jader'
%'ICA_mode' ('square') : 'square','fixed',or probabilistic: 'LAP','BIC','RRN','AIC','MDL';
%'PICA_percentage' (100) : this is only used if PICA (LAP, BIC, RRN, AIC, MDL)
%
% Author : 
% Andre Mouraux
% Institute of Neurosciences (IONS)
% Universite catholique de louvain (UCL)
% Belgium
% 
% Contact : andre.mouraux@uclouvain.be
% This function is part of Letswave 6
% See http://nocions.webnode.com/letswave for additional information
%

num_ICs=0;
ICA_algorithm='runica';
ICA_mode='square';
PICA_percentage=100;

%parse varagin
if isempty(varargin);
else
    %num_ICs
    a=find(strcmpi(varargin,'num_ICs'));
    if isempty(a);
    else
        num_ICs=varargin{a+1};
    end;
    %ICA_algorithm
    a=find(strcmpi(varargin,'ICA_algorithm'));
    if isempty(a);
    else
        ICA_algorithm=varargin{a+1};
    end;
    %ICA_mode
    a=find(strcmpi(varargin,'ICA_mode'));
    if isempty(a);
    else
        ICA_mode=varargin{a+1};
    end;
    %PICA_percentage
    a=find(strcmpi(varargin,'PICA_percentage'));
    if isempty(a);
    else
        PICA_percentage=varargin{a+1};
    end;
end;

matrix.ica_mm=[];
matrix.ica_um=[];

%init message_string
message_string={};
message_string{1}='Computing ICA'
message_string{2}=['ICA algorithm : ' ICA_algorithm];

%number of ICs
switch ICA_mode
    case 'square'
        message_string{end+1}='Square (unconstrained) matrix';
        num_ICs=header.datasize(2);
    case 'fixed'
        message_string{end+1}='Constrained ICA: user-defined number of ICs';
    case 'LAP'
        message_string{end+1}='Probabilistic ICA: Laplace approximate';
        message_string{end+1}=['Using ' num2str(PICA_percentage) '% of the estimate.'];
        num_ICs=ILW_PICA_numdim(header,data,'LAP');
        num_ICs=round(num_ICs*(PICA_percentage/100));
    case 'BIC'
        message_string{end+1}='Probabilistic ICA: Bayesian Information Criterion';
        message_string{end+1}=['Using ' num2str(PICA_percentage) '% of the estimate.'];
        num_ICs=ILW_PICA_numdim(header,data,'BIC');
        num_ICs=round(num_ICs*(PICA_percentage/100));
    case 'RRN'
        message_string{end+1}='Probabilistic ICA: Rajan & Rayner';
        message_string{end+1}=['Using ' num2str(PICA_percentage) '% of the estimate.'];
        num_ICs=ILW_PICA_numdim(header,data,'RRN');
        num_ICs=round(num_ICs*(PICA_percentage/100));
    case 'AIC'
        message_string{end+1}='Probabilistic ICA: AIC';
        message_string{end+1}=['Using ' num2str(PICA_percentage) '% of the estimate.'];
        num_ICs=ILW_PICA_numdim(header,data,'AIC');
        num_ICs=round(num_ICs*(PICA_percentage/100));
    case 'MDL'
        message_string{end+1}='Probabilistic ICA: MDL';
        message_string{end+1}=['Using ' num2str(PICA_percentage) '% of the estimate.'];
        num_ICs=ILW_PICA_numdim(header,data,'MDL');
        num_ICs=round(num_ICs*(PICA_percentage/100));
end;
message_string{end+1}=['Number of ICs : ' num2str(num_ICs)];

%horzcat data
tpdata=zeros(size(data,2),size(data,6)*size(data,1));
for epochpos=1:size(data,1);
    tpdata=horzcat(tpdata,squeeze(data(epochpos,:,1,1,1,:)));
end;

switch ICA_algorithm
    case 'runica'
        message_string{end+1}='Using the RUNICA algorithm as implemented in EEGLAB'
        %ica
        if strcmpi(ICA_mode,'square');
            [ica.weights,ica.sphere,ica.compvars,ica.bias,ica.signs,ica.lrates,ica.activations]=runica(tpdata);
        else
            [ica.weights,ica.sphere,ica.compvars,ica.bias,ica.signs,ica.lrates,ica.activations]=runica(tpdata,'pca',num_ICs);
        end;
        %unmixing matrix
        ica_um=ica.weights*ica.sphere;
        %mixing matrix
        ica_mm=pinv(ica_um);
    case 'jader'
        message_string{end+1}='Using the JADER algorithm';
        %ica (jader) > unmixing matrix
        if strcmpi(ICA_mode,'square');
            ica_um=jader(tpdata);
        else
            ica_um=jader(tpdata,num_ICs);
        end;
        %mixing matrix
        ica_mm=pinv(ica_um);
end;
%store ica_mm, ica_um
matrix.ica_mm=ica_mm;
matrix.ica_um=ica_um;



