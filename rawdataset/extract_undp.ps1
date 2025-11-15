# Read the CSV and find Vietnam data
$vietnamLine = Get-Content undp_hdr_data.csv | Where-Object { $_ -match "^VNM," }
$data = $vietnamLine -split ","

# HDI: columns 5-38 (1990-2023)
$hdiHash = @{}
for ($i = 0; $i -le 33; $i++) {
    $year = 1990 + $i
    $value = $data[5 + $i]
    if ($value -and $value -ne "") {
        $hdiHash[$year] = [math]::Round([double]$value, 3)
    }
}

# Life Expectancy: columns 39-72 (1990-2023)
$leHash = @{}
for ($i = 0; $i -le 33; $i++) {
    $year = 1990 + $i
    $value = $data[39 + $i]
    if ($value -and $value -ne "") {
        $leHash[$year] = [math]::Round([double]$value, 1)
    }
}

# Expected Years Schooling: columns 73-106 (1990-2023)
$eysHash = @{}
for ($i = 0; $i -le 33; $i++) {
    $year = 1990 + $i
    $value = $data[73 + $i]
    if ($value -and $value -ne "") {
        $eysHash[$year] = [math]::Round([double]$value, 1)
    }
}

# GNI per capita: columns 141-174 (1990-2023)
$gnipcHash = @{}
for ($i = 0; $i -le 33; $i++) {
    $year = 1990 + $i
    $value = $data[141 + $i]
    if ($value -and $value -ne "") {
        $gnipcHash[$year] = [math]::Round([double]$value, 0)
    }
}

Write-Host "HDI 2023: $($hdiHash[2023])"
Write-Host "Life Expectancy 2023: $($leHash[2023])"
Write-Host "Expected Years Schooling 2023: $($eysHash[2023])"
Write-Host "GNI per capita 2023: $($gnipcHash[2023])"
