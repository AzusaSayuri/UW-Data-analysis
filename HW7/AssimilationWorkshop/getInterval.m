function [iIntvl,Filter] = getInterval(i,iObs,NObs,Nt,Filter,MetDataWY)

if i==1,
    iIntvl=1:iObs(1);
elseif i<NObs+1
    iIntvl=iObs(i-1)+1:iObs(i);
elseif i==NObs+1,
    iIntvl=iObs(end)+1 : Nt;
end

if i==NObs+1,
    Filter.t=[Filter.t; MetDataWY.t(iIntvl)]; 
else
    Filter.t=[Filter.t; MetDataWY.t(iIntvl); MetDataWY.t(iObs(i));];        
end

return