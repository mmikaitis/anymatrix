function test_anymatrix_properties(regenerate_tests, warnings_on)
%TEST_ANYMATRIX_PROPERTIES  Test anymatrix matrix properties.
%   This function auto generates the function-based unit tests for matrix
%   properties and runs them.
%
%   Warnings are generated for properties that do not have tests available
%   if warnings_on == 1.
%
%   Tests are regenerated if regenerate_tests=1.

anymatrix('sc');
root_path = fileparts(strcat(mfilename('fullpath'), '.m'));

% Check which properties recognized by anymatrix have tests and throw
% warnings for those that can't be tested.
if warnings_on
    P = anymatrix('p');
    for prop = P.'
        if ~isfile(strcat(root_path, '/private/test_', prop{1}, '.m'))
            warning("Test for property %s was not found in anymatrix.", ...
                prop{1});
        end
    end
end

header = strcat( ...
        "function tests = anymatrix_func_based_tests\n", ...
        "%% ANYMATRIX_FUNC_BASED_TESTS   Function based tests for anymatrix.\n", ...
        "%%   This file contains function tests that are run by MATLAB's unit\n", ...
        "%%   testing framework. Run the script test_anymatrix_properties.m, not this\n", ...
        "%%   function, to invoke the tests here.\n%%\n", ...
        "%%   This file is automatically generated and is not meant to be modified.\n", ...
        "tests = functiontests(localfunctions);\n", ...
        "end");
M = anymatrix('all');
test_function_file = strcat(root_path, '/anymatrix_func_based_tests.m');
curr_contents = {};
if isfile(test_function_file)
  curr_contents = fileread(test_function_file);
end
% Open a file containing unit tests; if we need to regenerate the contents
% or if the file is empty/non-existent, write in a function definition.
if regenerate_tests == 1 || isempty(curr_contents)
    fileID = fopen(test_function_file, 'w+');
    fprintf(fileID, header);
else
    fileID = fopen(test_function_file, 'a+');
end

% Generate unit tests for those matrices that are found to be not present
% in the testsuite.
for mat = M.'
    existent_tests = fileread(test_function_file);
    matrix_ID = mat{1};
    slashloc = find(matrix_ID == '/');
    group_name = matrix_ID(1:slashloc-1);
    matrix_name = matrix_ID(slashloc+1:length(matrix_ID));
    if ~contains(existent_tests, ...
            strcat('test_', group_name, '_', matrix_name))
        test_file = strcat(root_path, '/../', group_name, ...
            '/private/am_unit_tests.m');
        % If tests provided with the group, read them in.
        if isfile(test_file) && contains(fileread(test_file), ...
                strcat('test_', group_name, '_', matrix_name))
           tests = fileread(test_file);
           header_pat = 'function' + whitespacePattern + ...
               strcat('test_', group_name, '_', matrix_name, '(testcase)');
           function_body = extractBetween(tests, header_pat, 'function');
           % NOTE: extractBetween returns a cell array whereas extractAfter
           % returns a char array, hence the conversion.
           if isempty(function_body)
               function_body = {extractAfter(tests, header_pat)};
           end
           tests = strcat('function test_', group_name, '_', ...
               matrix_name, '(testcase)', newline, function_body{1});
           fprintf(fileID, '\n\n');
           fprintf(fileID, tests);
        else
            % Otherwise, generate some tests with 0 or 1 inputs args.
            temp = strcat('\n\nfunction test_', group_name, ...
                '_', matrix_name, '(testcase)\n');
            ok_without_args = 1;
            A = [];
            try
                A = anymatrix(matrix_ID);
            catch
                ok_without_args = 0;
            end
            
            if isempty(A)
                ok_without_args = 0;
            end
            
            if (ok_without_args)
                temp = strcat(temp, ...
                    "    A = anymatrix('", matrix_ID, "');\n", ...
                    "    anymatrix_check_props(A, '", matrix_ID, "', testcase);\n");
            end
            
            % Set of dimensions to test.
            args = [3, 5, 8, 10, 15, 24, 25, 30, 31];
            for arg = args
                try
                    anymatrix(matrix_ID, arg);
                    temp = strcat(temp, ...
                        "    A = anymatrix('", matrix_ID, "',", num2str(arg), ");\n", ...
                        "    anymatrix_check_props(A, '", matrix_ID, "', testcase);\n");
                catch
                end
            end
            temp = strcat(temp, 'end');
            fprintf(fileID, temp);
        end
    end
end
fclose(fileID);

% Configure a test runner.
runner = matlab.unittest.TestRunner.withNoPlugins;
import matlab.unittest.plugins.TestRunProgressPlugin
import matlab.unittest.plugins.DiagnosticsOutputPlugin
runner.addPlugin(TestRunProgressPlugin.withVerbosity(2))
runner.addPlugin(DiagnosticsOutputPlugin('OutputDetail', 2))

% Run the testsuite.
test_results = runner.run(anymatrix_func_based_tests);
table(test_results)

end