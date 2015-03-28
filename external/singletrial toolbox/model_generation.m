function [P_mask] = model_generation(x_trials,f,Fs,epoch,threshold)

% Copyright (C) 2009 University of Oxford & The University of Hong Kong
% Authors:   Li Hu
%            huli@hku.hk

tt=min(epoch);
pre_point=round(abs(tt*Fs));
half_point= round(pre_point/2);

f_N = f./Fs;            % normalized frequency bin, Fs is sampling frequency
x_mean=mean(x_trials,2);

for i=1:size(x_trials,2)
    S_avg(:,:,i) = sub_sep_cwt(x_trials(:,i), f_N,'normal');   %%% cwt 
    P_trials(:,:,i) = abs(S_avg(:,:,i)).^2;
end
P=mean(P_trials,3);
P_norm = zeros(size(P));
for i=1:length(f)
    P_norm(i,:)=P(i,:)-mean(P(i,half_point:pre_point));
end
%figure; %%%this is used to plot the time frequency representation
%imagesc(epoch,f,P_norm);axis([-0.5 1 1 30]);
%axis xy; 

% calculate the mask based on ecdf
for i=1:length(threshold)
    [f1,p] = ecdf(P_norm(:));
    f_thres = threshold;
    f_axis = find(abs(f1-f_thres)==min(abs((f1-f_thres))));
    p_thres = p(f_axis);
    % mask
    P_mask = zeros(size(P_norm));
    P_mask(find(P_norm>p_thres)) = 1;
end

%figure; %%%this is used to plot the time frequency representation
%imagesc(epoch,f,P_mask);axis([-0.5 1 1 30]);
%axis xy; 

%% this is used to test the filter performance
%S1=S_avg.*P_mask;
%z_avg = sub_sep_icwt(S1, f_N, f_N);
%figure;plot(epoch,x_mean,':k','linewidth',2);set(gca,'YDir','reverse');hold on; grid off;axis([-2 3 -30 30]);
%plot(epoch,z_avg,'k','linewidth',3);





