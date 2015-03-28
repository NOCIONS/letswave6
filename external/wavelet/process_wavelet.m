function [header,data]=process_wavelet(header,data,ystart,ystep,ysize,type,periods,stdev,postprocess,baseline,baseline_start,baseline_end)

%calculate wavelet
[wav1 wav2]=calculate_wavelet(type,periods,stdev);

%parameters
srate=1/header.xstep;
xsize=header.datasize(6);
xstep=header.xstep;
xstart=header.xstart;

hzi=ystart;
outarray1=zeros(ysize,xsize);
outarray2=zeros(ysize,xsize);
outarray=zeros(ysize,xsize);

z=1;
y=1;

for epoch=1:header.datasize(1);
    for channel=1:header.datasize(2);
        for index=1:header.datasize(3);
            for dy=1:ysize;
                %compress wavelet
                specsize=round((srate*periods)/hzi);
                specsizediv2=floor(specsize/2);
                specinc=8192/specsize;
                tps=round(0:specinc:(specinc*(specsize-1)))+1;
                tspec1=wav1(tps)';
                tspec2=wav2(tps)';
                %res
                res=vertcat(zeros(specsizediv2,1),squeeze(data(epoch,channel,index,z,y,:)),zeros(specsizediv2,1));
                for dx=1:xsize;
                    %pseudo-convolution
                    %sigpos : start point on signal
                    outarray1(dy,dx)=mean(tspec1.*res(dx:dx+specsize-1));
                    outarray2(dy,dx)=mean(tspec2.*res(dx:dx+specsize-1));
                end;
                hzi=hzi+ystep;
            end;
            %postprocessing
            if strcmpi(postprocess,'amplitude');
                outarray=sqrt(outarray1.^2+outarray2.^2);
            end;
            if strcmpi(postprocess,'power');
                outarray=outarray1.^2+outarray2.^2;
            end;
            if strcmpi(postprocess,'phase');
                outarray=atan2(outarray2,outarray1);
            end;
            if strcmpi(postprocess,'real');
                outarray=outarray1;
            end;
            if strcmpi(postprocess,'imag');
                outarray=outarray2;
            end;
            %baseline correction
            if strcmpi(baseline,'subtract');
                bl1=((baseline_start-xstart)*xstep)+1;
                bl2=((baseline_end-xstart)*xstep)+1;
                outarray_mean=mean(outarray(:,bl1:bl2),2)
                for dy=1:ysize;
                    outarray(dy,:)=outarray(dy,:)-outarray_mean(dy);
                end;
            end;
        end;
    end;
end;
            
            
            %average
            
            
            

