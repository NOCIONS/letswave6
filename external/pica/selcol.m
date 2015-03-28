function newMatrix = selcol (oldMatrix, maskVector);


if size (maskVector, 1) ~= size (oldMatrix, 2),
  error ('The mask vector and matrix are of uncompatible size.');
end

numTaken = 0;

for i = 1 : size (maskVector, 1),
  if maskVector (i, 1) == 1,
    takingMask (1, numTaken + 1) = i;
    numTaken = numTaken + 1;
  end
end

newMatrix = oldMatrix (:, takingMask);
