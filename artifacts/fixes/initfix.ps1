<#
.SYNOPSIS
Terraform init fix for Azure provider first-run hang issue.

.DESCRIPTION
Deletes:
  - .terraform
  - .terraform.lock.hcl

From the CURRENT WORKING DIRECTORY (where the user runs it),
then runs terraform init.

Includes a safety check for Terraform files with optional user confirmation.
#>

$ErrorActionPreference = "Stop"

# Capture caller's working directory
$targetDir = Get-Location

Write-Host ""
Write-Host "Terraform Init Fix Utility" -ForegroundColor Cyan
Write-Host "Target directory: $targetDir" -ForegroundColor Yellow
Write-Host ""

# 🔍 Check for Terraform files
$tfFiles = Get-ChildItem -Path $targetDir -Filter "*.tf" -ErrorAction SilentlyContinue

if (-not $tfFiles) {
    Write-Host "WARNING: No Terraform files (*.tf) found in this directory." -ForegroundColor Red
    Write-Host "You may be in the wrong folder." -ForegroundColor Red
    Write-Host ""

    $response = Read-Host "Do you want to continue anyway? (Y/N)"

    if ($response -notin @("Y","y")) {
        Write-Host "Operation cancelled." -ForegroundColor Yellow
        exit 1
    }
}

$terraformDir  = Join-Path $targetDir ".terraform"
$terraformLock = Join-Path $targetDir ".terraform.lock.hcl"

# Remove .terraform directory
if (Test-Path $terraformDir) {
    Write-Host "Removing .terraform directory..." -ForegroundColor Yellow
    Remove-Item $terraformDir -Recurse -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "No .terraform directory found." -ForegroundColor DarkYellow
}

# Remove lock file
if (Test-Path $terraformLock) {
    Write-Host "Removing .terraform.lock.hcl..." -ForegroundColor Yellow
    Remove-Item $terraformLock -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "No .terraform.lock.hcl file found." -ForegroundColor DarkYellow
}

Write-Host ""
Write-Host "Re-initialising Terraform..." -ForegroundColor Cyan

terraform init

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Fix complete. You can now run: terraform plan" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "terraform init failed. Check output above." -ForegroundColor Red
    exit $LASTEXITCODE
}