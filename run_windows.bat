@echo off
setlocal
cd /d "%~dp0"
where py >nul 2>nul
if errorlevel 1 (
  echo Python launcher was not found. Install Python 3.13 from https://www.python.org/downloads/
  pause
  exit /b 1
)
py -3.13 --version >nul 2>nul
if errorlevel 1 (
  echo Python 3.13 was not found. Install Python 3.13, then run this file again.
  pause
  exit /b 1
)
if not exist ".venv313\Scripts\python.exe" py -3.13 -m venv .venv313
call ".venv313\Scripts\activate.bat"
if errorlevel 1 goto failed
python -m pip install --upgrade pip setuptools wheel
if errorlevel 1 goto failed
python -m pip install -r requirements.txt
if errorlevel 1 goto failed
echo.
echo Starting XNIDS FastAPI at http://127.0.0.1:8000
python -m uvicorn app:app --host 127.0.0.1 --port 8000
if errorlevel 1 goto failed
goto end
:failed
echo.
echo Setup failed. Read the error above and check README.md.
pause
:end
endlocal
