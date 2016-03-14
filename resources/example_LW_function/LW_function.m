function [outheader,outdata] = LW_function(header,data,parameter)
% LW_function
%
% Inputs
% - header (LW5 header)
% - data (LW5 data)
% - parameter : 
%
% Outputs
% - outheader (LW5 header)
% - outdata (LW5data)
%

%transfer header to outheader
outheader=header;

%add history
outheader.history(end+1).description='LW_function';
outheader.history(end).date=date;
outheader.history(end).index=[parameter];

%process data
disp('*** Processing : ');
outdata=data;

