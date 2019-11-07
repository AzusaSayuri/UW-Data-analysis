function MetData = ReadMet(fname)

fid=fopen(fname,'r');
data=textscan(fid,'%f','headerlines',1);
fclose(fid); 

Nmet=12;
N=length(data{1})/Nmet;
data=reshape(data{1},Nmet,N)';

MetData.WY=data(:,1);
MetData.Month=data(:,2);
MetData.Day=data(:,3);
MetData.Hr=data(:,4);
MetData.Yr=data(:,5);
MetData.Ta=data(:,6); %°C
MetData.RH=data(:,7); % Fraction

MetData.t=datenum(MetData.Yr,MetData.Month,MetData.Day,MetData.Hr,0,0);

MetData.DOY=dayofyear(MetData.Yr',MetData.Month',MetData.Day')';

end

