function [tseries,outarg] = ViewFMRI(Data,Mean,func,funcd,varargin)

% tseries = ViewFMRI(Data)
%
% Tool for viewing 4D FMRI datasets
%
% tseries = ViewFMRI(Data,Mean)
%
% Mean determines the data shown in the slice-by-slice lightbox.
% Mean='m' shows the mean volume, this is the default.
% Can alternatively be a matrix volume of the same size as the data
%
% tseries = ViewFMRI(Data,Mean,func,funcd,varargin)
%
% func is function that runs on middle mouse click
% default is plotseries, which just plots the time series
% an alternative is fftseries, which plots the fft of the time series
%
% funcd is function that runs when d is pressed
% default is plotseries, which just plots the time series
% an alternative is fftseries, which plots the fft of the time series
%
% varargin are any arguments to be passed to func and funcd

if (nargin<4)
  funcd = 'plotseries';
  if (nargin<3)
    func = 'plotseries';
  end;
end;

outarg=0;

if size(Data,1) ~= size(Data,2)
  fprintf('Image matrix has been padded with zeros to make it square');
  d1 = max([size(Data,1),size(Data,2)]);
  Data2 = zeros(d1,d1,size(Data,3),size(Data,4));
  Data2(1:size(Data,1),1:size(Data,2),:,:) = Data;
  Data = Data2;
  clear Data2;
end;

res = size(Data,1);

Index=0;

if (nargin<2),
  Mean='m';
end;

if length(size(Data))==2
  NumSlices=1;
end;

