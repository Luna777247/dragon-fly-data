# Update CSV with UNDP data
$csvPath = "src/data/vietnam_advance.csv"
$csv = Import-Csv $csvPath

# Read the CSV and find Vietnam data
$vietnamLine = Get-Content undp_hdr_data.csv | Where-Object { $_ -match "^VNM," }
$data = $vietnamLine -split ","

# HDI: columns 5-38 (1990-2023)
for ($i = 0; $i -le 33; $i++) {
    $year = 1990 + $i
    $value = $data[5 + $i]
    if ($value -and $value -ne "") {
        $row = $csv | Where-Object { $_.Year -eq $year }
        if ($row) {
            $row.HDI = [math]::Round([double]$value, 3)
        }
    }
}

# Life Expectancy: columns 39-72 (1990-2023)
for ($i = 0; $i -le 33; $i++) {
    $year = 1990 + $i
    $value = $data[39 + $i]
    if ($value -and $value -ne "") {
        $row = $csv | Where-Object { $_.Year -eq $year }
        if ($row) {
            $row.Life_Expectancy_UNDP = [math]::Round([double]$value, 1)
        }
    }
}

# Expected Years Schooling: columns 73-106 (1990-2023)
for ($i = 0; $i -le 33; $i++) {
    $year = 1990 + $i
    $value = $data[73 + $i]
    if ($value -and $value -ne "") {
        $row = $csv | Where-Object { $_.Year -eq $year }
        if ($row) {
            $row.Education_Index_UNDP = [math]::Round([double]$value, 1)
        }
    }
}

# GNI per capita: columns 141-174 (1990-2023)
for ($i = 0; $i -le 33; $i++) {
    $year = 1990 + $i
    $value = $data[141 + $i]
    if ($value -and $value -ne "") {
        $row = $csv | Where-Object { $_.Year -eq $year }
        if ($row) {
            $row.Income_Index_UNDP = [math]::Round([double]$value, 0)
        }
    }
}

# Export updated CSV
$csv | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

Write-Host "UNDP data successfully updated in vietnam_advance.csv"