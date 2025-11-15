# Process GSO regional density data
Write-Host "=== Processing GSO Regional Density Data ===" -ForegroundColor Cyan

# The GSO data includes these regions:
# - Bắc Trung Bộ và Duyên hải miền Trung (Miền Trung)
# - Trung du và miền núi phía Bắc (Đông Bắc)
# - Tây Nguyên
# - Đồng bằng sông Cửu Long (ĐBSCL)

# Parse the GSO data
$gsoData = @"
Bắc Trung Bộ và Duyên hải miền Trung	2011	95838,0	19116,3	199,5
Bắc Trung Bộ và Duyên hải miền Trung	2012	95835,8	19253,8	200,9
Bắc Trung Bộ và Duyên hải miền Trung	2013	95834,5	19392,0	202,3
Bắc Trung Bộ và Duyên hải miền Trung	2014	95832,4	19511,5	203,6
Bắc Trung Bộ và Duyên hải miền Trung	2015	95832,4	19653,7	205,1
Bắc Trung Bộ và Duyên hải miền Trung	2016	95871,3	19802,5	206,6
Bắc Trung Bộ và Duyên hải miền Trung	2017	95871,9	19949,0	208,1
Bắc Trung Bộ và Duyên hải miền Trung	2018	95876,0	20085,1	209,5
Bắc Trung Bộ và Duyên hải miền Trung	2019	95875,8	20220,4	211,0
Bắc Trung Bộ và Duyên hải miền Trung	2020	95860,1	20343,2	212,0
Bắc Trung Bộ và Duyên hải miền Trung	2021	95847,5	20584,9	215,0
Bắc Trung Bộ và Duyên hải miền Trung	2022	95847,9	20661,7	216,0
Bắc Trung Bộ và Duyên hải miền Trung	2023	95847,9	20768,7	216,7
Bắc Trung Bộ và Duyên hải miền Trung	2024	95848,5	20960,5	218,7
Trung du và miền núi phía Bắc	2011	95264,4	11311,4	118,7
Trung du và miền núi phía Bắc	2012	95272,3	11441,8	120,1
Trung du và miền núi phía Bắc	2013	95274,7	11574,5	121,5
Trung du và miền núi phía Bắc	2014	95266,8	11739,2	123,2
Trung du và miền núi phía Bắc	2015	95266,8	11907,0	125,0
Trung du và miền núi phía Bắc	2016	95222,3	12061,1	126,7
Trung du và miền núi phía Bắc	2017	95222,1	12230,8	128,4
Trung du và miền núi phía Bắc	2018	95222,2	12404,9	130,3
Trung du và miền núi phía Bắc	2019	95221,9	12569,3	132,0
Trung du và miền núi phía Bắc	2020	95184,1	12725,8	134,0
Trung du và miền núi phía Bắc	2021	95184,1	12925,1	136,0
Trung du và miền núi phía Bắc	2022	95184,2	13023,2	137,0
Trung du và miền núi phía Bắc	2023	95184,1	13162,4	138,3
Trung du và miền núi phía Bắc	2024	95177,0	13338,9	140,1
Tây Nguyên	2011	54641,0	5278,0	96,6
Tây Nguyên	2012	54641,1	5358,0	98,1
Tây Nguyên	2013	54641,1	5438,7	99,5
Tây Nguyên	2014	54641,0	5509,2	100,8
Tây Nguyên	2015	54641,0	5584,3	102,2
Tây Nguyên	2016	54508,0	5657,1	103,8
Tây Nguyên	2017	54508,3	5725,5	105,0
Tây Nguyên	2018	54508,3	5796,4	106,3
Tây Nguyên	2019	54508,3	5861,3	108,0
Tây Nguyên	2020	54545,2	5932,1	109,0
Tây Nguyên	2021	54548,3	6033,8	111,0
Tây Nguyên	2022	54548,3	6092,4	112,0
Tây Nguyên	2023	54548,3	6163,6	113,0
Tây Nguyên	2024	54548,3	6241,0	114,4
Đồng bằng sông Cửu Long	2011	40548,2	17217,7	424,6
Đồng bằng sông Cửu Long	2012	40553,1	17252,6	425,4
Đồng bằng sông Cửu Long	2013	40572,0	17269,9	425,7
Đồng bằng sông Cửu Long	2014	40576,0	17269,8	425,6
Đồng bằng sông Cửu Long	2015	40576,0	17266,7	425,5
Đồng bằng sông Cửu Long	2016	40816,3	17271,6	423,2
Đồng bằng sông Cửu Long	2017	40816,3	17279,5	423,3
Đồng bằng sông Cửu Long	2018	40816,4	17280,7	423,4
Đồng bằng sông Cửu Long	2019	40816,4	17282,5	423,0
Đồng bằng sông Cửu Long	2020	40921,7	17318,6	423,0
Đồng bằng sông Cửu Long	2021	40921,7	17422,6	426,0
Đồng bằng sông Cửu Long	2022	40922,6	17432,1	426,0
Đồng bằng sông Cửu Long	2023	40921,7	17463,3	426,7
Đồng bằng sông Cửu Long	2024	40921,8	17547,9	428,8
"@

