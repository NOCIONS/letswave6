function [W,Y,val] = pca(X,nbc)
% pca() - Principal Component Analysis (PCA)
%
% Usage:
%   >> [W,Y] = pca(X,nbc)
%
% Inputs:
%   X       - data matrix (d x N, data channels are rowwise) 
%   nbc     - number of principal components (def: d)
% 
% Output:
%   W               - Separation matrix (nbc x d)
%   Y               - Principal components (nbc x N)


% Copyright (C) <2006>  <German Gomez-Herreror>
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

if nargin < 2 || nbc>size(X,1), nbc = size(X,1); end

[M,N] = size(X);
% subtract off the mean for each dimension
mn = mean(X,2);
X = X - repmat(mn,1,N);
C = cov(X');
[V,D] = eig(C);
[val,I] = sort(abs(diag(D)),'descend');
V = V(:,I(1:nbc));
tmp =diag(D);
D = diag(tmp(I(1:nbc)));
W = D^(-.5)*V';
Y = W*X;
