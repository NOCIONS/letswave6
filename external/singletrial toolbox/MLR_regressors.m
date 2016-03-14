function [ST] = MLR_regressors(ave,ST)

ST.regressor=[];
T=ST.t_idx;
dat=ave(T);
for i=1:size(ST.peak,1)
    T_peak(i)=find(ST.epoch==ST.peak(i,1))-T(i)+1;    
end
t=ST.epoch(T);

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
% Fs=EEG.srate;
% number_trial=round(Fs*0.1);
% k=1:1/(number_trial-1):2;
for i=1:size(avg,1)
    temp=conv(avg(i,:),LW_gauss(2,10,1));
    d1=diff(temp);
    if V_peak1(i)>0
        smmax=max(temp);
        oldmax=find(smmax==temp);
        smmax=max(d1);
        newmax=find(smmax==d1);
        diff1=newmax-oldmax;
    elseif V_peak1(i)<0
        smmin=min(temp);
        oldmin=find(smmin==temp);
        smmin=min(d1);
        newmin=find(smmin==d1);
        diff1=newmin-oldmin;
    end
    if diff1>=0 && diff1<=10
    else
        diff1=5;
    end
    ST.regressor{i}(:,1)=temp(diff1+1:diff1+size(avg,2));
    ST.regressor{i}(:,2)=d1(diff1+1:diff1+size(avg,2));
end


