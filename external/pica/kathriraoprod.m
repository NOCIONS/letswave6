function [mat]=kathriraoprod(A,B)
% calculates the Kathri-Rao product of the two matrices


if (size(A,2)~=size(B,2)) then
  fprintf(['Input matrices need to have the same number of column ' ...
           'vectors']);
  exit(1);
end;

