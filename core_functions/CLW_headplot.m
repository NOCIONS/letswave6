function h=CLW_headplot(vector,header,varargin)
maplimits=[];
if isempty(varargin);
else
    %mother_name
    a=find(strcmpi(varargin,'maplimits'));
    if ~isempty(a)
        maplimits=varargin{a+1};
    end
end
chanlocs=[];
locs=[];
evalc('locs=readlocs(''Standard-10-20-Cap81.locs'')');
chanpos=1;
for locpos=1:length(locs);
    if isempty(locs(locpos).X);
    else
        chanlocs(chanpos).labels=locs(locpos).labels;
        chanlocs(chanpos).theta=locs(locpos).theta;
        chanlocs(chanpos).radius=locs(locpos).radius;
        chanlocs(chanpos).sph_theta=locs(locpos).sph_theta;
        chanlocs(chanpos).sph_phi=locs(locpos).sph_phi;
        chanlocs(chanpos).sph_theta_besa=locs(locpos).sph_theta_besa;
        chanlocs(chanpos).sph_phi_besa=locs(locpos).sph_phi_besa;
        chanlocs(chanpos).X=locs(locpos).X;
        chanlocs(chanpos).Y=locs(locpos).Y;
        chanlocs(chanpos).Z=locs(locpos).Z;
        chanlocs(chanpos).topo_enabled=1;
        chanlocs(chanpos).SEEG_enabled=0;
        chanpos=chanpos+1;
    end
end
chan_used=find([header.chanlocs.topo_enabled]==1, 1);
if isempty(chan_used)
    header=RLW_edit_electrodes(header,userdata.chanlocs);
end
load('headmodel.mat');
header=CLW_make_spl(header);
if length(vector)~=length(header.spl.indices)
    error('problem of index or electrode number with splinefile');
end
axis('image');
light('Position',[-125  125  80],'Style','infinite')
light('Position',[125  125  80],'Style','infinite')
light('Position',[125 -125 80],'Style','infinite')
light('Position',[-125 -125 80],'Style','infinite')
lighting phong;
meanval = mean(vector); vector = vector - meanval;
P=header.spl.GG * [vector(:);0]+meanval;
if size(maplimits)~=[1,2]
    amax = max(-min(min(abs(P))),max(max(abs(P))))*1.02; % 2% shrinkage keeps within color bounds
    maplimits=[-amax,amax];
end
caxis(maplimits);
surface_headplot= patch('Vertices',POS,'Faces',TRI,...
    'FaceVertexCdata',P,'FaceColor','interp','EdgeColor','none',...
    'DiffuseStrength',.6,'SpecularStrength',0,'AmbientStrength',.3,...
    'SpecularExponent',5,'vertexnormals', NORM);
axis([-125 125 -125 125 -125 125]);
view([0 90]);
dot_headplot=line(1,1,1,'Color',[0,0,0],'Linestyle','none','Marker','.','Markersize',10);
set( dot_headplot,'XData',header.spl.newElect(:,1));
set( dot_headplot,'YData',header.spl.newElect(:,2));
set( dot_headplot,'ZData',header.spl.newElect(:,3));

colormap(jet(512));
colorbar_headplot=colorbar;
axis off;