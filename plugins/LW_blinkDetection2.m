function [outheader,data,NbBlinks,blinkPerSec] = LW_blinkDetection2(header,data,blinkThreshold,channelName,Polarity)

% usage:
% [outheader,data,blinkPerSec] =LW_blinkDetection2(header,data,blinkThreshold,channelName,Polarity)
%
%
% Detects and counts blinks separatly for each epochs of eeg data
%
% Plugin for Letswave 5

%transfer header to outheader
outheader=header;

%add history
i=length(outheader.history)+1;
outheader.history(i).description=['LW_blinkDetection'];
outheader.history(i).date=date;

 AllChannels = {header.chanlocs(:).labels};
 if ischar(channelName)
 ChannelNb = strmatch(channelName,AllChannels,'exact');
 else
     ChannelNb =channelName;
 end

%  binsize = round(winLength/header.xstep);
%  binsizeStep = round(0.01/header.xstep);
%  [startbins endbins] = makebins(1,size(data,6),binsizeStep,'constant');
%  endbins = startbins + binsize;
%  endbins = min(endbins,size(data,6));
Polarity = lower(Polarity);

if strcmpi(Polarity,'automatic');
    
    %filter data with lowpass
    [headerauto,dataauto] = RLW_butterworth_filter(header, data,'filter_type','lowpass','high_cutoff',30,'filter_order',4);
    for epochpos=1:size(dataauto,1);
        stdThr = std(squeeze(dataauto(epochpos,ChannelNb,:,:,:,:)));
        datatemp = detrend(detrend(squeeze(dataauto(epochpos,ChannelNb,:,:,:,:)),'constant'),'linear');
        outlierInd = find(abs(datatemp) > 2*stdThr);
        polarityCue(epochpos) = mean(datatemp(outlierInd));
    end
    
    if mean(polarityCue) > 0
        Polarity = 'positive';
    else
        Polarity = 'negative';
    end
    disp(['Automatic polarity detection -> Detected blink polarity: ',Polarity]);
    clear dataauto;
end


%first filter data with highpass
[header,data]=RLW_butterworth_filter(header, data,'filter_type','bandpass','low_cutoff',0.8,'high_cutoff',25,'filter_order',4);

blinkMark = repmat([10 0],[1 round(size(data,6)/2)]); 

%loop through all the data
for epochpos=1:size(data,1)
    for indexpos=1
        for dz=1
            for dy=1                
                %               %detect blink
                switch Polarity
                    case 'positive'                       
                        blinkSig = squeeze(data(epochpos,ChannelNb,indexpos,dz,dy,:)) > blinkThreshold;
                    case 'negative'                       
                        blinkSig = squeeze(data(epochpos,ChannelNb,indexpos,dz,dy,:)) < -blinkThreshold;
                end
                nansig = NaN(length(blinkSig),1);
                nansig(blinkSig) = blinkMark(blinkSig);
                if ~max(blinkSig)
                    nansig(1) = 1;
                end
                
                data(epochpos,:,indexpos,dz,dy,:) = repmat(nansig',[size(data,2),1]);
                
                %take diff to compute nb of blinks
                blinkOnset = find(diff(blinkSig) == 1);
                NbBlinks(epochpos) = length(blinkOnset);
                blinkPerSec(epochpos) = NbBlinks(epochpos) / (header.xstep * header.datasize(6));
            end
        end
    end
end






