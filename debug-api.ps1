# Set environment variables
$env:ASPNETCORE_ENVIRONMENT = "Development"

# Enable verbose output
Set-PSDebug -Trace 1

# Navigate to the API project directory
Set-Location -Path "$PSScriptRoot\RestaurantRoller.API"

# Run the API with debugging enabled
dotnet run --launch-profile Development

# Reset debug settings
Set-PSDebug -Off 