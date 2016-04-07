function [outdataset_pvalue,outdataset_Fvalue] = ILW_custANOVA(datasets,within_levels,within_labels,between_levels,between_labels);
%within_levels(datasetpos,factorpos)
%between_levels(datasetpos,factorpos)


%initialize outdataset_pvalue and outdataset_Fvalue
outdataset_pvalue=[];
outdataset_Fvalue=[];
outdataset_pvalue.header=[];
outdataset_pvalue.data=[];
outdataset_Fvalue.header=[];
outdataset_Fvalue.data=[];

%header
header=datasets(1).header;

%ANOVA_type (1=within, 2=between, 3=mixed, 4=single between)
ANOVA_type=3;
if isempty(within_levels);
    ANOVA_type=2;
end;
if isempty(between_levels);
    ANOVA_type=1;
end;

if and(size(between_levels,2)==1,isempty(within_levels));
    ANOVA_type=4;
end;

%factors
within_factors=[];
between_factors=[];
subject_factor=[];

%add within_levels (if there are any)
if isempty(within_levels);
else
    k=1;
    for datapos=1:length(datasets);
        num_epochs=size(datasets(datapos).data,1);
        for i=1:num_epochs;
            within_factors(k,:)=within_levels(datapos,:);
            k=k+1;
        end;
    end;
end;

%add between_levels (if there are any)
if isempty(between_levels);
else
    k=1;
    for datapos=1:length(datasets);
        num_epochs=size(datasets(datapos).data,1);
        for i=1:num_epochs;
            between_factors(k,:)=between_levels(datapos,:);
            k=k+1;
        end;
    end;
end;

%add subject level (only if within_levels is not empty)
if isempty(within_levels);
else
    k=1;
    for datapos=1:length(datasets);
        num_epochs=size(datasets(datapos).data,1);
        for i=1:num_epochs;
            subject_factor(k,1)=i;
            k=k+1;
        end;
    end;
end;

%assemble factors
switch ANOVA_type
    case 1
        factors=[within_factors subject_factor];
        factors_label=[within_labels 'subject'];
        subject_pos=size(factors,2);
    case 2
        factors=between_factors;
        factors_label=between_labels;
    case 3
        factors=[within_factors between_factors subject_factor];
        factors_label=[within_labels between_labels 'subject'];
        subject_pos=size(factors,2);
    case 4
        factors=[between_factors];
        factors_label=between_labels;
end;

%nesting? (mixed ANOVA)
if ANOVA_type==3;
    % the variable subject is "nested" within the between-subject variables
    % square matrix whose dimensions are equal to the number of factors
    % each row and col represents a factor
    % value is 1 when the factor represented in the row is nested within the IV
    % represented in the column
    % nested variables (between-subject variables) are passed last
    % subject factor is last factor
    num_factors=size(factors,2);
    num_nested=size(between_factors,2);
    nesting=zeros(size(factors,2),size(factors,2));
    for i=1:num_nested;
        nesting(num_factors,num_factors-i)=1;
    end;
end;



%prepare tpdata_datapos
k=1;
for datapos=1:length(datasets);
    num_epochs=size(datasets(datapos).data,1);
    for i=1:num_epochs;
        tpdata_datapos(k)=datapos;
        tpdata_epochpos(k)=i;
        k=k+1;
    end;
end;

%num
num_channels=size(datasets(1).data,2);
num_index=size(datasets(1).data,3);
num_dz=size(datasets(1).data,4);
num_dy=size(datasets(1).data,5);
num_dx=size(datasets(1).data,6);

%anovan first pass
tpdata=[];
for i=1:length(tpdata_datapos);
    tpdata(i)=datasets(tpdata_datapos(i)).data(tpdata_epochpos(i),1,1,1,1,1);
