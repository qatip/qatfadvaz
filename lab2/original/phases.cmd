@echo off
setlocal ENABLEDELAYEDEXPANSION

REM This script lives in ...\lab2\guided
set "WORK_DIR=%~dp0"

REM Phased solutions are in ..\..\lab2\phases
REM Adjust this if your actual path differs
set "SOL_ROOT=%WORK_DIR%..\..\lab2\phases"

echo Working directory : %WORK_DIR%
echo Solutions directory: %SOL_ROOT%
echo.

:MENU
echo ========================================
echo   Terraform Lab 2 - Phase Switcher
echo ========================================
echo  1) Phase 1 - original mess
echo  2) Phase 2 - locals
echo  3) Phase 3 - clean shape
echo  4) Phase 4 - normalize
echo  5) Phase 5 - guardrails
echo  6) Phase 6 - exemplar
echo  X) Exit
echo.
set /p CHOICE=Select phase to load: 

if "%CHOICE%"=="1" call :COPY_PHASE "phase1" & call :DEL_LOCALS & goto END
if "%CHOICE%"=="2" call :COPY_PHASE "phase2" & goto END
if "%CHOICE%"=="3" call :COPY_PHASE "phase3" & goto END
if "%CHOICE%"=="4" call :COPY_PHASE "phase4" & goto END
if "%CHOICE%"=="5" call :COPY_PHASE "phase5" & goto END
if "%CHOICE%"=="6" call :COPY_PHASE "exemplar" & goto END
if /I "%CHOICE%"=="X" goto END

echo Invalid choice...
echo.
goto MENU

:COPY_PHASE
set "PHASE_NAME=%~1"
set "SRC=%SOL_ROOT%\%PHASE_NAME%"

if not exist "%SRC%" (
  echo.
  echo Phase folder "%SRC%" not found.
  echo.
  goto :eof
)

echo.
echo Applying %PHASE_NAME% to "%WORK_DIR%" ...

REM Copy core phase files into guided.
REM We deliberately do NOT touch providers.tf (students' subscription lives there).
for %%F in (main.tf locals.tf variables.tf outputs.tf terraform.tfvars) do (
  if exist "%SRC%\%%F" (
    copy /Y "%SRC%\%%F" "%WORK_DIR%\%%F.new" >nul
    move /Y "%WORK_DIR%\%%F.new" "%WORK_DIR%\%%F" >nul
  ) else (
    REM optional: uncomment next line for debug
    REM echo Skipping %%F (not found in %SRC%)
  )
)

echo Done. Your working folder now reflects "%PHASE_NAME%".
echo.
goto :eof

:DEL_LOCALS
REM Phase 1 is the "original mess" with no locals.tf,
REM so remove any locals.tf in guided to match that state.
if exist "%WORK_DIR%\locals.tf" (
  del "%WORK_DIR%\locals.tf" >nul
  echo Removed locals.tf to match phase 1 starter.
)
goto :eof

:END
echo Bye!
endlocal
exit /b 0
