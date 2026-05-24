@echo off
setlocal EnableExtensions

rem ============================================================================
rem sync_global_env.bat
rem One-click refresh of global toolchain profile under:
rem   C:\Users\xrq\dev-env
rem ============================================================================

set "ROOT=%~dp0.."
set "GLOBAL_DIR=C:\Users\xrq\dev-env"
set "PS_SCRIPT=%~dp0check_toolchain.ps1"
set "SRC_MD=%ROOT%\docs\local_toolchain_config.md"
set "DST_MD=%GLOBAL_DIR%\local_toolchain_config.md"
set "DST_JSON=%GLOBAL_DIR%\toolchain_report.json"

echo.
echo ============================================================================
echo  Sync Global Environment Profile
echo  Project root : %ROOT%
echo  Global dir   : %GLOBAL_DIR%
echo ============================================================================

if not exist "%GLOBAL_DIR%" (
    echo [INFO] Creating %GLOBAL_DIR%
    mkdir "%GLOBAL_DIR%"
    if errorlevel 1 (
        echo [ERROR] Failed to create global directory.
        exit /b 1
    )
)

if not exist "%PS_SCRIPT%" (
    echo [ERROR] Missing script: %PS_SCRIPT%
    exit /b 1
)

echo.
echo [1/2] Generating JSON report...
powershell -ExecutionPolicy Bypass -File "%PS_SCRIPT%" -OutputJsonPath "%DST_JSON%" -Pretty
if errorlevel 1 (
    echo [ERROR] Failed to generate toolchain_report.json
    exit /b 1
)

echo.
echo [2/2] Syncing local_toolchain_config.md...
if not exist "%SRC_MD%" (
    echo [ERROR] Missing source markdown: %SRC_MD%
    exit /b 1
)
copy "%SRC_MD%" "%DST_MD%" /Y >nul
if errorlevel 1 (
    echo [ERROR] Failed to sync markdown profile.
    exit /b 1
)

echo.
echo [OK] Global environment profile updated.
echo      JSON : %DST_JSON%
echo      MD   : %DST_MD%
echo ============================================================================
exit /b 0

