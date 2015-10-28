function [outheader] = LW_load_header(filename)

outheader=[];

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
%check compatibility for LW6
outheader=CLW_check_header(outheader);
end

