function [out_header,message_string]=RLW_properties(out_header,varargin);
%RLW_properties
%
%Edit header properties
%
%header
%
%varargin
%
%change_filetype (0)
%change_x (0)
%change_y (0)
%change_z (0)
%filetype ('time_amplitude');
%xstart (0);
%ystart (0);
%zstart (0);
%xstep (1);
%ystep (1);
%zstep (1);
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

change_filetype=0;
change_x=0;
change_y=0;
change_z=0;
filetype='time_amplitude';
xstart=0;
ystart=0;
zstart=0;
xstep=1;
ystep=1;
zstep=1;

%parse varagin
if isempty(varargin);
else
    %change_filetype
    a=find(strcmpi(varargin,'change_filetype'));
    if isempty(a);
    else
        change_filetype=varargin{a+1};
    end;
    %change_x
    a=find(strcmpi(varargin,'change_x'));
    if isempty(a);
    else
        change_x=varargin{a+1};
    end;
    %change_y
    a=find(strcmpi(varargin,'change_y'));
    if isempty(a);
    else
        change_y=varargin{a+1};
    end;
    %change_z
    a=find(strcmpi(varargin,'change_z'));
    if isempty(a);
    else
        change_z=varargin{a+1};
    end;
    %filetype
    a=find(strcmpi(varargin,'filetype'));
    if isempty(a);
    else
        filetype=varargin{a+1};
    end;
    %xstart
    a=find(strcmpi(varargin,'xstart'));
    if isempty(a);
    else
        xstart=varargin{a+1};
    end;
    %ystart
    a=find(strcmpi(varargin,'ystart'));
    if isempty(a);
    else
        ystart=varargin{a+1};
    end;
    %zstart
    a=find(strcmpi(varargin,'zstart'));
    if isempty(a);
    else
        zstart=varargin{a+1};
    end;
    %xstep
    a=find(strcmpi(varargin,'xstep'));
    if isempty(a);
    else
        xstep=varargin{a+1};
    end;
    %ystep
    a=find(strcmpi(varargin,'ystep'));
    if isempty(a);
    else
        ystep=varargin{a+1};
    end;
    %zstep
    a=find(strcmpi(varargin,'zstep'));
    if isempty(a);
    else
        zstep=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='Edit properties.';

%change_filetype?
if change_filetype==1;
    message_string{end+1}='Changing filetype.';
    out_header.filetype=filetype;
end;

%change_x?
if change_x==1;
    message_string{end+1}='Changing X-axis info.';
    out_header.xstart=xstart;
    out_header.xstep=xstep;
end;

%change_y?
if change_y==1;
    message_string{end+1}='Changing Y-axis info.';
    out_header.ystart=ystart;
    out_header.ystep=ystep;
end;

%change_z?
if change_z==1;
    message_string{end+1}='Changing Z-axis info.';
    out_header.zstart=zstart;
    out_header.zstep=zstep;
end;


