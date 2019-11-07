function [Model] = SnowModel(MetData,PptData,Params,InitCond)

%from Slater et al., Adv WR 2013, Appendix B

Ctrl.nt=length(MetData.t);

%Locals
% At ~ accumulation [mm]
% DOY ~ 
% MFAC ~
% MELT ~ 

Model.t=MetData.t;

for i=1:Ctrl.nt,
        
    %1) Accumulate snow if appropriate: use the corrected data
    if MetData.Ta(i)<Params.SRC,
        At=PptData.Corr(i)*Params.GUC;        
    else
        At=0;
    end
    
    if i==1,
        Model.SWE(i)=InitCond.SWE+At;
    else
        Model.SWE(i)=Model.SWE(i-1)+At;
    end
    
    %2) Phase shift day of year    
%     DOY = dayofyear(MetData.Yr(i),MetData.Month(i),MetData.Day(i));
    MDOY=MetData.DOY(i)-366/4+10;
    
    %3) Compute the melt factor for a given day of the year
    MFAC=(Params.Fmax+Params.Fmin)/2+(sin(2*pi*MDOY)/366*(Params.Fmax+Params.Fmin)/2 );
        
    %4) Compute the potential melt:
    if MetData.Ta(i)>Params.Mlt,
        MELT=MFAC*(MetData.Ta(i)-Params.Mlt);
    else
        MELT=0;
    end
    
    %5) Update the SWE:
    Model.SWE(i)=max(Model.SWE(i)-MELT,0);
    
end

return