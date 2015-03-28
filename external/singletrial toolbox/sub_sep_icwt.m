function [y] = sub_sep_icwt(P, f, f_span)
% this sub-function is used to reconsturct the signal from the wavelet transform (the wavelet basis is selected as the type proposed By Tognola)

% fprintf('Calculating ICWT ... ')

% 'x' - the original data samples
% 'f' - the discrete frequency samples (normalized)

% Copyright (C) 2009 University of Oxford & The University of Hong Kong
% Authors:   Zhiguo Zhang & Li Hu
%            huli@hku.hk

% pre-processing
N_F = length(f);
N_T = size(P,2);
t = [1:N_T];
f_use_index = find((f>f_span(1))&(f<=f_span(end))); % the selected frequency bands are located in (f_span_start, f_span_end]

% inverse continuous wavelet transform
alpha = 6;  % parameters used for ICWT (the wavelet basis was proposed By Tognola)
f0 = alpha; % central frequency
Fb=0.05;
Fc=f0;

% caculate normalized factor C_phi
phi_sampling_rate = f(2)-f(1);
xx = [-1+phi_sampling_rate:phi_sampling_rate:1];
phi_t = ((pi*Fb)^(-0.5))*exp(2*i*pi*Fc*xx).*exp(-(xx.*xx)/Fb);
C_phi = sum(abs(phi_t).^2)/2; % divided by 2 because the only real frequency components are computed


for tau=1:N_T
    for fi=f_use_index(1):f_use_index(end)   
        u = (f(fi)/f0) * (t-tau);
        phi = sqrt((f(fi)/f0)) * ((pi*Fb)^(-0.5))*exp(2*i*pi*Fc*u).*exp(-(u.*u)/Fb);
        P_fi(fi) = P(fi,:)*conj(phi.');
    end
    y(tau) = real(sum(P_fi)/C_phi);    
end
