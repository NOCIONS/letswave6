function [out_header,out_data,message_string,cluster_distribution]=RLW_wilcoxon(header1,data1,header2,data2,varargin);
%RLW_wilcoxon
%
%wilcoxon between two datasets
%
%header1,data1
%header2,data2
%
%varargin
%
%'test_type' ('signed_rank_test') 'signed_rank_test' 'rank_sum_test' 'sign_test';
%'tails' : 'both','right','left'
%'alpha' : 0.05
%'permutation' : 0
%'num_permutations' : 250
%'cluster_statistic' : 'perc_mean','perc_max','sd_mean','sd_max'
%'cluster_threshold' : 95
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

test_type='signed_rank_test'
tails='both';   %'both', 'right', 'left'
alpha=0.05;
permutation=0;
num_permutations=250;
cluster_statistic='perc_mean'; %'perc_mean' 'perc_max' 'sd_mean' 'sd_max'
cluster_threshold=95;

%parse varagin
if isempty(varargin);
else
    %constant
    a=find(strcmpi(varargin,'test_type'));
    if isempty(a);
    else
        test_type=varargin{a+1};
    end;
    %tails
    a=find(strcmpi(varargin,'tails'));
    if isempty(a);
    else
        tails=varargin{a+1};
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

%init message_string
message_string={};
message_string{1}='Wilcoxon.';

%prepare out_header
out_header=header1;

%init cluster_distribution
cluster_distribution.mean_statistic=[];
cluster_distribution.max_statistic=[];

message_string{end+1}=['Tails : ' tails ' Alpha : ' num2str(alpha)];

%prepare out_header
out_header.datasize(1)=1;
out_header.datasize(3)=2;

%prepare out_data
out_data=zeros(out_header.datasize);

%loop through epochs
indexpos=1;
for chanpos=1:header1.datasize(2);
    for dz=1:header1.datasize(4);
        for dy=1:header1.datasize(5);
            switch test_type
                case 'signed_rank_test'
                    for dx=1:header1.datasize(6);
                        tpleft=squeeze(data1(:,chanpos,indexpos,dz,dy,dx));
                        tpright=squeeze(data2(:,chanpos,indexpos,dz,dy,dx));
                        [actual_tres_pvalue(dy,dx),H,STATS]=signrank(tpleft,tpright,'alpha',alpha,'tail',tails);
                        actual_tres_Zvalue(dy,dx)=STATS.zval;
                    end;
                case 'rank_sum_test'
                    for dx=1:header1.datasize(6);
                        tpleft=squeeze(data1(:,chanpos,indexpos,dz,dy,dx));
                        tpright=squeeze(data2(:,chanpos,indexpos,dz,dy,dx));
                        [actual_tres_pvalue(dy,dx),H,STATS]=signtest(tpleft,tpright,'alpha',alpha,'tail',tails);
                        actual_tres_Zvalue(dy,dx)=STATS.zval;
                    end;
                case 'signed_test'
                    for dx=1:header1.datasize(6);
                        tpleft=squeeze(data1(:,chanpos,indexpos,dz,dy,dx));
                        tpright=squeeze(data2(:,chanpos,indexpos,dz,dy,dx));
                        [actual_tres_pvalue(dy,dx),H,STATS]=ranktest(tpleft,tpright,'alpha',alpha,'tail',tails);
                        actual_tres_Zvalue(dy,dx)=STATS.zval;
                    end;
            end;
        end;
    end;
    out_data(1,chanpos,1,dz,:,:)=actual_tres_pvalue;
    out_data(1,chanpos,2,dz,:,:)=actual_tres_Zvalue;
end;

%delete events
if isfield(out_header,'events');
    out_header.events=[];
end;

%set index_labels
out_header.index_labels{1}='p-value';
out_header.index_labels{2}='Z';



%delete epoch_data if present
if isfield(out_header,'epochdata');
    out_header=rmfield(out_header,'epochdata');
end;

