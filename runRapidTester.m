function runRapidTester(MATLABVersion)

% load mat file if present
if isfile('mystructfilenew.mat')
    load('mystructfilenew.mat')
    disp("found file")
else
    resultComparisonReport = struct();
    disp("created new struct")
end

% create testresults folder if needed
if ~isfolder('testresults')
    mkdir('testresults')
    disp("test folder created")
end

% create result folder inside testresults directory based on MATLAB version
resultFolder = fullfile("testresults",filesep,MATLABVersion);

% run the rapid tester
folderPath = fullfile('cdt',filesep,'doc');
obj = rapidTester(folderPath);
obj.OutputPath = resultFolder;
obj.executeTests();
results = obj.TestResults;


%save failed results struct for diff report
failedResult = [results.Failed];
resultComparisonReport.(MATLABVersion) = results(failedResult~=0);
save('mystructfilenew.mat','resultComparisonReport');
end