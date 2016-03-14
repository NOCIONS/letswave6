function csd_maker_no(data,adrate,time,muavg,fname,timerange,artrange,caxset,sweepno)

% data - averaged data, ch x timepoints
% adrate 
% time - time vector
% muavg - 1 if csd, 0 if mua
% fname - filename
% timerange - [-30 100] the time to display
% artrange - [-2 5] sets datapoints to baseline in this range
% caxset - specify [0 0] if autoscale, otherwise it does not

% if caxset is [0 0] then the scale is automatic
% example: csd_maker(1,'c:/xxx.avg',[-50 200],[0 0])


factor=1;

ti(1)=max(find(time<=timerange(1)));
ti(2)=max(find(time<=timerange(2)));

if isempty(artrange)
    artrange = [0 0];
end

if isempty(caxset)
    caxset = [0 0];
end
  

if artrange~=[0 0]
    ar(1)=max(find(time<=artrange(1)));
    ar(2)=max(find(time<=artrange(2)));
    artremove=mean(data(:,max(find(time<=-25)):max(find(time<=-4))),2);
    for i=ar(1):ar(2)
        data(:,i)=artremove;
    end
end
    
num_of_points=size(data,2);
xi=1:1:num_of_points*factor;
x=1:num_of_points*factor/num_of_points:num_of_points*factor;

for i=1:size(data,1)
    yi(i,:) = interp1(x,squeeze(data(i,:)),xi);
end
clear data
num_of_points=(2000*factor/adrate)*num_of_points;
adrate=2000*factor;

csd=yi(:,ti(1):ti(2));


GRID_SCALE2         = 500;
SHADING             = 'flat';
opengl 'neverselect';
x                   = zeros(1,size(csd,1));
y                   = linspace(0.5,-0.5,size(csd,1));
Xmapsize            = 1; 
Ymapsize            = 1;
rmax                = 0.5;
xmin        = min(-.5*Xmapsize,min(x)); xmax = max(0.5*Xmapsize,max(x));
ymin        = min(-.5*Ymapsize,min(y)); ymax = max(0.5*Ymapsize,max(y));

[x,y]       = meshgrid(linspace(xmin,xmax,size(csd,2)),y);
[Xi,Yi]     = meshgrid(linspace(xmin,xmax,size(csd,2)),linspace(ymax,ymin,GRID_SCALE2));

Zi          = interp2(x,y,csd,Xi,Yi,'cubic');
delta = Xi(2)-Xi(1);

fig_csd=figure('Tag', 'fig_csd','Name', [fname], 'NumberTitle', 'off','Color', [1,1,1]); 
set(gcf,'InvertHardcopy','off')
set(fig_csd,'DoubleBuffer','on');

colorbar

axpos   =  get(gca,'Position');
set(gca,'XColor','r','YColor','r','Visible','off');
set(gca,'Xlim',[-rmax*1*Xmapsize rmax*1*Xmapsize],'Ylim',[-rmax*1*Ymapsize  rmax*1*Ymapsize]);
hold on



handles.map = surface(Xi-delta/2,Yi-delta/2,zeros(size(Zi)),Zi,'EdgeColor','none','FaceColor',SHADING);

colormap(jet);
% set(gca,'YDir', 'reverse')
if abs(min(min(csd)))>max(max(csd))
    caxis([min(min(csd))*0.8 abs(min(min(csd)))*0.8])
else
    caxis([-max(max(csd))*0.8 max(max(csd))*0.8])    
end



if caxset==[0 0] 
else caxis(caxset)
end

% caxis
% colorbar
cmap=colormap;
if muavg==1
    cmap=flipud(cmap);
else
    if caxset==[0 0] 
        caxis([min(min(csd))*0.8 max(max(csd))*0.8]);
    else caxis(caxset)
    end   
end
colormap(cmap);
colorbar;
set(gca,'Position',axpos)
handles.mapax = axes( 'Position',axpos,...
        'Color','none',...
        'XColor','k','YColor','k',...
        'XLim', [time(ti(1)) time(ti(2))], 'YLim',[1 size(csd,1)],...
        'Ytick',[1:1:size(csd,1)],'YDir', 'reverse',...
        'Fontsize',6);

 % 'Xtick',[0 624.5 624.5*2 624.5*3],...    
% handles.mapax = axes( 'Position',axpos,...
%         'Color','none',...
%         'XColor','k','YColor','k',...
%         'XLim', [time(1) time(end)], 'YLim',[2 size(csd,1)+1],...
%         'Ytick',[2:size(csd,1)+1],...
%         'Fontsize',10);

hold on        
xlabel('time (ms)','Fontsize',10)
ylabel('electrodes','Fontsize',10)
title([fname '  -  ' num2str(sweepno) ' sweeps'],'Fontsize',12,'Interpreter','none')
