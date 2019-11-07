clear all

tic

%% A) Get Inputs
%A.1) Load in Reynolds data
load AllData.mat

%A.2) Load in pre-processed observations 
load('ObservationsDepth.mat')

%A.3) select data to run a particular WY or years based on observations
[MetDataWY,PptDataWY,ValDataWY,CourseDataWY,Nt]=SelectInputs(MetData,PptData,ValData,CourseData,WY);

%% B) Setup for model run
%B.1) Define model parameters
NominalParams.GUC=1.0; %Gauge undercatch. A multiplier on the amount of precipitation when it snows.
NominalParams.SRC=1.09; %Snow/Rain Criteria. Air temperature below which precipitation is snow. (�C)
NominalParams.Fmax=.189; %The maximum melt factor (mm day^-1 �C^-1)
NominalParams.Fmin=.0260; %The minimum melt factor (mm day^-1 �C^-1)
NominalParams.Mlt=1.22; %The air temperature below which no melt occurs (�C)

%B.2) Set initial condition: zero SWE for beginning WY start date
InitCond.SWE=0;

%B.3) Define a temporally invariant density for the depth assimilations,
%and a derived measurement operator
rho = SnowDensitySturmAlpine(tObs,Z);
H=1000./rho;
H(isinf(H))=0;

%% C) Create ensemble of model inputs
% C.1) Precipitation ensemble. Create a log-normal distribution of 
% multipliers (b) to scale precipitation, constant all season. 
Nr=100;
covPrecip=0.2;
PrecipSeed=1; 
b = MakeEnsemble(Nr,covPrecip,PrecipSeed);

% C.2) Melt factor ensemble. Create a log-normal distribution of multipliers 
% (c) to scale the Fmax parameter, constant all season. 
covMeltFactor=0.4;
MFSeed=2;
c = MakeEnsemble(Nr,covMeltFactor,MFSeed);

tic

%% D Measurement Interval Loop
Filter.t=[]; Filter.Ens=[]; Filter.EnsNoPrior=[];
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
        yplus = UpdateSWEH(Z(i),Yens,r,Nr,H(i));
    end
    
    %D.5) Store the ensemble
    if i<NObs+1,
        Filter.Ens=[Filter.Ens; Yens; yplus;];
    else
        Filter.Ens=[Filter.Ens; Yens;];
    end
    
    %D.6) store an optimal estimate timeseries, without prior included
    if i<NObs+1,
        Filter.EnsNoPrior=[Filter.EnsNoPrior; Yens(1:end-1,:); yplus;];
    else
        Filter.EnsNoPrior=[Filter.EnsNoPrior; Yens;];
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
Filter.EstimateNoPrior=mean(Filter.EnsNoPrior,2);

SWEobs=Z./H';
SWEobs(H==0)=0;

RMSEobs=sqrt(mean( (SWEobs-ValDataWY.SWE(iObs)).^2 ));
RMSEmod=sqrt(mean( (OpenLoop.SWE'-ValDataWY.SWE).^2 ));
RMSEf=sqrt(mean( (Filter.EstimateNoPrior-ValDataWY.SWE).^2 ));


figure(1)
plot(OpenLoop.t,OpenLoop.SWE,'r-',Filter.t,Filter.Estimate,'b-',...
    ValDataWY.t,ValDataWY.SWE,'k-','LineWidth',2)
set(gca,'FontSize',14)
ylabel('SWE, mm')
legend('Open Loop','Filter','Snow pillow')
datetick


%visualize ensemble
figure(2)
h=plot(Filter.t,Filter.Ens,'--',Filter.t,Filter.Estimate,'r-');
set(h(1:end-1),'Color',[.7 .7 .7])
set(gca,'FontSize',14)
ylabel('SWE, mm')
datetick
title('Ensemble and mean')

%visualize density estimate
figure(3)
RhoTrue=CourseDataWY.SWE./(CourseDataWY.z.*10).*917; %this gives units kg/m3
plot(CourseDataWY.t,RhoTrue,'o',tObs,rho,'LineWidth',2)
set(gca,'FontSize',14)
datetick
legend('Observed bulk density','Sturm 2010',0)