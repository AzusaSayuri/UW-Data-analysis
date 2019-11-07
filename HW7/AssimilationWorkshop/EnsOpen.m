clear all

%read all data
% MetData = ReadMet('met_sheltered.txt');
% PptData = ReadPpt('ppt_sheltered.txt');
% ValData = ReadVal('val_q-swe-zs.txt');
load AllData.mat

%select a particular year
WY=2008; 
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

%run ensemble model, creating a state vector Y with dimension Nt x Nr
for i=1:Nr,
    %precipitation ensemble
    PptDataEns=PptDataWY;
    PptDataEns.Corr=PptDataEns.Corr*b(i);    
    
    %melt factor ensemble
    ParamEns=NominalParams;
    ParamEns.Fmax=NominalParams.Fmax*c(i);
    
    [ModelWY] = SnowModel(MetDataWY,PptDataEns,ParamEns,InitCond);
    ModelEnsemble.Y(1:Nt,i)=ModelWY.SWE';
end

ModelEnsemble.t=ModelWY.t;

figure(1)
h=plot(ModelEnsemble.t,ModelEnsemble.Y,'b--',ValDataWY.t,ValDataWY.SWE,'r-');
set(gca,'FontSize',14)
datetick
title(['SWE for ' num2str(WY)])
ylabel('SWE, mm')
legend(h([1 end]),'Model','Obs')
