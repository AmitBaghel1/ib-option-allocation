@echo off
rem One-click push: IB Option Allocation -> github.com/AmitBaghel1/ib-option-allocation
rem A GitHub sign-in popup opens (Git Credential Manager). Sign in as AmitBaghel1 there.
cd /d "%~dp0"
set GIT=C:\Program Files\Git\cmd\git.exe
"%GIT%" config --global credential.helper manager
"%GIT%" push origin ib-deploy:main
if %ERRORLEVEL%==0 (
  echo.
  echo SUCCESS - verify at https://github.com/AmitBaghel1/ib-option-allocation
) else (
  echo.
  echo PUSH FAILED - if it asked for a password, use a classic PAT (repo scope)
  echo Create one at https://github.com/settings/tokens/new and paste as password.
)
pause
