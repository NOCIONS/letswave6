function [outheader] = CLW_load_header(filename)

[p,n,e]=fileparts(filename);
%load header
st=[p,filesep,n,'.lw6'];
load(st,'-MAT');
outheader=header;
%update header.name
outheader.name=n;
%check compatibility
outheader=CLW_check_header(outheader);
end

