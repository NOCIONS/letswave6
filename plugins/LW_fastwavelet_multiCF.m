function [outheader,outdata]=LW_fastwavelet_multiCF(header,data,freqVect,type,centFreq,stdev,mothersize,DownSamp,postprocess,baseline,baseline_start,baseline_end,output)



%parameters
nEpochs   = header.datasize(1);
nChannels = header.datasize(2);
srate=1/header.xstep;
xsize=header.datasize(6);
xstep = header.xstep * DownSamp; % adjust for downsampling
xstart=header.xstart;
ysize = length(freqVect);

isOptim = 1;


%calculate wavelet
wav1 = cell(1,ysize);
wav2 = cell(1,ysize);
for w = 1:ysize
    [wav1temp wav2temp]=LW_fastwavelet_mother(type,centFreq(w),stdev,mothersize);
    wav1{w} = wav1temp;
    wav2{w} = wav2temp;
end


% if isOptim
%     data = single(data);    
%     outarray1 = zeros(ysize,xsize,'single');
%     outarray2 = zeros(ysize,xsize,'single');
% %     outarray  = zeros(ysize,xsize,'single');
% else
    outarray1 = zeros(ysize,xsize);
    outarray2 = zeros(ysize,xsize);
%     outarray  = zeros(ysize,xsize);
    
% end

%outheader
outheader = header;

outheader.datasize(5) = ysize;
outheader.datasize(6) = ceil(size(data,6)./DownSamp); % downsampling

if strcmpi(output,'average');
    outheader.datasize(1) = 1;
end;
outheader.ystart = freqVect(1);
outheader.ystep = freqVect(2) - freqVect(1);
outheader.xstep = xstep;

%add history
i=length(outheader.history)+1;
outheader.history(i).description='LW_fastwavelet_multiCF';
outheader.history(i).date=date;
outheader.history(i).index=[];

if strcmpi(postprocess,'amplitude');
    outheader.filetype='frequency_time_amplitude';
elseif strcmpi(postprocess,'power');
    outheader.filetype='frequency_time_power';
elseif strcmpi(postprocess,'phase');
    outheader.filetype='frequency_time_phase';
elseif strcmpi(postprocess,'real');
    outheader.filetype='frequency_time_amplitude';
elseif strcmpi(postprocess,'imag');
    outheader.filetype='frequency_time_amplitude';
end;


%prepare outdata
if isOptim
    outdata = zeros(outheader.datasize,'single');
else
    outdata = zeros(outheader.datasize);
end


%prepare outdata for PLV
if strcmpi(output,'average');
    if strcmpi(postprocess,'phase'); %PLV
        tp=outheader.datasize;
        tp(1)=2;
        outdata=zeros(tp);
    end;
end;


z=1;
y=1;


TSPEC1 = cell(1,ysize);
TSPEC2 = cell(1,ysize);

if isOptim 
    for dy=1:ysize;
   
        %compress wavelet
        specsize=round((srate*centFreq(dy))/freqVect(dy));
        specinc=mothersize/specsize;
        tps=floor(0:specinc:(specinc*(specsize-1)))+1;
        tspec1 = wav1{dy}(tps)';
        tspec2 = wav2{dy}(tps)';       
        wavScale = sqrt(freqVect(dy)/centFreq(dy));        
        TSPEC1{dy} = tspec1 * wavScale;
        TSPEC2{dy} = tspec2 * wavScale;       
    end
