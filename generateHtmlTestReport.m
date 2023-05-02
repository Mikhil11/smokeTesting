function generateHtmlTestReport(myMatFile)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
load(myMatFile);
fieldNames = fieldnames(resultComparisonReport);
%matobj = matfile(myMatFile);
%varlist = who(matobj);
a={};

for i=1:numel(fieldNames)
    tempData = getfield(resultComparisonReport,fieldNames{i});
    temp = {tempData.Name};
    a = horzcat(a,temp);
end
a = unique(a);
failedCaseValues = cell(1,numel(fieldNames));

for i =1:numel(a)
    for j=1:numel(fieldNames)
        tempData = getfield(resultComparisonReport,fieldNames{j});
        if any(strcmp(a{i},{tempData.Name}))
            failedCaseValues{j}{end+1} = '&#10060';
        else
            failedCaseValues{j}{end+1} = '&#9989';
        end
    end
end

a_updated = a';
for i = 1:numel(failedCaseValues)
    a_updated = horzcat(a_updated,failedCaseValues{i}');
end


fig = uifigure;
uit = uitable(fig,"Data",a_updated);
uit.ColumnName = horzcat("Failed Cases",fieldNames(:)');
tableData = uit.Data;
dimData = size(tableData);
row = dimData(1);
column = dimData(2);
for i=2:column
    for j = 1:numel(row)
        if tableData{j,i} == 0
            s = uistyle('BackgroundColor','red');
        else
            s = uistyle('BackgroundColor','green');
        end
        addStyle(uit,s,'cell',[j,i])
    end
end
uitable2html(uit,'testresults/diffreport.html')
end
