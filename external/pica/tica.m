function [results] = tica(dat, mask, numPCA, numICA, vn)
   
flops(0)
   if(nargin<5)
      vn=1;
   end
   
   if(nargin<4)
      numICA=1;
   end
   
   if(nargin<3)
      numPCA=1;
   end

   if(nargin<2)
      mask=ones(1,size(dat,2));
   end;
   
   if((size(mask,2)==size(dat,2))&(sum(mask)<size(dat,2)))
     dat=dat(:,mask,:);
   end;
   
     
   di=[];
   dat2=[];
   DWM=zeros(size(dat,1),size(dat,1),size(dat,3));
   Means1=[];
   Means2=[];
   
   Pdims=zeros(1,size(dat,3));
   
   fprintf('data pre-processing ');
   for k=1:size(dat,3);
      fprintf('.');
      t1=squeeze(dat(:,:,k));
 
      m1=mean(t1);
      Means1=[Means1; m1];
      t1=remmean(t1')';
      
      m2=mean(t1');
      t2=remmean(t1);
      
      if (vn>0)
        [ws,wm,dwm]=hyv_ica(t2,'lastEig',min(30,size(t2,1)-1),'only','white','verbose','off');
        ws(ws<1.6)=0;
        t3=std(t2-dwm*ws);
        %t3=std(t1);
        t1=t1./(ones(size(t1,1),1)*t3);
      end;
 
      m2=mean(t1');
      Means2=[Means2;m2];
        
      if numPCA<1
	
	 [tE,tD]=hyv_ica(t1,'only','pca','verbose','off');
	 tD=diag(tD)';
	 tD=fliplr(sort(tD./iFeta([0.01:0.01:5],size(tD,2),size(t1,2))));

	 di=pca_dim(tD,size(tD,2),size(t1,2));
	  
	 numRed=find(di.lap==max(di.lap))+2;
	 numRed=min(60,numRed(1))

      else
	 numRed=numPCA
      end;
      Pdims(1,k)=numRed;
    
      [tWS,tWM,tDWM]=hyv_ica(t1,'only','white','lastEig',numRed,'verbose','off');
         
      dat2=[dat2; tWS];

      blah=tDWM;
      DWM(:,1:size(blah,2),k) = blah;

   end
   fprintf('\n\n');

   %%%%%%%%%%%%%%%%%%%%%%%  joint ICA 
   fprintf('ICA estimation \n\n');
   size(dat2)
   
   if numICA<1
     
      [tE,tD]=hyv_ica(dat2,'only','pca','verbose','off');
      tD=diag(tD)';
      tD=fliplr(sort(tD./iFeta([0.01:0.01:5],size(tD,2),size(dat2,2))));
      di=pca_dim(tD,size(tD,2),size(dat2,2));
	      
      numICA=min(3+find(di.lap==max(di.lap)),size(dat2,1)-1)
      
   end;
   
   [IC,A,W]=hyv_ica(dat2,'lastEig',numICA,'epsilon',0.00001,'verbose','on');
   
   
   
   %%%%%%%%%%%%%%%%%%%%%%%  reconstruct original TC 
   fprintf('reconstruct original TC \n');
  
   for k=1:size(A,2)
      for i=1:size(dat,3)
        %
        % TC(:,k,i)=squeeze(DWM(:,1:Pdims(i),i))*A(1+(i-1)*numPCA:i*numPCA,k);
	c=cumsum([0 Pdims]);
	TC(:,k,i)=squeeze(DWM(:,1:Pdims(i),i))*A(1+c(i):c(i+1),k);
      end;
   end;

   %%%%%%%%%%%%%%%%%%%%%%%  rank-one approx. 

   fprintf('Rank 1 approximation for the time courses \n\n');
   num=size(dat,1);
   anz=size(IC,1);
   modesT=zeros(anz,num);
   modesB=zeros(anz,size(dat,2));
   modesS=zeros(anz,size(dat,3));

   for k=1:anz
      TC2=squeeze(TC(:,k,:))';
      %size(TC2)
      [t1,t2,t3]=hyv_ica(TC2,'only','white','lastEig',1,'verbose','off');
      %size(t1)
      %size(t2)
      %size(t3)
      modesT(k,:)=t1;
      modesS(k,:)=t3';
      modesB(k,:)=IC(k,:);
   end;

   results.A=A;
   results.IC=IC;
   results.DWM=DWM;
   results.TC=TC;
   results.B=modesB;
   results.S=modesS;
   results.T=modesT;
   results.d2=dat2;
   results.Pdims=Pdims;
   results.d=di;
   results.flops=flops;   
