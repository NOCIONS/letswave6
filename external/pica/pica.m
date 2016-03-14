function Res = pica(param1,param2,param3);
%load data
load 'temp\c.mat';
%Number of ICs
%user-defined (param2)
if param1==0;                     
    NumIC=param2;
end;
%probabilistic ICA
if param1==2;                     
    dimprob=pcadim(c');
    %Rajan&Rayner approach
    if param2==0                  
        
    end;
end;

