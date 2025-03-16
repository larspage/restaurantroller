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
    
    $httpsUrl = $urls | Where-Object { $_ -like "https://*" } | Select-Object -First 1
    
    if (-not $httpsUrl) {
        $httpsUrl = "https://localhost:7224"
    }
    
    $httpsPort = ($httpsUrl -split ":")[2]
    
    # Kill any existing processes using these ports
    $httpsProcesses = Get-NetTCPConnection -LocalPort $httpsPort -ErrorAction SilentlyContinue | Where-Object State -eq Listen
    
    foreach ($process in $httpsProcesses) {
        $processId = $process.OwningProcess
        Write-Host "Killing process $processId that was using port $httpsPort" -ForegroundColor Yellow
        Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
    }
} else {
    Write-Host "Warning: Could not find launchSettings.json. Using default ports." -ForegroundColor Yellow
    $httpsUrl = "https://localhost:7224"
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
Start-Sleep -Seconds 10

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
$webProcess = Find-ProcessByPort $httpsPort
if (-not $webProcess) {
    $webProcess = Get-Process -Name "dotnet" | Where-Object { $_.CommandLine -like "*RestaurantRoller.Web*" } | Select-Object -First 1
}

# Get job output to check for URLs
$jobStatus = Receive-Job -Job $job -Keep
$webRunning = $false

if ($webProcess) {
    $processId = $webProcess.Id
    Write-Host "Web app is running with process ID: $processId" -ForegroundColor Green
    Write-Host ""
    Write-Host "Web URL:" -ForegroundColor Cyan
    Write-Host "  HTTPS: $httpsUrl" -ForegroundColor Green
    Write-Host ""
    Write-Host "Environment: $Environment" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To kill the Web app process, run this command:" -ForegroundColor Yellow
    Write-Host "Stop-Process -Id $processId -Force" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Or simply run:" -ForegroundColor Yellow
    Write-Host "./kill-web.ps1" -ForegroundColor Yellow
    $webRunning = $true
} else {
    # Look for URL in job output
    $urlMatch = $jobStatus | Select-String -Pattern "Now listening on: (https://[^\s]+)" -AllMatches
    if ($urlMatch -and $urlMatch.Matches.Count -gt 0) {
        $detectedUrl = $urlMatch.Matches[0].Groups[1].Value
        Write-Host "Web app is running" -ForegroundColor Green
        Write-Host ""
        Write-Host "Web URL:" -ForegroundColor Cyan
        Write-Host "  HTTPS: $detectedUrl" -ForegroundColor Green
        Write-Host ""
        Write-Host "Environment: $Environment" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "To kill the Web app process, run:" -ForegroundColor Yellow
        Write-Host "./kill-web.ps1" -ForegroundColor Yellow
        $webRunning = $true
    } else {
        Write-Host "Web app process not found. Checking job status..." -ForegroundColor Yellow
        Write-Host $jobStatus -ForegroundColor Gray
        Write-Host "Web app might not have started correctly." -ForegroundColor Red
        # Clean up the job if we couldn't find the process
        Remove-Job $job -Force
        Set-Location -Path $PSScriptRoot
        return
    }
}
    
# Create a kill script for easy termination
@"
# Kill the RestaurantRoller.Web process
`$webProcess = Get-Process -Name "dotnet" | Where-Object { `$_.CommandLine -like "*RestaurantRoller.Web*" } | Select-Object -First 1
if (-not `$webProcess) {
    # Try to find by port
    `$connections = Get-NetTCPConnection -LocalPort $httpsPort -ErrorAction SilentlyContinue | Where-Object State -eq Listen
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

# Return to the original directory
Set-Location -Path $PSScriptRoot 