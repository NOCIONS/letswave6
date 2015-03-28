function [factors] = myparafac(dat, num, itt, mask, lambda, A, B, C, demean, vn)

flops(0)
if (nargin<2)
   num = 10
end;

if (nargin<3)
   itt = 10;
end;

if (nargin<4)
   mask=ones(1,size(dat,2));
end;

if((size(mask,2)==size(dat,2))&(sum(mask)<size(dat,2)))
     dat=dat(:,mask,:);
end;

if (nargin<5)
   lambda = 0.2;
end;

if (nargin<6)
  
   t1=mean(dat,3);
   [ws,wm,dwm]=hyv_ica(t1,'only','white','lastEig',num);
   A=dwm;
   B=ws';
%A=randn(size(dat,1),num);
%B=randn(size(dat,2),num);
end
if (nargin<8)
   C=randn(size(dat,3),num);
end
 

if(nargin<10)
   demean=1;
   vn=0;
end;


for i=1:size(dat,3)
   i
  t=squeeze(dat(:,:,i));
  t=remmean(t')';
  t2=remmean(t);
  if (vn>0)
     [ws,wm,dwm]=hyv_ica(t2,'only','white','verbose','on');
     ws(ws<1)=0;
     t3=std(t2-dwm*ws);
     
     t=t./(ones(size(t,1),1)*t3);
  end;
      
  dat(:,:,i)=remmean(t);
%   t2=std(t);
%   t2(t2==0)=1;
%   dat(:,:,i)=t./(ones(size(dat,1),1)*t2);
end   
  

for l=1:itt
   fprintf('.');
   
%%%%%% update A

P=zeros(size(A));
t1=pinv(B'*B);
t3=C*pinv(C'*C);
for i=1:size(A,1)
   t2=B'*squeeze(dat(i,:,:));
   P(i,:)=diag(t1*t2*t3)';
end

t1=zeros(size(A));
t2=B'*B;
t3=lambda*eye(num);
for k=1:size(dat,3)
   dCk=diag(C(k,:));
   t1=t1+(squeeze(dat(:,:,k))*B)*dCk;
   t3=t3+dCk*t2*dCk;
end
t3=pinv(t3);

A=(t1+lambda*P)*t3;
%size(A)

%%%%%% update B

P=zeros(size(B));
t1=pinv(C'*C);
t3=A*pinv(A'*A);
for i=1:size(B,1)
%   if mod(i,10000)==0
%      i
%   end
   t2=C'*(squeeze(dat(:,i,:)))';
   P(i,:)=diag(t1*t2*t3)';
end

%size(P)

t1=zeros(size(B));
t2=C'*C;
t3=lambda*eye(num);
for k=1:size(dat,1)
%   if mod(k,10)==0
%      k
%   end
   dCk=diag(A(k,:));
   t1=t1+(squeeze(dat(k,:,:))*C)*dCk;
   t3=t3+dCk*t2*dCk;
end
t3=pinv(t3);

B=(t1+lambda*P)*t3;
%size(B)

%%%%%% update C

P=zeros(size(C));
t1=pinv(A'*A);
t3=B*pinv(B'*B);
for i=1:size(C,1)
%   if mod(i,10)==0
%      i
%   end
   t2=A'*(squeeze(dat(:,:,i)));
   P(i,:)=diag(t1*t2*t3)';
end

%size(P)

t1=zeros(size(C));
t2=A'*A;
t3=lambda*eye(num);
for k=1:size(dat,2)
%   if mod(k-1,10000)==0
%      k+1
%   end
   dCk=diag(B(k,:));
   t1=t1+(squeeze(dat(:,k,:))'*A)*dCk;
   t3=t3+dCk*t2*dCk;
end
t3=pinv(t3);

C=(t1+lambda*P)*t3;

%ICAtimedisplay(A)
%ICAdisplay(B',A,'background',~mask)
end

factors.A=A;
factors.B=B;
factors.C=C;
factors.flops=flops;
%ICAdisplay(B',A,'background',~mask)
%ICAtimedisplay(C')
