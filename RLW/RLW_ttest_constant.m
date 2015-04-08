function [out_header,out_data,message_string,cluster_distribution]=RLW_ttest_constant(header,data,varargin);
%RLW_ttest_constant
%
%ttest against a constant value
%
%varargin
%constant : 0
%tails : 'both','right','left'
%alpha : 0.05
%permutation : 0
%num_permutations : 250
%cluster_statistic : 'perc_mean','perc_max','sd_mean','sd_max'
%cluster_threshold : 95
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

constant=0;
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
    a=find(strcmpi(varargin,'constant'));
    if isempty(a);
    else
        constant=varargin{a+1};
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

%prepare out_header
out_header=header;

%init cluster_distribution
cluster_distribution.mean_statistic=[];
cluster_distribution.max_statistic=[];

%prepare actual_tres_pvalue and out_data
actual_tres_pvalue=zeros(header.datasize(5),header.datasize(6));
actual_tres_Tvalue=actual_tres_pvalue;
out_data=zeros(1,header.datasize(2),2,header.datasize(4),header.datasize(5),header.datasize(6));

%ttest
message_string{1}='Performing the ttest';
%loop through channels
for chanpos=1:header.datasize(2);
    %loop through dz
    for dz=1:header.datasize(4);
        %loop through dy
        for dy=1:header.datasize(5);
            %prepare t1
            t1=squeeze(data(:,chanpos,1,dz,dy,:))-constant;
            %[H,P,CI,STATS]
            [H,actual_tres_pvalue(dy,:),CI,STATS]=ttest(t1,0,alpha,tails);
            actual_tres_Tvalue(dy,:)=STATS.tstat;
        end;
        %out_data
        out_data(1,chanpos,1,dz,:,:)=actual_tres_pvalue;
        out_data(1,chanpos,2,dz,:,:)=actual_tres_Tvalue;
    end;
end;

%update out_header.datasize
out_header.datasize=size(out_data);

%set index labels
out_header.index_labels{1}='p-value';
out_header.index_labels{2}='T-value';

%clustersize thresholding?
if permutation==1;
    
    %initialize blob_size
    blob_size=[];
    blob_size_max=[];
    tp_plot=[];

    %figure to draw evolution of criticals
    hf=figure; 
    message_string{end+1}='Performing cluster-based thresholding. This may take a while!';
    message_string{end+1}=['Number of permutations : ' num2str(num_permutations)];
    message_string{end+1}=['Cluster threshold : ' num2str(cluster_threshold)];
    message_string{end+1}=['Cluster statistic : ' cluster_statistic];
    
    %init
    rnd_data=zeros(size(data,1),size(data,5),size(data,6));
    tres_pvalue=zeros(size(rnd_data,2),size(rnd_data,3));
    tres_Tvalue=zeros(size(rnd_data,2),size(rnd_data,3));
    
    %tp_data
    tp_data=data-constant;
    
    %loop through permutations
    for iter=1:num_permutations;
       disp(['Permutation : ' num2str(iter)]);
        %loop through channels
        for chanpos=1:size(data,2);
            %loop through dz
            for dz=1:size(data,4);
                %permutation (random sign change across epochs)
                for epochpos=1:size(data,1);
                    r=rand(2,1);
                    [a,b]=sort(r);
                    if b(1)==1;
                        rnd_data(epochpos,:,:)=squeeze(tp_data(epochpos,chanpos,1,dz,:,:))*1;
                    else
                        rnd_data(epochpos,:,:)=squeeze(tp_data(epochpos,chanpos,1,dz,:,:))*-1;
                    end;
                end;
                tres=[];
                %ttest (output is tres with p values and T values tres_pvalue / tres_Tvalue)
                for dy=1:size(rnd_data,2);
                    %[H,P,CI,STATS]
                    %ttest(tpleft,value,alpha,tail)
                    [H,P,CI,STATS]=ttest(squeeze(rnd_data(:,dy,:)),0,alpha,tails);
                    tres_pvalue(dy,:)=H.*P;
                    tres_Tvalue(dy,:)=H.*STATS.tstat;
                end;
                %blobology
                RLL=bwlabel(tres_Tvalue,4);
                RLL_size=[];
                blobpos=1;
                %plot(tres_Tvalue);
                for i=1:max(max(RLL));
                    ff=find(RLL==i);
                    v=sum(sum(RLL(ff)));
                    if v>0;
                        %size(tres_Tvalue);
                        RLL_size(blobpos)=sum(sum(abs(tres_Tvalue(ff))));
                        blobpos=blobpos+1;
                    end;
                end;
                if isempty(RLL_size);
                    RLL_size=0;
                end;
                %blob summary
                blob_size(chanpos,dz).size(iter)=mean(abs(RLL_size));
                blob_size_max(chanpos,dz).size(iter)=max(abs(RLL_size));
                %critical
                switch cluster_statistic
                    case 'sd_mean';
                        criticals(chanpos,dz)=(cluster_threshold*std(blob_size(chanpos,dz).size))+mean(blob_size(chanpos,dz).size);
                    case 'sd_max';
                        criticals(chanpos,dz)=(cluster_threshold*std(blob_size_max(chanpos,dz).size))+mean(blob_size_max(chanpos,dz).size);
                    case 'perc_mean';
                        criticals(chanpos,dz)=prctile(blob_size(chanpos,dz).size,cluster_threshold);
                    case 'perc_max';
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
    outdata_Tvalue=out_data(1,:,2,:,:,:);
    tres=zeros(size(outdata_pvalue));
    tp=find(outdata_pvalue<alpha);
    tres(tp)=1;
    blob_size=[];
    
    %loop through channels
    for chanpos=1:size(tres,2);
        %loop through z
        for dz=1:size(tres,4);
            tps=squeeze(tres(1,chanpos,1,dz,:,:));
            tp_Tvalues=squeeze(outdata_Tvalue(1,chanpos,1,dz,:,:));
            tp_pvalues=squeeze(outdata_pvalue(1,chanpos,1,dz,:,:));
            tp2=bwlabel(tps,4);
            %loop through blobs
            toutput_Tvalues=zeros(size(tp_Tvalues));
            toutput_pvalues=ones(size(tp_pvalues));
            for i=1:max(max(tp2));
                %sum Tvalues
                idx=find(tp2==i);
                blob_size=sum(sum(abs(tp_Tvalues(idx))));
                message_string{end+1}=['B' num2str(i) ': ' num2str(blob_size)];
                if sum(sum(tps(find(tp2==i))))>0;
                    if abs(blob_size)>criticals(chanpos,dz);
                        message_string{end+1}='FOUND a significant cluster!';
                        toutput_Tvalues(idx)=tp_Tvalues(idx);
                        toutput_pvalues(idx)=tp_pvalues(idx);
                    end;
                end;
            end;
            outdata_Tvalue(2,chanpos,1,dz,:,:)=toutput_Tvalues;
            outdata_pvalue(2,chanpos,1,dz,:,:)=toutput_pvalues;
        end;
    end;
    
    %update out_data
    out_data(1,:,3,:,:,:)=outdata_pvalue(2,:,:,:,:,:);
    out_data(1,:,4,:,:,:)=outdata_Tvalue(2,:,:,:,:,:);
    
    %set index labels
    out_header.index_labels{3}='cluster p-value';
    out_header.index_labels{4}='cluster T-value';
    
    %adjust header.datasize
    out_header.datasize(3)=4;
    
    %cluster_distribution
    cluster_distribution.mean_statistic=blob_size;
    cluster_distribution.max_statistic=blob_size_max;
end;
    

    


