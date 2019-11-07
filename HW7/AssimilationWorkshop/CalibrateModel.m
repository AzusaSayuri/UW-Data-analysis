clear all

load AllData.mat

%select a particular year
WY=[1984 1985 1986 1987 1988]; 
[MetDataWY,PptDataWY,ValDataWY,~,Nt]=...
    SelectInputs(MetData,PptData,ValData,CourseData,WY);

Params.GUC=1; %Gauge undercatch. A multiplier on the amount of precipitation when it snows.
Params.SRC=0; %Snow/Rain Criteria. Air temperature below which precipitation is snow. (°C)
Params.Fmax=.06; %The maximum melt factor (mm day^-1 °C^-1)
Params.Fmin=.001; %The minimum melt factor (mm day^-1 °C^-1)
Params.Mlt=-3; %The air temperature below which no melt occurs (°C)

InitCond.SWE=0;

GUCs=[.75 : .25 : 2];
Fmaxs=[.025 : .025 : .2]; 

for i=1:length(GUCs),
    disp(['Crunching parameter set ' num2str(i) '/' num2str(length(GUCs))])
    for j=1:length(Fmaxs),
        
        Params.GUC=GUCs(i);
        Params.Fmax=Fmaxs(j);
        
        ModelWY = SnowModel(MetDataWY,PptDataWY,Params,InitCond);
        
        RMSE(i,j)=sqrt(mean( (ModelWY.SWE-ValDataWY.SWE').^2 ));
        bias(i,j)=mean(ModelWY.SWE-ValDataWY.SWE');
    end
end

figure(1)
pcolor(GUCs,Fmaxs,RMSE')
set(gca,'FontSize',14)
xlabel('Gage Undercatch factor')
ylabel('Fmax')
title('RMSE in mm')
colorbar

figure(2)
pcolor(GUCs,Fmaxs,bias')
set(gca,'FontSize',14)
xlabel('Gage Undercatch factor')
ylabel('Fmax')
title('Bias in mm')
load 'ZeroColormap'
colormap(C)
colorbar
colormapeditor  %<-- adjust until zero is white for clarity


%run model for optimal dataset: something around a gage undercatch of 2,
%    and an Fmax of 0.1 looks ok. However these parameter may not have any
%    real physical meaning.

Params.GUC=1.2; %Gauge undercatch. A multiplier on the amount of precipitation when it snows.
Params.SRC=0; %Snow/Rain Criteria. Air temperature below which precipitation is snow. (°C)
Params.Fmax=.05; %The maximum melt factor (mm day^-1 °C^-1)
Params.Fmin=.001; %The minimum melt factor (mm day^-1 °C^-1)
Params.Mlt=-3; %The air temperature below which no melt occurs (°C)
ModelWY = SnowModel(MetDataWY,PptDataWY,Params,InitCond);

figure(3)
plot(ModelWY.t,ModelWY.SWE,ValDataWY.t,ValDataWY.SWE)
set(gca,'FontSize',14)
datetick
title(['SWE for ' num2str(WY)])
ylabel('SWE, mm')
legend('Model','Obs')