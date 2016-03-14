function out=powerspec(in);
   
   Freq=fft(in);
   Freq(1,:)=[];
   n=size(in,1);
   m=floor(n/2);
   nyquistfactor=1/2;
   power = abs(Freq(1:m,:)).^2;
   
   xseries = (1:m)/(m)*nyquistfactor;
   out = power;
   