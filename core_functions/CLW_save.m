function filename=CLW_save(path,header,data)
%filename
filename=header.name;
%save header and data files
[p,n,e]=fileparts(filename);
%if strcmpi(e,'.lw6');
%else
%    n=filename;
%end;
%if strcmpi(e,'.mat');
%else
%    n=filename;
%end;

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
%check for duplicate events
if isfield(header,'events');
    events=header.events;
    
    event_num=length(events);
    if event_num~=0
        event_latency=[events.latency];
        [~,event_index]=sort(event_latency);
        event_banned=[];
        for eventpos=1:event_num
            if  ismember(eventpos,event_banned)
                continue;
            end
            current_code=events(event_index(eventpos)).code;
            current_latency=events(event_index(eventpos)).latency;
            current_epoch=events(event_index(eventpos)).epoch;
            for eventpos2=eventpos+1:event_num
                if strcmpi(events(event_index(eventpos2)).code,current_code) &&...
                        (events(event_index(eventpos2)).epoch==current_epoch) &&...
                        (current_latency==events(event_index(eventpos2)).latency)
                    event_banned=[event_banned,eventpos2];
                else
                    break;
                end
            end
        end
        event_banned=event_index(event_banned);
        event_banned=[event_banned,find([events.epoch]<0)];
        event_banned=[event_banned,find([events.epoch]>header.datasize(1))];
        event_banned=[event_banned,find([events.latency]<header.xstart)];
        event_banned=[event_banned,find([events.latency]>header.xstart+(header.datasize(6)-1)*header.xstep)];
        event_banned=unique(event_banned);
        disp(['Deleting ' num2str(length(event_banned)) ' invalid events.']);
        header.events=events(setdiff(1:event_num,event_banned));
    end
    
    %     %loop through events
    %     if length(events)>1;
    %         event_index=ones(size(events));
    %         for eventpos=2:length(events);
    %             current_code=events(eventpos).code;
    %             current_latency=events(eventpos).latency;
    %             current_epoch=events(eventpos).epoch;
    %             event_list=1:eventpos-1;
    %             for eventpos2=1:length(event_list);
    %                 if strcmpi(events(event_list(eventpos2)).code,current_code);
    %                     if events(event_list(eventpos2)).epoch==current_epoch;
    %                         if current_latency==events(event_list(eventpos2)).latency;
    %                             event_index(event_list(eventpos2))=0;
    %                         end;
    %                     end;
    %                 end;
    %             end;
    %         end;
    %         idx=find(event_index==0);
    %         if isempty(idx);
    %         else
    %             disp(['Deleting ' num2str(length(idx)) ' duplicate events.']);
    %             idx=find(event_index==1);
    %             events=events(idx);
    %         end;
    %         %check for invalid events
    %         idx=[];
    %         for eventpos=1:length(events);
    %             if events(eventpos).epoch<0
    %                 idx(end+1)=eventpos;
    %             end;
    %             if events(eventpos).epoch>header.datasize(1)
    %                 idx(end+1)=eventpos;
    %             end;
    %             if events(eventpos).latency<header.xstart
    %                 idx(end+1)=eventpos;
    %             end;
    %             if events(eventpos).latency>header.xstart+((header.datasize(6)-1)*header.xstep)
    %                 idx(end+1)=eventpos;
    %             end;
    %         end;
    %         if isempty(idx);
    %         else
    %             idx=unique(idx);
    %             disp(['Deleting ' num2str(length(idx)) ' invalid events.']);
    %             events(idx)=[];
    %         end;
    %         header.events=events;
    %     end;
else
    header.events=[];
end
%!!!!!
%!!!!!
%save header
save([n '.lw6'],'-MAT','header');
%save data
data=single(data);
save([n '.mat'],'-MAT','-v7.3','data');
%filename
filename=n;



