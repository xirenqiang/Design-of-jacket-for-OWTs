@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ============================================================================
rem check_toolchain.bat
rem One-click local toolchain path + availability check for Stage-1.
rem
rem Known local paths (this machine - aligned with run_drivecode_matlab.bat):
rem   ROOT       = repo root (parent of tools\)
rem   MATLAB_EXE = D:\Program Files\MATLAB\R2018a\bin\matlab.exe  (R2018a / 9.4)
rem   VS_DEVENV  = Visual Studio 2019 Community devenv.com
rem   VS_DEVCMD  = Visual Studio 2019 VsDevCmd.bat
rem   MSVC_CL    = MSVC 14.29 cl.exe (x64)
rem   ONEAPI_*   = Intel oneAPI Fortran toolchain (optional Stage-1)
rem
rem Jacket design runtime (MATLAB):
rem   tools\run_drivecode_matlab.bat   - uses MATLAB_EXE above
rem   tools\build_drivecode_exe.bat    - same MATLAB_EXE; requires Compiler license
rem ============================================================================

set "ROOT=%~dp0.."
set "MATLAB_EXE=D:\Program Files\MATLAB\R2018a\bin\matlab.exe"
set "VS_DEVENV=C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\IDE\devenv.com"
set "VS_DEVCMD=C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\Tools\VsDevCmd.bat"
set "MSVC_CL=C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.29.30133\bin\HostX64\x64\cl.exe"
set "ONEAPI_SETVARS=D:\Program Files (x86)\Intel\oneAPI\setvars.bat"
set "IFORT_EXE=D:\Program Files (x86)\Intel\oneAPI\compiler\latest\windows\bin\intel64\ifort.exe"
set "IFX_EXE=D:\Program Files (x86)\Intel\oneAPI\compiler\latest\windows\bin\ifx.exe"

echo.
echo ============================================================================
echo  Stage-1 Toolchain Check
echo  Root: %ROOT%
echo ============================================================================
echo.

call :check_file "MATLAB R2018a matlab.exe" "%MATLAB_EXE%"
call :check_file "Visual Studio IDE devenv.com" "%VS_DEVENV%"
call :check_file "Visual Studio DevCmd" "%VS_DEVCMD%"
call :check_file "MSVC cl.exe" "%MSVC_CL%"
call :check_file "Intel oneAPI setvars.bat" "%ONEAPI_SETVARS%"
call :check_file "Intel ifort.exe" "%IFORT_EXE%"
call :check_file "Intel ifx.exe" "%IFX_EXE%"

echo.
echo [PATH Commands]
call :check_cmd python "--version"
call :check_cmd pip "--version"
call :check_cmd git "--version"
call :check_cmd cmake "--version"
call :check_cmd node "--version"
call :check_cmd npm "--version"
call :check_cmd java "-version"
call :check_cmd javac "-version"
call :check_cmd go "version"
call :check_cmd rustc "--version"
call :check_cmd cargo "--version"

echo.
echo [Fortran versions from absolute paths]
if exist "!IFORT_EXE!" (
    call "!IFORT_EXE!" /QV 2>nul
) else (
    echo [WARN] ifort path not found
)

if exist "!IFX_EXE!" (
    call "!IFX_EXE!" /help >nul 2>nul
    if errorlevel 1 (
        echo [WARN] ifx exists but failed to run
    ) else (
        echo [OK] ifx executable responds
    )
) else (
    echo [WARN] ifx path not found
)

echo.
echo [MATLAB R2018a jacket design runtime]
if exist "!MATLAB_EXE!" (
    echo [OK]  MATLAB_EXE
    echo       !MATLAB_EXE!
    echo       Documented release: 9.4 R2018a
    echo       Same path as run_drivecode_matlab.bat and build_drivecode_exe.bat
    set "DRIVECODE_EXE=%ROOT%\build\DriveCodeJckDesign\DriveCodeJckDesign.exe"
    if exist "!DRIVECODE_EXE!" (
        echo [OK]  DriveCodeJckDesign.exe
        echo       !DRIVECODE_EXE!
    ) else (
        echo [MISS] DriveCodeJckDesign.exe - run tools\build_drivecode_exe.bat
    )
) else (
    echo [WARN] matlab.exe path not found: !MATLAB_EXE!
)

echo.
echo [Recommended cmd startup sequence]
echo   call "%ONEAPI_SETVARS%"
echo   call "%VS_DEVCMD%" -arch=amd64
echo.
echo [Jacket design MATLAB commands]
echo   Run driver:  "%~dp0run_drivecode_matlab.bat"
echo   Build exe:   "%~dp0build_drivecode_exe.bat"
echo   MATLAB_EXE=  %MATLAB_EXE%
echo.
echo [Project build command]
echo   "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\IDE\devenv.com" "%ROOT%\vs-build\cantilever.sln" /Build "Release^|x64"
echo.
echo ============================================================================
echo  Check complete.
echo ============================================================================
exit /b 0

:check_file
set "LABEL=%~1"
set "FPATH=%~2"
if exist "!FPATH!" (
    echo [OK]  !LABEL!
    echo       !FPATH!
) else (
    echo [MISS] !LABEL!
    echo        !FPATH!
)
exit /b 0

:check_cmd
set "CNAME=%~1"
set "CARGS=%~2"
where %CNAME% >nul 2>nul
if errorlevel 1 (
    echo [MISS] command: %CNAME%
) else (
    for /f "tokens=* delims=" %%P in ('where %CNAME%') do (
        echo [OK]  command: %CNAME%
        echo       %%P
        goto :cmd_run
    )
)
exit /b 0

:cmd_run
if /i "%CNAME%"=="java" (
    %CNAME% %CARGS%
) else if /i "%CNAME%"=="javac" (
    %CNAME% %CARGS%
) else (
    %CNAME% %CARGS% 2>nul
)
exit /b 0
