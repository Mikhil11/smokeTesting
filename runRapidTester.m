function runRapidTester(MATLABVersion)

% check if MAT file is available. If not available it means you are running it for the first MATLAB release in the matrix
if isfile('mystructfilenew.mat')
    load('mystructfilenew.mat')
else
    % The MATLAB version is added as fieldname to below struct variable and the results object is stored as its value
    resultComparisonReport = struct();
end

% create testresults folder if tests are run for the first MATLAB release in the matrix
if ~isfolder('testresults')
    mkdir('testresults')
end

% create subfolder with MATLAB version as its name inside testresults folder
resultFolder = fullfile("testresults",filesep,MATLABVersion);

% run the rapid tester for a given MATLAB release
folderPath = fullfile('cdt',filesep,'doc');
obj = rapidTester(folderPath);
obj.OutputPath = resultFolder;
obj.executeTests();
results = obj.TestResults;


%save failed results inside the struct variable 'resultComparisonReport'
failedResult = [results.Failed];
resultComparisonReport.(MATLABVersion) = results(failedResult~=0);
save('mystructfilenew.mat','resultComparisonReport');
end
