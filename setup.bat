@echo off
echo === Trading Journal Setup ===
echo.

echo Step 1: Getting packages...
flutter pub get
if %errorlevel% neq 0 goto :error

echo.
echo Step 2: Generating Drift database code...
dart run build_runner build --delete-conflicting-outputs
if %errorlevel% neq 0 goto :error

echo.
echo === Setup complete! ===
echo Now run:  flutter run
goto :end

:error
echo.
echo ERROR: Setup failed. Check output above.
exit /b 1

:end
