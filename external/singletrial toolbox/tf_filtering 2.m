function [f_trials] = tf_filtering(x_trials,f,Fs,P_mask)

% Copyright (C) 2009 University of Oxford & The University of Hong Kong
% Authors:   Li Hu
%            huli@hku.hk

f_N = f./Fs;  % normalized frequency bin, Fs is sampling frequency
h=waitbar(0,'please wait...');
for i=1:size(x_trials,2)  %%% filtering,this part will be very slow, please be patient 
    x=x_trials(:,i);
    x = x-mean(x);
    [S] = sub_sep_cwt(x, f_N,'normal');
    S_filter=S.*P_mask;
    f_trials(:,i)= sub_sep_icwt(S_filter, f_N, f_N);
    %save filtered_single_trial f_s_t; %%% it's better to save the result timely
    waitbar(i/size(x_trials,2),h);
end

%%% please reduce the time length or time resolution, or reduce the
%%% frequency resolution, if you want to speed up the calculation