function [out_header,out_data,message_string,cluster_distribution]=RLW_channel_ttest_constant(header,data,varargin)
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
%x_start:0
%x_end:1
%threshold:4
%
% Author :
% Gan Huang
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
xstart=0;
xend=1;
threshold=0.5;

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
    end
    
    %xstart
    a=find(strcmpi(varargin,'xstart'));
    if isempty(a);
    else
        xstart=varargin{a+1};
    end
    %xend
    a=find(strcmpi(varargin,'xend'));
    if isempty(a);
    else
        xend=varargin{a+1};
    end
    
    %threshold
    a=find(strcmpi(varargin,'threshold'));
    if isempty(a);
    else
        threshold=varargin{a+1};
    end
end



fieldname=fieldnames(header.chanlocs(1));
if length(fieldname)<4
    chanlocs=readlocs('Standard-10-20-Cap81.locs');
    [header,~]=RLW_edit_electrodes(header,chanlocs);
end

connection=zeros(length(header.chanlocs),length(header.chanlocs));
for ch_1=1:length(header.chanlocs)
    if(header.chanlocs(ch_1).topo_enabled)==1
        connection(ch_1,ch_1)=1;
        for ch_2=ch_1+1:length(header.chanlocs)
            if(header.chanlocs(ch_2).topo_enabled)==1
                d=norm([header.chanlocs(ch_1).X,header.chanlocs(ch_1).Y,header.chanlocs(ch_1).Z]...
                    -[header.chanlocs(ch_2).X,header.chanlocs(ch_2).Y,header.chanlocs(ch_2).Z]);
                if d<threshold
                    connection(ch_1,ch_2)=1;
                    connection(ch_2,ch_1)=1;
                end
            end
        end
    end
end

% figure()
% hold on;
% for ch_1=1:length(header.chanlocs)
%     if(header.chanlocs(ch_1).topo_enabled)==1
%         plot3(header.chanlocs(ch_1).X,header.chanlocs(ch_1).Y,header.chanlocs(ch_1).Z,'b*')
%         for ch_2=ch_1+1:length(header.chanlocs)
%             if connection(ch_1,ch_2)==1
%
%         plot3([header.chanlocs(ch_1).X,header.chanlocs(ch_2).X],...
%               [header.chanlocs(ch_1).Y,header.chanlocs(ch_2).Y],...
%               [header.chanlocs(ch_1).Z,header.chanlocs(ch_2).Z],'r');
%             end
%         end
%     end
% end

dxstart=round(((xstart-header.xstart)/header.xstep)+1);
dxend=round(((xend-header.xstart)/header.xstep)+1);
%check limits
if dxstart<1;
    dxstart=1;
end;
if dxend>header.datasize(6);
    dxend=header.datasize(6);
end;

%init message_string
message_string={};

%prepare out_header
out_header=header;

%init cluster_distribution
cluster_distribution.mean_statistic=[];
cluster_distribution.max_statistic=[];

%prepare actual_tres_pvalue and out_data
actual_tres_pvalue=zeros(header.datasize(5),11);
actual_tres_Tvalue=actual_tres_pvalue;
out_data=zeros(1,header.datasize(2),2,header.datasize(4),header.datasize(5),11);

%ttest
message_string{1}='Performing the ttest';
%loop through channels
for chanpos=1:header.datasize(2);
    %loop through dz
    for dz=1:header.datasize(4);
        %loop through dy
        for dy=1:header.datasize(5);
            %prepare t1
            t1=squeeze(mean(data(:,chanpos,1,dz,dy,dxstart:dxend),6))-constant;
            %[H,P,CI,STATS]
            [~,p,~,STATS]=ttest(t1,0,alpha,tails);
            out_data(1,chanpos,1,dz,dy,:)=p;
            out_data(1,chanpos,2,dz,dy,:)=STATS.tstat;
        end;
    end;
end;


% figure()
% hold on;
% for ch_1=1:length(header.chanlocs)
%     if(header.chanlocs(ch_1).topo_enabled)==1
%         if out_data(1,ch_1,1,dz,dy,1)<0.05
%         plot3(header.chanlocs(ch_1).X,header.chanlocs(ch_1).Y,header.chanlocs(ch_1).Z,'b*')
%         else
%         plot3(header.chanlocs(ch_1).X,header.chanlocs(ch_1).Y,header.chanlocs(ch_1).Z,'ro')
%         end
%         for ch_2=ch_1+1:length(header.chanlocs)
%             if connection(ch_1,ch_2)==1
%         plot3([header.chanlocs(ch_1).X,header.chanlocs(ch_2).X],...
%               [header.chanlocs(ch_1).Y,header.chanlocs(ch_2).Y],...
%               [header.chanlocs(ch_1).Z,header.chanlocs(ch_2).Z],'r');
%             end
%         end
%     end
% end

%update out_header.datasize
out_header.datasize=size(out_data);
out_header.xstart=xstart;
out_header.xstep=(xend-xstart)/10;

%set index labels
out_header.index_labels{1}='p-value';
out_header.index_labels{2}='T-value';

%clustersize thresholding?
if permutation~=1
    return;
end

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
rnd_data=zeros(size(data,1),size(data,2));
tres_pvalue=zeros(size(rnd_data,2),1);
tres_Tvalue=zeros(size(rnd_data,2),1);

%tp_data
tp_data=mean(data(:,:,1,dz,dy,dxstart:dxend),6)-constant;

