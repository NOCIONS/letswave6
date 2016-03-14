function [P] = sub_sep_cwt(x, f, option)
% this sub-function is used to estimate PSD using wavelet transform (the wavelet basis is selected as the type proposed By Tognola)
% 'P' is used for illustration, and 'phi' is used for signal reconstruction
% option: 'normal' means slow but useful for icwt, 
%         'fast' means fast but not usable for icwt, 
%         'phi' only computes the wavelet basis for icwt
                                        
% fprintf('Calculating CWT ... ')

% 'x' - the original data samples
% 'f' - the discrete frequency samples (normalized)

% Copyright (C) 2009 University of Oxford & The University of Hong Kong
% Authors:   Zhiguo Zhang & Li Hu
%            huli@hku.hk

% pre-processing
if size(x,2)==1
    x = x.';
end

N_F = length(f);
N_T = length(x);
t = [1:N_T];

P = [];
phi = [];

% continuous wavelet transform
alpha = 6;%          (the wavelet basis was proposed By Tognola)
f0 = alpha; % central frequency
Fb=0.05;
Fc=f0;

L_hw = N_T; % filter length

if (strcmp(option,'normal')==1)|(strcmp(option,'fast')==1)
    for fi=1:N_F
        u = (f(fi)/f0) * -([-L_hw:L_hw]);
         hw(fi,:) = sqrt((f(fi)/f0)) *((pi*Fb)^(-0.5))*exp(2*i*pi*Fc*u).*exp(-(u.*u)/Fb);
        P_full(fi,:) = conv(x,conj(hw(fi,:)));
        P(fi,:) = P_full(fi,L_hw+1:L_hw+N_T);
    end
end
