function [ST] = peak_measure(signal,ST,Fs)

T=ST.t_idx;
dat=signal(:,T)';
for i=1:size(ST.peak,1)
    T_peak(i)=find(ST.epoch==ST.peak(i,1))-T(i)+1;    
end
t=ST.epoch(T);

for i=1:length(ST.regressor)
    Reg(:,size(ST.regressor{i},2)*(i-1)+1:size(ST.regressor{i},2)*i)=ST.regressor{i}(:,1:size(ST.regressor{i},2));
end
Reg(:,end+1)=ones;

for i=1:size(dat,2)                                                         
    Coeffs(i,:)=(regress(dat(:,i),Reg))';         
end
ST.Coeffs=Coeffs;
nfunc=size(Reg,2);
ntrials=size(dat,2);
%Multiply design matrix y by parameters b for each epoch
for i=1:nfunc          
    for j=1:ntrials             
        fmult(:,i,j)=Coeffs(j,i).*Reg(:,i);
    end
end

%sum up the contributions         
Fits=squeeze(sum(fmult,2));

T_peak1=sort(T_peak,'ascend');
for i=1:length(T_peak1)
    V_peak1(i)=ST.peak(find(T_peak==T_peak1(i)),2);
end


for i=1:size(Fits,2)
    [tmax tmin vmax vmin]=extreme_point(Fits(:,i)');
    for ii=1:length(V_peak1)
        Duration=round(Fs*ST.peak_interval(ii));
        plim1=max([1 round(T_peak1(ii)-Duration/2)]);
        plim2=min([size(Fits,1)-1 round(T_peak1(ii)+Duration/2)]);
        Pmax=[tmax(intersect(find(tmax>=plim1),find(tmax<=plim2)));vmax(intersect(find(tmax>=plim1),find(tmax<=plim2)))];
        Pmin=[tmin(intersect(find(tmin>=plim1),find(tmin<=plim2)));vmin(intersect(find(tmin>=plim1),find(tmin<=plim2)))];
        Fit(i,:)=sum(fmult(:,size(ST.regressor{ii},2)*(ii-1)+1:size(ST.regressor{ii},2)*ii,i),2);
        temp=corrcoef(mean(dat,2),Fit(i,:));
        if V_peak1(ii)<=0
            if temp(1,2)>0
                if length(Pmin)>0
                    Ppeak=min(Pmin(2,:));lat=t(find(Fits(:,i)==Ppeak));
                elseif length(Pmin)==0
                    if length(Pmax)==0
                        Ppeak=NaN;lat=NaN;
                    else
                        Ppeak=max(Pmax(2,:));lat=t(find(Fits(:,i)==Ppeak));
                    end
                end

            %% part 2    
            elseif temp(1,2)<0
                if length(Pmax)>0
                    Ppeak=max(Pmax(2,:));lat=t(find(Fits(:,i)==Ppeak));
                elseif length(Pmax)==0
                    if length(Pmin)==0
                        Ppeak=NaN;lat=NaN;
                    else
                        Ppeak=min(Pmin(2,:));lat=t(find(Fits(:,i)==Ppeak));
                    end
                end
            end            
        elseif V_peak1(ii)>0
            if temp(1,2)>0
                if length(Pmax)>0
                    Ppeak=max(Pmax(2,:));lat=t(find(Fits(:,i)==Ppeak));
                elseif length(Pmax)==0
                    if length(Pmin)==0
                        Ppeak=NaN;lat=NaN;
                    else
                        Ppeak=min(Pmin(2,:));lat=t(find(Fits(:,i)==Ppeak));
                    end
                end
            %% part 2    
            elseif temp(1,2)<0
                if length(Pmin)>0
                    Ppeak=min(Pmin(2,:));lat=t(find(Fits(:,i)==Ppeak));
                elseif length(Pmin)==0
                    if length(Pmax)==0
                        Ppeak=NaN;lat=NaN;
                    else
                        Ppeak=max(Pmax(2,:));lat=t(find(Fits(:,i)==Ppeak));
                    end
                end
            end
        end
      ST.amplitude(i,ii)=Ppeak;  
      ST.latency(i,ii)=lat;
    end    
end



