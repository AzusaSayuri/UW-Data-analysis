clear all

tic

%read all data
% MetData = ReadMet('met_sheltered.txt');
% PptData = ReadPpt('ppt_sheltered.txt');
% ValData = ReadVal('val_q-swe-zs.txt');
load AllData.mat

%select a particular year
WY=1990; 
iWY=MetData.WY==WY;  
MetDataWY = SelectData(MetData,iWY);
PptDataWY = SelectData(PptData,iWY);
ValDataWY = SelectData(ValData,iWY);
Nt=length(MetDataWY.t);

%Define model parameters
NominalParams.GUC=1; %Gauge undercatch. A multiplier on the amount of precipitation when it snows.
NominalParams.SRC=0; %Snow/Rain Criteria. Air temperature below which precipitation is snow. (°C)
NominalParams.Fmax=.06; %The maximum melt factor (mm day^-1 °C^-1)
NominalParams.Fmin=.001; %The minimum melt factor (mm day^-1 °C^-1)
NominalParams.Mlt=-5; %The air temperature below which no melt occurs (°C)

%Initial condition
InitCond.SWE=0;

%create a log-normal distribution of multipliers (b) to scale precipitation,
%constant all season. cov=std/m
Nr=100;
covPrecip=0.3;
b = MakeEnsemble(Nr,covPrecip);

%create a log-normal distribution of multipliers (c) to scale the Fmax parameter,
%constant all season. cov=std/m
covMeltFactor=0.4;
c = MakeEnsemble(Nr,covMeltFactor);

%Set up the observations and the observation matrix, H. Here, example is
%shown using weekly data
iObs=7*24:7*24:Nt;
tObs=ValDataWY.t(iObs);
NObs=length(tObs);
H=zeros(NObs,Nt);  
for i=1:NObs,
    H(i,iObs(i))=1;
end
Z=H*ValDataWY.SWE;
r=10^2;

%Initial condition
InitCond.SWE=0;

tic

% measurement window loop. note that the length of tEns and the associated
% states are all equal to Nt + Nobs, since the prior and posterior are
% effectively included in the state at each update
Filter.t=[]; Filter.Ens=[];
for i=1:NObs+1,
    %identify the indices of the model to run
    if i==1,
        iIntvl=1:iObs(1);
    elseif i<NObs+1
        iIntvl=iObs(i-1)+1:iObs(i);
    elseif i==NObs+1,
        iIntvl=iObs(end)+1 : Nt;
    end
    
    %assemble the time vector
    if i==NObs+1,
        Filter.t=[Filter.t; MetDataWY.t(iIntvl)]; 
    else
        Filter.t=[Filter.t; MetDataWY.t(iIntvl); MetDataWY.t(iObs(i));];        
    end
    
    %nominal met data selection
    MetDataInterval = SelectData(MetDataWY,iIntvl);
    PptDataInterval = SelectData(PptDataWY,iIntvl);
                
    %ensemble model integration
    for j=1:Nr,
        %precipitation ensemble
        PptDataEns=PptDataInterval;
        PptDataEns.Corr=PptDataEns.Corr*b(j);    

        %melt factor ensemble
        ParamEns=NominalParams;
        ParamEns.Fmax=NominalParams.Fmax*c(j);        
        
        %initial condition selection
        if i>1,
            InitCond.SWE=Filter.Ens(end,j);
        end
        
        %model call
        Model = SnowModel(MetDataInterval,PptDataEns,ParamEns,InitCond);
        
        %put together ensemble
        Yens(:,j)=Model.SWE';        
    end   
    
    %no update: just set yplus = yminus
    yminus=Yens(end,:);
    yplus=yminus;
    
    %storing the ensemble    
    if i<NObs+1,
        Filter.Ens=[Filter.Ens; Yens; yplus;];
    else
        Filter.Ens=[Filter.Ens; Yens;];
    end
    clear Yens
end

toc

%for comparison calculate the open loop, and the filter estimate
InitCond.SWE=0;
OpenLoop = SnowModel(MetDataWY,PptDataWY,NominalParams,InitCond);
Filter.Estimate=mean(Filter.Ens,2);

figure(1)
plot(OpenLoop.t,OpenLoop.SWE,'r-',Filter.t,Filter.Estimate,'b-',...
    ValDataWY.t,ValDataWY.SWE,'k-')
datetick