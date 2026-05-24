% Build DriveCodeJckDesign executable using MATLAB Compiler.
thisFileDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(thisFileDir);
entryFile = fullfile(projectRoot, 'modules', 'DriveCodeJckDesign.m');
outputDir = fullfile(projectRoot, 'build', 'DriveCodeJckDesign');

if ~license('test', 'Compiler')
    error('build_drivecode_exe:CompilerUnavailable', ...
        'MATLAB Compiler license is not available on this machine.');
end

if exist(entryFile, 'file') ~= 2
    error('build_drivecode_exe:EntryNotFound', ...
        'Entry file not found: %s', entryFile);
end

if exist(outputDir, 'dir') ~= 7
    mkdir(outputDir);
end

fprintf('Building executable from: %s\n', entryFile);
fprintf('Output directory: %s\n', outputDir);
mcc('-m', entryFile, '-d', outputDir, '-v');
fprintf('Build complete.\n');
