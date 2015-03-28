function [results] = tica4(dirnames, mask, fnames, numPCA, numICA, ...
                           vn, maxnumits, epsilon)

   if(nargin<8), epsilon = 0.001;end
   if(nargin<7), maxnumits=100; end  
   if(nargin<6), vn=1; end
   if(nargin<5), numICA=0; end
   if(nargin<4), numPCA=0; end

   num_files=size(dirnames,1);
   tmp=read_avw(char(strcat(dirnames(1,:),fnames)));
   num_vols=size(tmp,4);
   num_vox=sum(mask);
   
   di=[];
   dat2=[];
   DWM=[];
   Means1=[];
   Means2=[];
   
   Pdims=zeros(1,num_files);
   DCovM=zeros(num_vols,num_vols);
   
   fprintf(' Data pre-processing (%i files)\n\n',num_files);
   for k=1:num_files
     fprintf('   Reading data file %i : %s\n',k,char(strcat(dirnames(k,:),fnames)));
     t1=read_avw(char(strcat(dirnames(k,:),fnames)));
     t1=reshape(t1,prod(size(t1))./num_vols,num_vols)';
     t1=t1(:,mask);
     t1=remmean(t1')';
     t2=remmean(t1);  
     if (vn>0)
       [ws,wm,dwm]=hyv_ica(t2,'lastEig',min(30,size(t2,1)-1),'only','white','verbose','off');
       ws(ws<1.6)=0;
       t3=std(t2-dwm*ws);
       t1=t1./(ones(size(t1,1),1)*t3);
     end;
     DCovM=DCovM + cov(t1')./num_files;
   end
   fprintf('\n\n');
   [tE,tD]=pcamat(DCovM,1,num_vols-2,'off','off',0,'on');
   
   if numPCA<1    
       tD2=diag(tD)';
       tD2=fliplr(sort(tD2./iFeta([0.01:0.01:5],size(tD,2),size(t1,2)-2)));
       di=pca_dim(tD2,size(tD2,2),size(t1,2));
       numPCA=find(di.lap==max(di.lap))+2;
       numPCA=min(floor(size(t1,1)/2),numPCA(1));
       fprintf('   reducing each data set to %i dimensions (PCA)\n',numPCA);
   end;

   tWMset = inv (sqrt (tD(1:numPCA,1:numPCA))) * tE(:,1:numPCA)';
   DWM=zeros(num_vols,numPCA,num_files);
   
   for k=1:num_files
     fprintf('   Re-reading data file %i : %s\n',k,char(strcat(dirnames(k,:),fnames)));
     t1=read_avw(char(strcat(dirnames(k,:),fnames)));
     t1=reshape(t1,prod(size(t1))./num_vols,num_vols)';
     t1=t1(:,mask);
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
     
     Pdims(1,k)=numPCA;

     [tWS,tWM,tDWM]=hyv_ica(tWMset*t1,'only','white','lastEig',numPCA,'verbose','off');
     tDWM=pinv(tWMset)*tDWM;
       
     dat2=[dat2; tWS];
     
     blah=tDWM;
     DWM(:,1:size(blah,2),k) = blah;
   end
   fprintf('\n\n');

   %%%%%%%%%%%%%%%%%%%%%%%  joint ICA 
   fprintf(' Tensor estimation \n\n');

   if numICA<1   
      tD=diag(tD)';
      tD=fliplr(sort(tD./iFeta([0.01:0.01:5],size(tD,2),size(dat2,2))));
      di=pca_dim(tD,size(tD,2),size(dat2,2));
      numICA=min(3+find(di.lap==max(di.lap)),size(dat2,1)-1) 
   end;
   
   %   [newtmpE,newtmpD]=hyv_ica(dat2,'lastEig',numICA,'only','pca','verbose','on');
   [newtmpE,newtmpD]=empca(dat2,numICA);
   
   %newtmpWS,newtmpWM,newtmpDWM]=hyv_ica(dat2,'pcaE',newtmpE,'pcaD',newtmpD,'lastEig',numICA,'only','white','verbose','off');
   newtmpWM=inv(sqrt(diag(newtmpD))) * newtmpE';
   newtmpDWM=pinv(newtmpWM);
   newtmpWS=newtmpWM*dat2;
      
   rounds = maxnumits+5;
   newGuess = randn(size(dat2,1),numICA);;
   anz=numICA;

   modesT=randn(anz,num_vols);
   modesB=zeros(anz,num_vox);
   modesS=randn(anz,num_files);
   oldT=randn(size(modesT));
   oldS=randn(size(modesS));
   itt_ctr2=0;
  
   while ((1-min([max(abs(Corr(modesT',oldT')))])) >epsilon) & (itt_ctr2 < 20);   
     oldT=modesT;
     oldS=modesS;
     itt_ctr2 = itt_ctr2 +1;
     fprintf('  ICA estimation\n');
   
     [IC,A,W]=hyv_ica(newtmpWS,'epsilon',0.000001,'verbose','on','maxNumIterations',maxnumits,'initGuess',newGuess);
    % [IC,A,W,rounds]=hyv_ica(dat2,'pcaE',kron(newtmpE,eye(num_files)),'pcaD',kron(newtmpD,eye(num_files)),'whiteSig',newtmpWS,'whiteMat',newtmpWM,'dewhiteMat',newtmpDWM,'lastEig',numICA,'epsilon',0.000001,'verbose','on','maxNumIterations',maxnumits,'initGuess',newGuess);
    % [A,W,rounds]=fpica(newtmpWS);
    % IC=W*newtmpWS;
   
     %%%%%%%%%%%%%%%%%%%%%%%  reconstruct original TC 
     fprintf('   Reconstruct original TC \n');
     for k=1:size(A,2)
       for i=1:num_files
         c=cumsum([0 Pdims]);
         %
         %    TC(:,k,i)=squeeze(DWM(:,1:Pdims(i),i))*A(1+c(i):c(i+1),k);
         recMM = newtmpDWM*A;
         TC(:,k,i) =  squeeze(DWM(:,1:Pdims(i),i))* recMM(1+c(i):c(i+1),k);
       end;
     end;

     %%%%%%%%%%%%%%%%%%%%%%%  rank-one approx. 
     fprintf('   Rank 1 approximation for the time courses \n');
     newGuess = zeros(size(dat2,1),size(A,2));
     
     for k=1:anz
       TC2=squeeze(TC(:,k,:))';
       [t1,t2,t3]=hyv_ica(TC2,'only','white','lastEig',1,'verbose','off');
       modesT(k,:)=t1;
       modesS(k,:)=t3';
       modesB(k,:)=IC(k,:);
       for i=1:num_files
         newGuess(1+c(i):c(i+1),k) = squeeze(pinv(DWM(:,1:Pdims(i),i))*t1'*t3(i,1));
       end;
     end;
     fprintf(' Residual error: %f \n\n',(1-min([max(abs(Corr(modesT',oldT'))),max(abs(Corr(modesS',oldS')))])));
  end; 
   
   results.mixing=A;
   results.dewhiteMat=DWM;
   results.timecourses=TC;
   results.B=modesB;
   results.S=modesS;
   results.T=modesT;
   results.reduced_data=dat2;
   results.PCAdims=Pdims;
   results.dimest=di;
   results.allDWM=pinv(tWMset);
