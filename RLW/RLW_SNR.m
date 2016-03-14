function [out_header,out_data,message_string]=RLW_SNR(header,data,varargin);
%RLW_SNR
%
%SNR
%
%varargin
%'xstart' (2)
%'xend' (5)
%'operation' ('subtract')
%'num_extreme' (0)
%
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

xstart=2;
xend=5;
operation='subtract';
num_extreme=0;

%parse varagin
if isempty(varargin);
else
    %operation
    a=find(strcmpi(varargin,'operation'));
    if isempty(a);
    else
        operation=varargin{a+1};
    end;
    %xstart
    a=find(strcmpi(varargin,'xstart'));
    if isempty(a);
    else
        xstart=varargin{a+1};
    end;
    %xend
    a=find(strcmpi(varargin,'xend'));
    if isempty(a);
    else
        xend=varargin{a+1};
    end;
    %num_extreme
    a=find(strcmpi(varargin,'num_extreme'));
    if isempty(a);
    else
        num_extreme=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='SNR';

%prepare out_header
out_header=header;

%dx1,dx2
dx1=xstart;
dx2=xend;

%prepare out_data
out_data=zeros(size(data));

%init bl and stdbl
bl=zeros(size(data,2),size(data,6));
zscore_compute=0;
if strcmpi(operation,'zscore');
    zscore_compute=1;
    stdbl=bl;
end;

%loop (pooling across channels)
for epochpos=1:size(data,1);
    for indexpos=1:size(data,3);
        for dz=1:size(data,4);
            for dy=1:size(data,5);
                %tp
                tp=squeeze(data(epochpos,:,indexpos,dz,dy,:));
                %transpose tp when there is a single electrode
                if size(tp,2)==1;
                    tp=tp';
                end;
                %dxsize
                dxsize=size(data,6);
                %loop through dx
                for dx=1:size(data,6);
                    dx31=dx-dx2;
                    dx32=dx-dx1;
                    dx41=dx+dx1;
                    dx42=dx+dx2;
                    if dx31<1;
                        dx31=1;
                    end;
                    if dx32<1;
                        dx32=1;
                    end;
                    if dx41>dxsize;
                        dx41=dxsize;
                    end;
                    if dx42>dxsize;
                        dx42=dxsize;
                    end;
                    %tp2
                    tp2=tp(:,[dx31:dx32,dx41:dx42]);
                    if num_extreme>0;
                        tp2=sort(tp2,2);
                        tp2=tp2(:,1+num_extreme:end-num_extreme);
                    end;
                    % mean over selected bins
                    bl(:,dx)=mean(tp2,2);
                    % compute standard deviation over selected bins for
                    % zscore only (save computation time for other operations).
                    if zscore_compute==1;
                        stdbl(:,dx)=std(tp2,[],2);
                    end;
                end;
                switch operation
                    case 'subtract'
                        tp2=tp-bl;
                        %tp2=bsxfun(@minus,tp,bl);
                    case 'snr'
                        tp2=tp./bl;
                    case 'zscore'
                        tp2=(tp-bl)./stdbl;
                    case 'percent'
                        tp2=tp-bl;
                        tp2=tp2./bl;
                end;
                out_data(epochpos,:,indexpos,dz,dy,:)=tp2;
            end;
        end;
    end;
end;


