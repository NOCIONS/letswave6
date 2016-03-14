function [g] = gauss1(sigma,varargin)
% GAUSS   Creates a gaussian function
%    GAUSS(sigma,n) is an n-by-n gaussian matrix (st.dev = sigma)
%    GAUSS(sigma,m,n) is an m-by-n gaussian matrix (st.dev = sigma)
%    The result is normalised so that the Gaussian sums to 1

if (length(varargin)<1),
  disp('GAUSS must have at least two parameters');
  return;
end
m=varargin{1};
if (length(varargin)>1),
  n=varargin{2};
else
  n=m;
end
mx=(n+1)/2;
my=(m+1)/2;
x=kron(ones(m,1),(1:n)-mx);
y=kron(ones(1,n),(1:m).'-my);
if (length(varargin)<=2),
  g=exp(-(x.^2+y.^2)/(2*sigma^2));
  g=g/sum(sum(g));
  return;
end
if (length(varargin)>3),
  disp('GAUSS cannot create Gaussians in more than 3 dimensions... yet')
  return;
end

p=varargin{3};
mz=(p+1)/2;
bigz=zeros(m,n,p);
bigx=zeros(m,n,p);
bigy=zeros(m,n,p);
for q=1:p,
  bigz(:,:,q)=q-mz;
  bigx(:,:,q)=x;
  bigy(:,:,q)=y;
end
g=exp(-(bigx.^2 + bigy.^2 + bigz.^2)/(2*sigma^2));
g=g/sum(sum(sum(g)));
