function [out_dataset_Fvalue,out_dataset_pvalue,message_string,cluster_distribution]=RLW_ANOVA(datasets,factor_data,table_data,varargin);
%RLW_ANOVA
%
%Point-by-point ANOVA across datasets
%
%datasets
%factor_data
%table_data
%
%varargin
%'enable_parallel' (0)
%'alpha' (0.05)
%'permutation' (0)
%'num_permutations' (250)
%'cluster_statistic' ('perc_mean') : 'perc_mean' 'perc_max' 'sd_mean' 'sd_max'
%'cluster_threshold' (95)
%
% Author : 
% Andre Mouraux
% Institute of Neurosciences (IONS)
% Universite catholique de louvain (UCL)
% Belgium
% 
% Contact : andre.mouraux@uclouvain.be
% This function is part of Letswave 6
% See http://nocions.webnode.com/letswave for additional information
%

enable_parallel=0;
alpha=0.05;
permutation=0;
num_permutations=250;
cluster_statistic='perc_mean'; %'perc_mean' 'perc_max' 'sd_mean' 'sd_max'
cluster_threshold=95;

%parse varagin
if isempty(varargin);
else
    %enable_parallel
    a=find(strcmpi(varargin,'enable_parallel'));
    if isempty(a);
    else
        enable_parallel=varargin{a+1};
    end;
    %alpha
    a=find(strcmpi(varargin,'alpha'));
    if isempty(a);
    else
        alpha=varargin{a+1};
    end;
    %permutation
    a=find(strcmpi(varargin,'permutation'));
    if isempty(a);
    else
        permutation=varargin{a+1};
    end;
    %num_permutations
    a=find(strcmpi(varargin,'num_permutations'));
    if isempty(a);
    else
        num_permutations=varargin{a+1};
    end;
    %cluster_statistic
    a=find(strcmpi(varargin,'cluster_statistic'));
    if isempty(a);
    else
        cluster_statistic=varargin{a+1};
    end;
    %cluster_threshold
    a=find(strcmpi(varargin,'cluster_threshold'));
    if isempty(a);
    else
        cluster_threshold=varargin{a+1};
    end;
end;

cluster_distribution=[];

%init message_string
message_string={};
message_string{1}='ANOVA';

%parfor?
%matlabpool
if enable_parallel==1;
    message_string{end+1}='Starting the parallel pool...';
    try
        if exist('parpool')==2;
            message_string{end+1}='Using the parpool function.';
            parpool;
        else
            message_string{end+1}='Using the matlabpool function.';
            matlabpool(parcluster);
        end;
    end
    message_string{end+1}='Parallel pool is now enabled!';
end;

%groups
%groups : matrix n datafiles x m groups
groups=cell2mat(table_data);
groups=groups-1;
%within
%within : vector of m groups (0=between;1=within)
factors=factor_data;
for i=1:length(factors);
    within(i)=factors(i).within;
    label{i}=factors(i).label;
end;
%within_levels, within_labels
if isempty(find(within==1));
    within_levels=[];
    within_labels={};
else
    within_levels=groups(:,find(within==1));
    within_labels=label(find(within==1));
end;
%between_levels, between_labels
if isempty(find(within==0));
    between_levels=[];
    between_labels={};
else
    between_levels=groups(:,find(within==0));
    between_labels=label(find(within==0));
end;

%anovan
message_string{end+1}='Computing the point-by-point ANOVA.';
time=cputime;
if enable_parallel==1;
    [out_dataset_pvalue,out_dataset_Fvalue]=ILW_custANOVA_parfor(datasets,within_levels,within_labels,between_levels,between_labels);
else
    [out_dataset_pvalue,out_dataset_Fvalue]=ILW_custANOVA(datasets,within_levels,within_labels,between_levels,between_labels);
end;
message_string{end+1}=['Operation time : ' num2str(time) ' seconds.'];