end


 for channel = 1 : nChannels
        disp(['channel : ' num2str(channel)]);
        
        tic;
     for epoch = 1 : nEpochs
     disp(['     epoch : ' num2str(epoch)]);
    

        for index=1:header.datasize(3);
                      
            for dy=1:ysize;
                     
                if isOptim %<bj: optimized code: 4.7 msec>

                    R = squeeze(data(epoch,channel,index,z,y,:))';
                    outarray1(dy,:) = conv2(R,TSPEC1{dy}', 'same');
                    outarray2(dy,:) = conv2(R,TSPEC2{dy}', 'same');
%                     
                else %<old code: 30.5 msec>
                    res = vertcat(zeros(specsizediv2,1),squeeze(data(epoch,channel,index,z,y,:)),zeros(specsizediv2,1));
                    
                    specinc=mothersize/specsize;
                    tps=floor(0:specinc:(specinc*(specsize-1)))+1;
                    tspec1=wav1(tps)';
                    tspec2=wav2(tps)';
                    
                    for dx=1:xsize;
                        %pseudo-convolution
                        %sigpos : start point on signal
                        outarray1(dy,dx)=mean(tspec1.*res(dx:dx+specsize-1)); %!!! 97% time for those 2 lines !
                        outarray2(dy,dx)=mean(tspec2.*res(dx:dx+specsize-1)); %!!! 97% time for those 2 lines !
                    end;
                end             
            end;
            
            %postprocessing
            if strcmpi(postprocess,'amplitude');
                outarray=sqrt(outarray1.^2+outarray2.^2);
            elseif strcmpi(postprocess,'power');
                outarray=outarray1.^2+outarray2.^2;
            elseif strcmpi(postprocess,'phase');
                outarray=atan2(outarray2,outarray1);
            elseif strcmpi(postprocess,'real');
                outarray=outarray1;
            elseif strcmpi(postprocess,'imag');
                outarray=outarray2;
            end;
            
            
             %downsampling / decimation
            if DownSamp > 1;
                outarray_dec = zeros(outheader.datasize(5),outheader.datasize(6));
                for dy=1:ysize;
                    tempP2 = decimate(outarray(dy,:),DownSamp); %downsample wavelet transform
                    outarray_dec(dy,:) = tempP2(1:size(outarray_dec,2));
                end
                outarray = outarray_dec;
            end            
            
            
            %baseline correction
            if ~strcmpi(baseline,'none');
                bl1=round((baseline_start-xstart)/xstep)+1;
                bl2=round((baseline_end-xstart)/xstep)+1;
                outarray_mean = mean(outarray(:,bl1:bl2),2);
                
                switch baseline
                    case 'zscore'
                        outarray_std = std(outarray(:,bl1:bl2),[],2);
                        outarray = bsxfun(@minus,outarray,outarray_mean);
                        outarray = bsxfun(@rdivide,outarray,outarray_std);
                    case 'erpercent'
                        outarray = bsxfun(@minus,outarray,outarray_mean);
                        outarray = bsxfun(@rdivide,outarray,outarray_mean);
                    case 'divide'
                        outarray = bsxfun(@rdivide,outarray,outarray_mean);
                    case 'subtract'
                        outarray = bsxfun(@minus,outarray,outarray_mean);
                end
            end           
                       
            
            if strcmpi(output,'average');
                if strcmpi(postprocess,'phase'); %PLV
                    outdata(1,channel,index,z,:,:) = squeeze(outdata(1,channel,index,z,:,:)) + sin(outarray);
                    outdata(2,channel,index,z,:,:) = squeeze(outdata(2,channel,index,z,:,:)) + cos(outarray);
                else
                    outdata(1,channel,index,z,:,:) = squeeze(outdata(1,channel,index,z,:,:))+outarray;
                end;
            else
                outdata(epoch,channel,index,z,:,:) = outarray;
            end;
        end;
    end;
    toc
end;

if strcmpi(output,'average');
    outdata=outdata/header.datasize(1);
    if strcmpi(postprocess,'phase'); %PLV
        tp = outdata .^ 2;
        outdata = zeros(outheader.datasize);
        outdata(1,:,:,:,:,:) = sqrt(squeeze(tp(1,:,:,:,:,:)) + squeeze(tp(2,:,:,:,:,:)));
    end;
end;




% workspaceexport; %<bj>