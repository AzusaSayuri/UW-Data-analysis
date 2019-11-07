clear all

tic

%% A) Get Inputs
%A.1) Load in Reynolds data
load AllData.mat

%A.2) Load in pre-processed observations 
load('ObservationsCourse.mat')

%A.3) select data to run a particular WY or years based on observations
[MetDataWY,PptDataWY,ValDataWY,CourseDataWY,Nt]=SelectInputs(MetData,PptData,ValData,CourseData,WY);

%% B) Setup for model run
%B.1) Define model parameters: calibrated
NominalParams.GUC=1; %Gauge undercatch. A multiplier on the amount of precipitation when it snows.
NominalParams.SRC=1; %Snow/Rain Criteria. Air temperature below which precipitation is snow. (°C)
NominalParams.Fmax=.19; %The maximum melt factor (mm day^-1 °C^-1)
NominalParams.Fmin=.026; %The minimum melt factor (mm day^-1 °C^-1)
NominalParams.Mlt=1.22; %The air temperature below which no melt occurs (°C)

%B.2) Set initial condition: zero SWE for beginning WY start date
InitCond.SWE=0;

%% C) Create ensemble of model inputs
% C.1) Precipitation ensemble. Create a log-normal distribution of 
% multipliers (b) to scale precipitation, constant all season. 
Nr=100;
covPrecip=0.4;  
PrecipSeed=1; 
b = MakeEnsemble(Nr,covPrecip,PrecipSeed);

% C.2) Melt factor ensemble. Create a log-normal distribution of multipliers 
% (c) to scale the Fmax parameter, constant all season. 
covMeltFactor=0.4;
MFSeed=2;
c = MakeEnsemble(Nr,covMeltFactor,MFSeed);

tic


%% D Ensemble Batch Smoother
% D.1) Calculate prior model ensemble
for i=1:Nr,
    %precipitation ensemble
    PptDataEns=PptDataWY;
    PptDataEns.Corr=PptDataEns.Corr*b(i);    
    
    %melt factor ensemble
    ParamEns=NominalParams;
    ParamEns.Fmax=NominalParams.Fmax*c(i);
    
    [ModelWY] = SnowModel(MetDataWY,PptDataEns,ParamEns,InitCond);
    ModelEnsemble.Yminus(1:Nt,i)=ModelWY.SWE';
end

ModelEnsemble.t=ModelWY.t;

%D.2) Set up measurement operator
tObs=ValDataWY.t(iObs);
NObs=length(tObs);
H=zeros(NObs,Nt);  
for i=1:NObs,
    H(i,iObs(i))=1;
end

%D.3) Kalman-type ensemble batch smoother
stdZ=10;
R=stdZ^2*eye(NObs); %observation covariance matrix
ModelEnsemble.YminusMean=mean(ModelEnsemble.Yminus,2);
Ytilde=ModelEnsemble.Yminus-ModelEnsemble.YminusMean*ones(1,Nr);
P=1./(Nr-1).*Ytilde*Ytilde'; %calculation of model error covariance matrix
K=P*H'/(H*P*H'+R);
for i=1:Nr,
    ModelEnsemble.Yplus(:,i)=ModelEnsemble.Yminus(:,i)+K*(Z-H*ModelEnsemble.Yminus(:,i));
end
ModelEnsemble.YplusMean=mean(ModelEnsemble.Yplus,2);

%% E) Evaluation
%E.1) Calculate open loop
OpenLoop.SWE=ModelEnsemble.YminusMean';


%E.2) error metrics
RMSEobs=sqrt(mean( (Z-ValDataWY.SWE(iObs)).^2 ));
RMSEmod=sqrt(mean( (OpenLoop.SWE'-ValDataWY.SWE).^2 ));
RMSEf=sqrt(mean( (ModelEnsemble.YplusMean-ValDataWY.SWE).^2 ));

%E.3) Plots
figure(1) 
plot(ModelEnsemble.t,ModelEnsemble.YminusMean,'r-',ModelEnsemble.t,...
    ModelEnsemble.YplusMean,'g-',ValDataWY.t,ValDataWY.SWE,'b-',...
    tObs,Z,'ko');
set(gca,'FontSize',14)
datetick
title(['SWE for ' num2str(WY)])
ylabel('SWE, mm')
legend('Prior Mean','Posterior Mean','Truth','Obs')



toc