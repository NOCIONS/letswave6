function [out_configuration,out_datasets] = LW_ttest(operation,configuration,datasets,update_pointers)
% LW_ttest
% Compare two datasets (t-test)
%
% operations : 
% 'gui_info'
% 'default'
% 'process'
% 'configure'
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


%argument parsing
if nargin<1;
    error('operation is a required argument');
end;
if nargin<2;
    configuration=[];
end;
if nargin<3;
    datasets=[];
end;
if nargin<4;
    update_pointers=[];
end;

%gui_info
gui_info.function_name='LW_ttest';
gui_info.name='Compare two datasets (t-test)';
gui_info.description='Compare two datasets (t-test).';
gui_info.parent='stats_menu';
gui_info.scriptable='no';                       %function can be used in scripts?
gui_info.configuration_mode='direct';           %configuration GUI run in 'direct' 'script' 'history' mode?
gui_info.configuration_requires_data='no';      %configuration requires data of the dataset?
gui_info.save_dataset='yes';                    %process requires to save dataset? 'yes', 'no', 'unique'
gui_info.process_none='no';                     %for functions which have nothing to process (e.g. visualisation functions)
gui_info.process_requires_data='yes';           %process requires data of the dataset?
gui_info.process_filename_string='ttest';       %default filename suffix (or filename (if 'unique'))
gui_info.process_overwrite='no';                %process should overwrite the original dataset?

%operation
switch operation
    
    case 'gui_info'
        %configuration
        out_configuration=configuration;
        out_configuration.gui_info=gui_info;
        %datasets
        out_datasets=datasets;
        
    case 'default'
        %configuration
        out_configuration=configuration;
        out_configuration.gui_info=gui_info;
        out_configuration.parameters.test_type='paired' %'paired' 'non-paired'
        out_configuration.parameters.reference_dataset=[];
        out_configuration.parameters.tails='both';   %'both', 'right', 'left'
        out_configuration.parameters.alpha=0.05;
        out_configuration.parameters.permutation=0;
        out_configuration.parameters.num_permutations=250;
        out_configuration.parameters.cluster_statistic='perc_mean'; %'perc_mean' 'perc_max' 'sd_mean' 'sd_max'
        out_configuration.parameters.cluster_threshold=95;
        out_configuration.parameters.cluster_distribution.mean_statistic=[]
        out_configuraiton.parameters.cluster_distribution.max_statistic=[];
        %datasets
        out_datasets=datasets;
        
    case 'process'
        %init out_datasets
        out_datasets=[];
        %configuration
        out_configuration=configuration;
        %handles feedback
        if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'*** TTest.',1,0); end;        
        %ref_header, ref_data
        if isempty(update_pointers) else update_pointers.function(update_pointers.handles,['Reference dataset : ' configuration.parameters.reference_dataset],1,0); end;
        [ref_header,ref_data]=CLW_load(configuration.parameters.reference_dataset);
        %loop through datasets
        setpos2=1;
        for setpos=1:length(datasets);
            %check that dataset is different from reference dataset
            [p1,n1,e1]=fileparts(datasets(setpos).header.name);
            [p2,n2,e2]=fileparts(configuration.parameters.reference_dataset);
            if strcmpi(n1,n2);
            else
                %process
                [out_datasets(setpos2).header,out_datasets(setpos2).data,message_string,cluster_distribution]=RLW_ttest(datasets(setpos).header,datasets(setpos).data,ref_header,ref_data,'test_type',configuration.parameters.test_type,'tails',configuration.parameters.tails,'alpha',configuration.parameters.alpha,'permutation',configuration.parameters.permutation,'num_permutations',configuration.parameters.num_permutations,'cluster_statistic',configuration.parameters.cluster_statistic,'cluster_threshold',configuration.parameters.cluster_threshold);
                %message_string
                if isempty(update_pointers);
                else
                    if isempty(message_string);
                    else
                        for i=1:length(message_string);
                            update_pointers.function(update_pointers.handles,message_string{i},1,0);
                        end;
                    end;
                end;
                %add cluster_distribution to configuration
                configuration.parameters.cluster_distribution=cluster_distribution;
                %add configuration to history
                if isempty(out_datasets(setpos2).header.history);
                    out_datasets(setpos2).header.history(1).configuration=configuration;
                else
                    out_datasets(setpos2).header.history(end+1).configuration=configuration;
                end;
                %update header.name
                if strcmpi(configuration.gui_info.process_overwrite,'no');
                    out_datasets(setpos2).header.name=[configuration.gui_info.process_filename_string ' ' out_datasets(setpos2).header.name];
                end;
                setpos2=setpos2+1;
            end;
        end;
        if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'Finished.',0,1); end;
        
        

        
    case 'configure'
        %configuration
        [a out_configuration]=GLW_ttest('dummy',configuration,datasets);
        %datasets
        out_datasets=datasets;

end;
