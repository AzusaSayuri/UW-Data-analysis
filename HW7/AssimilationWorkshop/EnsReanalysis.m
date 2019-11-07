clear all

tic

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
    ModelEnsemble.Yminus(1:Nt,i)=ModelWY.SWE';
end

ModelEnsemble.t=ModelWY.t;

%Perform weak-constraint reanalysis... as a first start, use weekly data
iObs=7*24:7*24:Nt;
tObs=ValDataWY.t(iObs);
NObs=length(tObs);
H=zeros(NObs,Nt);  
for i=1:NObs,
    H(i,iObs(i))=1;
end
Z=H*ValDataWY.SWE;

%Kalman-type ensemble reanalysis calculations
R=10^2*eye(NObs); %observation covariance matrix
ModelEnsemble.YminusMean=mean(ModelEnsemble.Yminus,2);
Ytilde=ModelEnsemble.Yminus-ModelEnsemble.YminusMean*ones(1,Nr);
P=1./(Nr-1).*Ytilde*Ytilde'; %calculation of model error covariance matrix
K=P*H'/(H*P*H'+R);
for i=1:Nr,
    ModelEnsemble.Yplus(:,i)=ModelEnsemble.Yminus(:,i)+K*(Z-H*ModelEnsemble.Yminus(:,i));
end
ModelEnsemble.YplusMean=mean(ModelEnsemble.Yplus,2);

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