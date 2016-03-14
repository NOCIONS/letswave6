function [out_header,out_data,message_string]=RLW_merge_channels(datasets,merge_idx);
%RLW_merge_channels
%
%Merge channels
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

%init message_string
message_string={};
message_string{end+1}='Merge channels';

%check merge_idx
if isempty(merge_idx);
    message_string{end+1}='No files to merge. Exit.';
    return;
end;

%merge_idx(1) > out_data & out_header
out_data=datasets(merge_idx(1)).data;
out_header=datasets(merge_idx(1)).header;

%check epochdata
if isfield(out_header,'epochdata');
    if isempty(out_header.epochdata);
    else
        if isfield(out_header.epochdata(1),'data');
            message_string{end+1}='Epoch data found in the dataset. Merged file will only contain epoch data of the first dataset.';
        end;
    end;
end;

%check events
if isfield(out_header,'events');
else
    out_header.events=[];
end;

%loop through merge_idx
if length(merge_idx)>1;
    for merge_pos=2:length(merge_idx);

        %check sizes
        if (out_header.datasize([1 3:6])==datasets(merge_idx(merge_pos)).header.datasize([1 3:6]));
        else
            message_string{end+1}='Datasets cannot be merged as their sizes do not match. Exit.';
            return;
        end;

        %merge data
        out_data=cat(2,out_data,datasets(merge_idx(merge_pos)).data);

        %number of channels
        num_channels=size(out_data,2);

        %header
        header=datasets(merge_idx(merge_pos)).header;

        %make sure chanlocs have matching fields
        tp.labels='';
        tp.topo_enabled=0;
        tp.theta=[];
        tp.radius=[];
        tp.sph_theta=[];
        tp.sph_phi=[];
        tp.sph_theta_besa=[];
        tp.sph_phi_besa=[];
        tp.X=[];
        tp.Y=[];
        tp.Z=[];
        tp.SEEG_enabled=[];
        for i=1:length(out_header.chanlocs);
            tp2=out_header.chanlocs(i);
            tp3=tp;
            if isfield(tp2,'topo_enabled');
                tp3.topo_enabled=tp2.topo_enabled;
            end;
            if isfield(tp2,'theta');
                tp3.theta=tp2.theta;
            end;
            if isfield(tp2,'radius');
                tp3.radius=tp2.radius;
            end;
            if isfield(tp2,'sph_theta');
                tp3.sph_theta=tp2.sph_theta;
            end;
            if isfield(tp2,'sph_phi');
                tp3.sph_phi=tp2.sph_phi;
            end;
            if isfield(tp2,'sph_theta_besa');
                tp3.sph_theta_besa=tp2.sph_theta_besa;
            end;
            if isfield(tp2,'sph_phi_besa');
                tp3.sph_phi_besa=tp2.sph_phi_besa;
            end;
            if isfield(tp2,'X');
                tp3.X=tp2.X;
            end;
            if isfield(tp2,'Y');
                tp3.Y=tp2.Y;
            end;
            if isfield(tp2,'Z');
                tp3.Z=tp2.Z;
            end;
            if isfield(tp2,'SEEG_enabled');
                tp3.SEEG_enabled=tp2.SEEG_enabled;
            end;
            out_header.chanlocs(i)=tp3;
        end;
        for i=1:length(header.chanlocs);
            tp2=header.chanlocs(i);
            tp3=tp;
            if isfield(tp2,'topo_enabled');
                tp3.topo_enabled=tp2.topo_enabled;
            end;
            if isfield(tp2,'theta');
                tp3.theta=tp2.theta;
            end;
            if isfield(tp2,'radius');
                tp3.radius=tp2.radius;
            end;
            if isfield(tp2,'sph_theta');
                tp3.sph_theta=tp2.sph_theta;
            end;
            if isfield(tp2,'sph_phi');
                tp3.sph_phi=tp2.sph_phi;
            end;
            if isfield(tp2,'sph_theta_besa');
                tp3.sph_theta_besa=tp2.sph_theta_besa;
            end;
            if isfield(tp2,'sph_phi_besa');
                tp3.sph_phi_besa=tp2.sph_phi_besa;
            end;
            if isfield(tp2,'X');
                tp3.X=tp2.X;
            end;
            if isfield(tp2,'Y');
                tp3.Y=tp2.Y;
            end;
            if isfield(tp2,'Z');
                tp3.Z=tp2.Z;
            end;
            if isfield(tp2,'SEEG_enabled');
                tp3.SEEG_enabled=tp2.SEEG_enabled;
            end;
            header.chanlocs(i)=tp3;
        end;

        out_header.chanlocs=[out_header.chanlocs header.chanlocs];

        %events
        if isfield(header,'events');
            if isempty(header.events);
            else
                message_string{end+1}='Merging events.';
                out_header.events=[out_header.events header.events];
            end;
        end;
    end;
end;

%clear out_header.history
out_header.history=[];

%change number of channels
out_header.datasize=size(out_data);

%delete duplicate events
if isfield(out_header,'events');
    if isempty(out_header.events);
    else
        message_string{end+1}='Deleting duplicate events.';
        events=out_header.events;
        if length(events)>1;
            %loop through events
            eventindex=ones(length(events));
            for eventpos=1:length(events)-1;
                for eventpos2=eventpos+1:length(events);
                    if isequal(events(eventpos),events(eventpos2));
                        eventindex(eventpos2)=0;
                    end;
                end;
            end;
            events(find(eventindex==0))=[];
            out_header.events=events;
        end;
    end;
end;
