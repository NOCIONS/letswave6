function [out_configuration,out_datasets] = LW_timecourse_FT(operation,configuration,datasets,update_pointers)
% LW_timecourse_FT
% get the time course Fourier transformed response for certain frequency points
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
gui_info.function_name='LW_timecourse_FT';
gui_info.name='timecourse_FT';
gui_info.description='get the time course response for certain frequency points';
gui_info.parent='frequency_transforms_menu';
gui_info.scriptable='yes';                      %function can be used in scripts?
gui_info.configuration_mode='direct';           %configuration GUI run in 'direct' 'script' 'history' mode?
gui_info.configuration_requires_data='no';      %configuration requires data of the dataset?
gui_info.save_dataset='yes';                    %process requires to save dataset? 'yes', 'no', 'unique'
gui_info.process_none='no';                     %for functions which have nothing to process (e.g. visualisation functions)
gui_info.process_requires_data='yes';           %process requires data of the dataset?
gui_info.process_filename_string='ft';          %default filename suffix (or filename (if 'unique'))
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
        out_configuration.parameters.fre=10;            %the frequency point(Hz)
        out_configuration.parameters.harmonic=1;        %1=only the basic frequency point, 2=including the harmonic frequency, 3=including the second harmonic frequency 
        out_configuration.parameters.windowsize=1;      %width of the window (in s)
        out_configuration.parameters.windowstep=0.2;    %step of the window (in s)
        %datasets
        out_datasets=datasets;
        
    case 'process'
        out_datasets=[];
        %handles feedback
        if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'*** timecourse_FT.',1,0); end;
        %datasets
        for setpos=1:length(datasets);
            %process
            [out_datasets(setpos).header,out_datasets(setpos).data,message_string]=...
                RLW_timecourse_FT(datasets(setpos).header,datasets(setpos).data,...
                'fre',configuration.parameters.fre,'harmonic',configuration.parameters.harmonic,...
                'windowsize',configuration.parameters.windowsize,'windowstep',configuration.parameters.windowstep);
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
            %add configuration to history
            if isempty(out_datasets(setpos).header.history);
                out_datasets(setpos).header.history(1).configuration=configuration;
            else
                out_datasets(setpos).header.history(end+1).configuration=configuration;
            end;
            %out_configuration
            out_configuration=configuration;
            %update header.name
            if strcmpi(configuration.gui_info.process_overwrite,'no');
                out_datasets(setpos).header.name=[configuration.gui_info.process_filename_string ' ' out_datasets(setpos).header.name];
            end;
        end;
        if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'Finished.',0,1); end;

        
    case 'configure'
        %configuration
        [a out_configuration]=GLW_timecourse_FT('dummy',configuration,datasets);
        %datasets
        out_datasets=datasets;
end;
