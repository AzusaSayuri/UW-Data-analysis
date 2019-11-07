function Data = SelectData(AllData,iWY)

Names=fieldnames(AllData);

for i=1:length(Names),
    eval(['Data.' Names{i} '=AllData.' Names{i} '(iWY);'])
end

end