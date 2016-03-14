function [outheader,outdata] = CLW_load(filename)

outheader=[];
outdata=[];

[p,n,e]=fileparts(filename);
%load header
if isempty(p);
    st=[n,'.lw6'];
else
    st=[p,filesep,n,'.lw6'];
end;
load(st,'-MAT');
outheader=header;
%update header.name
outheader.name=n;
%load data
if isempty(p);
    st=[n,'.mat'];
else
    st=[p,filesep,n,'.mat'];
end;
load(st,'-MAT');
outdata=double(data);
%check compatibility for LW6
outheader=CLW_check_header(outheader);
end

