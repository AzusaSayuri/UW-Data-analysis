function [yplus] = UpdateSWEH(z,Yens,r,Nr,H)

yminus=Yens(end,:);
p=var(yminus);
k=p*H/(H*p*H+r);    
for j=1:Nr,
    yplus(j)=yminus(j)+k*(z-H*yminus(j));
end

return