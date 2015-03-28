function [wav1 wav2]=calculate_wavelet(type,periods,stdev)
%Calculate wavelet

if strcmpi(type,'morlet');
    idx=0:1:8191;
    idx=(idx-4096)/8191;
    tp1=sin(idx*2*pi*periods);
    tp2=cos(idx*2*pi*periods);
    tpp=-(idx.^2)/(2*stdev^2);
    tp3=exp(tpp);
    wav1=tp1.*tp3;
    wav2=tp2.*tp3;
%     pivar:=pi;
%     {Generate a Morlet Wavelet wav1 = real, wav2 = imag}
%     for i:=0 to 8191 do begin
%       tp:=(i-4096)/8192;
%       {Real (Complex Exponential)}
%       tp1:=sin(tp*2*pivar*periods);
%       {Imaginary (Complex Exponential)}
%       tp2:=cos(tp*2*pivar*periods);
%       {Gaussian Window}
%       tpp:=(tp*tp*-1)/(2*stdev*stdev);
%       tp3:=exp(tpp);
%       {Complex exponential x Gaussian Window}
%       {Mother Wavelet has a frequency of freq and a variance of variance}
%       wav1[i]:=tp1*tp3;
%       wav2[i]:=tp2*tp3;
%       end;
%     end;
end;

if strcmpi(type,'hanning');
    id=0:1:8191;
    idx=(id-4096)/8191;
    tp1=sin(idx*2*pi*periods);
    tp2=cos(idx*2*pi*periods);
    tp3=0.5*(1-cos((2*pi*id)/8192));
    wav1=tp1.*tp3;
    wav2=tp2.*tp3;
%     pivar:=pi;
%     {Generate a Morlet Wavelet wav1 = real, wav2 = imag}
%     for i:=0 to 8191 do begin
%       tp:=(i-4096)/8192;
%       {Real (Complex Exponential)}
%       tp1:=sin(tp*2*pivar*periods);
%       {Imaginary (Complex Exponential)}
%       tp2:=cos(tp*2*pivar*periods);
%       {Hanning Window}
%       tp3:=0.5*(1-cos((6.2831*i)/8192));
%       {Complex exponential x Hanning Window}
%       wav1[i]:=tp1*tp3;
%       wav2[i]:=tp2*tp3;
%       end;
%     end;
%   tp:=sqrt(periods/stdev);
%   for i:=0 to 8191 do begin
%     wav1[i]:= wav1[i]*tp;
%     wav2[i]:= wav2[i]*tp;
%     end;
%   end;
end;



end

