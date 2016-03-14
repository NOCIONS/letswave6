function [out_configuration,out_datasets] = LW_dipfit_fit_latency(operation,configuration,datasets,update_pointers)
% LW_dipfit_fit_latency
% DIPFIT : fit dipole(s) at a given latency
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
gui_info.function_name='LW_dipfit_fit_latency';
gui_info.name='dipfit : fit dipole(s) at a given latency';
gui_info.description='dipfit : fit dipole(s) at a given latency';
gui_info.parent='source_analysis_menu';
gui_info.scriptable='no';                       %function can be used in scripts?
gui_info.configuration_mode='direct';           %configuration GUI run in 'direct' 'script' 'history' mode?
gui_info.configuration_requires_data='yes';      %configuration requires data of the dataset?
gui_info.save_dataset='yes';                    %process requires to save dataset? 'yes', 'no', 'unique'
gui_info.process_none='no';                     %for functions which have nothing to process (e.g. visualisation functions)
gui_info.process_requires_data='yes';           %process requires data of the dataset?
gui_info.process_filename_string='dipfit';         %default filename suffix (or filename (if 'unique'))
gui_info.process_overwrite='yes';                %process should overwrite the original dataset?

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
        out_configuration.parameters.dipole_model='single'; %'single','pairX','pairY','pairZ','pair'
        out_configuration.parameters.gridsearch_resolution=10;
        out_configuration.parameters.dipole_label='dipole';
        out_configuration.parameters.latency=0;
        out_configuration.parameters.epoch=1;
        out_configuration.parameters.index=1;
        out_configuration.parameters.dipole_list=[];
        out_configuration.parameters.topo_list=[];
        out_configuratoin.parameters.topo_channel_labels=[];
        out_configuration.parameters.vol=[];
        out_configuration.parameters.elec=[];
        out_configuration.parameters.mri=[];
        if isempty(datasets);
        else
            header=datasets(1).header;
            out_configuration.parameters.y=header.ystart;
            out_configuration.parameters.z=header.zstart;
        end;
        %datasets
        out_datasets=datasets;
        
    case 'process'
        out_datasets=[];
        %handles feedback
        if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'*** DIPFIT : fit dipole(s) at latencies.',1,0); end;
        %datasets
        out_datasets=datasets;
        for setpos=1:length(datasets);
            %find dipfit chanlocs,vol,mri
            header=datasets(setpos).header;
            %hist_st
            for i=1:length(header.history);
                hist_st{i}=header.history(i).configuration.gui_info.function_name;
            end;
            %vol
            a=find(strcmpi(hist_st,'LW_dipfit_assign_headmodel'));
            if isempty(a);
                if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'No headmodel found. Exit.',1,0); end;
                if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'You must first assign a headmodel to the dataset.',1,0); end;
                return;
            else
                if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'Loading headmodel.',1,0); end;
                vol=header.history(a(end)).configuration.parameters.vol;
            end;
            %mri
            a=find(strcmpi(hist_st,'LW_dipfit_assign_mri'));
            if isempty(a);
                if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'No MRI data found. Exit.',1,0); end;
                if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'You must first assign MRI data to the dataset.',1,0); end;
                return;
            else
                if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'Loading MRI data.',1,0); end;
                mri=header.history(a(end)).configuration.parameters.mri;
            end;           
            %chanlocs
            a=find(strcmpi(hist_st,'LW_dipfit_assign_chanlocs'));
            if isempty(a);
                if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'No dipfit channel locations found. Exit.',1,0); end;
                if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'You must first assign dipfit channel locations to the dataset.',1,0); end;
                return;
            else
                if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'Loading channel locations.',1,0); end;
                chanlocs=header.history(a(end)).configuration.parameters.chanlocs;
            end;
            %process
            [dipole_data,message_string]=RLW_dipfit_fit_latency(datasets(setpos).header,datasets(setpos).data,configuration.parameters.latency,chanlocs,vol,mri,'dipole_model',configuration.parameters.dipole_model,'gridsearch_resolution',configuration.parameters.gridsearch_resolution,'epoch',configuration.parameters.epoch,'index',configuration.parameters.index,'y',configuration.parameters.y,'z',configuration.parameters.z,'dipole_label',configuration.parameters.dipole_label);
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
            %store dipole_data in configuration
            configuration.parameters.dipole_list=dipole_data.dipole_list;
            configuration.parameters.topo_list=dipole_data.topo_list;
            configuration.parameters.topo_channel_labels=dipole_data.topo_channel_labels;
            configuration.parameters.elec=dipole_data.elec;
            configuration.parameters.vol=dipole_data.vol;
            configuration.parameters.mri=dipole_data.mri;
            %store out_configuration
            out_configuration=configuration;
            %add configuration to history
            if isempty(out_datasets(setpos).header.history);
                out_datasets(setpos).header.history(1).configuration=out_configuration;
            else
                out_datasets(setpos).header.history(end+1).configuration=out_configuration;
            end;
            %update header.name
            if strcmpi(configuration.gui_info.process_overwrite,'no');
                out_datasets(setpos).header.name=[configuration.gui_info.process_filename_string ' ' out_datasets(setpos).header.name];
            end;
        end;
        if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'Finished.',0,1); end;
        
        
    case 'configure'
        %configuration
        [a out_configuration]=GLW_dipfit_fit_latency('dummy',configuration,datasets);
        %datasets
        out_datasets=datasets;
end;
