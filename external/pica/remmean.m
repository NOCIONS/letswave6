function [newVectors, meanValue] = remmean (vectors);



newVectors = zeros (size (vectors));
meanValue = mean (vectors')';
newVectors = vectors - meanValue * ones (1,size (vectors, 2));