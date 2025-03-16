# Script to run both RestaurantRoller.API and RestaurantRoller.Web together
param (
    [string]$Environment = "Development"
)

Write-Host "Starting RestaurantRoller API and Web app in $Environment environment..." -ForegroundColor Cyan

# Read API port numbers from launchSettings.json
$apiLaunchSettingsPath = "$PSScriptRoot\RestaurantRoller.API\Properties\launchSettings.json"
if (Test-Path $apiLaunchSettingsPath) {
    $apiLaunchSettings = Get-Content -Raw -Path $apiLaunchSettingsPath | ConvertFrom-Json
    
    # Get the profile based on environment
    $apiProfile = $apiLaunchSettings.profiles.$Environment
    if (-not $apiProfile) {
        Write-Host "Warning: API profile for environment '$Environment' not found. Using 'Development' profile." -ForegroundColor Yellow
        $apiProfile = $apiLaunchSettings.profiles.Development
    }
    
    $apiApplicationUrl = $apiProfile.applicationUrl
    $apiUrls = $apiApplicationUrl -split ";"
    
    $apiHttpsUrl = $apiUrls | Where-Object { $_ -like "https://*" } | Select-Object -First 1
    
    if (-not $apiHttpsUrl) {
        $apiHttpsUrl = "https://localhost:7214"
    }
    
    $apiHttpsPort = ($apiHttpsUrl -split ":")[2]
    
    # Kill any existing processes using these ports
    $apiHttpsProcesses = Get-NetTCPConnection -LocalPort $apiHttpsPort -ErrorAction SilentlyContinue | Where-Object State -eq Listen
    
    foreach ($process in $apiHttpsProcesses) {
        $processId = $process.OwningProcess
        Write-Host "Killing process $processId that was using API port $apiHttpsPort" -ForegroundColor Yellow
        Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
    }
} else {
    Write-Host "Warning: Could not find API launchSettings.json. Using default ports." -ForegroundColor Yellow
    $apiHttpsUrl = "https://localhost:7214"
    $apiHttpsPort = "7214"
}

# Read Web port numbers from launchSettings.json
$webLaunchSettingsPath = "$PSScriptRoot\RestaurantRoller.Web\Properties\launchSettings.json"
if (Test-Path $webLaunchSettingsPath) {
    $webLaunchSettings = Get-Content -Raw -Path $webLaunchSettingsPath | ConvertFrom-Json
    
    # Get the profile based on environment
    $webProfile = $webLaunchSettings.profiles.$Environment
    if (-not $webProfile) {
        Write-Host "Warning: Web profile for environment '$Environment' not found. Using 'Development' profile." -ForegroundColor Yellow
        $webProfile = $webLaunchSettings.profiles.Development
    }
    
    $webApplicationUrl = $webProfile.applicationUrl
    $webUrls = $webApplicationUrl -split ";"
    
    $webHttpsUrl = $webUrls | Where-Object { $_ -like "https://*" } | Select-Object -First 1
    
    if (-not $webHttpsUrl) {
        $webHttpsUrl = "https://localhost:7224"
    }
    
    $webHttpsPort = ($webHttpsUrl -split ":")[2]
    
    # Kill any existing processes using these ports
    $webHttpsProcesses = Get-NetTCPConnection -LocalPort $webHttpsPort -ErrorAction SilentlyContinue | Where-Object State -eq Listen
    
    foreach ($process in $webHttpsProcesses) {
        $processId = $process.OwningProcess
        Write-Host "Killing process $processId that was using Web port $webHttpsPort" -ForegroundColor Yellow
        Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
    }
} else {
    Write-Host "Warning: Could not find Web launchSettings.json. Using default ports." -ForegroundColor Yellow
    $webHttpsUrl = "https://localhost:7224"
    $webHttpsPort = "7224"
}

# Give a moment for killed processes to fully terminate
Start-Sleep -Seconds 2

# Start the API as a background job
Write-Host "Starting API in $Environment environment..." -ForegroundColor Cyan
$apiJob = Start-Job -ScriptBlock {
    Set-Location -Path "$using:PSScriptRoot\RestaurantRoller.API"
    $env:ASPNETCORE_ENVIRONMENT = $using:Environment
    dotnet run --launch-profile $using:Environment
}

# Wait for the API to start
Write-Host "Waiting for API to start..." -ForegroundColor Cyan
Start-Sleep -Seconds 10

# Start the Web app as a background job
Write-Host "Starting Web app in $Environment environment..." -ForegroundColor Cyan
$webJob = Start-Job -ScriptBlock {
    Set-Location -Path "$using:PSScriptRoot\RestaurantRoller.Web"
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

# Function to find a process by command line pattern
function Find-ProcessByCommandLine {
    param (
        [string]$pattern
    )
    
    $processes = Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like $pattern }
    return $processes | Select-Object -First 1
}

# Try to find processes by port first, then by command line
$apiProcess = Find-ProcessByPort $apiHttpsPort
if (-not $apiProcess) {
    $apiProcess = Find-ProcessByCommandLine "*RestaurantRoller.API*"
}

$webProcess = Find-ProcessByPort $webHttpsPort
if (-not $webProcess) {
    $webProcess = Find-ProcessByCommandLine "*RestaurantRoller.Web*"
}

# Display information about the running processes
Write-Host "`n=== RESTAURANT ROLLER PROCESSES ===" -ForegroundColor Cyan
Write-Host "Environment: $Environment" -ForegroundColor Cyan

# Check API job status
$apiJobStatus = Receive-Job -Job $apiJob -Keep
$apiRunning = $false

