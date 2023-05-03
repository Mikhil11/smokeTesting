function generateHtmlTestReport(myMatFile)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% load mystructfilenew.mat in the workspace and get fieldnames which are different MATLAB versions
load(myMatFile);
fieldNames = fieldnames(resultComparisonReport);
a={};

% combine all the failed cases from different MATLAB versions and then remove duplicates
for i=1:numel(fieldNames)
    tempData = getfield(resultComparisonReport,fieldNames{i});
    temp = {tempData.Name};
    a = horzcat(a,temp);
end
a = unique(a);
failedCaseValues = cell(1,numel(fieldNames));

% For a given test case check against different MATLAB release whether its failed or passed. Add right tick for pass case and cross tick for failed case
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


% convert the data into uitable
fig = uifigure;
uit = uitable(fig,"Data",a_updated);
uit.ColumnName = horzcat("Failed Cases",fieldNames(:)');
tableData = uit.Data;
dimData = size(tableData);
row = dimData(1);
column = dimData(2);

% based on pass or fail add color to UI table. In case if we directly publish ui table instead of HTML report
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

% converts uitable to html file this is a third party m file
uitable2html(uit,'testresults/comparisonreport.html')
end