# Parse data into hashtable
$regionalData = @{}
foreach ($line in $gsoData -split "`n") {
    $parts = $line -split "`t"
    if ($parts.Count -eq 5) {
        $region = $parts[0].Trim()
        $year = [int]$parts[1].Trim()
        $density = $parts[4].Trim().Replace(',', '.')
        
        if (-not $regionalData.ContainsKey($year)) {
            $regionalData[$year] = @{}
        }
        $regionalData[$year][$region] = $density
    }
}

Write-Host "`nRegional data parsed for years: $($regionalData.Keys -join ', ')" -ForegroundColor Green

# Load CSV and update
$csv = Import-Csv "src\data\vietnam_advance.csv" -Encoding UTF8
$updates = 0

Write-Host "`nUpdating CSV with regional density data..." -ForegroundColor Yellow

foreach ($row in $csv) {
    $year = [int]$row.Year
    
    if ($regionalData.ContainsKey($year)) {
        $yearData = $regionalData[$year]
        
        # Đông Bắc = Trung du và miền núi phía Bắc
        if ($yearData.ContainsKey('Trung du và miền núi phía Bắc')) {
            $row.'Population Density by Region (?BSH)' = $yearData['Trung du và miền núi phía Bắc']
            $updates++
        }
        
        # Miền Trung = Bắc Trung Bộ và Duyên hải miền Trung
        if ($yearData.ContainsKey('Bắc Trung Bộ và Duyên hải miền Trung')) {
            $row.'Population Density by Region (Mi?n Trung)' = $yearData['Bắc Trung Bộ và Duyên hải miền Trung']
            $updates++
        }
        
        # ĐBSCL = Đồng bằng sông Cửu Long
        if ($yearData.ContainsKey('Đồng bằng sông Cửu Long')) {
            $row.'Population Density by Region (?BSCL)' = $yearData['Đồng bằng sông Cửu Long']
            $updates++
        }
        
        # Miền Núi = Tây Nguyên
        if ($yearData.ContainsKey('Tây Nguyên')) {
            $row.'Population Density by Region (Mi?n N?i)' = $yearData['Tây Nguyên']
            $updates++
        }
    }
}

# Save updated CSV
$csv | Export-Csv "src\data\vietnam_advance.csv" -Encoding UTF8 -NoTypeInformation

Write-Host "`n✓ Regional density data updated: $updates values" -ForegroundColor Green

# Verify sample data
Write-Host "`nSample verification (2020-2024):" -ForegroundColor Cyan
$recent = $csv | Where-Object { [int]$_.Year -ge 2020 -and [int]$_.Year -le 2024 }

foreach ($r in $recent) {
    Write-Host "`nYear $($r.Year):" -ForegroundColor Yellow
    Write-Host "  Đông Bắc (Northern Midlands): $($r.'Population Density by Region (?BSH)') người/km²" -ForegroundColor White
    Write-Host "  Miền Trung (Central Coast): $($r.'Population Density by Region (Mi?n Trung)') người/km²" -ForegroundColor White
    Write-Host "  ĐBSCL (Mekong Delta): $($r.'Population Density by Region (?BSCL)') người/km²" -ForegroundColor White
    Write-Host "  Miền Núi (Central Highlands): $($r.'Population Density by Region (Mi?n N?i)') người/km²" -ForegroundColor White
}

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "✓ 4 regional columns updated with GSO data (2011-2024)" -ForegroundColor Green
Write-Host "  - Đông Bắc (Northern Midlands & Mountains)" -ForegroundColor Gray
Write-Host "  - Miền Trung (North Central & Central Coast)" -ForegroundColor Gray
Write-Host "  - ĐBSCL (Mekong River Delta)" -ForegroundColor Gray
Write-Host "  - Miền Núi (Central Highlands)" -ForegroundColor Gray
