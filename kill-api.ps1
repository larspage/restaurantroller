# Kill the RestaurantRoller.API process
$apiProcess = Get-Process -Name "dotnet" | Where-Object { $_.CommandLine -like "*RestaurantRoller.API*" } | Select-Object -First 1
if (-not $apiProcess) {
    # Try to find by port
    $connections = Get-NetTCPConnection -LocalPort 7214 -ErrorAction SilentlyContinue | Where-Object State -eq Listen
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
