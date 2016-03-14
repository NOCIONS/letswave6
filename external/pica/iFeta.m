function [Result] = iFeta(eta,d1,d2);
   
  res = d1*(1-Feta(eta,d1/d2));
 
  Result = zeros(1,d1);
  
  for k= 1 : d1;
     Result(k) = eta(max(find(res>=k)));
  end;
  