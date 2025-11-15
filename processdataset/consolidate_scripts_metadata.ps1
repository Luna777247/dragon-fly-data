# ============================================================================
# Consolidate Scripts & Reports Metadata
# ============================================================================
# Purpose: Create comprehensive metadata CSV about all PowerShell scripts 
#          and reports in the rawdataset directory
#
# Categories:
#   - Download scripts (download_*.ps1)
#   - Integration scripts (integrate_*.ps1)
#   - Validation scripts (validate_*, check_*, verify_*.ps1)
#   - Fix scripts (fix_*, update_*.ps1)
#   - Report scripts (final_*, *_report.ps1)
#   - Report files (*.md, *_issues.csv, *_report.csv)
#
# Author: Data Processing Script
# Created: 2025
# ============================================================================

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Scripts & Reports Metadata Analysis" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$ErrorActionPreference = "Stop"

# Set working directory to project root
Set-Location "$PSScriptRoot\.."

$rawDataPath = "rawdataset"
$outputPath = "processdataset"
$outputFile = "$outputPath\scripts_reports_metadata.csv"

# ============================================================================
# Helper Functions
# ============================================================================

function Get-ScriptMetadata {
    param(
        [System.IO.FileInfo]$File,
        [string]$Category
    )
    
    try {
        $content = Get-Content $File.FullName -Raw -ErrorAction SilentlyContinue
        $lines = (Get-Content $File.FullName | Measure-Object -Line).Lines
        
        # Extract first comment block (description)
        $description = ""
        if ($content -match '(?s)^#\s*(.+?)(?:\r?\n\r?\n|\r?\n[^#])') {
            $description = $Matches[1] -replace '#', '' -replace '\r?\n', ' ' -replace '\s+', ' '
            $description = $description.Trim().Substring(0, [Math]::Min(200, $description.Length))
        }
        
        # Count Write-Host statements (indicates verbosity/reporting)
        $writeHostCount = ([regex]::Matches($content, 'Write-Host')).Count
        
        # Check for error handling
        $hasErrorHandling = $content -match '\$ErrorActionPreference' -or 
                           $content -match 'try\s*{' -or 
                           $content -match 'catch\s*{'
        
        # Check for functions
        $functionCount = ([regex]::Matches($content, 'function\s+[\w-]+')).Count
        
        # Check for API calls
        $hasAPICall = $content -match 'Invoke-RestMethod' -or 
                     $content -match 'Invoke-WebRequest'
        
        # Check for CSV operations
        $hasCSVRead = $content -match 'Import-Csv'
        $hasCSVWrite = $content -match 'Export-Csv'
        
        # Check for JSON operations
        $hasJSONRead = $content -match 'ConvertFrom-Json'
        $hasJSONWrite = $content -match 'ConvertTo-Json'
        
        return [PSCustomObject]@{
            FileName = $File.Name
            Category = $Category
            FileType = $File.Extension
            SizeBytes = $File.Length
            Lines = $lines
            LastModified = $File.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
            Description = $description
            FunctionCount = $functionCount
            WriteHostCount = $writeHostCount
            HasErrorHandling = $hasErrorHandling
            HasAPICall = $hasAPICall
            HasCSVRead = $hasCSVRead
            HasCSVWrite = $hasCSVWrite
            HasJSONRead = $hasJSONRead
            HasJSONWrite = $hasJSONWrite
            Purpose = Get-ScriptPurpose -FileName $File.Name -Category $Category
        }
    }
    catch {
        Write-Host "  ⚠ Error analyzing $($File.Name): $_" -ForegroundColor Yellow
        return $null
    }
}

