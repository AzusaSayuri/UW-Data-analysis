%extract observations

clear all

load AllData.mat

WY=[1998 1999 2000 2001]; 
[MetDataWY,PptDataWY,ValDataWY,~,Nt]=SelectInputs(MetData,PptData,ValData,CourseData,WY);

dtObs=24; %daily observations
iObs=dtObs:dtObs:Nt-dtObs; %time indices when observations occur
tObs=ValDataWY.t(iObs); %the time vector when observations occur
NObs=length(tObs); %number of observations
H=zeros(NObs,Nt);  %observation matrix
for i=1:NObs,
    H(i,iObs(i))=1;
end
Z=H*ValDataWY.zSheltered*10; %this creates the observation sequence, and 
                             %  convert from cm to mm

stdZ=50; %uncertainty of the depth observations in mm
r=stdZ^2; %uncertainty error variance

save('ObservationsDepth.mat','Z','tObs','NObs','WY','stdZ','r','iObs')