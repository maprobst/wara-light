<#
.SYNOPSIS
    Wrapper script to run the Well-Architected Reliability Assessment (WARA) tools.

.DESCRIPTION
    This script imports the WARA module from the checked-out repository and
    executes the assessment scripts.

.PARAMETER WaraRepoPath
    Path to the checked-out Well-Architected-Reliability-Assessment repository.

.EXAMPLE
    ./run_wara.ps1 -WaraRepoPath "/path/to/wara-repo"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$WaraRepoPath
)

$ErrorActionPreference = "Stop"

Write-Host "=== WARA Assessment Script ===" -ForegroundColor Cyan
Write-Host "WARA Repository Path: $WaraRepoPath" -ForegroundColor Green

# Verify the repository path exists
if (-not (Test-Path -Path $WaraRepoPath)) {
    Write-Error "WARA repository path does not exist: $WaraRepoPath"
    exit 1
}

# List contents of the WARA repository
Write-Host "`nContents of WARA repository:" -ForegroundColor Yellow
Get-ChildItem -Path $WaraRepoPath -Depth 1 | Format-Table Name, Mode, LastWriteTime

# Check for PowerShell module in src directory
$srcPath = Join-Path -Path $WaraRepoPath -ChildPath "src"
if (Test-Path -Path $srcPath) {
    Write-Host "`nContents of src directory:" -ForegroundColor Yellow
    Get-ChildItem -Path $srcPath -Recurse -Filter "*.ps1" | ForEach-Object {
        Write-Host "  - $($_.FullName.Replace($WaraRepoPath, '.'))" -ForegroundColor Gray
    }

    # Look for module manifest or main script
    $moduleManifest = Get-ChildItem -Path $srcPath -Recurse -Filter "*.psd1" | Select-Object -First 1
    if ($moduleManifest) {
        Write-Host "`nFound module manifest: $($moduleManifest.FullName)" -ForegroundColor Green

        # Import the module
        Write-Host "Importing WARA module..." -ForegroundColor Yellow
        Import-Module $moduleManifest.FullName -Force -Verbose

        # List available commands from the module
        Write-Host "`nAvailable WARA commands:" -ForegroundColor Yellow
        Get-Command -Module (Get-Module | Where-Object { $_.Path -like "*$WaraRepoPath*" }).Name |
            Format-Table Name, CommandType
    }
}

# Get environment variables for optional parameters
$subscriptionId = $env:SUBSCRIPTION_ID
$resourceGroup = $env:RESOURCE_GROUP

Write-Host "`n=== Configuration ===" -ForegroundColor Cyan
if ($subscriptionId) {
    Write-Host "Subscription ID: $subscriptionId" -ForegroundColor Gray
}
if ($resourceGroup) {
    Write-Host "Resource Group: $resourceGroup" -ForegroundColor Gray
}

# Create results subdirectory with timestamp and subscription
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$subscriptionSuffix = if ($subscriptionId) { "_$subscriptionId" } else { "" }
$subfolderName = "${timestamp}${subscriptionSuffix}"

$resultsBasePath = Join-Path -Path $PSScriptRoot -ChildPath ".." | Join-Path -ChildPath "results"
$resultsPath = Join-Path -Path $resultsBasePath -ChildPath $subfolderName

if (-not (Test-Path -Path $resultsPath)) {
    New-Item -ItemType Directory -Path $resultsPath -Force | Out-Null
}

Write-Host "`nResults will be saved to: $resultsPath" -ForegroundColor Green

# ============================================================
# Add your WARA script execution logic here
# ============================================================
#
# Example usage (uncomment and modify as needed):
#
# # Run the collector
# Start-WARACollector -SubscriptionId $subscriptionId -OutputPath $resultsPath
#
# # Run the analyzer
# $collectorOutput = Get-ChildItem -Path $resultsPath -Filter "*.json" | Select-Object -First 1
# if ($collectorOutput) {
#     Start-WARAAnalyzer -InputFile $collectorOutput.FullName -OutputPath $resultsPath
# }
#
# # Generate report
# $analyzerOutput = Get-ChildItem -Path $resultsPath -Filter "*.xlsx" | Select-Object -First 1
# if ($analyzerOutput) {
#     Start-WARAReport -InputFile $analyzerOutput.FullName -OutputPath $resultsPath
# }
# ============================================================

Write-Host "`n=== Script completed ===" -ForegroundColor Cyan
Write-Host "WARA repository is available at: $WaraRepoPath" -ForegroundColor Green
Write-Host "You can now call WARA scripts from this path." -ForegroundColor Green
