function [p_bootstrap,p_bootstrap_r,p_bootstrap_l] = sub_tfd_bootstrp(P_Pre, P_Post, N_Bootstrap)
% bootstrap for TFD
%
% Copyright (C) 2011 The University of Hong Kong
% Authors:   Zhiguo Zhang, Li Hu, Yong Hu
%            zgzhang@eee.hku.hk
% reference: Durka et al., IEEE TBME 51(7), 2004

disp(['Bootstrapping for Time-frequency Distributions (Number of Resampling: ',num2str(N_Bootstrap),')'])
fprintf(['Progress: '])
% Bootstrap
[NF,NT_Pre,N_Trials] = size(P_Pre);
NT_Post = size(P_Post,2);
for fi=1:NF
    fprintf(1,'%03.0f%%',fi/NF*100)
    E_Pre = P_Pre(fi,:,:);
    E_Pre = E_Pre(:);
    % bootstrap
    for n_bs=1:N_Bootstrap
        E_Pre_bs = randsample(E_Pre,NT_Pre*N_Trials,true);
        E_Post_bs = randsample(E_Pre,N_Trials,true);
        pooled_var = ((NT_Pre*N_Trials-1)*var(E_Pre_bs)+(N_Trials-1)*var(E_Post_bs)) / (NT_Pre*N_Trials+N_Trials-2);
        pseudo_t_bs{fi}(n_bs) = (mean(E_Post_bs)-mean(E_Pre_bs)) / pooled_var;        
    end    
    for ti=1:NT_Post
        E_Post = squeeze(P_Post(fi,ti,:));
        pooled_var = ((NT_Pre*N_Trials-1)*var(E_Pre)+(N_Trials-1)*var(E_Post)) / (NT_Pre*N_Trials+N_Trials-2);
        pseudo_t(fi,ti) = (mean(E_Post)- mean(E_Pre)) / pooled_var;
        %The two-tailed P-value is twice the lower of the two one-tailed P-values
        p1 = numel(find(pseudo_t_bs{fi}>=pseudo_t(fi,ti)))/N_Bootstrap;
        p2 = numel(find(pseudo_t_bs{fi}<=pseudo_t(fi,ti)))/N_Bootstrap;
        p_bootstrap(fi,ti) = 2*min(p1,p2);
        p_bootstrap_r(fi,ti) = p1;
        p_bootstrap_l(fi,ti) = p2;
    end
    if fi<NF
        for nn=1:4; fprintf('\b'); end
    else
        fprintf('\n');
    end
end
