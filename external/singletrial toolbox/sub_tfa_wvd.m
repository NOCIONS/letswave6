function [ P, S ] = sub_tfa_wvd( x, L, f, Fs, smooth_option )
% sub-function used to compute the Wigner-Ville Distribution

% fprintf('Calculating WVD ... ')

% 'x' - the original data samples
% 'f' - the discrete frequency samples (normalized)

% pre-processing
if size(x,2)==1
    x = x.';
end
% x = x - mean(x);
N = length(x);
t = [1:N]/Fs;

if isempty(L) % The traditional WVD
    L = round(N/2)-1;
    for ti=1:length(t)
        L_t = min(ti-1,N-ti);
        tau_t{ti} = [-L_t:L_t];
        x_t = x(ti+tau_t{ti});
%         x_t = x_t-mean(x_t);
        int_t1{ti} = x_t.*x_t(end:-1:1);
    end
    for fi=1:length(f)
        int_f1{fi} = exp(-j*2*pi*f(fi)/Fs*2*[-L:L]);
    end
    for ti=1:length(t)
        for fi=1:length(f)
            S(fi,ti) = 2*(int_t1{ti}*int_f1{fi}(L+1+tau_t{ti}).');%/length(tau_t{ti});
        end
    end
else
    % Pseudo WVD with (half) window size L
    tau=[-L:L];
    w = hamming(2*L+1);
    x_pad = [zeros(1,L),x,zeros(1,L)];
    for ti=1:length(t)
        N_t(ti) = min(ti-1,N-ti)*2+1;
        int_t(ti,:) = w.'.*x_pad(ti+L+tau).*conj(x_pad(ti+L-tau));
    end
    for fi=1:length(f)
        int_f(fi,:) = exp(-j*2*pi*f(fi)/Fs*2*tau);
    end
    for ti=1:length(t)
        for fi=1:length(f)
            S(fi,ti) = 2*(int_t(ti,:)*int_f(fi,:).');%/N_t(ti);
        end
    end
end

% Smooth
if smooth_option~=0
    L = smooth_option;
    w = gausswin(2*L+1);
    w = w./sum(w);
    W = repmat(w.',length(f),1);
    S_Raw = [zeros(length(f),L),S,zeros(length(f),L)];
    for ti=1:length(t)
        S(:,ti) = sum(W.*S_Raw(:,ti:ti+2*L),2);
    end
end

P = abs(S).^2;

% fprintf('Done!\n')
