function [S, P] = sub_tfa_stft(x, xtimes, t, f, Fs, winsize, wintype, padvalue)
% This sub-function is used to estimate time-varying spectrum using 
% short-time Fourier transform (STFT)
% Note that it is only used for multi-trial EEG data.

% /Input/
% x: the original data samples (Time Points x Trials)
% xtimes: the time axis of the original data
% t: evaluated time points in STFT
% f: evaluated frequency bins in STFT
% Fs: sampling rate
% winsize: window size (NOTE: the unit is ms)
% wintype: window type (default: hanning window)
% padvalue: the pad value used for padding data (default: 'circular'; See matlab function 'padarray')

% /Output/
% S: results with phase information
% P: squared magnitude without phase

fprintf('\nShort-time Fourier Transform: ')

%% Parameters
N_Trials = size(x,2);
L = round(winsize/1000*Fs/2); % half of window size (points)
h = L*2+1; %  window size (points)
if nargin<=6; wintype = 'hann'; end; % default winow type is 'hann'
win = window(wintype,h); % window (one trial)
W = repmat(win,1,N_Trials); % window (all trials)
U = win'*win;  % compensates for the power of the window

% index of time points in time-frequency domain
dt = t(2)-t(1); % time interval (uniform step)
[junk,t_idx_min] = min(abs(xtimes-t(1)));
[junk,t_idx_max] = min(abs(xtimes-t(end)));
t_idx = t_idx_min:round(dt*Fs/1000):t_idx_max; 
N_T = length(t);

% index of time points in time-frequency domain
df = f(2)-f(1); % frequency step (uniform step)
nfft = round(Fs/df) * max(1,2^(nextpow2(h/round(Fs/df)))); % points of FFT
f_full = Fs/2*linspace(0,1,round(nfft/2)+1);
[junk,f_idx_min] = min(abs(f_full-f(1)));
[junk,f_idx_max] = min(abs(f_full-f(end)));
f_idx = f_idx_min:max(1,2^(nextpow2(h/round(Fs/df)))):f_idx_max; 
N_F = length(f);

fprintf('%d Time Points x %d Frequency Bins x %d Trials\n',N_T,N_F,N_Trials);

%% Pad x (default mode is "circular")
x = detrend(x); % Remove linear trends
if nargin<=7; padvalue = 'circular'; end;
X = padarray(x, L, padvalue);
X = detrend(X); % Remove linear trends

%% STFT
S = zeros(N_F,N_T,N_Trials);
fprintf('Processing...     ')
for n=1:N_T
    fprintf('\b\b\b\b%3.0f%%',n/N_T*100)
    X_n = detrend(X(t_idx(n)+[0:h-1],:),'constant'); % remove DC
    S_n = fft(X_n.*W,nfft,1);
    S(:,n,:) = S_n(f_idx,:);
end
P = S.*conj(S)/Fs/U;
fprintf('  Done!\n')
%     P(2:end-1,:,:) = 2*P(2:end-1,:,:); % *2 means to consider the components
%     in negative freq bands. If it is required to let the program is the
%     same as spectrogram of Matlab, then enable it. Note that the end
%     frequency should be the Nyquist frequency

