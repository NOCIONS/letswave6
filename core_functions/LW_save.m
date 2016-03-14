function filename=LW_save(filename,prefix,header,data)
%filename
[p,n,e]=fileparts(filename);
%prefix
if isempty(prefix);
else
    n=[prefix ' ' n];
end;
%header.name
header.name=n;
%check header consistency
%check for duplicate events
if isfield(header,'events');
    events=header.events;
    %loop through events
    if length(events)>1;
        event_index=ones(size(events));
        for eventpos=2:length(events);
            current_code=events(eventpos).code;
            current_latency=events(eventpos).latency;
            current_epoch=events(eventpos).epoch;
            event_list=1:eventpos-1;
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
            disp(['Deleting ' num2str(length(idx)) ' duplicate events.']);
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
            disp(['Deleting ' num2str(length(idx)) ' invalid events.']);
            events(idx)=[];
        end;
        header.events=events;
    end;
else
    header.events=[];
end;

%save header
save([p filesep n '.lw6'],'-MAT','header');
%save data
data=single(data);
save([p filesep n '.mat'],'-MAT','-v7.3','data');
%filename
filename=n;



