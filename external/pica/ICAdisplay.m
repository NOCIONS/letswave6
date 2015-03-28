function ICAdisplay(ICMat, MixMat, s1, v1, s2, v2, s3, v3, s4, ...
		    v4, s5, v5, s6, v6, s7, v7, s8, v8, s9, v9, s10, ...
		    v10, s11, v11, s12, v12, s13, v13);
% function ICAdisplay(ICMat, MixMat, Title, s1, v1, s2, v2, s3, v3,
% s4, v4, s5, v5, s6, v6, s7, v7, s8,  v8, s9, v9, s10, v10, s11,
% v11, s12, v12, s13, v13);
%
% Creates plots of spatial components together with the associated 
% timecourse and a frequency plot
%
% Possible parameters have to be passed as pairs of strings, the
% following parameters are recognised:
% 
%      'verbose'    : 'on' or 'off' , where 'on' is default
%      'title'      : any string that will appear as title of plot
%      'IClist'     : any list or interval containing the number of
%                     ICs of interest; ex.: [2:5] or [1 3 5,19:22]
%      'colormap'   : any valid name of a colormap; default is 'jet'
%      'scaleCmap'  : whether all slices are to be plotted using a
%                     single colormap for the rang; possible values
%                     are 'on' or 'off' with 'on' as default
%      'clearWins'  : does clear all the plot windows; useful if plot
%                     psOutput option is selected
%      'psOutput'   : will create a file called 'Output-all.pdf'
%      'logPow'     : if 'on', the log of the power will be plotted
%      'periodPlot' : will produce a periodogram rather than a
%                     frequency plot
%      'fplotRange' : specifies frequency (or periodicity) range of
%                     interest; example is [0 0.3]
%      'background' : binary sequence used to pad ICMat with zeros
%                     incase the analysis was carried out on thresholded data
%      'xdim','ydim': number of voxels - 64x64 as default
%
     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Calculate Size of the Matrices

if(length(size(ICMat))==4)
   ICMat=reshape(ICMat,size(ICMat,1)*size(ICMat,2)*size(ICMat,3), ...
		 size(ICMat,4))';
end;

if(length(size(ICMat))==3)
   ICMat=reshape(ICMat,size(ICMat,1)*size(ICMat,2)*size(ICMat,3),1)';
end;


v_NumVoxels       = size(ICMat,2);
v_NumICs          = size(ICMat,1);
v_NumTimepoints   = size(MixMat,1);

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default values for optional parameters

v_verbose           = 1;
v_psOutput          = 0;
v_logPow            = 0;
v_scaleCmap         = 1;
v_clearWins         = 0;
v_colormap          = 'jet';
v_title             = 'No title specified';
v_IClist            = [1:v_NumICs];
v_periodPlot        = 0;
v_fplotRange        = [0, 0.5];
v_bg                = 0;
v_xdim              = 64;
v_ydim              = 64;
v_equalsize         = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read the optional parameters

if(rem(nargin-2,2)==1)
  error('Optional parameters should always go by pairs');
