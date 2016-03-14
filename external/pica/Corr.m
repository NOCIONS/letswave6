function [Res] = Corr(TC1, Data);
   
   NumRows=size(TC1,2);
   NumCols=size(Data,2);
   Res=zeros(NumRows,NumCols);
   
   for row=1:NumRows
      for col=1:NumCols
	 if mod(col,100)==0
	    fprintf('.');
	 end;
	 
	 tmp=corrcoef(TC1(:,row),Data(:,col));
	 Res(row,col)=tmp(1,2);
      end;
   end;
 