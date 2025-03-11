# Kill both RestaurantRoller.API and RestaurantRoller.Web processes
Write-Host "Stopping all RestaurantRoller processes..." -ForegroundColor Cyan

# Kill API process
$apiProcess = Get-Process -Name "dotnet" | Where-Object { $_.CommandLine -like "*RestaurantRoller.API.dll*" -or $_.CommandLine -like "*RestaurantRoller.API*" } | Select-Object -First 1
if (-not $apiProcess) {
    # Try to find by port
    $connections = Get-NetTCPConnection -LocalPort 5132 -ErrorAction SilentlyContinue | Where-Object State -eq Listen
    if ($connections) {
        $apiProcess = Get-Process -Id $connections[0].OwningProcess -ErrorAction SilentlyContinue
    }
}

if ($apiProcess) {
    $processId = $apiProcess.Id
    Write-Host "Stopping API process with ID: $processId" -ForegroundColor Cyan
    Stop-Process -Id $processId -Force
    Write-Host "API process stopped successfully" -ForegroundColor Green
} else {
    Write-Host "No RestaurantRoller.API process found running" -ForegroundColor Yellow
}

# Kill Web process
$webProcess = Get-Process -Name "dotnet" | Where-Object { $_.CommandLine -like "*RestaurantRoller.Web.dll*" -or $_.CommandLine -like "*RestaurantRoller.Web*" } | Select-Object -First 1
if (-not $webProcess) {
    # Try to find by port
    $connections = Get-NetTCPConnection -LocalPort 5146 -ErrorAction SilentlyContinue | Where-Object State -eq Listen
    if ($connections) {
        $webProcess = Get-Process -Id $connections[0].OwningProcess -ErrorAction SilentlyContinue
    }
}

if ($webProcess) {
    $processId = $webProcess.Id
    Write-Host "Stopping Web app process with ID: $processId" -ForegroundColor Cyan
    Stop-Process -Id $processId -Force
    Write-Host "Web app process stopped successfully" -ForegroundColor Green
} else {
    Write-Host "No RestaurantRoller.Web process found running" -ForegroundColor Yellow
}

Write-Host "All processes stopped" -ForegroundColor Cyan
