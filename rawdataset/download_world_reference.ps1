# Download world reference data correctly
Write-Host "=== Downloading World Reference Data ===" -ForegroundColor Cyan

# World Population
Write-Host "`nWorld Population..." -ForegroundColor Yellow
try {
    $url = "https://api.worldbank.org/v2/country/WLD/indicator/SP.POP.TOTL?format=json&per_page=1000&date=1960:2024"
    $response = Invoke-RestMethod -Uri $url -Method Get
    
    if ($response -and $response.Count -gt 1) {
        $data = $response[1] | Where-Object { $null -ne $_.value } | Sort-Object date -Descending
        $latest = $data | Select-Object -First 1
        Write-Host "  ✓ Latest: $($latest.date) = $($latest.value)" -ForegroundColor Green
        $response | ConvertTo-Json -Depth 10 | Out-File "wb_world_population.json" -Encoding UTF8
    }
}
catch {
    Write-Host "  ✗ Error: $_" -ForegroundColor Red
}

# World Urbanization Rate
Write-Host "`nWorld Urbanization Rate..." -ForegroundColor Yellow
try {
    $url = "https://api.worldbank.org/v2/country/WLD/indicator/SP.URB.TOTL.IN.ZS?format=json&per_page=1000&date=1960:2024"
    $response = Invoke-RestMethod -Uri $url -Method Get
    
    if ($response -and $response.Count -gt 1) {
        $data = $response[1] | Where-Object { $null -ne $_.value } | Sort-Object date -Descending
        $latest = $data | Select-Object -First 1
        Write-Host "  ✓ Latest: $($latest.date) = $($latest.value)%" -ForegroundColor Green
        $response | ConvertTo-Json -Depth 10 | Out-File "wb_world_urbanization.json" -Encoding UTF8
    }
}
catch {
    Write-Host "  ✗ Error: $_" -ForegroundColor Red
}

# CO2 Emissions per capita for Vietnam
Write-Host "`nCO2 Emissions per Capita (Vietnam)..." -ForegroundColor Yellow
try {
    $url = "https://api.worldbank.org/v2/country/VNM/indicator/EN.ATM.CO2E.PC?format=json&per_page=1000&date=1960:2024"
    $response = Invoke-RestMethod -Uri $url -Method Get
    
    if ($response -and $response.Count -gt 1) {
        $data = $response[1] | Where-Object { $null -ne $_.value } | Sort-Object date -Descending
        $latest = $data | Select-Object -First 1
        Write-Host "  ✓ Latest: $($latest.date) = $($latest.value) metric tons" -ForegroundColor Green
        $response | ConvertTo-Json -Depth 10 | Out-File "wb_co2_emissions.json" -Encoding UTF8
    }
}
catch {
    Write-Host "  ✗ Error: $_" -ForegroundColor Red
}

# Global Median Age
Write-Host "`nGlobal Median Age..." -ForegroundColor Yellow
try {
    $url = "https://api.worldbank.org/v2/country/WLD/indicator/SP.POP.AG00.MA.IN?format=json&per_page=1000&date=1960:2024"
    $response = Invoke-RestMethod -Uri $url -Method Get
    
    if ($response -and $response.Count -gt 1) {
        $data = $response[1] | Where-Object { $null -ne $_.value } | Sort-Object date -Descending
        if ($data) {
            $latest = $data | Select-Object -First 1
            Write-Host "  ✓ Latest: $($latest.date) = $($latest.value) years" -ForegroundColor Green
            $response | ConvertTo-Json -Depth 10 | Out-File "wb_world_median_age.json" -Encoding UTF8
        } else {
            Write-Host "  ✗ No data available" -ForegroundColor Red
        }
    }
}
catch {
    Write-Host "  ✗ Error: $_" -ForegroundColor Red
}

# Vietnam Median Age
Write-Host "`nVietnam Median Age..." -ForegroundColor Yellow
try {
    $url = "https://api.worldbank.org/v2/country/VNM/indicator/SP.POP.AG00.MA.IN?format=json&per_page=1000&date=1960:2024"
    $response = Invoke-RestMethod -Uri $url -Method Get
    
    if ($response -and $response.Count -gt 1) {
        $data = $response[1] | Where-Object { $null -ne $_.value } | Sort-Object date -Descending
        if ($data) {
            $latest = $data | Select-Object -First 1
            Write-Host "  ✓ Latest: $($latest.date) = $($latest.value) years" -ForegroundColor Green
            $response | ConvertTo-Json -Depth 10 | Out-File "wb_vietnam_median_age.json" -Encoding UTF8
        } else {
            Write-Host "  ✗ No data available" -ForegroundColor Red
        }
    }
}
catch {
    Write-Host "  ✗ Error: $_" -ForegroundColor Red
}

Write-Host "`n=== Download Complete ===" -ForegroundColor Green
