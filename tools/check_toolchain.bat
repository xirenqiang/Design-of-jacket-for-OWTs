@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ============================================================================
rem check_toolchain.bat
rem One-click local toolchain path + availability check for Stage-1.
rem ============================================================================

set "ROOT=%~dp0.."
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

call :check_file "Visual Studio IDE (devenv.com)" "%VS_DEVENV%"
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
if exist "%IFORT_EXE%" (
    "%IFORT_EXE%" /QV 2>nul
) else (
    echo [WARN] ifort path not found
)

if exist "%IFX_EXE%" (
    "%IFX_EXE%" /help >nul 2>nul
    if errorlevel 1 (
        echo [WARN] ifx exists but failed to run
    ) else (
        for /f "tokens=* delims=" %%L in ('"%IFX_EXE%" /help ^| findstr /i "Intel(R) Fortran Compiler"') do (
            echo %%L
            goto :ifx_done
        )
        echo [OK] ifx executable responds
    )
) else (
    echo [WARN] ifx path not found
)
:ifx_done

echo.
echo [Recommended cmd startup sequence]
echo   call "%ONEAPI_SETVARS%"
echo   call "%VS_DEVCMD%" -arch=amd64
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
if exist "%FPATH%" (
    echo [OK]  %LABEL%
    echo       %FPATH%
) else (
    echo [MISS] %LABEL%
    echo        %FPATH%
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
