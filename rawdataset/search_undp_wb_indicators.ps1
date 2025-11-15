# Search for UNDP-related indicators in World Bank API
Write-Host "=== Searching for UNDP/HDR indicators in World Bank ===" -ForegroundColor Cyan

# Try different indicator code patterns
$searchPatterns = @(
    # Poverty indicators
    @{Name="Poverty Rate ($1.90/day)"; Code="SI.POV.DDAY"},
    @{Name="Poverty Rate ($2.15/day 2017 PPP)"; Code="SI.POV.LMIC"},
    @{Name="Poverty Rate ($3.65/day 2017 PPP)"; Code="SI.POV.UMIC"},
    @{Name="Poverty Rate ($6.85/day 2017 PPP)"; Code="SI.POV.UMIC.GP"},
    @{Name="Poverty headcount ratio"; Code="SI.POV.NAHC"},
    
    # Education indicators
    @{Name="Mean years of schooling (adult)"; Code="HD.HCI.LAYS"},
    @{Name="Expected years of schooling"; Code="SE.SCH.LIFE"},
    @{Name="School enrollment tertiary"; Code="SE.TER.ENRR"},
    @{Name="Adult literacy rate"; Code="SE.ADT.LITR.ZS"},
    @{Name="Education Index proxy"; Code="SE.XPD.TOTL.GD.ZS"},
    
    # Human Capital / Development
    @{Name="Human Capital Index"; Code="HD.HCI.OVRL"},
    @{Name="Human Capital Index (male)"; Code="HD.HCI.OVRL.MA"},
    @{Name="Human Capital Index (female)"; Code="HD.HCI.OVRL.FE"},
    
    # Inequality
    @{Name="Gini coefficient"; Code="SI.POV.GINI"},
    @{Name="Income share top 10%"; Code="SI.DST.10TH.10"},
    @{Name="Income share bottom 10%"; Code="SI.DST.FRST.10"},
    
    # Additional development metrics
    @{Name="GNI per capita (Atlas method)"; Code="NY.GNP.PCAP.CD"},
    @{Name="GNI per capita (PPP)"; Code="NY.GNP.PCAP.PP.CD"},
    @{Name="Adjusted net national income per capita"; Code="NY.ADJ.NNTY.PC.CD"}
)

foreach ($indicator in $searchPatterns) {
    Write-Host "`nTrying: $($indicator.Name) [$($indicator.Code)]..." -ForegroundColor Yellow
    try {
        $url = "https://api.worldbank.org/v2/country/VNM/indicator/$($indicator.Code)?format=json&per_page=1000&date=1960:2024"
        $response = Invoke-RestMethod -Uri $url -Method Get
        
        if ($response.Count -gt 1) {
            $data = $response[1] | Where-Object { $_.countryiso3code -eq 'VNM' -and $null -ne $_.value } | Sort-Object date -Descending
            if ($data) {
                $latest = $data | Select-Object -First 1
                Write-Host "  ✓ FOUND: Latest $($latest.date) = $($latest.value)" -ForegroundColor Green
                
                # Save the data
                $response | ConvertTo-Json -Depth 10 | Out-File "wb_$($indicator.Code.Replace('.','_')).json" -Encoding UTF8
            } else {
                Write-Host "  ✗ No data for Vietnam" -ForegroundColor Red
            }
        }
    } catch {
        Write-Host "  ✗ API Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    Start-Sleep -Milliseconds 300
}

Write-Host "`n=== Search Complete ===" -ForegroundColor Cyan
