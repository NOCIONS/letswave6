clc;clear;close all;
file_src='';

for intensity=1%1:2
    for time_index=1%1:2
        str='minus minus HFS';
        if intensity==1
            str=[str,' 64'];
        else
            str=[str,' 90'];
        end
        if time_index==1
            str=[str,' T1'];
        else
            str=[str,' T2'];
        end
        
        clc;disp(str);
        [header,data] = CLW_load([file_src,str]);
        
        fieldname=fieldnames(header.chanlocs(1));
        if length(fieldname)<4
            chanlocs=readlocs('Standard-10-20-Cap81.locs');
            [header,~]=RLW_edit_electrodes(header,chanlocs);
        end
        

        [header,data,~,~]=RLW_channel_ttest_constant(header,data,'xstart',0.37,'xend',1.6,'threshold',0.42,'permutation',1,'num_permutations',250); %0.56 %
        header.name=['ch_ttest',header.name];
        CLW_save(file_src,header,data);
        
        figure()
        hold on;axis off;
        for ch_1=1:size(data,2)
            if(header.chanlocs(ch_1).topo_enabled)==1
                if data(1,ch_1,3,1,1,1,1)<0.05
                plot(header.chanlocs(ch_1).radius*sin(header.chanlocs(ch_1).theta/180*pi),header.chanlocs(ch_1).radius*cos(header.chanlocs(ch_1).theta/180*pi),'r*');
                else
                plot(header.chanlocs(ch_1).radius*sin(header.chanlocs(ch_1).theta/180*pi),header.chanlocs(ch_1).radius*cos(header.chanlocs(ch_1).theta/180*pi),'k.');
                end
                %text(header.chanlocs(ch_1).radius*sin(header.chanlocs(ch_1).theta/180*pi),header.chanlocs(ch_1).radius*cos(header.chanlocs(ch_1).theta/180*pi),header.chanlocs(ch_1).labels);
            end
        end
    end
end


