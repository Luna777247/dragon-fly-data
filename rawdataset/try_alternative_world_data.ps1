# Try alternative methods for world data
Write-Host "=== Trying Alternative World Data Methods ===" -ForegroundColor Cyan

# Try different aggregate codes
$worldCodes = @("WLD", "1W", "WOR")
$indicatorCode = "SP.POP.TOTL"

foreach ($code in $worldCodes) {
    Write-Host "`nTrying country code: $code for World Population..." -ForegroundColor Yellow
    try {
        $url = "https://api.worldbank.org/v2/country/$code/indicator/$indicatorCode?format=json&per_page=100&date=2020:2024"
        Write-Host "URL: $url" -ForegroundColor Gray
        $response = Invoke-RestMethod -Uri $url -Method Get -ErrorAction Stop
        
        if ($response -and $response.Count -gt 1) {
            Write-Host "Response received, checking data..." -ForegroundColor Gray
            if ($response[1]) {
                Write-Host "Data type: $($response[1].GetType().Name)" -ForegroundColor Gray
                
                # Check if it's an array of values
                if ($response[1] -is [Array]) {
                    $data = $response[1] | Where-Object { $null -ne $_.value }
                    if ($data) {
                        Write-Host "  ✓ SUCCESS with code: $code" -ForegroundColor Green
                        $data | Select-Object -First 3 | ForEach-Object {
                            Write-Host "    $($_.date): $($_.value)"
                        }
                        
                        # Download full data
                        $fullUrl = "https://api.worldbank.org/v2/country/$code/indicator/$indicatorCode?format=json&per_page=1000&date=1960:2024"
                        $fullData = Invoke-RestMethod -Uri $fullUrl -Method Get
                        $fullData | ConvertTo-Json -Depth 10 | Out-File "wb_world_population.json" -Encoding UTF8
                        
                        # Also get urbanization
                        $urbUrl = "https://api.worldbank.org/v2/country/$code/indicator/SP.URB.TOTL.IN.ZS?format=json&per_page=1000&date=1960:2024"
                        $urbData = Invoke-RestMethod -Uri $urbUrl -Method Get
                        $urbData | ConvertTo-Json -Depth 10 | Out-File "wb_world_urbanization.json" -Encoding UTF8
                        
                        Write-Host "`n✓ World data downloaded successfully" -ForegroundColor Green
                        break
                    }
                } elseif ($response[1].value) {
                    # Single object with value array
                    $data = $response[1].value | Where-Object { $null -ne $_.value }
                    if ($data) {
                        Write-Host "  ✓ SUCCESS with code: $code (nested value)" -ForegroundColor Green
                        $data | Select-Object -First 3 | ForEach-Object {
                            Write-Host "    $($_.date): $($_.value)"
                        }
                    }
                }
            }
        }
    }
    catch {
        Write-Host "  ✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    Start-Sleep -Milliseconds 500
}

# Try getting median age from different sources
Write-Host "`n=== Trying Median Age with V2 API ===" -ForegroundColor Cyan
$medianAgeCodes = @("SP.POP.AG25.MA.IN", "SP.POP.AG00.MA.IN", "SP.POP.1564.MA.ZS")

foreach ($code in $medianAgeCodes) {
    Write-Host "`nTrying code: $code..." -ForegroundColor Yellow
    try {
        $url = "https://api.worldbank.org/v2/country/VNM/indicator/$code?format=json&per_page=100"
        $response = Invoke-RestMethod -Uri $url -Method Get
        
        if ($response -and $response.Count -gt 1) {
            if ($response[1].value) {
                $data = $response[1].value | Where-Object { $null -ne $_.value } | Select-Object -First 1
                if ($data) {
                    Write-Host "  ✓ Found data: $($data.date) = $($data.value)" -ForegroundColor Green
                }
            }
        }
    }
    catch {
        # Continue
    }
}

Write-Host "`n=== Complete ===" -ForegroundColor Cyan
