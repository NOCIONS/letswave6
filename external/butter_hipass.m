function outdata=butter_hipass(data,locutoff1,locutoff2,stopband,passband,samplingrate);
%
% Author : 
% André Mouraux
% Institute of Neurosciences (IONS)
% Université catholique de louvain (UCL)
% Belgium
% 
% Contact : andre.mouraux@uclouvain.be



%high pass the data (locutoff)
Wp=locutoff2/(samplingrate/2);
Ws=locutoff1/(samplingrate/2);
Rp=passband;
Rs=stopband;
[n,Wn]=buttord(Wp,Ws,Rp,Rs);
[b,a]=butter(n,Wn,'high');

%filter
outdata=filtfilt(b,a,data);
