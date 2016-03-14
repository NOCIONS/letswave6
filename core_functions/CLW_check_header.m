function [outheader] = CLW_check_header(header)
%check history structure is compatible with LW6
if isfield(header,'history');
    if isfield(header.history,'configuration');
    else
        disp('Deleting History as it is not compatible with LW6');
        header.history=[];
    end;
end;
outheader=header;