if ($apiProcess) {
    $apiProcessId = $apiProcess.Id
    Write-Host "API is running with process ID: $apiProcessId" -ForegroundColor Green
    Write-Host "API Base URL:" -ForegroundColor Cyan
    Write-Host "  HTTPS: $apiHttpsUrl" -ForegroundColor Green
    Write-Host "API Endpoints:" -ForegroundColor Cyan
    Write-Host "  REST API: $apiHttpsUrl/api/restaurant" -ForegroundColor Green
    Write-Host "  Swagger UI: $apiHttpsUrl/swagger" -ForegroundColor Green
    $apiRunning = $true
} else {
    # Look for URL in job output
    $apiUrlMatch = $apiJobStatus | Select-String -Pattern "Now listening on: (https://[^\s]+)" -AllMatches
    if ($apiUrlMatch -and $apiUrlMatch.Matches.Count -gt 0) {
        $detectedApiUrl = $apiUrlMatch.Matches[0].Groups[1].Value
        Write-Host "API is running" -ForegroundColor Green
        Write-Host "API Base URL:" -ForegroundColor Cyan
        Write-Host "  HTTPS: $detectedApiUrl" -ForegroundColor Green
        Write-Host "API Endpoints:" -ForegroundColor Cyan
        Write-Host "  REST API: $detectedApiUrl/api/restaurant" -ForegroundColor Green
        Write-Host "  Swagger UI: $detectedApiUrl/swagger" -ForegroundColor Green
        $apiRunning = $true
    } else {
        Write-Host "API process not found. Checking job status..." -ForegroundColor Yellow
        Write-Host $apiJobStatus -ForegroundColor Gray
        Write-Host "API might not have started correctly." -ForegroundColor Red
    }
}

Write-Host ""

# Check Web job status
$webJobStatus = Receive-Job -Job $webJob -Keep
$webRunning = $false

if ($webProcess) {
    $webProcessId = $webProcess.Id
    Write-Host "Web app is running with process ID: $webProcessId" -ForegroundColor Green
    Write-Host "Web URL:" -ForegroundColor Cyan
    Write-Host "  HTTPS: $webHttpsUrl" -ForegroundColor Green
    $webRunning = $true
} else {
    # Look for URL in job output
    $webUrlMatch = $webJobStatus | Select-String -Pattern "Now listening on: (https://[^\s]+)" -AllMatches
    if ($webUrlMatch -and $webUrlMatch.Matches.Count -gt 0) {
        $detectedWebUrl = $webUrlMatch.Matches[0].Groups[1].Value
        Write-Host "Web app is running" -ForegroundColor Green
        Write-Host "Web URL:" -ForegroundColor Cyan
        Write-Host "  HTTPS: $detectedWebUrl" -ForegroundColor Green
        $webRunning = $true
    } else {
        Write-Host "Web app process not found. Checking job status..." -ForegroundColor Yellow
        Write-Host $webJobStatus -ForegroundColor Gray
        Write-Host "Web app might not have started correctly." -ForegroundColor Red
    }
}

# Create kill scripts
if ($apiRunning) {
    @"
# Kill the RestaurantRoller.API process
`$apiProcess = Get-Process -Name "dotnet" | Where-Object { `$_.CommandLine -like "*RestaurantRoller.API*" } | Select-Object -First 1
if (-not `$apiProcess) {
    # Try to find by port
    `$connections = Get-NetTCPConnection -LocalPort $apiHttpsPort -ErrorAction SilentlyContinue | Where-Object State -eq Listen
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
}

if ($webRunning) {
    @"
# Kill the RestaurantRoller.Web process
`$webProcess = Get-Process -Name "dotnet" | Where-Object { `$_.CommandLine -like "*RestaurantRoller.Web*" } | Select-Object -First 1
if (-not `$webProcess) {
    # Try to find by port
    `$connections = Get-NetTCPConnection -LocalPort $webHttpsPort -ErrorAction SilentlyContinue | Where-Object State -eq Listen
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
}

# Create a script to kill both processes
@"
# Kill both RestaurantRoller.API and RestaurantRoller.Web processes
Write-Host "Stopping all RestaurantRoller processes..." -ForegroundColor Cyan

# Kill API process
`$apiProcess = Get-Process -Name "dotnet" | Where-Object { `$_.CommandLine -like "*RestaurantRoller.API*" } | Select-Object -First 1
if (-not `$apiProcess) {
    # Try to find by port
    `$connections = Get-NetTCPConnection -LocalPort $apiHttpsPort -ErrorAction SilentlyContinue | Where-Object State -eq Listen
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

# Kill Web process
`$webProcess = Get-Process -Name "dotnet" | Where-Object { `$_.CommandLine -like "*RestaurantRoller.Web*" } | Select-Object -First 1
if (-not `$webProcess) {
    # Try to find by port
    `$connections = Get-NetTCPConnection -LocalPort $webHttpsPort -ErrorAction SilentlyContinue | Where-Object State -eq Listen
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

Write-Host "All processes stopped" -ForegroundColor Cyan
"@ | Out-File -FilePath "$PSScriptRoot\kill-all.ps1" -Encoding utf8

# Display kill commands
Write-Host "`n=== KILL COMMANDS ===" -ForegroundColor Yellow
Write-Host "To kill the API process: ./kill-api.ps1" -ForegroundColor Yellow
Write-Host "To kill the Web app process: ./kill-web.ps1" -ForegroundColor Yellow
Write-Host "To kill both processes: ./kill-all.ps1" -ForegroundColor Yellow
Write-Host ""

# Wait for both jobs to complete (which they won't unless there's an error)
# This keeps the script running so both apps stay up
$jobs = @($apiJob, $webJob)
Wait-Job -Job $jobs
foreach ($job in $jobs) {
    Receive-Job $job
} 