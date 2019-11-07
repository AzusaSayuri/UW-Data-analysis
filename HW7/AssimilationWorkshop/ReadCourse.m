function CourseData = ReadCourse(fname)

fid=fopen(fname,'r');
data=textscan(fid,'%f','headerlines',1);
fclose(fid);

Ncourse=7;
N=length(data{1})/Ncourse;
data=reshape(data{1},Ncourse,N)';

CourseData.WY=data(:,1);
CourseData.Month=data(:,2);
CourseData.Day=data(:,3);
CourseData.Yr=data(:,4);

CourseData.SWE=data(:,5); % mm
CourseData.z=data(:,6); %cm
CourseData.rho=data(:,7); %cm

CourseData.Hr=12*ones(size(CourseData.WY)); %assumed

CourseData.t=datenum(CourseData.Yr,CourseData.Month,CourseData.Day,CourseData.Hr,0,0);

end