function outdata=butter_lopass(data,hicutoff1,hicutoff2,stopband,passband,samplingrate);
%
% Author : 
% André Mouraux
% Institute of Neurosciences (IONS)
% Université catholique de louvain (UCL)
% Belgium
% 
% Contact : andre.mouraux@uclouvain.be




%high pass the data (locutoff)
Wp=hicutoff1/(samplingrate/2);
Ws=hicutoff2/(samplingrate/2);
Rp=passband;
Rs=stopband;
[n,Wn]=buttord(Wp,Ws,Rp,Rs);
[b,a]=butter(n,Wn,'low');

%filter
outdata=filtfilt(b,a,data);