% Beckmanns old stuff for viewing 2D matrix
% if length(size(Data))==2
%  MeanImg=Data(floor(size(Data,1)/2),:);
%  if (nargin>1)
%    if Mean=='m'
%      MeanImg=mean(Data);
%    end;
%  end;
%  
%  NumSlices=size(Data,2)/slicesize;
%  Data=reshape(Data',res,res,NumSlices,size(Data,1));
%end;


if ~isstr(Mean),
  MeanImg=Mean;

  if size(MeanImg,1) ~= size(MeanImg,2)
      d1 = max([size(MeanImg,1),size(MeanImg,2)]);
      MeanImg2 = zeros(d1,d1,size(MeanImg,3));
      MeanImg2(1:size(MeanImg,1),1:size(MeanImg,2),:) = MeanImg;
      MeanImg = MeanImg2;
      clear MeanImg2;
  end;

else,
  MeanImg=mean(Data,4);
end;


NumSlices=size(MeanImg,3);

if NumSlices>21
      AllData = MeanImg;
      MeanImg = AllData(:,:,Index+1:Index+21); 
end
MeanImg=reshape(MeanImg,1,prod(size(MeanImg)));

if NumSlices<21
  tmp=zeros(1,size(Data,1)*size(Data,2)*21);
  tmp(1:size(Data,1)*size(Data,2)*NumSlices)=MeanImg;
  MeanImg=tmp;
end;

MeanImg=reshape(MeanImg,res,res,21);

LeftPanel=zeros(7*res,3*res);
for ct1=0:2
  for ct2=0:6
    LeftPanel(1+ct2*res:res+ct2*res,1+ct1*res:res+ct1*res)=flipud(MeanImg(:,:,1+ct1+ct2*3)');
  end;
end;

HndlImg=figure;

factor=2;

colormap('bone');
Xrange=[1,res];
Yrange=[1,res];
scale=res;
ImgNum=1;Xind=1;Yind=1;  

LeftImg=subplot('position',[0.01,0.05,0.29,0.9]);
imagesc(LeftPanel);
axis('equal')
axis('off')
if NumSlices > 21
  title(sprintf('n for next 21 slices\np for previous 21 slices'));
end;

tseries=squeeze(Data(Xind,Yind,ImgNum+Index,:));
MeanInt=MeanImg(Xind,Yind,ImgNum+Index);
subplot('position',[0.37,0.05,0.61,0.29]);    
feval(func, tseries, Xind,Yind,ImgNum+Index,varargin{:});

RightImg=subplot('position',[0.37,0.41,0.4,0.55]);
imagesc((MeanImg(:,:,ImgNum)'))
set(RightImg,'XLim',Xrange,'YLim',Yrange);
axis('equal')
axis('tight')
set(RightImg,'XColor','red','YColor','red');


while 1==1
  
  TextImg=subplot('position',[0.8,0.41,0.18,0.55]);
  plot([1])
  axis('off')
  set(TextImg,'XLim',[0,2],'YLim',[0,2]);
  text(0.3,1.8,sprintf('Slice No: %2d',ImgNum+Index));
  text(0.3,1.6,sprintf('       X: %2d',Xind));
  text(0.3,1.4,sprintf('       Y: %2d',Yind));
  text(0.3,1.2,sprintf('Intensity'));
  text(0.3,1.0,sprintf('     %5.3f',MeanInt));
  line([0.05,1.95],[0.85,0.85],'Color','black')
  text(0.05,0.7,sprintf('<left>,<right>: zoom'));
  text(0.05,0.5,sprintf('<centre>: plot tc '));
  text(0.05,0.3,sprintf('q,Q: quit'));
  text(0.05,0.1,sprintf('d,D: indiv. tc'));
  
  drawflag=1;
  
  subplot(RightImg); 
  [X_c,Y_c,B_c]=ginput(1);
  
  if gca==LeftImg	 
    
    tmp=1+floor(X_c/res)+3*floor(Y_c/res);
    if tmp<=NumSlices-Index
      ImgNum=tmp;
    else
      drawflag=0;
    end;
    
    if drawflag
      tseries=squeeze(Data(Xind,Yind,ImgNum+Index,:));
      
      MeanInt=MeanImg(Xind,Yind,ImgNum);
      subplot('position',[0.37,0.05,0.61,0.29]);    
      feval(func, tseries, Xind,Yind,ImgNum+Index,varargin{:});
      
      RightImg=subplot('position',[0.37,0.41,0.4,0.55]);
      imagesc((MeanImg(:,:,ImgNum)'))
      set(RightImg,'XLim',Xrange,'YLim',Yrange);
      title(strcat('Slice ',num2str(ImgNum+Index)));
      set(RightImg,'XColor','red','YColor','red');
      
      LeftImg=subplot('position',[0.01,0.05,0.29,0.9]);
      imagesc(LeftPanel);
      axis('off')
      axis('equal')
      Corner1=1+res*floor(X_c/res);
      Corner2=1+res*floor(Y_c/res);
      line([Corner1,Corner1],[Corner2,Corner2+res-1]);
      line([Corner1+res-1,Corner1+res-1],[Corner2,Corner2+res-1]);
      line([Corner1,Corner1+res-1],[Corner2,Corner2]);
      line([Corner1,Corner1+res-1],[Corner2+res-1,Corner2+res-1]);
    end;
  end; 
  
  if gca==RightImg
    if (B_c==1)|(B_c==2)|(B_c==3) 
      if (round(X_c)>0)&(round(X_c)<=res)
	Xind=round(X_c);
      end;
      if (round(Y_c)>0)&(round(Y_c)<=res)      
	Yind=round(Y_c);
      end;
    end;
    if B_c==2
      TSImg=subplot('position',[0.37,0.05,0.61,0.29]);    
      tseries=squeeze(Data(Xind,Yind,ImgNum+Index,:));
      MeanInt=MeanImg(Xind,Yind,ImgNum);
      feval(func, tseries, Xind,Yind,ImgNum+Index,varargin{:});
    end;
    if (B_c==1)&(scale>3)
      scale=round(scale/factor);
      Xrange=[Xind-0.5*scale,Xind+0.5*scale-1];
      Yrange=[Yind-0.5*scale,Yind+0.5*scale-1];
      %%Xrange=Xrange+sum(Xrange<1)-sum(Xrange>res);
      %%Yrange=Yrange+sum(Yrange<1)-sum(Yrange>res);
      Xrange=Xrange-min(Xrange-1)*max(Xrange<1)-max(Xrange-res)*max(Xrange>res);
      Yrange=Yrange-min(Yrange-1)*max(Yrange<1)-max(Yrange-res)*max(Yrange>res);
      %%fprintf('X:%d Y:%d Xr: %d-%d Yr: %d-%d\n',Xind,Yind,min(Xrange),max(Xrange),min(Yrange),max(Yrange))
      RightImg=subplot('position',[0.37,0.41,0.4,0.55]);
      imagesc((MeanImg(:,:,ImgNum)'))
      set(RightImg,'XLim',Xrange,'YLim',Yrange);
      title(strcat('Slice ',num2str(ImgNum+Index)));
      set(RightImg,'XColor','red','YColor','red');
    end;
    if (B_c==3)&(scale < res-1)
      scale=round(scale*factor);
      Xrange=[Xind-0.5*scale,Xind+0.5*scale-1];
      Yrange=[Yind-0.5*scale,Yind+0.5*scale-1];
      Xrange=Xrange-min(Xrange-1)*max(Xrange<1)-max(Xrange-res)*max(Xrange>res);
      Yrange=Yrange-min(Yrange-1)*max(Yrange<1)-max(Yrange-res)*max(Yrange>res);
      RightImg=subplot('position',[0.37,0.41,0.4,0.55]);
      imagesc((MeanImg(:,:,ImgNum)'))
      set(RightImg,'XLim',Xrange,'YLim',Yrange);
      title(strcat('Slice ',num2str(ImgNum+Index)));
      set(RightImg,'XColor','red','YColor','red');
    end;
  end;
  
  if (B_c==113)|(B_c==81)
    % close(HndlImg);
    break
  end;	 
  if (B_c==68)|(B_c==100)
    figure
    feval(funcd, tseries, Xind,Yind,ImgNum+Index,varargin{:});     
    if size(outarg,1)==1
       outarg=tseries;
    else
       outarg=[outarg,tseries];
    end;
    
    
    figure(HndlImg);
  end;
  if (B_c==112)|(B_c==80)
    %P or p
    if (Index>0)
      Index=Index-21;
      MeanImg = zeros(res,res,21);
      MeanImg(:,:,1:min([Index+21 NumSlices])-Index) = AllData(:,:,Index+1:min([Index+21 NumSlices])); 
      LeftPanel=zeros(7*res,3*res);
      for ct1=0:2
	for ct2=0:6
	  LeftPanel(1+ct2*res:res+ct2*res,1+ct1*res:res+ct1*res)=MeanImg(:,:,1+ct1+ct2*3)';
	end;
      end;
      subplot(LeftImg);
      imagesc(LeftPanel);
      axis('equal')
      axis('off')
      if NumSlices > 21
	title(sprintf('n for next 21 slices\np for previous 21 slices'));
      end;
    end;
  end;
  if (B_c==110)|(B_c==78)
    %N or n
    if ((Index+21)<NumSlices)
      Index=Index+21;
      MeanImg = zeros(res,res,21);
      MeanImg(:,:,1:min([Index+21 NumSlices])-Index) = AllData(:,:,Index+1:min([Index+21 NumSlices])); 
      LeftPanel=zeros(7*res,3*res);
      for ct1=0:2
	for ct2=0:6
	  LeftPanel(1+ct2*res:res+ct2*res,1+ct1*res:res+ct1*res)=MeanImg(:,:,1+ct1+ct2*3)';
	end;
      end;
      subplot(LeftImg);
      imagesc(LeftPanel);
      axis('equal')
      axis('off')
      if NumSlices > 21
	title(sprintf('n for next 21 slices\np for previous 21 slices'));
      end;
    end;
  end;
end;
