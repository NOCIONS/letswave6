function outdata=butter_notch(data,locutoff1,locutoff2,hicutoff1,hicutoff2,stopband,passband,samplingrate);
%
% Author : 
% André Mouraux
% Institute of Neurosciences (IONS)
% Université catholique de louvain (UCL)
% Belgium
% 
% Contact : andre.mouraux@uclouvain.be



%notch filter
Wp=[locutoff1 hicutoff2]/(samplingrate/2);
Ws=[locutoff2 hicutoff1]/(samplingrate/2);
Rp=passband;
Rs=stopband;
[n,Wn]=buttord(Wp,Ws,Rp,Rs);
[b,a]=butter(n,Wn,'stop');

%filter
outdata=filtfilt(b,a,data);
