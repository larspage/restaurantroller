# Install the template locally
Write-Host "Installing the MVC API Logging template locally..."
dotnet new uninstall MvcApiLoggingTemplate
dotnet new install $PSScriptRoot

Write-Host "Template installed successfully!"
Write-Host "You can now create a new project using:"
Write-Host "dotnet new mvcapilog -n YourProjectName" 