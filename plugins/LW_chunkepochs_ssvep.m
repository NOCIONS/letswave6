function [outheader,outdata] = LW_chunkepochs_ssvep(header,data,offset,epochlength,epochstep,numchunks,NbChunks2Remove, baselineOffset);
% Segment epochs relative to events
%
% Inputs
% - header (LW5 header)
% - data (LW5 data)
% - offset : offset (units) for the first chunk
% - epochlength : length of epochs (units)
% - epochstep : step of epochs (units), can be equal to epochlength
% - numchunks : number of chunked epochs: value or 'max'
%
% Outputs
% - outheader (LW5 header)
% - outdata (LW5 data)
%
% Dependencies : none.
%
% Author : 
% André Mouraux
% Institute of Neurosciences (IONS)
% Université catholique de louvain (UCL)
% Belgium
% 
% Function Modified by Corentin Jacques (UCL) to fix a bug and add the
% <NbChunks2Remove> variable.
% todo: the event data is incorrect after chunking -> fix it. 
% 
% Contact : andre.mouraux@uclouvain.be
% This function is part of Letswave 5
% See http://nocions.webnode.com/letswave for additional information

%transfer header>outheader
outheader=header;

%offset in bins
dx_offset=round(((offset-header.xstart)/header.xstep)+1);


%Currently there is a small problem with the way the chuncking is
%performed. This is due to the length of the chuncks beeing rounded to fit
%with sampling rate so that never 'exactly' corresponds to the user input
%length. This result in an small rounding error being added to each
%succesive chunck, which is a problem when there is a large number of
%chuncks. 
% what we need to do is determine before rounding the start and end
% position of each chunk and then round. Of course each chunck should have
% the same size.


%epochlength in bins
%  dx_epochlength=round(epochlength/header.xstep);
% Let's round later for each chunck separately to avoid an accumulation of
% rounding errors.
 dx_epochlength = epochlength/header.xstep;

%epochstep in bins
%  dx_epochstep=round(epochstep/header.xstep);
% Let's round later for each chunck separately to avoid an accumulation of
% rounding errors.
 dx_epochstep = epochstep/header.xstep;

%numchunks
if isnumeric(numchunks);
else
    if strcmpi(numchunks,'max');
        disp('Extracting maximum number of chunks');
        numchunks=floor((header.datasize(6)-(dx_offset-1)-dx_epochlength)/dx_epochstep);        
    end;
end;

%adjust outheader.datasize
outheader.datasize(1) = header.datasize(1)*numchunks;
outheader.datasize(6) = round(dx_epochlength);

%prepare outdata
outdata=zeros(outheader.datasize);

%disp
disp(['Offset (bins) : ' num2str(offset) ' (' num2str(dx_offset) ')']);
disp(['Epoch length (bins) : ' num2str(epochlength) ' (' num2str(round(dx_epochlength)) ')']);
disp(['Epoch step (bins) : ' num2str(epochstep) ' (' num2str(round(dx_epochstep)) ')']);
disp(['Number of chunks : ' num2str(numchunks)]);

%remove events from outheader
if isfield(outheader,'events');
    outheader=rmfield(outheader,'events');
end;


%loop through epochs
newepochpos=1;
neweventpos=1;
for epochpos=1:header.datasize(1);
    %loop through chunks
    for chunkpos=1:numchunks - NbChunks2Remove;
        %dx1,dx2
%         dx1 = dx_offset+((chunkpos-1)*dx_epochstep);
%         dx2 = dx1+dx_epochlength-1;
%       Let's round the lenght and step of each chunck here to avoid
%       accumulation of rounding errors. 
        dx1 = round(dx_offset+((chunkpos-1 + NbChunks2Remove)*dx_epochstep));
        dx2 = round(dx1+dx_epochlength-1);
        dx1_raw = dx_offset+((chunkpos-1 + NbChunks2Remove)*dx_epochstep);
        dx2_raw = dx1+dx_epochlength-1;
%         dx1_store(chunkpos) = dx1;
%         dx2_store(chunkpos) = dx2;
        
        outdata(newepochpos,:,:,:,:,:)=data(epochpos,:,:,:,:,dx1:dx2);
        %x1,x2
        x1=((dx1_raw-1)*header.xstep)+header.xstart;
        x2=((dx2_raw-1)*header.xstep)+header.xstart;
        %search for events
        if isfield(header,'events');
            for eventpos=1:length(header.events);
                if header.events(eventpos).epoch==epochpos;
                    if header.events(eventpos).latency>=x1;
                        if header.events(eventpos).latency<=x2;
                            outheader.events(neweventpos) = header.events(eventpos);
                            outheader.events(neweventpos).latency = header.events(eventpos).latency-x1 - baselineOffset;
                            outheader.events(neweventpos).epoch = newepochpos;
                            neweventpos=neweventpos+1;
                        end;
                    end;
                end;
            end;
        end;
        newepochpos=newepochpos+1;
    end;
end;

%adjust xstart
outheader.xstart = -baselineOffset;

%adjust conditions if present
if isfield(outheader,'conditions');
    conditions=[];
    newepochpos=1;
    for epochpos=1:header.datasize(1);
        %loop through chunks
        for chunkpos = 1:numchunks - NbChunks2Remove;
            conditions(newepochpos,:)=header.conditions(epochpos,:);
            newepochpos=newepochpos+1;
        end;
    end;
    outheader.conditions=conditions;
end;

%adjust epochdata if present
if isfield(outheader,'epochdata');
    epochdata=header.epochdata;
    newepochpos=1;
    for epochpos=1:header.datasize(1);
        %loop through chunks
        for chunkpos = 1:numchunks - NbChunks2Remove;
            tp=header.epochdata(epochpos);
            epochdata(newepochpos)=tp;
            newepochpos=newepochpos+1;
        end;
    end;
    outheader.epochdata=epochdata;
end;

%delete fieldtrip_dipfit.dipoles if present
if isfield(outheader,'fieldtrip_dipfit');
    if isfield(outheader.fieldtrip_dipfit,'dipole');
        outheader.fieldtrip_dipfit=rmfield(outheader.fieldtrip_dipfit,'dipole');
    end;
end;

disp('*** Done!');