end;
tpdata=tpdata';
switch ANOVA_type
    case 1
        [result_p,result_T]=anovan(tpdata,factors,'varnames',factors_label,'random',subject_pos,'model','full','display','off');
        a=result_T(2:end-2,1);
        b=strfind(a,'subject');
        fact_idx=[];
        for i=1:length(b);
            if isempty(b{i});
                fact_idx=[fact_idx i+1];
            end;
        end;
        outdataset_pvalue.data=zeros(1,header.datasize(2),length(fact_idx),header.datasize(4),header.datasize(5),header.datasize(6));
        outdataset_Fvalue.data=zeros(1,header.datasize(2),length(fact_idx),header.datasize(4),header.datasize(5),header.datasize(6));
        T=cell2mat(result_T(fact_idx,6:7));
        outdataset_pvalue.data(1,1,:,1,1,1)=T(:,2);
        outdataset_Fvalue.data(1,1,:,1,1,1)=T(:,1);
    case 2
        [result_p,result_T]=anovan(tpdata,factors,'varnames',factors_label,'model','full','display','off');
        T=cell2mat(result_T(2:end-2,6));
        outdataset_pvalue.data=zeros(1,header.datasize(2),length(T),header.datasize(4),header.datasize(5),header.datasize(6));
        outdataset_Fvalue.data=zeros(1,header.datasize(2),length(T),header.datasize(4),header.datasize(5),header.datasize(6));
        outdataset_pvalue.data(1,1,:,1,1,1)=result_p;
        outdataset_Fvalue.data(1,1,:,1,1,1)=T;  
        fact_idx=2:size(result_T,1)-2;
    case 3
        [result_p,result_T]=anovan(tpdata,factors,'varnames',factors_label,'nested',nesting,'random',subject_pos,'model','full','display','off');
        a=result_T(2:end-2,1);
        b=strfind(a,'subject(');
        fact_idx=[];
        for i=1:length(b);
            if isempty(b{i});
                fact_idx=[fact_idx i+1];
            end;
        end;
        outdataset_pvalue.data=zeros(1,header.datasize(2),length(fact_idx),header.datasize(4),header.datasize(5),header.datasize(6));
        outdataset_Fvalue.data=zeros(1,header.datasize(2),length(fact_idx),header.datasize(4),header.datasize(5),header.datasize(6));
        T=cell2mat(result_T(fact_idx,6:7));
        outdataset_pvalue.data(1,1,:,1,1,1)=T(:,2);
        outdataset_Fvalue.data(1,1,:,1,1,1)=T(:,1);
    case 4
        [result_p,result_T]=anova1(tpdata,factors,'off');
        outdataset_pvalue.data=zeros(1,header.datasize(2),1,header.datasize(4),header.datasize(5),header.datasize(6));
        outdataset_Fvalue.data=zeros(1,header.datasize(2),1,header.datasize(4),header.datasize(5),header.datasize(6));
        outdataset_pvalue.data(1,1,1,1,1,1)=result_p;
        outdataset_Fvalue.data(1,1,1,1,1,1)=result_T{2,5};
        fact_idx=2;
end;


%anovan loop
for channelpos=1:num_channels
    for dz=1:num_dz
        for dy=1:num_dy
            disp(['C:' num2str(channelpos) ' Z:' num2str(dz) ' Y:' num2str(dy)]);
            %anovan
            for dx=1:num_dx
                tpdata=[];
                for i=1:length(tpdata_datapos);
                    tpdata(i)=datasets(tpdata_datapos(i)).data(tpdata_epochpos(i),channelpos,1,dz,dy,dx);
                end;
                tpdata=tpdata';
                switch ANOVA_type
                    case 1
                        [result_p,result_T]=anovan(tpdata,factors,'varnames',factors_label,'random',subject_pos,'model','full','display','off');
                        T=cell2mat(result_T(fact_idx,6:7));
                        outdataset_pvalue.data(1,channelpos,:,dz,dy,dx)=T(:,2);
                        outdataset_Fvalue.data(1,channelpos,:,dz,dy,dx)=T(:,1);
                    case 2
                        [result_p,result_T]=anovan(tpdata,factors,'varnames',factors_label,'model','full','display','off');
                        T=cell2mat(result_T(2:end-2,6));
                        outdataset_pvalue.data(1,channelpos,:,dz,dy,dx)=result_p;
                        outdataset_Fvalue.data(1,channelpos,:,dz,dy,dx)=T;
                    case 3
                        [result_p,result_T]=anovan(tpdata,factors,'varnames',factors_label,'nested',nesting,'random',subject_pos,'model','full','display','off');
                        T=cell2mat(result_T(fact_idx,6:7));
                        outdataset_pvalue.data(1,channelpos,:,dz,dy,dx)=T(:,2);
                        outdataset_Fvalue.data(1,channelpos,:,dz,dy,dx)=T(:,1);
                    case 4
                        [result_p,result_T]=anova1(tpdata,factors,'off');
                        outdataset_pvalue.data(1,channelpos,1,dz,dy,dx)=result_p;
                        outdataset_Fvalue.data(1,channelpos,1,dz,dy,dx)=result_T{2,5};
                end;
            end;
        end;
    end;
end;
  
outdataset_pvalue.header=header;
outdataset_pvalue.header.datasize=size(outdataset_pvalue.data);

for i=1:length(fact_idx);
    outdataset_pvalue.header.index_labels{i}=result_T{fact_idx(i),1};
end;
outdataset_Fvalue.header=outdataset_pvalue.header;





