function PptData = ReadPpt(fname)

fid=fopen(fname,'r');
data=textscan(fid,'%f','HeaderLines',1);
fclose(fid);

Nppt=9;
N=length(data{1})/Nppt;
data=reshape(data{1},Nppt,N)';

PptData.WY=data(:,1);
PptData.Month=data(:,2);
PptData.Day=data(:,3);
PptData.Hr=data(:,4);
PptData.Yr=data(:,5);

PptData.SH=data(:,6); % mm
PptData.USH=data(:,7); % mm
PptData.Corr=data(:,8); % mm
PptData.PctSnow=data(:,9); %

PptData.t=datenum(PptData.Yr,PptData.Month,PptData.Day,PptData.Hr,0,0);

end

