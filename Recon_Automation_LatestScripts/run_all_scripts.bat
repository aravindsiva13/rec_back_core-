
@echo off
title Complete Reconciliation Process
echo =====================================
echo   COMPLETE RECONCILIATION PROCESS
echo =====================================
echo.

cd /d "%~dp0"
echo Current directory: %CD%
echo.

echo Step 1/3: Preparing Input Files...
echo =====================================
call "1_Prepare_Input_Files.bat"
if %errorlevel% neq 0 (
    echo ERROR: Step 1 failed - Prepare Input Files
    echo Error code: %errorlevel%
    echo Script will exit in 10 seconds...
    timeout /t 10 /nobreak >nul
    exit /b 1
)
echo Step 1 completed successfully.
echo.

echo Step 2/3: Processing PayTM and PhonePe Data...
echo =====================================
echo Please wait while PayTM and PhonePe reconciliation is processing...
echo This may take several minutes to complete.
echo WARNING: Do NOT close any PowerShell windows that open during this process.
echo.

REM Count PowerShell processes before starting Step 2
echo Checking for existing PowerShell processes...
for /f %%i in ('tasklist /fi "imagename eq powershell.exe" 2^>nul ^| find /c "powershell.exe"') do set ps_before=%%i
echo Current PowerShell processes: %ps_before%

REM Execute Step 2
echo Starting Step 2...
call "2_PayTm_PhonePe_Recon.bat"
set step2_result=%errorlevel%

REM Enhanced PowerShell monitoring with smarter logic
echo Monitoring PowerShell processes for completion...
echo Initial PowerShell count: %ps_before%
set /a wait_counter=0
set /a max_wait=120
set /a stable_count=0
set /a required_stable=3

:wait_for_powershell
timeout /t 15 /nobreak >nul
set /a wait_counter+=1

REM Get current PowerShell process count
for /f %%i in ('tasklist /fi "imagename eq powershell.exe" 2^>nul ^| find /c "powershell.exe"') do set ps_current=%%i

REM Check if PowerShell count has returned to baseline or lower
if %ps_current% leq %ps_before% (
    set /a stable_count+=1
    echo PowerShell count stable at %ps_current% ^(check %stable_count%/%required_stable%^)
    
    REM Require 3 consecutive stable readings to ensure completion
    if %stable_count% geq %required_stable% (
        echo All PowerShell processes have completed successfully.
        goto check_step2_result
    )
) else (
    set /a stable_count=0
    echo PowerShell processes still active: %ps_current% ^(waiting... %wait_counter%/%max_wait%^)
)

REM Check for timeout (30 minutes total)
if %wait_counter% geq %max_wait% (
    echo TIMEOUT: Reached maximum wait time of 30 minutes.
    echo Current PowerShell processes: %ps_current%
    echo Proceeding anyway - monitor for potential issues!
    goto check_step2_result
)

goto wait_for_powershell

:check_step2_result
echo All background processes have finished.

REM Check Step 2 result
if %step2_result% neq 0 (
    echo ERROR: Step 2 failed - PayTM PhonePe Reconciliation
    echo Error code: %step2_result%
    echo Step 3 will NOT be executed due to Step 2 failure.
    echo Script will exit in 10 seconds...
    timeout /t 10 /nobreak >nul
    exit /b 2
)

echo Step 2 completed successfully.
echo Proceeding to Step 3...
echo.

echo Step 3/3: Loading Database and Generating Report...
echo =====================================
echo Step 2 has completed successfully. Now starting Step 3...
echo.

call "3_LoadDB_ReconDailyExtract.bat"
if %errorlevel% neq 0 (
    echo ERROR: Step 3 failed - Load Database and Generate Report
    echo Error code: %errorlevel%
    echo Script will exit in 10 seconds...
    timeout /t 10 /nobreak >nul
    exit /b 3
)
echo Step 3 completed successfully.
echo.

