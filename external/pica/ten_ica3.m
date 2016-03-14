function [results] = ten_ica3(dirnames, mask, fnames, numPCA, numICA, ...
                             vn, maxnumits, epsilon, spatial_mask)   

   if(nargin<9), spatial_mask = 0;end
   if(nargin<8), epsilon = 0.03;end
   if(nargin<7), maxnumits=99; end  
   if(nargin<6), vn=1; end
   if(nargin<5), numICA=0; end
   if(nargin<4), numPCA=0; end

   num_files=size(dirnames,1);
   tmp=read_avw(char(strcat(dirnames(1,:),fnames)));
   num_vols=size(tmp,4);
   num_vox=sum(mask);
   num_samples=100;
   sample_size=8;
   
   di=[];
   di2=[];
   dat2=[];
   DWM=[];
   Means1=[];
   Means2=[];
   
   Pdims=zeros(1,num_files);
   DCovM=zeros(num_vols,num_vols);
   DWM=zeros(num_vols/2,numPCA,num_files);
   samples=zeros(num_samples,num_files/2);
  
   fprintf('\n Data pre-processing (%i files)\n',num_files);
     
   for k=1:num_files
     fprintf('   Reading data file %i : %s\n',k,char(strcat(dirnames(k,:),fnames)));
     t1=read_avw(char(strcat(dirnames(k,:),fnames)));
     t1=reshape(t1,prod(size(t1))./num_vols,num_vols)';
     t1=t1(:,mask);
     m1=mean(t1);
     Means1=[Means1; m1];
     t1=remmean(t1')';
     exec_str=strcat('save raw',num2str(k),'.mat t1');
     eval(exec_str);
     m2=mean(t1');
     t2=remmean(t1);
     if (vn>0)
       [ws,wm,dwm]=hyv_ica(t2,'lastEig',min(30,size(t2,1)-1),'only','white','verbose','off');
       ws(abs(ws)<1.6)=0;
       t3=std(t2-dwm*ws);
       %t3=std(t1);
       t1=t1./(ones(size(t1,1),1)*t3);
     end;
 
     m2=mean(t1');
     Means2=[Means2;m2];
     t1=powerspec(t1);
    
     if numPCA<1
	
	 [tE,tD]=hyv_ica(t1,'only','pca','verbose','off');
	 tD=diag(tD)';
	 tD=fliplr(sort(tD./iFeta([0.01:0.01:5],size(tD,2),size(t1,2))));

	 di=pca_dim(tD,size(tD,2),size(t1,2));
	  
	 numRed=find(di.lap==max(di.lap))+2;
	 numRed=min(60,numRed(1));

      else
	 numRed=numPCA;
      end;
      Pdims(1,k)=numRed;     
      fprintf('PCA dimensionality reduction: %i \n', numRed);
      [tWS,tWM,tDWM]=hyv_ica(t1,'only','white','lastEig',numRed,'verbose','off'); 
      dat2=[dat2; tWS];
      blah=tDWM;
      DWM(:,1:size(blah,2),k) = blah;
      Pdims(1,k)=numPCA;
   end
    
   fprintf('\n');
   fprintf('   Data size: %i x %i \n\n',size(dat2,1),size(dat2,2));

   %%%%%%%%%%%%%%%%%%%%%%%  joint ICA 
   fprintf('Tensor - ICA estimation \n\n');
   
   if numICA<1     
      tmpCovar = zeros(numPCA);
      for i=1:num_files
	c=cumsum([0 Pdims]);
	tmpCovar=tmpCovar+cov(dat2(1+c(i):c(i+1),:)');
      end;
      [tE,tD]=pcamat(tmpCovar,1,numPCA,'off','off',0,'on');
      tD=diag(tD)';
      tD=fliplr(sort(tD./iFeta([0.01:0.01:5],size(tD,2),num_vox/6))); ...
         
      di2=pca_dim(tD,size(tD,2),size(dat2,2));
      numICA=min(3+find(di2.lap==max(di2.lap)),min(find((cumsum(tD)./sum(tD)>0.99)==1)));
   end;
   
   fprintf('   number of components: %i \n\n', numICA);

   for k=1:num_samples;
     samples(k,:)=2*randperm(num_files/2)-1+(rand(1,num_files/2)>0.5);
   end;
   samples=samples(:,1:sample_size);  
   
     
   rounds = maxnumits+5;
   newGuess = randn(size(dat2,1),numICA);
   rank1var=zeros(1,numICA);

   new_mask=zeros(1,num_vox);
   modesT=randn(numICA,num_vols);
   modesB=zeros(numICA,num_vox);
   modesS=randn(numICA,num_files);
   oldT=randn(size(modesT));
   oldS=randn(size(modesS));
   itt_ctr2=0;

   new_mask=max(abs(dat2));
   tmp_mix=ggmfit(new_mask,2,'ggm',[]);
   new_mask=new_mask>tmp_mix.mus(1)+tmp_mix.sig(1);  

   
   
   samples=sort(samples,2);
   
   IC=zeros(numICA,num_vox);
   A=zeros(sample_size*numPCA,numICA);
   W=zeros(numICA,sample_size*numPCA);
   
   for k=1:num_samples
     fprintf('   Estimating sample %i\n',k);
     dat3=dat2([(samples(k,1)-1)*numPCA+1:samples(k,1)*numPCA],:);
     for l=2:sample_size;
       dat3=[dat3;dat2([(samples(l,1)-1)*numPCA+1:samples(l,1)*numPCA],:)];
     end;
     
     [newtmpE,newtmpD]=empca(dat3(:,new_mask),numICA);
     newtmpWM=inv(sqrt(diag(newtmpD))) * newtmpE';
     newtmpDWM=pinv(newtmpWM);
     newtmpWS=newtmpWM*dat3;
     [IC,A,W,rounds, minAbsCos]=hyv_ica(dat3,'pcaE',newtmpE,'pcaD',newtmpD,'whiteSig',newtmpWS,'whiteMat',newtmpWM,'dewhiteMat',newtmpDWM,'lastEig',numICA,'epsilon',0.0001,'verbose','off');
     
     exec_str=strcat('save second',num2str(k),['.mat IC A W rounds minAbsCos ' ...
                         'DWM k samples']);
     eval(exec_str);
     
     
     
     
     save second IC A W rounds minAbsCos DWM k samples
   end;
   
   
   
   
   [newtmpE,newtmpD]=empca(dat3(:,new_mask),numICA);
   newtmpWM=inv(sqrt(diag(newtmpD))) * newtmpE';
   newtmpDWM=pinv(newtmpWM);
   newtmpWS=newtmpWM*dat3;
   residual_error=1;
   
      
   while ( residual_error >epsilon) & (itt_ctr2 < 30);
     oldT=modesT;
     oldS=modesS;
     fprintf('   ICA estimation (iteration %i)\n',itt_ctr2);
     itt_ctr2 = itt_ctr2 +1;
     new_mask=ones(1,size(dat2,2));

     [IC,A,W,rounds, minAbsCos]=hyv_ica(dat2,'pcaE',newtmpE,'pcaD',newtmpD,'whiteSig',newtmpWS,'whiteMat',newtmpWM,'dewhiteMat',newtmpDWM,'lastEig',numICA,'epsilon',0.0001,'verbose','off','maxNumIterations',maxnumits,'initGuess',newGuess);
     fprintf('   number of iterations: %i , residual error: %f\n',rounds,1-minAbsCos);

%     IC=W*dat2;
 %    new_mask=max(abs(IC));
 %    tmp_mix=ggmfit(new_mask,2,'ggm',[]);
 %    new_mask=new_mask>tmp_mix.mus(1)+tmp_mix.sig(1);
     fprintf('   number of voxels included: %i\n', sum(new_mask));
     
   %%%%%%%%%%%%%%%%%%%%%%%  reconstruct original TC 
   fprintf('   Reconstruct original TC \n');
  
   for k=1:numICA
      for i=1:num_files
	c=cumsum([0 Pdims]);
	TC(:,k,i)=squeeze(DWM(:,1:Pdims(i),i))*A(1+c(i):c(i+1),k);
      end;
   end;

   %%%%%%%%%%%%%%%%%%%%%%%  rank-one approx. 

   %fprintf('   Rank 1 approximation for the time courses \n');
   newGuess = zeros(size(A));
   
   for k=1:numICA
      TC2=squeeze(TC(:,k,:))';
      [t1,t2,t3]=hyv_ica(TC2,'only','white','lastEig',1,'verbose','off');
      modesT(k,:)=t1;
      modesS(k,:)=t3';
      modesB(k,:)=IC(k,:);
      [blah1,blah2]=hyv_ica(TC2,'only','pca','verbose','off');
      rank1var(1,k)=blah2(1,1)./sum(diag(blah2));
      for i=1:num_files
        newGuess(1+c(i):c(i+1),k) = squeeze(pinv(DWM(:,1:Pdims(i),i))*t1'*t3(i,1));
      end;
   end;
   
   residual_error = 1-min(abs(diag(Corr(modesT',oldT'))));
                       
   fprintf('   Residual error (Tmodes): %f \n\n',residual_error);
   
   if itt_ctr2 <5, residual_error = 1; end
  end; 

   
   [tmpS,tmpSind]=(sort(abs(median(modesS'))));
   tmpSind=fliplr(tmpSind);
   
   results.mixing=A(:,tmpSind);
   results.dewhiteMat=DWM;
   results.timecourses=TC(:,tmpSind,:);
   results.B=modesB(tmpSind,:);
   results.S=modesS(tmpSind,:);
   results.T=modesT(tmpSind,:);
   results.reduced_data=dat2;
   results.PCAdims=Pdims;
   results.PCAdimest=di;
   results.ICAdimest=di2;
   results.rank1var=rank1var(tmpSind);