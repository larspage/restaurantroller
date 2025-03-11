# Script to run both RestaurantRoller.API and RestaurantRoller.Web together
Write-Host "Starting RestaurantRoller API and Web app..." -ForegroundColor Cyan

# Read API port numbers from launchSettings.json
$apiLaunchSettingsPath = "$PSScriptRoot\RestaurantRoller.API\Properties\launchSettings.json"
if (Test-Path $apiLaunchSettingsPath) {
    $apiLaunchSettings = Get-Content -Raw -Path $apiLaunchSettingsPath | ConvertFrom-Json
    $apiHttpUrl = $apiLaunchSettings.profiles.http.applicationUrl
    $apiHttpsUrl = ($apiLaunchSettings.profiles.https.applicationUrl -split ";")[0]
    $apiHttpPort = ($apiHttpUrl -split ":")[2]
    $apiHttpsPort = ($apiHttpsUrl -split ":")[2]
    
    # Kill any existing processes using these ports
    $apiHttpProcesses = Get-NetTCPConnection -LocalPort $apiHttpPort -ErrorAction SilentlyContinue | Where-Object State -eq Listen
    $apiHttpsProcesses = Get-NetTCPConnection -LocalPort $apiHttpsPort -ErrorAction SilentlyContinue | Where-Object State -eq Listen
    
    foreach ($process in $apiHttpProcesses) {
        $processId = $process.OwningProcess
        Write-Host "Killing process $processId that was using API port $apiHttpPort" -ForegroundColor Yellow
        Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
    }
    
    foreach ($process in $apiHttpsProcesses) {
        $processId = $process.OwningProcess
        Write-Host "Killing process $processId that was using API port $apiHttpsPort" -ForegroundColor Yellow
        Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
    }
} else {
    Write-Host "Warning: Could not find API launchSettings.json. Using default ports." -ForegroundColor Yellow
    $apiHttpUrl = "http://localhost:5132"
    $apiHttpsUrl = "https://localhost:7214"
}

# Read Web port numbers from launchSettings.json
$webLaunchSettingsPath = "$PSScriptRoot\RestaurantRoller.Web\Properties\launchSettings.json"
if (Test-Path $webLaunchSettingsPath) {
    $webLaunchSettings = Get-Content -Raw -Path $webLaunchSettingsPath | ConvertFrom-Json
    $webHttpUrl = $webLaunchSettings.profiles.http.applicationUrl
    $webHttpsUrl = ($webLaunchSettings.profiles.https.applicationUrl -split ";")[0]
    $webHttpPort = ($webHttpUrl -split ":")[2]
    $webHttpsPort = ($webHttpsUrl -split ":")[2]
    
    # Kill any existing processes using these ports
    $webHttpProcesses = Get-NetTCPConnection -LocalPort $webHttpPort -ErrorAction SilentlyContinue | Where-Object State -eq Listen
    $webHttpsProcesses = Get-NetTCPConnection -LocalPort $webHttpsPort -ErrorAction SilentlyContinue | Where-Object State -eq Listen
    
    foreach ($process in $webHttpProcesses) {
        $processId = $process.OwningProcess
        Write-Host "Killing process $processId that was using Web port $webHttpPort" -ForegroundColor Yellow
        Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
    }
    
    foreach ($process in $webHttpsProcesses) {
        $processId = $process.OwningProcess
        Write-Host "Killing process $processId that was using Web port $webHttpsPort" -ForegroundColor Yellow
        Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
    }
} else {
    Write-Host "Warning: Could not find Web launchSettings.json. Using default ports." -ForegroundColor Yellow
    $webHttpUrl = "http://localhost:5146"
    $webHttpsUrl = "https://localhost:7224"
}

# Give a moment for killed processes to fully terminate
Start-Sleep -Seconds 2

# Start the API as a background job
Write-Host "Starting API..." -ForegroundColor Cyan
$apiJob = Start-Job -ScriptBlock {
    Set-Location -Path "$using:PSScriptRoot\RestaurantRoller.API"
    dotnet run
}

# Wait for the API to start
Write-Host "Waiting for API to start..." -ForegroundColor Cyan
Start-Sleep -Seconds 5

