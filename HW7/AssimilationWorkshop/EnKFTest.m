clear all

tic

%% A) Get Inputs
%A.1) read Reynolds Creek data
% MetData = ReadMet('met_sheltered.txt');
% PptData = ReadPpt('ppt_sheltered.txt');
% ValData = ReadVal('val_q-swe-zs.txt');
% save('AllData.mat','MetData','PptData','ValData');
load AllData.mat

%% B) Get observations and related information
load('Observations.mat')

%A.2) select data to run a particular WY or years based on observations
[MetDataWY,PptDataWY,ValDataWY,Nt]=SelectInputs(MetData,PptData,ValData,WY);

%A.3) Define model parameters
NominalParams.GUC=1; %Gauge undercatch. A multiplier on the amount of precipitation when it snows.
NominalParams.SRC=0; %Snow/Rain Criteria. Air temperature below which precipitation is snow. (°C)
NominalParams.Fmax=.06; %The maximum melt factor (mm day^-1 °C^-1)
NominalParams.Fmin=.003; %The minimum melt factor (mm day^-1 °C^-1)
NominalParams.Mlt=-5; %The air temperature below which no melt occurs (°C)

%A.4) Set initial condition: zero SWE for beginning WY start date
InitCond.SWE=0;

%% B) Create ensemble of model inputs
% B.1) Precipitation ensemble. Create a log-normal distribution of 
% multipliers (b) to scale precipitation, constant all season. 
Nr=100;
covPrecip=0.2;
PrecipSeed=1; 
b = MakeEnsemble(Nr,covPrecip,PrecipSeed);

% B.2) Melt factor ensemble. Create a log-normal distribution of multipliers 
% (c) to scale the Fmax parameter, constant all season. 
covMeltFactor=0.4;
MFSeed=2;
c = MakeEnsemble(Nr,covMeltFactor,MFSeed);

tic

%% D Measurement Interval Loop
Filter.t=[]; Filter.Ens=[];
for i=1:NObs+1,
    %D.1) identify the indices of the model to run
    [iIntvl,Filter] = getInterval(i,iObs,NObs,Nt,Filter,MetDataWY);
    
    %D.2) Select Meteorological data for this measurement interval
    MetDataInterval = SelectData(MetDataWY,iIntvl);
    PptDataInterval = SelectData(PptDataWY,iIntvl);                

    %D.3) Ensemble model integration
    Yens=EnsembleModelIntegration(Nr,i,PptDataInterval,b,c,NominalParams,...
          Filter,MetDataInterval);

    %D.4) Update
    if i<NObs+1,
        yplus = UpdateSWE(Z(i),Yens,r,Nr);
    end
    
    %D.5) Store the ensemble
    if i<NObs+1,
        Filter.Ens=[Filter.Ens; Yens; yplus;];
    else
        Filter.Ens=[Filter.Ens; Yens;];
    end
    clear Yens
end

toc

%% E) Evaluation
%E.1) For comparison calculate the open loop model run with nominal inputs
InitCond.SWE=0;
OpenLoop = SnowModel(MetDataWY,PptDataWY,NominalParams,InitCond);

%E.2) Calculate filter estimate
Filter.Estimate=mean(Filter.Ens,2);

figure(1)
plot(OpenLoop.t,OpenLoop.SWE,'r-',Filter.t,Filter.Estimate,'b-',...
    ValDataWY.t,ValDataWY.SWE,'k-','LineWidth',2)
set(gca,'FontSize',14)
datetick