else
  for i=1:(nargin-2)/2
    % get the name and value of parameter
    str_param = eval (['s' int2str(i)]);
    val_param = eval (['v' int2str(i)]);

    % change the value of parameter
    if strcmp (str_param, 'verbose')
      if strcmp (val_param, 'off'), v_verbose = 0; end
    elseif strcmp (str_param, 'colormap')
      v_colormap=val_param;
    elseif strcmp (str_param, 'clearWins')
      if strcmp (val_param, 'on'), v_clearWins = 1; v_psOutput = 1; end
    elseif strcmp (str_param, 'IClist')
      v_IClist=val_param;
    elseif strcmp (str_param, 'scaleCmap')
      if strcmp (val_param, 'off'), v_scaleCmap = 0; end
    elseif strcmp (str_param, 'logPow')
      if strcmp (val_param, 'on'), v_logPow = 1; end
    elseif strcmp (str_param, 'psOutput')
      if strcmp (val_param, 'on'), v_psOutput = 1; end      
    elseif strcmp (str_param, 'title')
      v_title = val_param;
    elseif strcmp (str_param, 'periodPlot')
       if strcmp (val_param, 'on'), v_periodPlot = 1; end           
    elseif strcmp (str_param, 'fplotRange')
      v_fplotRange = val_param;
    elseif strcmp (str_param, 'background')
       v_background = val_param;
       v_bg = 1;
    elseif strcmp (str_param, 'xdim')
       v_xdim = val_param;
    elseif strcmp (str_param, 'ydim')
       v_ydim = val_param;
    elseif strcmp (str_param, 'equalsize')
       if strcmp (val_param, 'off'), v_equalsize = 0; end  
    else
      % Hmmm, something wrong with the parameter string
      error(['Unrecognized parameter: ''' str_param '''']);
    end;
  end;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check if everything is OK
%
if v_NumICs > v_NumVoxels
  if v_verbose
    fprintf('Warning: ');
    fprintf('The component matrix may be oriented in the wrong way.\n');
    fprintf('In that case transpose the matrix.\n\n');
  end
end

if size(MixMat,2) ~= v_NumICs
   error([' Dimensions of the component-matrix and the mixing-matrix' ...
	  ' do not match'])
end   

if (mod(v_NumVoxels,v_xdim*v_ydim)~=0)&(v_bg==0)
   error([' Number of voxels in ICMat does not match xdim*vdim -' ...
	  ' please specify a background sequence'])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




for comp=v_IClist

   figure
   orient landscape;
 

   % get the component and pad the background if necessary
   if v_bg == 1
      Component = zeros(1,max(size(v_background)));
      Component(1,~v_background)=ICMat(comp,:);
      tmpMean = mean(ICMat(comp,:));
      Component(1,v_background)=tmpMean;
   else % get the component
      Component=ICMat(comp,:);
   end
     
   % get min and max for colorscale adjustment
   if v_scaleCmap 
      clow=min(Component);
      chigh=max(Component);
   end
 
   Numslices=size(Component,2)/(v_xdim*v_ydim);
   Component=reshape(Component,v_xdim,v_ydim,Numslices);

   % Do one slice at a turn
   for slice=1:Numslices
      if Numslices<=14     
	 if slice<9
	    subplot('position',[1/30+floor((slice-0.5)/4)*0.23,3/100+ ...
				1/5*rem(slice-1,4),1/5,1/6]);
	 else  
	    subplot('position',[0.50+1/30+floor((slice-8.5)/3)*0.23, ...
				3/100+1/5*rem(slice-9,3),1/6,1/6]);
	 end;
      elseif Numslices == 21
	 if slice<13 
	    subplot('position',[1/50+floor((slice-0.5)/4)*0.165,3/ ...
				100+1/5*rem(slice-1,4),1/7,1/6]); 
	 else
	    subplot('position',[0.52+floor((slice-12.5)/3)*0.165,3/100+1/ ...
				5*rem(slice-13,3),1/7,1/6]);
	 end;
      else
	 factornum=factor(Numslices);
	 xplots=prod(factornum(1:ceil(length(factornum)/2)));
	 yplots=Numslices/xplots;
	 subplotposition(ceil(slice/(yplots)),xplots,rem(slice-1,yplots)+1,yplots+3,0.02,0.02);
      end;
      
      % Plot a single slice
      if (v_scaleCmap)&(chigh>clow)
	 imagesc(flipud(squeeze(Component(:,:,slice))'),[clow,chigh]);
      else
	 imagesc(flipud(squeeze(Component(:,:,slice))'));
      end;
   
      % and label it
      set(gca,'FontSize',8);
      title(strcat('Slice ',int2str(slice)));
      if v_equalsize
	 axis('off','equal'); 
      else
	 axis('off');
      end;
      colormap(v_colormap); 
   end; 
   
   % Write title 
   tmp=strcat('IC : ',int2str(comp)); 
   subplot('position',[1/30,3/100+4/5,2/5,1/7]); 
   text(0.1,0.8,[v_title]); 
   text(0.1,0.6,[strcat(int2str(v_NumICs),' ICs')]); 
   text(0.1,0.2,[tmp]); 
   axis('off');

   %get the corresponding timecourse  
   timecourse=MixMat(:,comp);
   
   % and plot it
   subplot('position',[0.50+1/30,4/100+4/5,2/5,1/9]); 
   plot(timecourse); 
   set(gca,'YTickLabel',{}); 
   title('associated Timecourse'); 
   axis('tight');
   set(gca,'FontSize',8);

   % Now plot the frequency spectrum
   Freq = fft(timecourse);
   Freq(1)=[];
   n=v_NumTimepoints-1;
   m=floor(n/2);
   nyquistfactor=1/2;
   power = abs(Freq(1:m)).^2;
   
   subplot('position',[0.50+1/30,6/100+3/5,2/5,1/9]); 
   
   xseries = (1:m)/(m)*nyquistfactor;
   yseries = power;
   
   if v_logPow
      yseries=log(power);      
   end;
   if v_periodPlot
      xseries=1./xseries;
   end;
   
   if v_fplotRange ~=[0, 0.5]
      index=(xseries>=v_fplotRange(1)&xseries<=v_fplotRange(2));
      xseries=xseries(index);
      yseries=yseries(index);
   end;
   
   plot(xseries, yseries);
   %set(gca,'YTickLabel',{}); 
   set(gca,'FontSize',8);
   axis('tight');
   
   if v_periodPlot
      title('Periodogram (TR/cycle)');
      %xlabel('Period (TR/cycles)');
   else
      title('Frequency (cycles/TR)'); 
      %xlabel('Frequency (cycles/TR)');
   end;
   if v_logPow
      ylabel('log(Power)');
   else
      ylabel('Power');
   end;
   set(gca,'FontSize',8);

   if v_psOutput
      if v_verbose
         fprintf(strcat('Creating plot for IC  ',int2str(comp),'\n'));
      end;
      if comp<10 
	 tmp2=strcat('print -dpsc2 output2-IC-00',int2str(comp),'.tPS');
      elseif comp<100
	 tmp2=strcat('print -dpsc2 output2-IC-0',int2str(comp), ...
		     '.tPS'); 
      else 
	 tmp2=strcat('print -dpsc2 output2-IC-',int2str(comp), ...
		     '.tPS'); 
      end; 
      eval(tmp2);
   end;
   
   if v_clearWins
      close(gcf);
   end;
   
end;

if v_psOutput  
  ! gs -sOutputFile=Output-all.pdf -dNOPAUSE -q -dBATCH -sDEVICE=pdfwrite output2-IC-*
  !rm *.tPS
  if v_verbose
     fprintf('Output written to file Output-all.pdf\n');
  end;
end;
   
      