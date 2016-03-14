function [X,Y,rank1]=krfact(mat,N)
% KRFACT Kathri-Rao product
%    [X,Y,rank1]= KRFACT(Z,N) is the Kathri-Rao factorisation 
%    of Z into two matrices X and Y such that Z = KRPROD(X,Y)
%    The result is a larger matrix formed by the column 
%    vectors of Y stacked multiple times, each time scaled 
%    the corresponding values from the associated column in Y.
%    For example, if Y is 2 by 3, then KRPROD(X,Y) is
%
%       [ X(:,1)*Y(1,1) X(:,2)*Y(1,2) X(:,3)*Y(1,3)
%         X(:,1)*Y(2,1) X(:,2)*Y(2,2) X(:,3)*Y(2,3) ]
%
%    N needs to be a factor of the number of rows of Z
%    mat is expected to have zero-mean columns
%    X is estimated such that every column is zero mean and unit 
%      standrad deviation
%    rank1 gives the amount of explained variance per column approximation
%
%    See also KRPROD, KRAPPROX

%    (c) Christian F. Beckmann
%        FMRIB Centre
%        University of Oxford

rows=size(mat,1);
cols=size(mat,2);

if (isempty(intersect(factor(rows),N)))
  error('N needs to be a factor of the number of rows in the input matrix');
end;

X=zeros(rows/N,cols);
Y=zeros(N,cols);
rank1=zeros(1,cols);

for k=1:cols
  TC=(reshape(mat(:,k),rows/N,N));
  TCmean=mean(TC);
  [t1,t2,t3]=hyv_ica(TC','only','white','lastEig',1,'verbose','off');
  X(:,k)=t1';
  Y(:,k)=t3;
  [tmp1,tmp2]=hyv_ica(TC,'only','pca','verbose','off');
  rank1(1,k)=tmp2(1,1)./sum(diag(tmp2));
end;
   
