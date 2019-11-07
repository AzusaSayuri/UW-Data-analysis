%extract observations

clear all

load AllData.mat

WY=[2000 2001]; 
[MetDataWY,PptDataWY,ValDataWY,Nt]=SelectInputs(MetData,PptData,ValData,WY);

dtObs=24; %daily observations
iObs=dtObs:dtObs:Nt-dtObs; %time indices when observations occur
tObs=ValDataWY.t(iObs); %the time vector when observations occur
NObs=length(tObs); %number of observations
H=zeros(NObs,Nt);  %observation matrix
for i=1:NObs,
    H(i,iObs(i))=1;
end
Z=H*ValDataWY.SWE; %this creates the observation sequence

stdZ=30; %uncertainty of the SWE observations in mm
r=stdZ^2; %uncertainty error variance

save('Observations.mat','Z','tObs','NObs','WY','stdZ','r','iObs')