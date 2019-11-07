function ValData = ReadVal(fname)

fid=fopen(fname,'r');
data=textscan(fid,'%f','headerlines',1);
fclose(fid);

Nval=9;
N=length(data{1})/Nval;
data=reshape(data{1},Nval,N)';

ValData.WY=data(:,1);
ValData.Month=data(:,2);
ValData.Day=data(:,3);
ValData.Hr=data(:,4);
ValData.Yr=data(:,5);

ValData.Q=data(:,6); % m3/s
ValData.SWE=data(:,7); % mm
ValData.zSheltered=data(:,8); %cm
ValData.zExposed=data(:,9); %cm

ValData.t=datenum(ValData.Yr,ValData.Month,ValData.Day,ValData.Hr,0,0);

end

