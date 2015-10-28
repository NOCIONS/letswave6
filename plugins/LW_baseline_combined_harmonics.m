function [outheader,outdata] = LW_baseline_combined_harmonics(header,data,freqBins,dx1,dx2,operation, method)

% LW_BootstrapHarmonics
%
% Inputs
% - header (LW5 header)
% - data (LW5 data)
% -freqBins
% - dx1 : begin of sliding baseline interval (bin)
% - dx2 : end of sliding baseline interval (bin)
% -operation
% - method : 'averageH','sumH'
%
% Outputs
% - outheader (LW5 header)
% - outdata (LW5data)
%
% Dependencies : none.
%
% Author :
% Corentin Jacques
% IPSY
% Université catholique de louvain (UCL)
% Belgium
%


%transfer header to outheader
outheader=header;


%add history
i=length(outheader.history)+1;
outheader.history(i).description='LW_baseline_combined_harmonics';
outheader.history(i).date=date;
outheader.history(i).index=[dx1,dx2,operation];

outdata = data(:,:,:,:,:,1:2);

%convert harmic values to bins
binHarmonics = round((freqBins - header.xstart) ./ header.xstep +1);
binHarmonics = binHarmonics(:);

% create a cell array that contains avalable bins for
dxsize=size(data,6);
dx = 0;
dx31=dx-dx2;
dx32=dx-dx1;
dx41=dx+dx1;
dx42=dx+dx2;
surroundBins = [dx31:dx32,dx41:dx42];

%Here I will have to use cell arrays to hold surronding
%bins indices in case the number of available bins are
%not identical for each harmonic.
AllBslBins = cell(length(binHarmonics),1);
AllBslBinsVect = [];
NbbinsPerHarmonic = [];
for bh = 1:length(binHarmonics);
    tempBins = binHarmonics(bh) + surroundBins;
    
    %remove non-existing bins.
    tempBins(tempBins<1) = [];
    tempBins(tempBins>dxsize) = [];
    %store bsl bins
    AllBslBins{bh} = tempBins;
    AllBslBinsVect = [AllBslBinsVect tempBins];
    
    %store nb of valeus per cell
    NbbinsPerHarmonic(bh) = length(tempBins);
end

NbbinsPerHarmonicCumSum = cumsum(NbbinsPerHarmonic) - NbbinsPerHarmonic(1);

if ~any(diff(NbbinsPerHarmonic));
    equalNbBins = 1;
else
    equalNbBins = 0;
end

% surroundBins = repmat([dx31:dx32,dx41:dx42],[length(binHarmonics),1]);
% AllBslBins = bsxfun(@plus,surroundBins, binHarmonics );

%method to cimbine harmonics
method = lower(method);
switch method
    case 'averageh'
        funf = @mean;
    case 'sumh'
        funf = @sum;
    otherwise
        error('unknown method for combining harmonics!');
end

if strcmpi(operation,'zscore');
    if strcmpi(method,'sumh');
        warning('zscore operation is not compatible with summing method for combining harmonics! -> Aborting!');
        return
    end
end


%loop through all the data (pooling across channels)
for epochpos=1:size(data,1);
    for indexpos=1:size(data,3);
        for dz=1:size(data,4);
            for dy=1:size(data,5);
                tp = squeeze(data(epochpos,:,indexpos,dz,dy,:));
                combHarmonicValue = funf(tp(:,binHarmonics),2);% -> actual value for combined harmonics
                 combBaselineValue = zeros(size(tp,1),length(binHarmonics));
                for bh = 1:length(binHarmonics);                
                combBaselineValue(:,bh) = mean(tp(:,AllBslBins{bh}),2);                
                end
                combBaselineValue = funf(combBaselineValue,2);
                
                switch operation
                    case 'subtract'%subtraction
                        tp2 = combHarmonicValue - combBaselineValue;
                    case 'snr'
                        tp2 = combHarmonicValue ./ combBaselineValue;
                    case 'zscore'
                        %first remove the mean in each harmonic interval to
                        %avoid inflating the std due to baseline
                        %differences across the frequency spectrum.
                        AllBslValuesDC = [];
                        AllBslValuesDCVect = [];
                        for bh = 1:length(binHarmonics);
                              AllBslValuesDC{bh} = bsxfun(@minus,tp(:,AllBslBins{bh}), mean(tp(:,AllBslBins{bh}),2));
                              AllBslValuesDCVect = [AllBslValuesDCVect AllBslValuesDC{bh}];
                        end                        
                        combBaselineStd = std(AllBslValuesDCVect,[],2);                        
                        tp2 = (combHarmonicValue - combBaselineValue) ./combBaselineStd;
                    case 'percent'
                        tp2 = combHarmonicValue - combBaselineValue;
                        tp2 = tp2 ./ combBaselineValue;
                    case 'percentbootstrap'
                        
                        %perform bootstrap
                        Nboot = 40000;
                        bootBaselineValues = zeros(size(tp,1), Nboot);
                        for b = 1:Nboot;
                            if equalNbBins;%equal number of bins for each harmonics -> faster
                                randsampling = ceil(NbbinsPerHarmonic(1) .* rand(length(binHarmonics),1));
                            else
                                for bh = 1:length(binHarmonics);
                                    randsampling(bh) = ceil(NbbinsPerHarmonic(bh) .* rand(1,1));
                                end
                            end
                            randsamplingBins = AllBslBinsVect(NbbinsPerHarmonicCumSum(:) + randsampling(:));
                            
                            bootBaselineValues(:,b) = funf(tp(:,randsamplingBins),2);
                        end
                        
                        bootBaselineValuesSorted = sort(bootBaselineValues,2);
                        
                        %pvalue
                        tail = 2;
                        PvalueStore = zeros(size(bootBaselineValuesSorted,1),1);
                        threshold = combHarmonicValue;
                        for E=1:size(bootBaselineValuesSorted,1);
                            if threshold(E) < max(bootBaselineValuesSorted(E,:)) && threshold(E) > min(bootBaselineValuesSorted(E,:));
                                temp_P = find(bootBaselineValuesSorted(E,:) >= threshold(E));
                                tempPval(1) = (1-(temp_P(1)-1)/Nboot) * tail;
                                tempPval(2) = (temp_P(1)/Nboot) * tail;
                                PvalueStore(E) = min(tempPval);
                            else PvalueStore(E) = (1/(Nboot+1)) * tail; %actual difference is outside bootstrap range
                            end
                        end
                        
                        %percentile
                        tp2 = 100 * (1 - PvalueStore);                        
                end                
                % store in outdata
                outdata(epochpos,:,indexpos,dz,dy,:) = repmat(tp2,[1 2]);              
            end  
        end
    end
end


%update xaxis values
outheader.xstart = freqBins(1);
if numel(freqBins) > 1;
    outheader.xstep = abs(freqBins(2) - freqBins(1));
else
    outheader.xstep =  freqBins(1);
end
outheader.datasize = size(outdata);