function Get-ReportMetadata {
    param(
        [System.IO.FileInfo]$File,
        [string]$Category
    )
    
    try {
        $lines = (Get-Content $File.FullName | Measure-Object -Line).Lines
        
        # For CSV reports
        if ($File.Extension -eq ".csv") {
            $csv = Import-Csv $File.FullName -ErrorAction SilentlyContinue
            $rowCount = if ($csv) { ($csv | Measure-Object).Count } else { 0 }
            $columnCount = if ($csv -and $csv.Count -gt 0) { ($csv[0].PSObject.Properties | Measure-Object).Count } else { 0 }
            
            return [PSCustomObject]@{
                FileName = $File.Name
                Category = $Category
                FileType = $File.Extension
                SizeBytes = $File.Length
                Lines = $lines
                LastModified = $File.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
                RowCount = $rowCount
                ColumnCount = $columnCount
                Description = "CSV report: $rowCount rows × $columnCount columns"
                Purpose = Get-ReportPurpose -FileName $File.Name
            }
        }
        # For Markdown reports
        elseif ($File.Extension -eq ".md") {
            $content = Get-Content $File.FullName -Raw
            $wordCount = ($content -split '\s+' | Measure-Object).Count
            $headerCount = ([regex]::Matches($content, '^#+\s', [System.Text.RegularExpressions.RegexOptions]::Multiline)).Count
            
            return [PSCustomObject]@{
                FileName = $File.Name
                Category = $Category
                FileType = $File.Extension
                SizeBytes = $File.Length
                Lines = $lines
                LastModified = $File.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
                WordCount = $wordCount
                HeaderCount = $headerCount
                Description = "Markdown report: $wordCount words, $headerCount sections"
                Purpose = Get-ReportPurpose -FileName $File.Name
            }
        }
    }
    catch {
        Write-Host "  ⚠ Error analyzing $($File.Name): $_" -ForegroundColor Yellow
        return $null
    }
}

function Get-ScriptPurpose {
    param(
        [string]$FileName,
        [string]$Category
    )
    
    switch -Regex ($FileName) {
        '^download_demographic' { return "Download population and demographic indicators from World Bank API" }
        '^download_economic' { return "Download economic indicators (GDP, GNI, trade) from World Bank API" }
        '^download_health_env' { return "Download health and environment indicators from World Bank API" }
        '^download_ilo' { return "Download employment data from ILO API" }
        '^download_unesco' { return "Download education data from UNESCO API" }
        '^download_undp' { return "Download Human Development Report data from UNDP" }
        '^download_world' { return "Download world reference data for benchmarking" }
        '^download_missing' { return "Download missing World Bank indicators" }
        '^download_remaining' { return "Download remaining World Bank indicators" }
        '^download_specific' { return "Download specific requested indicators" }
        
        '^integrate_demographic' { return "Integrate demographic indicators into main CSV" }
        '^integrate_unesco' { return "Integrate UNESCO education data into main CSV" }
        '^integrate_undp' { return "Integrate UNDP HDI data into main CSV" }
        '^integrate_world' { return "Integrate world reference data for comparison" }
        '^integrate_remaining' { return "Integrate remaining World Bank indicators" }
        '^integrate_additional' { return "Integrate additional indicators" }
        
        '^validate_ranges' { return "Validate all indicator values against expected ranges" }
        '^check_value_ranges' { return "Check if values fall within acceptable ranges" }
        '^check_unesco' { return "Verify UNESCO data integrity" }
        '^check_health' { return "Verify health indicator data" }
        '^check_available' { return "Check which indicators are available in API" }
        '^check_all_wb' { return "Comprehensive check of all World Bank data" }
        '^check_all_health' { return "Comprehensive check of health/environment data" }
        
        '^verify_rounding' { return "Verify numeric rounding consistency" }
        '^verify_real_data' { return "Verify data authenticity and accuracy" }
        '^verify_population' { return "Verify population data consistency" }
        
        '^fix_all_issues' { return "Apply fixes for all identified data issues" }
        '^fix_invalid' { return "Fix invalid or out-of-range values" }
        '^fix_primary' { return "Fix primary education completion rate data" }
        '^fix_urban_rural' { return "Fix urban/rural population split" }
        '^fix_urban_population' { return "Fix urban population percentage calculations" }
        '^fix_source' { return "Fix issues in source data files" }
        
        '^update_accurate_undp' { return "Update UNDP data with accurate values" }
        '^update_rankings' { return "Update Vietnam global/regional rankings" }
        '^update_primary' { return "Update primary education indicators" }
        '^update_ilo' { return "Update ILO employment data" }
        '^update_regional' { return "Update regional density calculations" }
        '^update_health_env' { return "Update health and environment indicators" }
        '^update_economic' { return "Update economic indicators" }
        '^update_unesco' { return "Update UNESCO education data" }
        '^update_who' { return "Update WHO health data" }
        '^update_undp_csv' { return "Update UNDP CSV file" }
        
        '^final_verification' { return "Final verification of all data before export" }
        '^final_update' { return "Final update of remaining data gaps" }
        '^final_summary_report' { return "Generate final summary report" }
        '^final_summary' { return "Generate final data summary" }
        '^final_population' { return "Generate final population summary" }
        '^final_detailed' { return "Generate detailed final report" }
        '^final_comprehensive' { return "Generate comprehensive final report" }
        '^final_complete' { return "Generate complete final report" }
        '^final_accurate' { return "Generate accurate final report" }
        
        '^verification_summary' { return "Generate verification summary report" }
        '^updated_comprehensive' { return "Generate updated comprehensive report" }
        
        default { return $Category }
    }
}

