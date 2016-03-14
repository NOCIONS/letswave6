function [mat]=krprod(A,B)
% KRPROD Kathri-Rao product
%    KRPROD(X,Y) is the Kathri-Rao product of X and Y
%    The result is a larger matrix formed by the column 
%    vectors of X stacked multiple times, each time scaled 
%    the corresponding values from the associated column in Y.
%    For example, if Y is 2 by 3, then KRPROD(X,Y) is
%
%       [ X(:,1)*Y(1,1) X(:,2)*Y(1,2) X(:,3)*Y(1,3)
%         X(:,1)*Y(2,1) X(:,2)*Y(2,2) X(:,3)*Y(2,3) ]
%
%    X and Y need to have the same number of columns
%
%    See also KRFACT, KRAPPROX

%    (c) Christian F. Beckmann
%        FMRIB Centre
%        University of Oxford
%    


if (size(A,2)~=size(B,2))
  error('Input matrices need to have the same number of column vectors');
end;

mat=zeros(size(A,1)*size(B,1),size(A,2));

for i=1:size(A,2)
  mat(:,i)=kron(B(:,i),A(:,i));
end;
