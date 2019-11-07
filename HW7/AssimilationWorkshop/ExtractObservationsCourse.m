%extract observations

clear all

%load in data from the Reynolds sheltered site
load AllData.mat

WY=[2000 2001 2002 2003 ]; 
%WY=1995:1998; [1989 1990 1991 1992 ]; 
[MetDataWY,PptDataWY,ValDataWY,CourseDataWY,Nt]=...
    SelectInputs(MetData,PptData,ValData,CourseData,WY);

tObs=CourseDataWY.t; %the time vector when observations occur: use all

%now calculate iObs, which are the hourly indices of the forcing data at
%which the observations occur. should be unique & exact find
for i=1:length(tObs),
    iObs(i)=find(MetDataWY.t==tObs(i));
end

NObs=length(tObs); %number of observations
Z=CourseDataWY.SWE; %this creates the observation sequence

stdZ=30; %uncertainty of the depth observations in cm
r=stdZ^2; %uncertainty error variance

save('ObservationsCourse.mat','Z','tObs','NObs','WY','stdZ','r','iObs')