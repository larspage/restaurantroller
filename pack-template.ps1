# Package the template as a NuGet package
Write-Host "Packaging the MVC API Logging template..."

# Clean up any existing packages
Remove-Item -Path "*.nupkg" -ErrorAction SilentlyContinue

# Create the NuGet package
nuget pack MvcApiLoggingTemplate.nuspec

Write-Host "Template packaged successfully!"
Write-Host "You can now install the template using:"
Write-Host "dotnet new install MvcApiLoggingTemplate.1.0.0.nupkg" 