function filename=CLW_save(filename,suffix,header,data)
%save header and data files
[p,n,e]=fileparts(filename);
if isempty(suffix);
    if isempty(p);
        st=[n,'.lw6'];
        header.name=[n];
    else
        st=[p,filesep,n,'.lw6'];
        header.name=[n];
    end;
else
    if isempty(p);
        st=[suffix,' ',n,'.lw6'];
        header.name=[suffix,' ',n];
    else
        st=[p,filesep,suffix,' ',n,'.lw6'];
        header.name=[suffix,' ',n];
    end;
end;
%save header
save(st,'-MAT','header');
%save data
if isempty(suffix);
    st=[p,filesep,n,'.mat'];
else
    st=[p,filesep,suffix,' ',n,'.mat'];
end;
data=single(data);
%data=double(data);
save(st,'-MAT','-v7.3','data');
%filename
filename=[p,filesep,suffix,' ',n];
    end