%permutation?
if permutation==1;

    %cluster_criterion
    st={'sd_mean' 'sd_max' 'perc_mean' 'perc_max'};
    a=find(strcmpi(st,cluster_statistic));
    if isempty(a);
        message_string{end+1}=('ERROR! Cluster criterion not found.');
    else
        message_string{end+1}=['Cluster criterion : ' st{a}];
        cluster_criterion=a;
    end;

    %figure
    figure;
    
    %number of permutations
    message_string{end+1}='Performing cluster-based thresholding.';
    disp('Performing cluster-based thresholding. This may take several hours!!!');
    disp(['Total expected time for permutation (s): ' num2str(time*num_permutations)]);
    
    %criticalz
    criticalz=cluster_threshold;
    %criticalp
    criticalp=alpha;
    
    %datasets2
    datasets2=datasets;
    
    %tres0
    tres0=zeros(size(out_dataset_pvalue.data));
    message_string{end+1}=['Number of permutations : ' num2str(num_permutations)];
    message_string{end+1}=['Cluster threshold : ' num2str(criticalz)];
    disp(['Number of permutations : ' num2str(num_permutations)]);
    disp(['Cluster threshold : ' num2str(criticalz)]);
    
    %loop through permutations
    for iter=1:num_permutations;
        disp(['Permutation : ' num2str(iter)]);
        %loop through epochs
        for i=1:size(datasets(1).data,1);
            r=rand(length(datasets),1);
            [a,b]=sort(r);
            for j=1:length(datasets);
                datasets2(j).data(i,:,:,:,:,:)=datasets(b(j)).data(i,:,:,:,:,:);
            end;
        end;
        if enable_parallel==1;
            [outdataset2_pvalue,outdataset2_Fvalue]=ILW_custANOVA_parfor(datasets2,within_levels,within_labels,between_levels,between_labels);
        else
            [outdataset2_pvalue,outdataset2_Fvalue]=ILW_custANOVA(datasets2,within_levels,within_labels,between_levels,between_labels);
        end;
        
        %threshold
        tres=tres0;
        tp=find(outdataset2_pvalue.data<criticalp);
        tres(tp)=1;
        
        %loop through channels
        for chanpos=1:size(tres,2);
            %loop through z
            for dz=1:size(tres,4);
                %loop through index
                for indexpos=1:size(tres,3);
                    tps=squeeze(tres(1,chanpos,indexpos,dz,:,:));
                    tp_Fvalues=squeeze(outdataset2_Fvalue.data(1,chanpos,indexpos,dz,:,:));
                    tp2=bwlabel(tps,4);
                    %loop through blobs
                    tpsize=[];
                    for i=1:max(max(tp2));
                        %sum Fvalues
                        if sum(sum(tps(find(tp2==i))))>0;
                            tpsize(i)=sum(sum(tp_Fvalues(find(tp2==i))));
                        end;
                    end;
                    if isempty(tpsize);
                        blob_size(chanpos,dz,indexpos).size(iter)=0;
                        blob_size_max(chanpos,dz,indexpos).size(iter)=0;
                    else
                        blob_size(chanpos,dz,indexpos).size(iter)=mean(abs(tpsize));
                        blob_size_max(chanpos,dz,indexpos).size(iter)=max(abs(tpsize));
                    end;
                    
                    %criticals(chanpos,dz,indexpos)=(criticalz*std(blob_size(chanpos,dz,indexpos).size))+mean(blob_size(chanpos,dz,indexpos).size);
                    switch cluster_criterion
                        case 1;
                            criticals(chanpos,dz,indexpos)=(criticalz*std(blob_size(chanpos,dz,indexpos).size))+mean(blob_size(chanpos,dz,indexpos).size);
                        case 2;
                            criticals(chanpos,dz,indexpos)=(criticalz*std(blob_size_max(chanpos,dz,indexpos).size))+mean(blob_size_max(chanpos,dz,indexpos).size);
                        case 3;
                            criticals(chanpos,dz,indexpos)=prctile(blob_size(chanpos,dz,indexpos).size,criticalz);
                        case 4;
                            criticals(chanpos,dz,indexpos)=prctile(blob_size_max(chanpos,dz,indexpos).size,criticalz);
                    end;
                end;
            end;
        end;
        
        %loop throuch criticals channels
        for chanpos=1:size(criticals,1);
            for dz=1:size(criticals,2);
                message_string{end+1}=['Critical S [' num2str(chanpos) ',' num2str(dz) '] : ' num2str(criticals(chanpos,dz,:))];
            end;
        end;
        tp_plot(iter,:)=squeeze(criticals(1,1,:));
        plot(tp_plot);
        drawnow;
    end;
    
    %distribution
    message_string{end+1}='Calculating distributions';
    blob_size_dist_x=0:0.1:100;
    for chanpos=1:size(tres,2);
        for dz=1:size(tres,4);
            for indexpos=1:size(tres,3);
                for i=1:length(blob_size_dist_x);
                    blob_size_dist(chanpos,dz,indexpos,i)=prctile(blob_size(chanpos,dz,indexpos).size,blob_size_dist_x(i));
                    blob_size_max_dist(chanpos,dz,indexpos,i)=prctile(blob_size_max(chanpos,dz,indexpos).size,blob_size_dist_x(i));
                end;
            end;
        end;
    end;
    
    %process actual data (out_dataset_pvalue/oudataset_Fvalue)
    tres=tres0;
    tp=find(out_dataset_pvalue.data<criticalp);
    tres(tp)=1;
    blob_size=[];
    %loop through channels
    for chanpos=1:size(tres,2);
        %loop through z
        for dz=1:size(tres,4);
            %loop through index
            for indexpos=1:size(tres,3);
                tps=squeeze(tres(1,chanpos,indexpos,dz,:,:));
                tp_Fvalues=squeeze(out_dataset_Fvalue.data(1,chanpos,indexpos,dz,:,:));
                tp_pvalues=squeeze(out_dataset_pvalue.data(1,chanpos,indexpos,dz,:,:));
                tp2=bwlabel(tps,4);
                %loop through blobs
                toutput_Fvalues=zeros(size(tp_Fvalues));
                toutput_pvalues=ones(size(tp_pvalues));
                toutput_cluster_perc=zeros(size(tp_pvalues));
                toutput_cluster_perc_max=zeros(size(tp_pvalues));
                for i=1:max(max(tp2));
                    %sum Fvalues
                    idx=find(tp2==i);
                    blob_size=sum(sum(tp_Fvalues(idx)));
                    message_string{end+1}=['B' num2str(i) ': ' num2str(blob_size)];
                    if sum(sum(tps(find(tp2==i))))>0;
                        if abs(blob_size)>criticals(chanpos,dz,indexpos);
                            message_string{end+1}='FOUND a significant cluster!';
                            toutput_Fvalues(idx)=tp_Fvalues(idx);
                            toutput_pvalues(idx)=tp_pvalues(idx);
                        end;
                        %add cluster statistic sum values
                        [a,b]=min(abs(squeeze(blob_size_dist(chanpos,dz,indexpos,:))-blob_size));
                        toutput_cluster_perc(idx)=blob_size_dist_x(b);
                        [a,b]=min(abs(squeeze(blob_size_max_dist(chanpos,dz,indexpos,:))-blob_size));
                        toutput_cluster_perc_max(idx)=blob_size_dist_x(b);
                    end;
                end;
                out_dataset_Fvalue.data(2,chanpos,indexpos,dz,:,:)=toutput_Fvalues;
                out_dataset_pvalue.data(2,chanpos,indexpos,dz,:,:)=toutput_pvalues;
                out_dataset_Fvalue.data(3,chanpos,indexpos,dz,:,:)=toutput_cluster_perc;
                out_dataset_Fvalue.data(4,chanpos,indexpos,dz,:,:)=toutput_cluster_perc_max;
                out_dataset_pvalue.data(3,chanpos,indexpos,dz,:,:)=toutput_cluster_perc;
                out_dataset_pvalue.data(4,chanpos,indexpos,dz,:,:)=toutput_cluster_perc_max;
            end;
        end;
    end;
    
    %store cluster sizes in cluster_distribution
    cluster_distribution.cluster_values_all=blob_size;
    cluster_distribution.cluster_values_max=blob_size_max;
    cluster_distribution.cluster_values_all=blob_size;
    cluster_distribution.cluster_values_max=blob_size_max;
    
end;

out_dataset_pvalue.header.datasize=size(out_dataset_pvalue.data);
out_dataset_Fvalue.header.datasize=size(out_dataset_Fvalue.data);

%matlabpool close
if enable_parallel==1;
    message_string{end+1}='Closing parallel pool.';
    try
        if exist(parpool)==2;
            delete(gcp('nocreate'));
        else
            matlabpool close;
        end;
    end
    message_string{end+1}='Parallel pool is now closed.';
end;