%cluster thresholding?
if permutation==1;
    
    message_string{end+1}=['Number of permutations : ' num2str(num_permutations)];
    message_string{end+1}=['Cluster threshold : ' num2str(cluster_threshold)];
    
    %init
    rnd_data=zeros(size(data1,1),size(data1,5),size(data1,6));
    tres_pvalue=zeros(size(rnd_data,2),size(rnd_data,3));
    tres_Zvalue=zeros(size(rnd_data,2),size(rnd_data,3));
    
    %figure to draw evolution of criticals
    hf=figure;
    disp(['Performing cluster-based thresholding. This may take a while!']);
    
    %merge
    tp=size(data1);
    tp(3)=2;
    merged_data=zeros(tp);
    merged_data(:,:,1,:,:,:)=data1(:,:,1,:,:,:);
    merged_data(:,:,2,:,:,:)=data2(:,:,1,:,:,:);
    merged_cat(:,1)=zeros(size(merged_data,1),1)+1;
    merged_cat(:,2)=zeros(size(merged_data,1),1)+2;
    
    %loop
    blobsizes=[];
    for iter=1:num_permutations;
        disp(['Permutation : ' num2str(iter)]);
        %loop through channels
        for chanpos=1:size(data1,2);
            %loop through dz
            for dz=1:size(data1,4);
                %permutation
                for epochpos=1:size(merged_cat,1);
                    r=rand(size(merged_cat,2),1);
                    [a,b]=sort(r);
                    rnd_cat(epochpos,:)=b;
                end;
                tres=[];
                %wilcoxon (output is tres with p values and Z values tres_pvalue / tres_Zvalue)
                for dy=1:size(data1,5);
                    for epochpos=1:size(merged_data,1);
                        t1(epochpos,:)=squeeze(merged_data(epochpos,chanpos,rnd_cat(epochpos,1),dz,dy,:));
                        t2(epochpos,:)=squeeze(merged_data(epochpos,chanpos,rnd_cat(epochpos,2),dz,dy,:));
                    end;
                    switch test_type
                        case 'signed_rank_test'
                            for dx=1:size(data1,6);
                                tpleft=squeeze(t1(:,dx));
                                tpright=squeeze(t2(:,dx));
                                [p,H,STATS]=signrank(tpleft,tpright,'alpha',alpha,'tail',tails);
                                tres_pvalue(dy,dx)=p*H;
                                tres_Zvalue(dy,dx)=STATS.zval*H;
                            end;
                        case 'rank_sum_test'
                            for dx=1:size(data1,6);
                                tpleft=squeeze(t1(:,dx));
                                tpright=squeeze(t2(:,dx));
                                [p,H,STATS]=signtest(tpleft,tpright,'alpha',alpha,'tail',tails);
                                tres_pvalue(dy,dx)=p*H;
                                tres_Zvalue(dy,dx)=STATS.zval*H;
                            end;
                        case 'signed_test'
                            for dx=1:size(data1,6);
                                tpleft=squeeze(t1(:,dx));
                                tpright=squeeze(t2(:,dx));
                                [p,H,STATS]=ranktest(tpleft,tpright,'alpha',alpha,'tail',tails);
                                tres_pvalue(dy,dx)=p*H;
                                tres_Zvalue(dy,dx)=STATS.zval*H;
                            end;
                    end;
                end;
                
                %blobology
                RLL=bwlabel(tres_Zvalue,4);
                RLL_size=[];
                blobpos=1;
                for i=1:max(max(RLL));
                    ff=find(RLL==i);
                    v=sum(sum(abs(RLL(ff))));
                    if v>0;
                        RLL_size(blobpos)=v;
                        blobpos=blobpos+1;
                    end;
                end;
                if isempty(RLL_size);
                    RLL_size=0;
                end;
                
                %blob summary
                blob_size(chanpos,dz).size(iter)=mean(RLL_size);
                blob_size_max(chanpos,dz).size(iter)=max(RLL_size);
                
                %critical
                switch cluster_statistic
                    case 'sd_mean'
                        criticals(chanpos,dz)=(cluster_threshold*std(blob_size(chanpos,dz).size))+mean(blob_size(chanpos,dz).size);
                    case 'sd_max'
                        criticals(chanpos,dz)=(cluster_threshold*std(blob_size_max(chanpos,dz).size))+mean(blob_size_max(chanpos,dz).size);
                    case 'perc_mean'
                        criticals(chanpos,dz)=prctile(blob_size(chanpos,dz).size,cluster_threshold);
                    case 'perc_max'
                        criticals(chanpos,dz)=prctile(blob_size_max(chanpos,dz).size,cluster_threshold);
                end;
            end;
        end;
        
        tp_plot(iter,:)=squeeze(criticals(:,1));
        plot(tp_plot);
        drawnow;
    end;
    
    %display criticals
    for chanpos=1:size(criticals,1);
        for dz=1:size(criticals,2);
            message_string{end+1}=['Critical S [' num2str(chanpos) ',' num2str(dz) '] : ' num2str(criticals(chanpos,dz,:))];
        end;
    end;
    
    %process actual data (outheader_pvalue/outheader_Fvalue)
    outdata_pvalue=out_data(1,:,1,:,:,:);
    outdata_Zvalue=out_data(1,:,2,:,:,:);
    tres=zeros(size(outdata_pvalue));
    tp=find(outdata_pvalue<alpha);
    tres(tp)=1;
    blob_size=[];
    
    %loop through channels
    for chanpos=1:size(tres,2);
        %loop through z
        for dz=1:size(tres,4);
            tps=squeeze(tres(1,chanpos,1,dz,:,:));
            tp_Zvalues=squeeze(outdata_Zvalue(1,chanpos,1,dz,:,:));
            tp_pvalues=squeeze(outdata_pvalue(1,chanpos,1,dz,:,:));
            tp2=bwlabel(tps,4);
            %loop through blobs
            toutput_Zvalues=zeros(size(tp_Zvalues));
            toutput_pvalues=ones(size(tp_pvalues));
            for i=1:max(max(tp2));
                %sum Zvalues
                idx=find(tp2==i);
                blob_size=sum(sum(abs(tp_Zvalues(idx))));
                message_string{end+1}=['B' num2str(i) ': ' num2str(blob_size)];
                if sum(sum(tps(find(tp2==i))))>0;
                    if blob_size>criticals(chanpos,dz);
                        message_string{end+1}='FOUND a significant cluster!';
                        toutput_Zvalues(idx)=tp_Zvalues(idx);
                        toutput_pvalues(idx)=tp_pvalues(idx);
                    end;
                end;
            end;
            outdata_Zvalue(2,chanpos,1,dz,:,:)=toutput_Zvalues;
            outdata_pvalue(2,chanpos,1,dz,:,:)=toutput_pvalues;
        end;
    end;

    %update out_data
    out_data(1,:,3,:,:,:)=outdata_pvalue(2,:,:,:,:,:);
    out_data(1,:,4,:,:,:)=outdata_Zvalue(2,:,:,:,:,:);
    %adjust header.datasize
    out_header.datasize(3)=4;
    %set index labels
    out_header.index_labels{3}='cluster p-value';
    out_header.index_labels{4}='cluster T-value';

    %cluster_distribution
    cluster_distribution.mean_statistic=blob_size;
    cluster_distribution.max_statistic=blob_size_max;
end;