%loop through permutations
for iter=1:num_permutations;
    disp(['Permutation : ' num2str(iter)]);
    for dz=1:size(data,4)
        for dy=1:size(data,5)
            %permutation (random sign change across epochs)
            for epochpos=1:size(data,1);
                r=rand(2,1);
                [a,b]=sort(r);
                if b(1)==1;
                    rnd_data(epochpos,:)=squeeze(tp_data(epochpos,:,1,dz,dy))*1;
                else
                    %rnd_data(epochpos,:)=squeeze(tp_data(epochpos,:,1,dz,dy))*1;
                    rnd_data(epochpos,:)=squeeze(tp_data(epochpos,:,1,dz,dy))*-1;
                end;
            end;
            tres=[];
            %ttest (output is tres with p values and T values tres_pvalue / tres_Tvalue)
            for chanpos=1:size(rnd_data,2);
                %[H,P,CI,STATS]
                %ttest(tpleft,value,alpha,tail)
                [H,P,~,STATS]=ttest(squeeze(rnd_data(:,chanpos)),0,alpha,tails);
                tres_pvalue(chanpos)=H.*P;
                tres_Tvalue(chanpos)=H.*STATS.tstat;
            end;
            %blobology
            RLL=bwlabel_channel(tres_Tvalue,connection);
            
            %                 figure()
            %                 hold on;
            %                 style={'ro','b*','kd','g<','m^'};
            %                 for ch_1=1:length(RLL)
            %                     if(header.chanlocs(ch_1).topo_enabled)==1
            %                         plot3(header.chanlocs(ch_1).X,header.chanlocs(ch_1).Y,header.chanlocs(ch_1).Z,style{RLL(ch_1)+1});
            %                         for ch_2=ch_1+1:length(header.chanlocs)
            %                             if connection(ch_1,ch_2)==1
            %                                 plot3([header.chanlocs(ch_1).X,header.chanlocs(ch_2).X],...
            %                                     [header.chanlocs(ch_1).Y,header.chanlocs(ch_2).Y],...
            %                                     [header.chanlocs(ch_1).Z,header.chanlocs(ch_2).Z],'r');
            %                             end
            %                         end
            %                     end
            %                 end
            
            RLL_size=[];
            blobpos=1;
            %plot(tres_Tvalue);
            for i=1:max(RLL);
                RLL_size(blobpos)=sum(abs(tres_Tvalue(RLL==i)));
                blobpos=blobpos+1;
            end;
            if isempty(RLL_size);
                RLL_size=0;
            end;
            %blob summary
            blob_size(dz,dy).size(iter)=mean(abs(RLL_size));
            blob_size_max(dz,dy).size(iter)=max(abs(RLL_size));
            %critical
            switch cluster_statistic
                case 'sd_mean';
                    criticals(dz,dy)=(cluster_threshold*std(blob_size(dz,dy).size))+mean(blob_size(dz,dy).size);
                case 'sd_max';
                    criticals(dz,dy)=(cluster_threshold*std(blob_size_max(dz,dy).size))+mean(blob_size_max(dz,dy).size);
                case 'perc_mean';
                    criticals(dz,dy)=prctile(blob_size(dz,dy).size,cluster_threshold);
                case 'perc_max';
                    criticals(dz,dy)=prctile(blob_size_max(dz,dy).size,cluster_threshold);
            end;
        end;
    end;
    tp_plot(iter,:)=squeeze(criticals(:,1));
    plot(tp_plot);
    drawnow;
end;

%display criticals
for dz=1:size(criticals,1);
    for dy=1:size(criticals,2);
        message_string{end+1}=['Critical S [' num2str(dz) ',' num2str(dy) '] : ' num2str(criticals(dz,dy))];
    end;
end;

%process actual data (outheader_pvalue/outheader_Fvalue)
outdata_pvalue=out_data(1,:,1,:,:,:);
outdata_Tvalue=out_data(1,:,2,:,:,:);
out_data(1,:,3,:,:,:)=1;
out_data(1,:,4,:,:,:)=0;
tres=zeros(size(outdata_pvalue));
tres(outdata_pvalue<alpha)=1;
blob_size=[];

for dz=1:size(tres,4);
    for dy=1:size(tres,5);
        tps=squeeze(tres(1,:,1,dz,dy,1));
        tp_Tvalues=squeeze(outdata_Tvalue(1,:,1,dz,dy,1));
        tp_pvalues=squeeze(outdata_pvalue(1,:,1,dz,dy,1));
        tp2=bwlabel_channel(tps',connection);
        for i=1:max(tp2);
            %sum Tvalues
            idx=find(tp2==i);
            blob_size=sum(abs(tp_Tvalues(idx)));
            message_string{end+1}=['B' num2str(i) ': ' num2str(blob_size)];
            if abs(blob_size)>criticals(dz,dy);
               message_string{end+1}='FOUND a significant cluster!';
               for k=1:length(idx)
               out_data(1,idx(k),3,dz,dy,:)=tp_pvalues(idx(k));
               out_data(1,idx(k),4,dz,dy,:)=tp_Tvalues(idx(k));
               end
            end;
        end;
    end;
end;

%set index labels
out_header.index_labels{3}='cluster p-value';
out_header.index_labels{4}='cluster T-value';

%adjust header.datasize
out_header.datasize(3)=4;

%cluster_distribution
cluster_distribution.mean_statistic=blob_size;
cluster_distribution.max_statistic=blob_size_max;