# Script to run the RestaurantRoller.API and provide easy kill command
Write-Host "Starting RestaurantRoller.API..." -ForegroundColor Cyan

# Change to the API directory
Set-Location -Path "$PSScriptRoot\RestaurantRoller.API"

# Read port numbers from launchSettings.json
$launchSettingsPath = "Properties\launchSettings.json"
if (Test-Path $launchSettingsPath) {
    $launchSettings = Get-Content -Raw -Path $launchSettingsPath | ConvertFrom-Json
    $httpUrl = $launchSettings.profiles.http.applicationUrl
    $httpsUrl = ($launchSettings.profiles.https.applicationUrl -split ";")[0]
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
    $httpUrl = "http://localhost:5132"
    $httpsUrl = "https://localhost:7214"
    $httpPort = "5132"
    $httpsPort = "7214"
}

# Give a moment for killed processes to fully terminate
Start-Sleep -Seconds 2

# Start the API as a background job
Write-Host "Starting API..." -ForegroundColor Cyan
$job = Start-Job -ScriptBlock {
    Set-Location -Path $using:PWD
    dotnet run
}

# Wait for the API to start
Write-Host "Waiting for API to start..." -ForegroundColor Cyan
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

# Try to find the API process by port first, then by command line
$apiProcess = Find-ProcessByPort $httpPort
if (-not $apiProcess) {
    $apiProcess = Get-Process -Name "dotnet" | Where-Object { $_.CommandLine -like "*RestaurantRoller.API.dll*" -or $_.CommandLine -like "*RestaurantRoller.API*" } | Select-Object -First 1
}

if ($apiProcess) {
    $processId = $apiProcess.Id
    Write-Host "API is running with process ID: $processId" -ForegroundColor Green
    Write-Host ""
    Write-Host "API URLs:" -ForegroundColor Cyan
    Write-Host "  HTTP:  $httpUrl" -ForegroundColor Green
    Write-Host "  HTTPS: $httpsUrl" -ForegroundColor Green
    Write-Host ""
    Write-Host "To kill the API process, run this command:" -ForegroundColor Yellow
    Write-Host "Stop-Process -Id $processId -Force" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Or simply run:" -ForegroundColor Yellow
    Write-Host "./kill-api.ps1" -ForegroundColor Yellow
    
    # Create a kill script for easy termination
    @"
# Kill the RestaurantRoller.API process
`$apiProcess = Get-Process -Name "dotnet" | Where-Object { `$_.CommandLine -like "*RestaurantRoller.API.dll*" -or `$_.CommandLine -like "*RestaurantRoller.API*" } | Select-Object -First 1
if (-not `$apiProcess) {
    # Try to find by port
    `$connections = Get-NetTCPConnection -LocalPort $httpPort -ErrorAction SilentlyContinue | Where-Object State -eq Listen
    if (`$connections) {
        `$apiProcess = Get-Process -Id `$connections[0].OwningProcess -ErrorAction SilentlyContinue
    }
}

if (`$apiProcess) {
    `$processId = `$apiProcess.Id
    Write-Host "Stopping API process with ID: `$processId" -ForegroundColor Cyan
    Stop-Process -Id `$processId -Force
    Write-Host "API process stopped successfully" -ForegroundColor Green
} else {
    Write-Host "No RestaurantRoller.API process found running" -ForegroundColor Yellow
}
"@ | Out-File -FilePath "$PSScriptRoot\kill-api.ps1" -Encoding utf8

    # Wait for the job to complete (which it won't unless there's an error)
    # This keeps the script running so the API stays up
    Wait-Job $job
    Receive-Job $job
} else {
    # Check if the job is still running
    $jobStatus = Receive-Job -Job $job -Keep
    Write-Host "API process not found. Checking job status..." -ForegroundColor Yellow
    Write-Host $jobStatus -ForegroundColor Gray
    Write-Host "API might not have started correctly." -ForegroundColor Red
    # Clean up the job if we couldn't find the process
    Remove-Job $job -Force
}

# Return to the original directory
Set-Location -Path $PSScriptRoot 