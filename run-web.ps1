# Script to run the RestaurantRoller.Web and provide easy kill command
param (
    [string]$Environment = "Development"
)

Write-Host "Starting RestaurantRoller.Web in $Environment environment..." -ForegroundColor Cyan

# Change to the Web directory
Set-Location -Path "$PSScriptRoot\RestaurantRoller.Web"

# Read port numbers from launchSettings.json
$launchSettingsPath = "Properties\launchSettings.json"
if (Test-Path $launchSettingsPath) {
    $launchSettings = Get-Content -Raw -Path $launchSettingsPath | ConvertFrom-Json
    
    # Get the profile based on environment
    $profile = $launchSettings.profiles.$Environment
    if (-not $profile) {
        Write-Host "Warning: Profile for environment '$Environment' not found. Using 'Development' profile." -ForegroundColor Yellow
        $profile = $launchSettings.profiles.Development
        $Environment = "Development"
    }
    
    $applicationUrl = $profile.applicationUrl
    $urls = $applicationUrl -split ";"
    
    $httpUrl = $urls | Where-Object { $_ -like "http://*" } | Select-Object -First 1
    $httpsUrl = $urls | Where-Object { $_ -like "https://*" } | Select-Object -First 1
    
    if (-not $httpUrl) {
        $httpUrl = "http://localhost:5146"
    }
    
    if (-not $httpsUrl) {
        $httpsUrl = "https://localhost:7224"
    }
    
    $httpPort = ($httpUrl -split ":")[2]
    $httpsPort = ($httpsUrl -split ":")[2]
    
    # Kill any existing processes using these ports
    $httpProcesses = Get-NetTCPConnection -LocalPort $httpPort -ErrorAction SilentlyContinue | Where-Object State -eq Listen
    $httpsProcesses = Get-NetTCPConnection -LocalPort $httpsPort -ErrorAction SilentlyContinue | Where-Object State -eq Listen
    
    foreach ($process in $httpProcesses) {
        $processId = $process.OwningProcess
        Write-Host "Killing process $processId that was using port $httpPort" -ForegroundColor Yellow
        Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
    }
    
    foreach ($process in $httpsProcesses) {
        $processId = $process.OwningProcess
        Write-Host "Killing process $processId that was using port $httpsPort" -ForegroundColor Yellow
        Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
    }
} else {
    Write-Host "Warning: Could not find launchSettings.json. Using default ports." -ForegroundColor Yellow
    $httpUrl = "http://localhost:5146"
    $httpsUrl = "https://localhost:7224"
    $httpPort = "5146"
    $httpsPort = "7224"
}

# Give a moment for killed processes to fully terminate
Start-Sleep -Seconds 2

# Start the Web app as a background job with the specified environment
Write-Host "Starting Web app in $Environment environment..." -ForegroundColor Cyan
$job = Start-Job -ScriptBlock {
    Set-Location -Path $using:PWD
    $env:ASPNETCORE_ENVIRONMENT = $using:Environment
    dotnet run --launch-profile $using:Environment
}

# Wait for the Web app to start
Write-Host "Waiting for Web app to start..." -ForegroundColor Cyan
Start-Sleep -Seconds 5

# Function to find a process by port
function Find-ProcessByPort {
    param (
        [string]$port
    )
    
    $connections = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue | Where-Object State -eq Listen
    if ($connections) {
        foreach ($conn in $connections) {
            $process = Get-Process -Id $conn.OwningProcess -ErrorAction SilentlyContinue
            if ($process) {
                return $process
            }
        }
    }
    return $null
}

# Try to find the Web app process by port first, then by command line
$webProcess = Find-ProcessByPort $httpPort
if (-not $webProcess) {
    $webProcess = Get-Process -Name "dotnet" | Where-Object { $_.CommandLine -like "*RestaurantRoller.Web.dll*" -or $_.CommandLine -like "*RestaurantRoller.Web*" } | Select-Object -First 1
}

if ($webProcess) {
    $processId = $webProcess.Id
    Write-Host "Web app is running with process ID: $processId" -ForegroundColor Green
    Write-Host ""
    Write-Host "Web URLs:" -ForegroundColor Cyan
    Write-Host "  HTTP:  $httpUrl" -ForegroundColor Green
    Write-Host "  HTTPS: $httpsUrl" -ForegroundColor Green
    Write-Host ""
    Write-Host "Environment: $Environment" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To kill the Web app process, run this command:" -ForegroundColor Yellow
    Write-Host "Stop-Process -Id $processId -Force" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Or simply run:" -ForegroundColor Yellow
    Write-Host "./kill-web.ps1" -ForegroundColor Yellow
    
    # Create a kill script for easy termination
    @"
# Kill the RestaurantRoller.Web process
`$webProcess = Get-Process -Name "dotnet" | Where-Object { `$_.CommandLine -like "*RestaurantRoller.Web.dll*" -or `$_.CommandLine -like "*RestaurantRoller.Web*" } | Select-Object -First 1
if (-not `$webProcess) {
    # Try to find by port
    `$connections = Get-NetTCPConnection -LocalPort $httpPort -ErrorAction SilentlyContinue | Where-Object State -eq Listen
    if (`$connections) {
        `$webProcess = Get-Process -Id `$connections[0].OwningProcess -ErrorAction SilentlyContinue
    }
}

if (`$webProcess) {
    `$processId = `$webProcess.Id
    Write-Host "Stopping Web app process with ID: `$processId" -ForegroundColor Cyan
    Stop-Process -Id `$processId -Force
    Write-Host "Web app process stopped successfully" -ForegroundColor Green
} else {
    Write-Host "No RestaurantRoller.Web process found running" -ForegroundColor Yellow
}
"@ | Out-File -FilePath "$PSScriptRoot\kill-web.ps1" -Encoding utf8

    # Wait for the job to complete (which it won't unless there's an error)
    # This keeps the script running so the Web app stays up
    Wait-Job $job
    Receive-Job $job
} else {
    # Check if the job is still running
    $jobStatus = Receive-Job -Job $job -Keep
    Write-Host "Web app process not found. Checking job status..." -ForegroundColor Yellow
    Write-Host $jobStatus -ForegroundColor Gray
    Write-Host "Web app might not have started correctly." -ForegroundColor Red
    # Clean up the job if we couldn't find the process
    Remove-Job $job -Force
}

# Return to the original directory
Set-Location -Path $PSScriptRoot 