function Get-ReportPurpose {
    param([string]$FileName)
    
    switch -Regex ($FileName) {
        'DATA_QUALITY' { return "Comprehensive data quality assessment report" }
        'VERIFICATION_REPORT' { return "Data verification and validation report" }
        'employment_issues' { return "Issues found in employment data" }
        'population_sum_issues' { return "Population sum validation issues" }
        'value_range_issues' { return "Out-of-range value issues" }
        'column_verification' { return "Column-level verification report" }
        'value_range_validation' { return "Value range validation results" }
        default { return "Data analysis report" }
    }
}

# ============================================================================
# Scan All Scripts and Reports
# ============================================================================

Write-Host "Scanning rawdataset directory..." -ForegroundColor Cyan

$allMetadata = @()

# 1. Download Scripts
Write-Host "`n1. Download Scripts (download_*.ps1)" -ForegroundColor Yellow
$downloadScripts = Get-ChildItem "$rawDataPath\download_*.ps1" -ErrorAction SilentlyContinue
Write-Host "  Found: $($downloadScripts.Count) scripts" -ForegroundColor Gray
foreach ($script in $downloadScripts) {
    $metadata = Get-ScriptMetadata -File $script -Category "Download"
    if ($metadata) { $allMetadata += $metadata }
}

# 2. Integration Scripts
Write-Host "`n2. Integration Scripts (integrate_*.ps1)" -ForegroundColor Yellow
$integrationScripts = Get-ChildItem "$rawDataPath\integrate_*.ps1" -ErrorAction SilentlyContinue
Write-Host "  Found: $($integrationScripts.Count) scripts" -ForegroundColor Gray
foreach ($script in $integrationScripts) {
    $metadata = Get-ScriptMetadata -File $script -Category "Integration"
    if ($metadata) { $allMetadata += $metadata }
}

# 3. Validation Scripts
Write-Host "`n3. Validation Scripts (validate_*, check_*, verify_*.ps1)" -ForegroundColor Yellow
$validationScripts = @()
$validationScripts += Get-ChildItem "$rawDataPath\validate_*.ps1" -ErrorAction SilentlyContinue
$validationScripts += Get-ChildItem "$rawDataPath\check_*.ps1" -ErrorAction SilentlyContinue
$validationScripts += Get-ChildItem "$rawDataPath\verify_*.ps1" -ErrorAction SilentlyContinue
Write-Host "  Found: $($validationScripts.Count) scripts" -ForegroundColor Gray
foreach ($script in $validationScripts) {
    $metadata = Get-ScriptMetadata -File $script -Category "Validation"
    if ($metadata) { $allMetadata += $metadata }
}

# 4. Fix Scripts
Write-Host "`n4. Fix Scripts (fix_*.ps1)" -ForegroundColor Yellow
$fixScripts = Get-ChildItem "$rawDataPath\fix_*.ps1" -ErrorAction SilentlyContinue
Write-Host "  Found: $($fixScripts.Count) scripts" -ForegroundColor Gray
foreach ($script in $fixScripts) {
    $metadata = Get-ScriptMetadata -File $script -Category "Fix"
    if ($metadata) { $allMetadata += $metadata }
}

# 5. Update Scripts
Write-Host "`n5. Update Scripts (update_*.ps1)" -ForegroundColor Yellow
$updateScripts = Get-ChildItem "$rawDataPath\update_*.ps1" -ErrorAction SilentlyContinue
Write-Host "  Found: $($updateScripts.Count) scripts" -ForegroundColor Gray
foreach ($script in $updateScripts) {
    $metadata = Get-ScriptMetadata -File $script -Category "Update"
    if ($metadata) { $allMetadata += $metadata }
}

# 6. Report Scripts
Write-Host "`n6. Report Scripts (final_*, *_report.ps1)" -ForegroundColor Yellow
$reportScripts = @()
$reportScripts += Get-ChildItem "$rawDataPath\final_*.ps1" -ErrorAction SilentlyContinue
$reportScripts += Get-ChildItem "$rawDataPath\*_report.ps1" -ErrorAction SilentlyContinue | Where-Object { $_.Name -notlike "final_*" }
$reportScripts = $reportScripts | Sort-Object Name -Unique
Write-Host "  Found: $($reportScripts.Count) scripts" -ForegroundColor Gray
foreach ($script in $reportScripts) {
    $metadata = Get-ScriptMetadata -File $script -Category "Report"
    if ($metadata) { $allMetadata += $metadata }
}

