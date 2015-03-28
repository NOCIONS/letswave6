function [out_configuration,out_datasets] = LW_average_epochs_sliding(operation,configuration,datasets,update_pointers)
% LW_average_epochs_sliding
% Sliding operations
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
gui_info.function_name='LW_average_epochs_sliding';
gui_info.name='Sliding operation along dimension';
gui_info.description='Sliding operation along dimension.';
gui_info.parent='average_menu';
gui_info.scriptable='yes';                      %function can be used in scripts?
gui_info.configuration_mode='direct';           %configuration GUI run in 'direct' 'script' 'history' mode?
gui_info.configuration_requires_data='no';      %configuration requires data of the dataset?
gui_info.save_dataset='yes';                    %process requires to save dataset? 'yes', 'no', 'unique'
gui_info.process_none='no';                     %for functions which have nothing to process (e.g. visualisation functions)
gui_info.process_requires_data='yes';           %process requires data of the dataset?
gui_info.process_filename_string='slid';         %default filename suffix (or filename (if 'unique'))
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
        out_configuration.parameters.operation='average';
        out_configuration.parameters.dimension='x';
        out_configuration.parameters.width=0.2;
        %datasets
        out_datasets=datasets;
        
    case 'process'
        out_datasets=[];
        %configuration
        out_configuration=configuration;
        %handles feedback
        if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'*** Sliding average along dimension.',1,0); end;
        %datasets
        for setpos=1:length(datasets);
            %process
            [out_datasets(setpos).header,out_datasets(setpos).data,message_string]=RLW_average_epochs_sliding(datasets(setpos).header,datasets(setpos).data,'operation',configuration.parameters.operation,'dimension',configuration.parameters.dimension,'width',configuration.parameters.width);
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
            %update header.name
            if strcmpi(configuration.gui_info.process_overwrite,'no');
                out_datasets(setpos).header.name=[configuration.gui_info.process_filename_string ' ' out_datasets(setpos).header.name];
            end;
        end;
        if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'Finished.',0,1); end;
        
        
        
        
        out_datasets=[];
        %configuration
        out_configuration=configuration;
        %handles feedback
        if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'*** Sliding operation.',1,0); end;
        if isempty(update_pointers) else update_pointers.function(update_pointers.handles,['Operation : ' configuration.parameters.operation],1,0); end;
        if isempty(update_pointers) else update_pointers.function(update_pointers.handles,['Dimension : ' configuration.parameters.dimension],1,0); end;
        if isempty(update_pointers) else update_pointers.function(update_pointers.handles,['Width : ' num2str(configuration.parameters.width)],1,0); end;
        %datasets
        for setpos=1:length(datasets);
            %header
            header=datasets(setpos).header;
            %data
            data=datasets(setpos).data;
            %add configuration to history
            if isempty(header.history);
                header.history(1).configuration=configuration;
            else
                header.history(end+1).configuration=configuration;
            end;
            %out_header
            out_header=header;
            %out_data
            out_data=zeros(size(data));
            %width
            width=configuration.parameters.width;
            %binwidth
            switch configuration.parameters.dimension
                case 'x'
                    binwidth=round(width/header.xstep);
                    binwidth2=round(binwidth/2);
                case 'y'
                    binwidth=round(width/header.ystep);
                    binwidth2=round(binwidth/2);
                case 'z'
                    binwidth=round(width/header.zstep);
                    binwidth2=round(binwidth/2);
            end;     
            %loop
            switch configuration.parameters.dimension
                case 'x'
                    for dx=1:header.datasize(6);
                        dx1=dx-binwidth2;
                        dx2=dx+binwidth2;
                        if dx1<1;
                            dx1=1;
                        end;
                        if dx2>header.datasize(6);
                            dx2=header.datasize(6);
                        end;
                        switch configuration.parameters.operation
                            case 'average'
                                out_data(:,:,:,:,:,dx)=mean(data(:,:,:,:,:,dx1:dx2),6);
                            case 'stdev'
                                out_data(:,:,:,:,:,dx)=std(data(:,:,:,:,:,dx1:dx2),0,6);
                            case 'max'
                                out_data(:,:,:,:,:,dx)=max(data(:,:,:,:,:,dx1:dx2),[],6);
                            case 'min'
                                out_data(:,:,:,:,:,dx)=min(data(:,:,:,:,:,dx1:dx2),[],6);
                            case 'perc75'
                                out_data(:,:,:,:,:,dx)=prctile(data(:,:,:,:,:,dx1:dx2),75,6);
                            case 'perc25'
                                out_data(:,:,:,:,:,dx)=prctile(data(:,:,:,:,:,dx1:dx2),25,6);
                            case 'maxminmean'
                                out_data(:,:,:,:,:,dx)=(max(data(:,:,:,:,:,dx1:dx2),[],6)-mean(data(:,:,:,:,:,dx1:dx2),6)).*(mean(data(:,:,:,:,:,dx1:dx2),6)-min(data(:,:,:,:,:,dx1:dx2),[],6));
                        end;
                    end;
                case 'y'
                    for dy=1:header.datasize(5);
                        dy1=dy-binwidth2;
                        dy2=dy+binwidth2;
                        if dy1<1;
                            dy1=1;
                        end;
                        if dy2>header.datasize(5);
                            dy2=header.datasize(5);
                        end;
                        switch configuration.parameters.operation
                            case 'average'
                                out_data(:,:,:,:,dy,:)=mean(data(:,:,:,:,dy1:dy2,:),5);
                            case 'stdev'
                                out_data(:,:,:,:,dy,:)=std(data(:,:,:,:,dy1:dy2,:),0,5);
                            case 'max'
                                out_data(:,:,:,:,dy,:)=max(data(:,:,:,:,dy1:dy2,:),[],5);
                            case 'min'
                                out_data(:,:,:,:,dy,:)=min(data(:,:,:,:,dy1:dy2,:),[],5);
                            case 'perc75'
                                out_data(:,:,:,:,dy,:)=prctile(data(:,:,:,:,dy1:dy2,:),75,5);
                            case 'perc25'
                                out_data(:,:,:,:,dy,:)=prctile(data(:,:,:,:,dy1:dy2,:),25,5);
                            case 'maxminmean'
                                out_data(:,:,:,:,dy,:)=(max(data(:,:,:,:,dy1:dy2,:),[],5)-mean(data(:,:,:,:,dy1:dy2,:),5)).*(mean(data(:,:,:,:,dy1:dy2,:),5)-min(data(:,:,:,:,dy1:dy2,:),[],5));
                        end;
                    end;
                case 'z'
                    for dz=1:header.datasize(4);
                        dz1=dz-binwidth2;
                        dz2=dz+binwidth2;
                        if dz1<1;
                            dz1=1;
                        end;
                        if dz2>header.datasize(4);
                            dz2=header.datasize(4);
                        end;
                        switch configuration.parameters.operation
                            case 'average'
                                out_data(:,:,:,dz,:,:)=mean(data(:,:,:,dz1:dz2,:,:),4);
                            case 'stdev'
                                out_data(:,:,:,dz,:,:)=std(data(:,:,:,dz1:dz2,:,:),0,4);
                            case 'max'
                                out_data(:,:,:,dz,:,:)=max(data(:,:,:,dz1:dz2,:,:),[],4);
                            case 'min'
                                out_data(:,:,:,dz,:,:)=min(data(:,:,:,dz1:dz2,:,:),[],4);
                            case 'perc75'
                                out_data(:,:,:,dz,:,:)=prctile(data(:,:,:,dz1:dz2,:,:),75,4);
                            case 'perc25'
                                out_data(:,:,:,dz,:,:)=prctile(data(:,:,:,dz1:dz2,:,:),25,4);
                            case 'maxminmean'
                                out_data(:,:,:,dz,:,:)=(max(data(:,:,:,dz1:dz2,:,:),[],4)-mean(data(:,:,:,dz1:dz2,:,:),4)).*(mean(data(:,:,:,dz1:dz2,:,:),4)-min(data(:,:,:,dz1:dz2,:,:),[],4));
                        end;
                    end;
            end;
            %out_datasets
            out_datasets(setpos).header=out_header;
            out_datasets(setpos).data=out_data;
        end;
        if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'*** Finished!.',0,1); end;
        
    case 'configure'
        %configuration
        [a out_configuration]=GLW_average_epochs_sliding('dummy',configuration,datasets);
        %datasets
        out_datasets=datasets;
end;
