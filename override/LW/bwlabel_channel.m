function y=bwlabel_channel(t_value, connection)
h=(1:length(t_value))'.*((t_value>0)-(t_value<0)).*diag(connection);
for ch_1=1:length(t_value)
    for ch_2=ch_1+1:length(t_value)
        if( connection(ch_1,ch_2)==1 && h(ch_1)*h(ch_2)>0)
            h([find(h==h(ch_1));find(h==h(ch_2))])=min(h(ch_1),h(ch_2));
        end
    end
end
b=setdiff(unique(h),0);
y=zeros(length(h),1);
for k=1:length(b)
    y(h==b(k))=k;
end