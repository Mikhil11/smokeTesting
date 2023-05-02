classdef wrapperTest < matlab.unittest.TestCase

    properties (TestParameter)
        tests =struct("testName", []);
    end

    methods (TestMethodTeardown)
        % Teardown for each test. Each test method should start in a clean
        % test environment (For eg. No variables in base workspace.) Code
        % placed in this section is executed at the end of each test method
        % below.
        function closeAllFigures(~)
            figHandles = findall(groot,'Type','figure');
            close(figHandles, "force");
        end
    end

    methods (Test)
        % Test methods

        function runTestFile(testCase, tests)
            try
                run(tests);
            catch ME
                testCase.verifyEmpty(ME, 'Exception was thrown');
                throwAsCaller(ME);
            end

        end
    end

    methods (Static)
        function files = getmscripts(testSuites)
            folderPath = readcell(testSuites);
            allFiles = {};
            allFields = {};
            for idx = 1:numel(folderPath)
                filelist = dir(fullfile(folderPath{idx}, '**\*.m'));  %get list of files and folders in any subfolder

                files = fullfile({filelist.folder}, {filelist.name});
                files = files(~strcmp(files, [mfilename '.m']));
                files = strtok(files, '.');
                fields = strcat([folderPath{idx} '_'], strtok({filelist.name}, '.'));
                allFiles = [allFiles(:)' files(:)'];
                allFields = [allFields(:)' fields(:)'];
            end

            files = cell2struct(allFiles, allFields, 2);
        end
    end

end