# Start the Web app as a background job
Write-Host "Starting Web app..." -ForegroundColor Cyan
$webJob = Start-Job -ScriptBlock {
    Set-Location -Path "$using:PSScriptRoot\RestaurantRoller.Web"
    dotnet run
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

# Try to find processes by port first, then by command line
$apiProcess = Find-ProcessByPort $apiHttpPort
if (-not $apiProcess) {
    $apiProcess = Get-Process -Name "dotnet" | Where-Object { $_.CommandLine -like "*RestaurantRoller.API.dll*" -or $_.CommandLine -like "*RestaurantRoller.API*" } | Select-Object -First 1
}

$webProcess = Find-ProcessByPort $webHttpPort
if (-not $webProcess) {
    $webProcess = Get-Process -Name "dotnet" | Where-Object { $_.CommandLine -like "*RestaurantRoller.Web.dll*" -or $_.CommandLine -like "*RestaurantRoller.Web*" } | Select-Object -First 1
}

# Display information about the running processes
Write-Host "`n=== RESTAURANT ROLLER PROCESSES ===" -ForegroundColor Cyan

if ($apiProcess) {
    $apiProcessId = $apiProcess.Id
    Write-Host "API is running with process ID: $apiProcessId" -ForegroundColor Green
    Write-Host "API URLs:" -ForegroundColor Cyan
    Write-Host "  HTTP:  $apiHttpUrl" -ForegroundColor Green
    Write-Host "  HTTPS: $apiHttpsUrl" -ForegroundColor Green
} else {
    # Check if the job is still running
    $apiJobStatus = Receive-Job -Job $apiJob -Keep
    Write-Host "API process not found. Checking job status..." -ForegroundColor Yellow
    Write-Host $apiJobStatus -ForegroundColor Gray
    Write-Host "API might not have started correctly." -ForegroundColor Red
}

Write-Host ""

if ($webProcess) {
    $webProcessId = $webProcess.Id
    Write-Host "Web app is running with process ID: $webProcessId" -ForegroundColor Green
    Write-Host "Web URLs:" -ForegroundColor Cyan
    Write-Host "  HTTP:  $webHttpUrl" -ForegroundColor Green
    Write-Host "  HTTPS: $webHttpsUrl" -ForegroundColor Green
} else {
    # Check if the job is still running
    $webJobStatus = Receive-Job -Job $webJob -Keep
    Write-Host "Web app process not found. Checking job status..." -ForegroundColor Yellow
    Write-Host $webJobStatus -ForegroundColor Gray
    Write-Host "Web app might not have started correctly." -ForegroundColor Red
}

# Create kill scripts
if ($apiProcess) {
    @"
# Kill the RestaurantRoller.API process
`$apiProcess = Get-Process -Name "dotnet" | Where-Object { `$_.CommandLine -like "*RestaurantRoller.API.dll*" -or `$_.CommandLine -like "*RestaurantRoller.API*" } | Select-Object -First 1
if (-not `$apiProcess) {
    # Try to find by port
    `$connections = Get-NetTCPConnection -LocalPort $apiHttpPort -ErrorAction SilentlyContinue | Where-Object State -eq Listen
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

if ($webProcess) {
    @"
# Kill the RestaurantRoller.Web process
`$webProcess = Get-Process -Name "dotnet" | Where-Object { `$_.CommandLine -like "*RestaurantRoller.Web.dll*" -or `$_.CommandLine -like "*RestaurantRoller.Web*" } | Select-Object -First 1
if (-not `$webProcess) {
    # Try to find by port
    `$connections = Get-NetTCPConnection -LocalPort $webHttpPort -ErrorAction SilentlyContinue | Where-Object State -eq Listen
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
`$apiProcess = Get-Process -Name "dotnet" | Where-Object { `$_.CommandLine -like "*RestaurantRoller.API.dll*" -or `$_.CommandLine -like "*RestaurantRoller.API*" } | Select-Object -First 1
if (-not `$apiProcess) {
    # Try to find by port
    `$connections = Get-NetTCPConnection -LocalPort $apiHttpPort -ErrorAction SilentlyContinue | Where-Object State -eq Listen
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
`$webProcess = Get-Process -Name "dotnet" | Where-Object { `$_.CommandLine -like "*RestaurantRoller.Web.dll*" -or `$_.CommandLine -like "*RestaurantRoller.Web*" } | Select-Object -First 1
if (-not `$webProcess) {
    # Try to find by port
    `$connections = Get-NetTCPConnection -LocalPort $webHttpPort -ErrorAction SilentlyContinue | Where-Object State -eq Listen
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