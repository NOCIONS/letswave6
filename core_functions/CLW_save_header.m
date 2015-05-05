function filename=CLW_save_header(path,header)
%filename
filename=header.name;
%save header and data files
[p,n,e]=fileparts(filename);
%add path
if isempty(path);
else
    if path(end)==filesep;
        path=path(1:end-1);
    end;
    n=[path filesep n];
end;
%!!!!!!
%!!!!!!
%check header consistency
%check for duplicate events
events=header.events;
%loop through events
if length(events)>1;
    event_index=[];
    for eventpos=1:length(events);
        current_code=events(eventpos).code;
        current_latency=events(eventpos).latency;
        current_epoch=events(eventpos).epoch;
        event_list=1:length(events);
        event_list(eventpos)=[];
        for eventpos2=1:length(event_list);
            if strcmpi(events(event_list(eventpos2)).code,current_code);
                if events(event_list(eventpos2)).epoch==current_epoch;
                    if current_latency==events(event_list(eventpos2)).latency;
                        event_index(event_list(eventpos2))=0;
                    end;
                end;
            end;
        end;
    end;
    idx=find(event_index==0);
    if isempty(idx);
    else
        message_string{end+1}=['Deleting ' num2str(length(idx)) ' duplicate events.'];
        idx=find(event_index==1);
        events=events(idx);
    end;
    %check for invalid events
    idx=[];
    for eventpos=1:length(events);
        if events(eventpos).epoch<0
            idx(end+1)=eventpos;
        end;
        if events(eventpos).epoch>header.datasize(1)
            idx(end+1)=eventpos;
        end;
        if events(eventpos).latency<header.xstart
            idx(end+1)=eventpos;
        end;
        if events(eventpos).latency>header.xstart+((header.datasize(6)-1)*header.xstep)
            idx(end+1)=eventpos;
        end;
    end;
    if isempty(idx);
    else
        idx=unique(idx);
        message_string{end+1}=['Deleting ' num2str(length(idx)) ' invalid events.'];
        events(idx)=[];
    end;
    header.events=events;
end;
%!!!!!
%!!!!!
%save header
save([n '.lw6'],'-MAT','header');
%filename
filename=n;




