@echo off
echo Starting Web app with debugging...
set ASPNETCORE_ENVIRONMENT=Development
cd %~dp0RestaurantRoller.Web
dotnet run --launch-profile Development
echo Web app stopped. 