# 7. Markdown Reports
Write-Host "`n7. Markdown Reports (*.md)" -ForegroundColor Yellow
$mdReports = Get-ChildItem "$rawDataPath\*.md" -ErrorAction SilentlyContinue
Write-Host "  Found: $($mdReports.Count) reports" -ForegroundColor Gray
foreach ($report in $mdReports) {
    $metadata = Get-ReportMetadata -File $report -Category "Markdown Report"
    if ($metadata) { $allMetadata += $metadata }
}

# 8. CSV Issue Reports
Write-Host "`n8. CSV Issue Reports (*_issues.csv)" -ForegroundColor Yellow
$issueReports = Get-ChildItem "$rawDataPath\*_issues.csv" -ErrorAction SilentlyContinue
Write-Host "  Found: $($issueReports.Count) reports" -ForegroundColor Gray
foreach ($report in $issueReports) {
    $metadata = Get-ReportMetadata -File $report -Category "Issue Report"
    if ($metadata) { $allMetadata += $metadata }
}

# 9. CSV Validation Reports
Write-Host "`n9. CSV Validation Reports (*_report.csv)" -ForegroundColor Yellow
$validationReports = Get-ChildItem "$rawDataPath\*_report.csv" -ErrorAction SilentlyContinue
Write-Host "  Found: $($validationReports.Count) reports" -ForegroundColor Gray
foreach ($report in $validationReports) {
    $metadata = Get-ReportMetadata -File $report -Category "Validation Report"
    if ($metadata) { $allMetadata += $metadata }
}

# ============================================================================
# Export to CSV
# ============================================================================

Write-Host "`nExporting metadata to CSV..." -ForegroundColor Cyan

# Ensure output directory exists
if (-not (Test-Path $outputPath)) {
    New-Item -ItemType Directory -Path $outputPath | Out-Null
}

# Export to CSV
$allMetadata | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8

Write-Host "  ✓ Exported to: $outputFile" -ForegroundColor Green

# ============================================================================
# Calculate Statistics
# ============================================================================

Write-Host "`nCalculating statistics..." -ForegroundColor Cyan

$totalFiles = $allMetadata.Count
$totalSize = ($allMetadata | Measure-Object -Property SizeBytes -Sum).Sum
$totalLines = ($allMetadata | Measure-Object -Property Lines -Sum).Sum

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Metadata Analysis Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Total Files:          $totalFiles" -ForegroundColor White
Write-Host "Total Size:           $([Math]::Round($totalSize / 1KB, 2)) KB" -ForegroundColor White
Write-Host "Total Lines:          $totalLines" -ForegroundColor White

# Category breakdown
Write-Host "`nFiles by Category:" -ForegroundColor Cyan
$allMetadata | Group-Object Category | Sort-Object Count -Descending | ForEach-Object {
    $size = ($_.Group | Measure-Object -Property SizeBytes -Sum).Sum
    $lines = ($_.Group | Measure-Object -Property Lines -Sum).Sum
    Write-Host ("  {0,-20} {1,3} files ({2,6} lines, {3,7:N1} KB)" -f $_.Name, $_.Count, $lines, ($size / 1KB)) -ForegroundColor Gray
}

# Script capabilities
Write-Host "`nScript Capabilities:" -ForegroundColor Cyan
$scriptsWithAPI = ($allMetadata | Where-Object { $_.HasAPICall -eq $true }).Count
$scriptsWithCSV = ($allMetadata | Where-Object { $_.HasCSVRead -eq $true -or $_.HasCSVWrite -eq $true }).Count
$scriptsWithJSON = ($allMetadata | Where-Object { $_.HasJSONRead -eq $true -or $_.HasJSONWrite -eq $true }).Count
$scriptsWithErrors = ($allMetadata | Where-Object { $_.HasErrorHandling -eq $true }).Count

Write-Host "  Scripts with API calls:      $scriptsWithAPI" -ForegroundColor Gray
Write-Host "  Scripts with CSV operations: $scriptsWithCSV" -ForegroundColor Gray
Write-Host "  Scripts with JSON operations: $scriptsWithJSON" -ForegroundColor Gray
Write-Host "  Scripts with error handling: $scriptsWithErrors" -ForegroundColor Gray

Write-Host "`n✓ Scripts & Reports metadata analysis complete!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan
