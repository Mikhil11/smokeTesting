classdef rapidTester < handle

    properties
        CreateTestReport      
        CreateCodeCoverageReport = false
        TestReportFormat
        CodeCoverageReportFormat
        OutputPath
        Tests   
        TestResults
    end

    properties (Access=private)
        Runner            
    end

    properties (Constant, Access=private)
        testPackage = 'tests'
    end

    methods
        function obj = rapidTester(Tests, args)
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                Tests (1, :) string
                args.?rapidTester
                args.GenerateTestReport (1,1) logical = true
                args.GeneratecodeCoverageReport (1,1) logical = false
                args.TestReportFormat (1, :) string = "html"
                args.CodeCoverageReportFormat (1, :) string = "html"
                args.OutputPath (1, :) string = ""
            end            
            
            obj.CreateTestReport = args.GenerateTestReport;
            obj.CreateCodeCoverageReport = args.GeneratecodeCoverageReport;
            obj.TestReportFormat = args.TestReportFormat;
            obj.CodeCoverageReportFormat = args.CodeCoverageReportFormat;
            obj.OutputPath = args.OutputPath;

            if obj.isJsonPath(Tests)
                obj.readTestFiles(Tests);
            else                
                obj.Tests = Tests;
            end
                                   
        end

        function executeTests(obj)
            % Function runs specified MATLAB scripts via MathWorks unit
            % testing framework and generates reports

            % Create test suite from TestFoldersAndFiles

            import matlab.unittest.TestSuite
            import matlab.unittest.parameters.Parameter
            
            initializeTestRunner(obj);
            % Generate test suite for test mentioned as testName in class.
            % Folders and files mentioned in TestFoldersAndFiles as passed
            % as External Parameters while creating the tests

            testFiles = obj.extractTesFilesFromFolders();
            testFilesAndFolders = Parameter.fromData('tests', testFiles);
            % testFilesAndFolders = Parameter.fromData('tests', struct("testName", cellstr(obj.Tests)));            
            suite = TestSuite.fromPackage(obj.testPackage, 'ExternalParameters', testFilesAndFolders);

            obj.TestResults = obj.Runner.run(suite);
            
        end

        function results = rerunFailedTests(obj)

            % function runs MATLAB scripts which failed in initial run via
            % MathWorks unit testing framework

            if isempty(obj.TestResults)
                error('TestResults is empty! Make sure test suite is run at lease once before calling rerunFailedTests');

            end
            failedTests = suite([obj.TestResults.Failed]);
            results = run(failedTests);

            warning('Tests have been rerun! Results is TestResults property might be incomplete!')
        end


        function writeTestsToFile(obj, fileName)
            % Saves list of testFiles from TestFile property to a json file
            % mentioned in fileName. fileName can be relative or absolute
            % path
           fileID = fopen(fileName, 'w');
           data = jsonencode(obj.Tests);
           fprintf(fileID, '%s', data);
           fclose(fileID);            
        end
        
    end

    methods(Access=private)

        function initializeTestRunner(obj)

            % Method initializes a Testrunner based on the values provided
            % by user while creating a class contructor

            import matlab.unittest.plugins.DiagnosticsRecordingPlugin
            import matlab.unittest.plugins.CodeCoveragePlugin
            import matlab.unittest.plugins.codecoverage.CoverageReport
            import matlab.unittest.plugins.codecoverage.CoberturaFormat
            import matlab.unittest.plugins.TestReportPlugin;
            import matlab.unittest.plugins.XMLPlugin

            % Create a test runner with no plugins
            obj.Runner = testrunner("textoutput");

            % Diagnostic record plugin enables logging in the tests
            obj.Runner.addPlugin(DiagnosticsRecordingPlugin);

            % Add code coverage plugin
            if obj.CreateCodeCoverageReport
            sourceCodeFolder = pwd;
            reportFolder = fullfile(obj.OutputPath, 'coverageReport-report');

            % Add codecoverage plugin based on user input

            if strcmp(obj.CodeCoverageReportFormat, 'html')
                codeCovReportFormat = CoverageReport(reportFolder);
            else
                codeCovReportFormat = CoberturaFormat(reportFolder);
            end

            codeCovPlugin = CodeCoveragePlugin.forFolder(sourceCodeFolder,"Producing",codeCovReportFormat, 'IncludingSubfolders',true);
            obj.Runner.addPlugin(codeCovPlugin);

            end

            % Add Test Report plugin based on user inputs
            testReportFolder = fullfile(pwd(),obj.OutputPath);

            if strcmp(obj.TestReportFormat, 'html')

                testReportPlugin = TestReportPlugin.producingHTML(testReportFolder);

            elseif strcmp(obj.TestReportFormat, 'Docx')

                testReportPlugin = TestReportPlugin.producingDOCX(fullfile(testReportFolder, 'TestReport.docx'));

            elseif stcmp(obj.TestReportFormat, 'pdf')
                
                testReportPlugin = TestReportPlugin.producingPDF(fullfile(testReportFolder, 'TestReport.pdf'));

            else  

                testReportPlugin = XMLPlugin.producingJUnitFormat(xmlFile);
                
            end

            obj.Runner.addPlugin(testReportPlugin);
        end


        function testFiles = extractTesFilesFromFolders(obj)
            folderPath = string(obj.Tests);
            allFiles = {};
            allFields = {};
            for idx = 1:numel(folderPath)
                filelist = dir(fullfile(folderPath{idx},'**',filesep,'*.m'));  %get list of files and folders in any subfolder

                files = fullfile({filelist.folder}, {filelist.name});
                files = files(~strcmp(files, [mfilename '.m']));
                [folder, fileName] = fileparts(files);
                files = fullfile(folder, fileName);
                % files = strtok(files, '.');
                fields = strcat([folderPath{idx} '_'], fileName);
                allFiles = [allFiles(:)' files(:)'];
                allFields = [allFields(:)' fields(:)'];
            end
            allFields = strrep(allFields, filesep, '_');
            testFiles = cell2struct(allFiles, allFields, 2);
        end

        function isJson =  isJsonPath(obj, Tests)
            % Function returns true if obj.Tests is passed as a json
            % filename else will return false
            isJson = false;
            if (isstring(Tests) && isscalar(Tests)) || ischar(Tests)
                [~, ~, fileExt] = fileparts(char(Tests));
                isJson = strcmp(fileExt, ".json");
            end
        end

        function readTestFiles(obj, fileName)
            % Reads testfiles from file mentioned. fileName can be relative
            % or absolute with fileExtension

            rawData = fileread(fileName);
            obj.Tests = jsondecode(rawData);

        end
    end
end
