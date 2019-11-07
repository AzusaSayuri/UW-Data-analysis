function [yplus] = UpdateSWE(z,Yens,r,Nr)

yminus=Yens(end,:);
p=var(yminus);
k=p/(p+r);    
for j=1:Nr,
    yplus(j)=yminus(j)+k*(z-yminus(j));
end

return