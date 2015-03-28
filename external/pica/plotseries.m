function plotseries(tseries, i, j, k, x)

plot(tseries);

if(nargin>4)
   ho;
   if(size(x,4)>1)
      plot(x(i,j,k,:),'r');
   else
      plot(x,'r');
   end;
end;

title(sprintf('Slice %d; X: %d  Y: %d',k,i,j)); 

hold off;