clear all

load AllData.mat

%select a particular year
WY=1980:1986; %[2006 2007 2008];
[MetDataWY,PptDataWY,ValDataWY,CourseDataWY,Nt]=...
    SelectInputs(MetData,PptData,ValData,CourseData,WY);

Params.GUC=1.2; %Gauge undercatch. A multiplier on the amount of precipitation when it snows.
Params.SRC=2; %Snow/Rain Criteria. Air temperature below which precipitation is snow. (°C)
Params.Fmax=.1; %The maximum melt factor (mm day^-1 °C^-1)
Params.Fmin=.0001; %The minimum melt factor (mm day^-1 °C^-1)
Params.Mlt=-3; %The air temperature below which no melt occurs (°C)

%plot up data
% figure(1)
% plot(MetDataWY.t,MetDataWY.Ta)
% set(gca,'FontSize',14)
% datetick
% title(['Air temperatures for WY' num2str(WY)])
% ylabel('Air temperature, °C')
% 
% figure(2)
% bar(PptDataWY.t,PptDataWY.Corr)
% set(gca,'FontSize',14)
% datetick
% title(['Precip. for WY' num2str(WY)])
% ylabel('Precipitation (corrected), mm')
% 
% figure(3)
% plot(ValDataWY.t,ValDataWY.SWE)
% set(gca,'FontSize',14)
% datetick
% title(['Measured SWE for WY' num2str(WY)])
% ylabel('SWE, mm')

%run model
InitCond.SWE=0;
[ModelWY] = SnowModel(MetDataWY,PptDataWY,Params,InitCond);

figure(4)
plot(ModelWY.t,ModelWY.SWE,ValDataWY.t,ValDataWY.SWE)
set(gca,'FontSize',14)
datetick
title(['SWE for ' num2str(WY)])
ylabel('SWE, mm')
legend('Model','Obs')