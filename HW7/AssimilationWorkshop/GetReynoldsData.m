clear all

MetData = ReadMet('met_sheltered.txt');
PptData = ReadPpt('ppt_sheltered.txt');
ValData = ReadVal('val_q-swe-zs.txt');
CourseData = ReadCourse('val_snowcourse.txt');

save('AllData.mat','MetData','PptData','ValData','CourseData');
