function [ST] = MLRd_regressors(ave,ST,Fs)
ST.regressor=[];

T_idx=ST.t_idx;
dat=ave(T_idx);
for i=1:size(ST.peak,1)
    T_peak(i)=find(ST.epoch==ST.peak(i,1))-T_idx(i)+1;    
end
t=ST.epoch(T_idx);

T_peak1=sort(T_peak,'ascend');
for i=1:length(T_peak1)
    V_peak1(i)=ST.peak(find(T_peak==T_peak1(i)),2);
end

%%
if T_peak1>=2
    for i=1:length(T_peak1)-1
        for j=T_peak1(i):T_peak1(i+1)
            if dat(j)*dat(j+1)<0
                zeropoint(i)=j;
            end
        end
    end
end

if length(T_peak1)==1
        avg=dat;
elseif length(T_peak1)==2
    avg(1,:)=dat;avg(1,zeropoint(1):end)=0;
    avg(2,:)=dat;avg(2,1:zeropoint(1))=0;
else    
    avg(1,:)=dat;avg(1,zeropoint(1):end)=0;
    avg(size(ST.peak,1),:)=dat;avg(size(ST.peak,1),1:zeropoint(end))=0;
    for i=2:size(ST.peak,1)-1    
        avg(i,:)=dat;avg(i,1:zeropoint(i-1))=0;avg(i,zeropoint(i):end)=0;     
    end
end
%% 
number_trial=round(Fs*0.05); %% the default latency jitter limit
if Fs>500
    index_=2;%% if out of memory, this number should be increased
elseif Fs<=500
    index_=1; 
end
k=1:index_/(number_trial-1):2; %% the default compression limit
for i=1:size(avg,1)
    peak=T_peak1(i);
%     data=zeros(length(k),length(dat));    
%     for j=1:length(k)
%         T(j,:)=t/k(j);
%         ur = resample(double(avg(i,:)),round(Fs/k(j)),Fs);
%         peak_point=find(abs(ur-V_peak1(i))==min(abs(ur-V_peak1(i))));%% peak point
%         if peak-peak_point<=0
%             data(j,1:length(ur))=ur; 
%         else 
%             data(j,peak-peak_point+1:peak-peak_point+length(ur))=ur;  
%         end          
%     end
%     data1=zeros(length(k),length(t)+length(k));
%     for j=1:length(k)
%         data1(j,j:length(t)+j-1)=avg(i,:);    
%     end
%     data1=data1(:,round(length(k)/2)+1:length(t)+round(length(k)/2));
%     DATA=[data;data1];

    data=zeros(length(k),length(dat));
    for j=1:length(k)
        T(j,:)=t/k(j);
        ur = resample(double(avg(i,:)),round(Fs/k(j)),Fs);
        peak_point=find(abs(ur-V_peak1(i))==min(abs(ur-V_peak1(i))));%% peak point
        if peak-peak_point<=0
            data(j,1:length(ur))=ur; 
        else
            data(j,peak-peak_point+1:peak-peak_point+length(ur))=ur;  
        end
    end
    if size(data,2)>length(dat)
        data=data(:,1:length(dat));
    end
    DATA=[];
    for j=1:length(k)
        data1=zeros(length(k),length(t)+length(k));
        for ii=1:length(k)
            data1(ii,index_*ii:length(t)+index_*ii-1)=data(j,:);    
        end
        data1=data1(:,round(length(k)/2)*index_+1:length(t)+round(length(k)/2)*index_);
        DATA=[DATA;data1];
    end
    [W,Y,val] = pca(DATA);
    for kk=1:3  ST.regressor{i}(:,kk)=real(Y(kk,:));end
    clear peak data data1 DATA Y W val;
end
