function h=LW_headplot(header,data,epoch,index,x,y,z,varargin)
%LW_headplot
%h=LW_headplot(header,data,epoch,index,x,y,z,varargin)



%fetch data to display
vector=squeeze(data(epoch,:,index,z,y,x));
%parse data and chanlocs according to topo_enabled
k=1;
for chanpos=1:size(header.chanlocs,2);
    if header.chanlocs(chanpos).topo_enabled==1
        vector2(k)=vector(chanpos);
        chanlocs2(k)=header.chanlocs(chanpos);
        k=k+1;
    end;
end;

%headplot
%h=topoplot(vector2,chanlocs2,varargin{:});
%headplot(values,'spline_file','Param','Value',...)
%splinefile
st='LW_headmodel_compute';
for i=1:length(header.history);
    if strcmpi(st,header.history(i).configuration.gui_info.function_name);
        splinefile=header.history(i).configuration.parameters.spl_filename;
    end;
end;
if isempty(splinefile);
    disp('SPL file not found. Run the Build spline file function to display headplots');
    return;
end;

h=headplot(vector2,splinefile,varargin{:});
    



