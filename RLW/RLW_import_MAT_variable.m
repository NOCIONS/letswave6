function [out_header,out_data,message_string]=RLW_import_MAT_variable(matdata,varargin);
%RLW_import_MAT_variable
%
%Import MAT variable
%filename : name of LW4 MAT file 
%
%varargin
%'dimension_descriptors' ({'epochs','channels','Y','X'});
%'unit 'amplitude'
%'x_unit 'time'
%'y_unit 'frequency'
%'xstart (0)
%'ystart (0)
%'xstep (1)
%'ystep (1)
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

dimension_descriptors={'epochs','channels','Y','X'};
unit='amplitude';
x_unit='time';
y_unit='frequency';
xstart=0;
ystart=0;
xstep=1;
ystep=1;

%parse varagin
if isempty(varargin);
else
    %dimension_descriptors
    a=find(strcmpi(varargin,'dimension_descriptors'));
    if isempty(a);
    else
        dimension_descriptors=varargin{a+1};
    end;
    %unit
    a=find(strcmpi(varargin,'unit'));
    if isempty(a);
    else
        unit=varargin{a+1};
    end;
    %x_unit
    a=find(strcmpi(varargin,'x_unit'));
    if isempty(a);
    else
        x_unit=varargin{a+1};
    end;
    %y_unit
    a=find(strcmpi(varargin,'y_unit'));
    if isempty(a);
    else
        y_unit=varargin{a+1};
    end;
    %x_start
    a=find(strcmpi(varargin,'x_start'));
    if isempty(a);
    else
        x_start=varargin{a+1};
    end;
    %y_start
    a=find(strcmpi(varargin,'y_start'));
    if isempty(a);
    else
        y_start=varargin{a+1};
    end;
    %x_step
    a=find(strcmpi(varargin,'x_step'));
    if isempty(a);
    else
        x_step=varargin{a+1};
    end;
    %y_step
    a=find(strcmpi(varargin,'y_step'));
    if isempty(a);
    else
        y_step=varargin{a+1};
    end;
end;


message_string={};
out_out_header=[];
out_data=[];

message_string{1}='Import MAT variable';

%init header and data
out_header=[];
out_data=[];

message_string{end+1}='Generating header.';

%set header filetype
filetype=unit;
if isempty(x_unit);
else
    filetype=[x_unit '_' filetype];
end;
if isempty(y_unit);
else
    filetype=[y_unit '_' filetype];
end;
message_string{end+1}=['File type : ' filetype];
out_header.filetype=filetype;

%header
out_header.name=[];
out_header.tags={};
out_header.history=[];
out_header.datasize=[];
out_header.xstart=x_start;
out_header.ystart=y_start;
out_header.zstart=0;
out_header.xstep=x_step;
out_header.ystep=y_step;
out_header.zstep=1;

%prepare data
message_string{end+1}='Importing data.';
if ndims(matdata)==1;
    out_data(:,1,1,1,1,1)=matdata;
end;
if ndims(matdata)==2;
    out_data(:,:,1,1,1,1)=matdata;
end;
if ndims(matdata)==3;
    out_data(:,:,:,1,1,1)=matdata;
end;
if ndims(matdata)==4;
    out_data(:,:,:,:,1,1)=matdata;
end;
if ndims(matdata)==5;
    out_data(:,:,:,:,:,1)=matdata;
end;
if ndims(matdata)==6;
    out_data(:,:,:,:,:,:)=matdata;
end;

%dim_list
dimlist{1}='epochs';
dimlist{2}='channels';
dimlist{3}='index';
dimlist{4}='Z';
dimlist{5}='Y';
dimlist{6}='X';

%dim_labels
dim_labels=dimension_descriptors;

%dim_order
for i=1:length(dim_labels);
    tp=find(strcmpi(dim_labels{i},dimlist));
    if isempty(tp);
        message_string{end+1}='Error : dimension not recognized.';
        return;
    else
        a(i)=tp;
    end;
end;
dim_order=[0 0 0 0 0 0];
for i=1:length(a);
    dim_order(a(i))=i;
end;
tp=find(dim_order==0);
if isempty(tp);
else
    for i=1:length(tp);
        dim_order(tp(i))=length(a)+i;
    end;
end;
%permute according to dim_order
out_data=permute(out_data,dim_order);

%update header.datasize
out_header.datasize=size(out_data);

%set chanlocs
message_string{end+1}='Generating channel labels.';
%dummy chanloc
chanloc.labels='';
chanloc.topo_enabled=0;
chanloc.SEEG_enabled=0;
%set chanlocs
for chanpos=1:out_header.datasize(2);
    chanloc.labels=['C' num2str(chanpos)];
    out_header.chanlocs(chanpos)=chanloc;
end;

%header.events
out_header.events=[];
