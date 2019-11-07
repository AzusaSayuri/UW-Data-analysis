function [Yens] = EnsembleModelIntegration(Nr,i,PptDataInterval,b,c,NominalParams,...
                  Filter,MetDataInterval)

%ensemble model integration
for j=1:Nr,
    %precipitation ensemble
    PptDataEns=PptDataInterval;
    PptDataEns.Corr=PptDataEns.Corr*b(j);    

    %melt factor ensemble
    ParamEns=NominalParams;
    ParamEns.Fmax=NominalParams.Fmax*c(j);        

    %initial condition selection
    if i==1,
        InitCond.SWE=0;
    else 
        InitCond.SWE=Filter.Ens(end,j);
    end

    %model call
    Model = SnowModel(MetDataInterval,PptDataEns,ParamEns,InitCond);

    %put together ensemble
    Yens(:,j)=Model.SWE';        
end  

return