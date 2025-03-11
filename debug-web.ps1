# Set environment variables
$env:ASPNETCORE_ENVIRONMENT = "Development"

# Enable verbose output
Set-PSDebug -Trace 1

# Navigate to the Web project directory
Set-Location -Path "$PSScriptRoot\RestaurantRoller.Web"

# Run the Web app with debugging enabled
dotnet run --launch-profile Development

# Reset debug settings
Set-PSDebug -Off 