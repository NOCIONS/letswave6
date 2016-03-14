function ICAtimedisplay(MixMat, s1, v1, s2, v2, s3, v3, s4, ...
		    v4, s5, v5, s6, v6, s7, v7);
% function ICAtimedisplay(MixMat, Title, s1, v1, s2, v2, s3, v3,
% s4, v4, s5, v5, s6, v6, s7, v7);
%
% Creates plots of spatial components together with the associated 
% timecourse and a frequency plot
%
% Possible parameters have to be passed as pairs of strings, the
% following parameters are recognised:
% 
%      'title'      : any string that will appear as title of plot
%      'IClist'     : any list or interval containing the number of
%                     ICs of interest; ex.: [2:5] or [1 3 5,19:22]
%      'clearWins'  : does clear all the plot windows; useful if plot
%                     psOutput option is selected
%      'psOutput'   : will create a file called 'Output-all.pdf'
%      'logPow'     : if 'on', the log of the power will be plotted
%      'periodPlot' : will produce a periodogram rather than a
%                     frequency plot
%      'fplotRange' : specifies frequency (or periodicity) range of
%                     interest; example is [0 0.3]
%
     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Calculate Size of the Matrices

v_NumICs          = size(MixMat,2);
v_NumTimepoints   = size(MixMat,1);

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default values for optional parameters

v_verbose           = 1;
v_psOutput          = 0;
v_logPow            = 0;
v_clearWins         = 0;
v_title             = 'No title specified';
v_IClist            = [1:v_NumICs];
v_periodPlot        = 0;
v_fplotRange        = [0, 0.5];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read the optional parameters

if(rem(nargin-1,2)==1)
  error('Optional parameters should always go by pairs');
else
  for i=1:(nargin-1)/2
    % get the name and value of parameter
    str_param = eval (['s' int2str(i)]);
    val_param = eval (['v' int2str(i)]);

    % change the value of parameter
    if strcmp (str_param, 'clearWins')
      if strcmp (val_param, 'on'), v_clearWins = 1; v_psOutput = 1; end
    elseif strcmp (str_param, 'IClist')
      v_IClist=val_param;
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
    else
      % Hmmm, something wrong with the parameter string
      error(['Unrecognized parameter: ''' str_param '''']);
    end;
  end;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check if everything is OK
%
if v_NumICs > v_NumTimepoints
  if v_verbose
    fprintf('Warning: ');
    fprintf('The mixing matrix may be oriented in the wrong way.\n');
    fprintf('In that case transpose the matrix.\n\n');
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


for comp=1:ceil(v_NumICs/10)
   
   figure
   orient landscape;
   
   for k=1+10*(comp-1):min(10*comp,v_NumICs)

   %get the corresponding timecourse  
   timecourse=MixMat(:,k);
 
   % Now plot the frequency spectrum
   Freq = fft(timecourse);
   Freq(1)=[];
   n=v_NumTimepoints-1;
   m=floor(n/2);
   nyquistfactor=1/2;
   power = abs(Freq(1:m)).^2;
   
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

  i=k-10*(comp-1);
  subplot('position',[4/100+floor((i-0.5)/5)*0.48,9/200+4/22*rem(i-1, ...
						  5),1/5,3/29]);
  plot(timecourse);title(strcat('IC ',int2str(k)));
  axis('tight');set(gca,'FontSize',8);
  subplot('position',[4/100+0.24+floor((i-0.5)/5)*0.48,9/200+4/22*rem(i-1, ...
						  5),1/5,3/29]);
  plot(xseries,yseries);title(strcat('IC ',int2str(k),' - FT'));
  axis('tight');
  set(gca,'FontSize',8);
end;
     
   % Write title 
   subplot('position',[1/15,0.92,3/5,1/29]); 
   text(0.1,0.8,[v_title]); 
   axis('off');

   if v_psOutput
      if v_verbose
         fprintf(strcat('Creating plot for page p',int2str(comp),'\n'));
      end;
      if comp<10 
	 tmp2=strcat('print -dpsc2 timecourses-IC-00',int2str(comp),'.tPS');
      elseif comp<100
	 tmp2=strcat('print -dpsc2 timecourses-IC-0',int2str(comp), ...
		     '.tPS'); 
      else 
	 tmp2=strcat('print -dpsc2 timecourses-IC-',int2str(comp), ...
		     '.tPS'); 
      end; 
      eval(tmp2);
   end;
   
   if v_clearWins
      close(gcf);
   end;
   
end;

if v_psOutput  
  ! gs -sOutputFile=Timecourses-all.pdf -dNOPAUSE -q -dBATCH -sDEVICE=pdfwrite timecourses-IC-*
  !rm *.tPS
  if v_verbose
     fprintf('Output written to file Timecourses-all.pdf\n');
  end;
end;
   
      