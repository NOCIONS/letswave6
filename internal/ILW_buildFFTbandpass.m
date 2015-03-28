function vector = ILW_buildFFTbandpass(header,locutoff,hicutoff,locutoff_width,hicutoff_width)
% ILW_buildFFTbandpass
%
% Inputs
% - header (LW6 header): input data must be FFT
% - locutoff : lower cutoff frequency (in Hz), no low cutoff: locutoff=0
% - hicuoff : higher cutoff frequency (in Hz), no high cutoff: locutoff=0
% - locutoff_width : width of the Hanning window for locutoff (in Hz)
% - hicutoff_width : width of the Hanning window for hicutoff (in Hz)
%
% Outputs
% - vector : filter mask to apply on the FFT
%
% Author : 
% Andre Mouraux
% Institute of Neurosciences (IONS)
% Université catholique de louvain (UCL)
% Belgium
% 
% Contact : andre.mouraux@uclouvain.be


%ones
v=ones(header.datasize(6),1);
vectorsize=length(v);

%locate locutoff and hicutoff
dx1=fix(((locutoff-header.xstart)/header.xstep)+1);
dx2=fix(((hicutoff-header.xstart)/header.xstep)+1);

%remove low frequencies if locutoff>0
if locutoff>0;
    v(1:dx1+1)=0;
    v(vectorsize-(dx1-1):vectorsize)=0;
    %smoothing if locutoff_width>0
    if locutoff_width>0
        dwidth=fix(locutoff_width/header.xstep);
        %check
        if dwidth>dx1;
            disp('Warning : Cutoff width greater than cutoff frequency. Adjusting...');
            dwidth=dx1;
        end;
        han=hanning(dwidth*2);
        %ascending slope
        han1=han(1:dwidth);
        v((dx1+1)-(dwidth-1):(dx1+1))=han1;
        %descending slope
        han2=han(dwidth+1:dwidth*2);
        v(vectorsize-(dx1-1):(vectorsize-(dx1-1))+(dwidth-1))=han2;
    end;
end;

%remove high frequencies if hicutoff>0
if hicutoff>0;
    v(dx2+1:vectorsize-(dx2-1))=0;
    %smoothing if hicutoff_width>0
    if hicutoff_width>0;
        dwidth=fix(hicutoff_width/header.xstep);
        han=hanning(dwidth*2);
        %descending slope
        han2=han(dwidth+1:dwidth*2);
        v((dx2+1):(dx2+1)+(dwidth-1))=han2;
        %ascending slope
        han1=han(1:dwidth);
        v((vectorsize-(dx2-1)-(dwidth-1)):(vectorsize-(dx2-1)))=han1;
    end;
end;

vector=v;