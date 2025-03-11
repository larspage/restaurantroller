# Kill the RestaurantRoller.Web process
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
