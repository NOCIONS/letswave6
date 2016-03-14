 % this calculates the csds in a directory and makes weathermaps
% example: dircsd ('c:/Noelle1/data/s106107/')

function dircsd03 (directory,filenames)

%Our raw datafiles are band pass filtered to extract field potential [0 300
%hz],our eeg data file consists of 23 channels , n epochs, ntime points
%see the example I sent you , 75 trials, -100 to 500 msecs length epochs
%2KHZ sampling

if isempty(filenames)
    filenames=[];
    f=dir( [ directory '*@e*.mat']); % populate the list of the files that are concerned in the folder defined when typing the command dircsd03(directory)
    for i=1:1:size(f,1)
        ff=f(i).name;
        filenames{i}=ff;
    end
end


for ii=1:size(filenames,2)
    load( [directory filenames{ii}])
    
    % filtering the eeg to adapt to your needs
    
    
        n = 2;
        Wn = [.25 200]/(adrate/2);
        [b,a] = butter(n,Wn);
        for i=1:size(eeg,1)
            for iii=1:size(eeg,2)
                eeg(i,iii,:)=filtfilt(b,a,eeg(i,iii,:));
            end
        end
        n = 2;
        Wn = [0.5]/(adrate/2);
        [b,a] = butter(n,Wn,'high');
        for i=1:size(eeg,1)
            for iii=1:size(eeg,2)
                eeg(i,iii,:)=filtfilt(b,a,eeg(i,iii,:));
            end
        end
    
    % Creating the CSD 
    if size(eeg,1)>3
    
        csd=zeros(size(eeg,1)-2,size(eeg,2),size(eeg,3));
        for i=2:size(eeg,1)-1
            csd(i-1,:,:)=-1.*eeg(i-1,:,:)+-1.*eeg(i+1,:,:)+2.*eeg(i,:,:);
        end
        clear eeg
        eeg=csd;
        clear csd
        x=filenames{ii};
        for i=1:size(x,2)-1
            if strcmp(x(i:i+1),'@e')
                x(i:i+1)='@c';
            end
        end
        filenames{ii}=x;
        save([directory filenames{ii}],'time','adrate','eeg','ttype','trig','eventfile','triglength', 'chansets', 'chansubset', 'espace', 'oldnew', 'remarks', 'otherdata','trigchan','voltagethreshold','paradigm','-mat')
    
        
        % 60 Hz filter
    wo = 60/(adrate/2);  bw = wo/50;
    [b,a] = iirnotch(wo,bw);
    for i=1:size(eeg,1)
        for iii=1:size(eeg,2)
            eeg(i,iii,:)=filtfilt(b,a,squeeze(eeg(i,iii,:)));
        end
    end
 

        % baseline before image
        for i=1:size(eeg,1)
            for iii=1:size(eeg,2)
                eeg(i,iii,:)=squeeze(eeg(i,iii,:))-squeeze(mean(eeg(i,iii,max(find(time<=-29)):max(find(time<=-2))),3));
            end
        end

   %%%%%%%%%%%%%%

        a=0; trigtype=[]; % will make a  different csd for every type of trigger you may have in your list of triggers
        for i=1:256
            z=find(ttype==i);
            if ~isempty(z)
                a=a+1;
                trigtype(a)=i;
            end
        end

        for i=1:length(trigtype)
            z=find(ttype==trigtype(i));
            sweepno=length(z);
            csd_maker_no(squeeze(mean(eeg(:,z,:),2)),adrate,time,1,[filenames{ii}(1:end-4) '_' num2str(trigtype(i),'%02.0f') ],[-50 450],[0 0],[0 0],sweepno) % Here define the time range here -50 to 450 msecs as well as the scale for the csd figure, by default 0 will do for automatic scaling 
            print ('-djpeg', '-r300', [directory 'csd_' filenames{ii}(1:end-4) '_' num2str(trigtype(i),'%02.0f') '.jpg']);
        end
        close all
        clear eeg
    end
end