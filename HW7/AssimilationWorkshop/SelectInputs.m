function [MetDataWY,PptDataWY,ValDataWY,CourseDataWY,Nt]=...
    SelectInputs(MetData,PptData,ValData,CourseData,WY)

%Note: the MetData, PptData, and ValData are hourly, but CourseData is biweekly
iWY=any(ones(length(MetData.t),1)*WY==MetData.WY*ones(1,length(WY)),2);
MetDataWY = SelectData(MetData,iWY);
PptDataWY = SelectData(PptData,iWY);
ValDataWY = SelectData(ValData,iWY);

iWY=any(ones(length(CourseData.t),1)*WY==CourseData.WY*ones(1,length(WY)),2);
CourseDataWY = SelectData(CourseData,iWY);
Nt=length(MetDataWY.t);

return