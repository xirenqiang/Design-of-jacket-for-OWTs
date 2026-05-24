@echo off
setlocal EnableExtensions

set "ROOT=%~dp0.."
set "MATLAB_EXE=D:\Program Files\MATLAB\R2018a\bin\matlab.exe"

if not exist "%MATLAB_EXE%" (
    echo [ERROR] MATLAB executable not found: %MATLAB_EXE%
    exit /b 1
)

"%MATLAB_EXE%" -nosplash -nodesktop -wait -r "cd('%ROOT:\=/%'); run('run_DriveCodeJckDesign.m');"
exit /b %ERRORLEVEL%
