@echo off
echo Starting API with debugging...
set ASPNETCORE_ENVIRONMENT=Development
cd %~dp0RestaurantRoller.API
dotnet run --launch-profile Development
echo API stopped. 