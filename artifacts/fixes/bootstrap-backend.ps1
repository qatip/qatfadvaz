$ErrorActionPreference = "Stop"

Write-Host "========================================="
Write-Host " Landing Zone State Backend Bootstrap"
Write-Host "========================================="
Write-Host ""

# Paths
$scriptDir     = Split-Path -Parent $MyInvocation.MyCommand.Path
$artifactsRoot = Split-Path $scriptDir -Parent
$backendDir    = Join-Path $artifactsRoot "lz-state-backend-bootstrap"
$tfvarsPath    = Join-Path $backendDir "terraform.tfvars"
$infoFile      = Join-Path $backendDir "backend-info.txt"

if (!(Test-Path $backendDir)) {
    throw "Backend folder not found at: $backendDir"
}

if (!(Test-Path $tfvarsPath)) {
    throw "terraform.tfvars not found at: $tfvarsPath"
}

# Read tfvars
$content = Get-Content -Path $tfvarsPath -Raw

# Detect placeholders
$hasPlaceholderSubscription = $content -match '\{your subscription id here\}'
$hasPlaceholderSuffix       = $content -match '\{suffix\}'

$subscriptionId = $null
$storageAccountName = $null
$suffix = $null

# -------------------------------
# FIRST RUN (placeholders present)
# -------------------------------
if ($hasPlaceholderSubscription -or $hasPlaceholderSuffix) {

    Write-Host "terraform.tfvars contains placeholder values."
    Write-Host "Collecting setup values..."
    Write-Host ""

    # Subscription
    $subscriptionId = Read-Host "Enter your Azure subscription ID"
    if ([string]::IsNullOrWhiteSpace($subscriptionId)) {
        throw "Subscription ID cannot be blank."
    }

    if ($subscriptionId -notmatch '^[0-9a-fA-F-]{36}$') {
        Write-Warning "That does not look like a standard subscription GUID."
    }

    # Suffix
    $suffixInput = Read-Host "Press Enter to auto-generate a storage suffix, or type one manually"

    if ([string]::IsNullOrWhiteSpace($suffixInput)) {
        $suffix = -join ((48..57) | Get-Random -Count 4 | ForEach-Object { [char]$_ })
        Write-Host "Generated suffix: $suffix"
    }
    else {
        $suffix = $suffixInput.Trim().ToLower()
        if ($suffix -notmatch '^[a-z0-9]+$') {
            throw "Suffix must contain lowercase letters and/or numbers only."
        }
    }

    $storageAccountName = "advtfstate$suffix"

    # Update tfvars
    $content = [regex]::Replace(
        $content,
        '(?m)^(\s*subscription_id\s*=\s*)".*?"',
        { param($m) $m.Groups[1].Value + '"' + $subscriptionId + '"' }
    )

    $content = [regex]::Replace(
        $content,
        '(?m)^(\s*state_storage_account_name\s*=\s*)".*?"',
        { param($m) $m.Groups[1].Value + '"' + $storageAccountName + '"' }
    )

    Set-Content -Path $tfvarsPath -Value $content -Encoding UTF8

    Write-Host ""
    Write-Host "terraform.tfvars updated:"
    Write-Host "  subscription_id            = $subscriptionId"
    Write-Host "  state_storage_account_name = $storageAccountName"
    Write-Host ""
}

# -------------------------------
# RERUN (already configured)
# -------------------------------
else {

    Write-Host "terraform.tfvars already configured."
    Write-Host "Reusing existing values..."
    Write-Host ""

    $subscriptionId = [regex]::Match($content, '(?m)^\s*subscription_id\s*=\s*"([^"]+)"').Groups[1].Value
    $storageAccountName = [regex]::Match($content, '(?m)^\s*state_storage_account_name\s*=\s*"([^"]+)"').Groups[1].Value

    if ($storageAccountName -match '^advtfstate(.+)$') {
        $suffix = $Matches[1]
    }

    Write-Host "  subscription_id            = $subscriptionId"
    Write-Host "  state_storage_account_name = $storageAccountName"
    Write-Host ""
    Write-Host "Useful if a previous run was interrupted."
    Write-Host ""
}

# -------------------------------
# Friendly guidance (YOUR REQUEST)
# -------------------------------
Write-Host ""
Write-Host "NOTE:" -ForegroundColor Yellow
Write-Host "If this is your first Azure run today and it appears slow or stuck," -ForegroundColor Yellow
Write-Host "press Ctrl+C and rerun this script." -ForegroundColor Yellow
Write-Host ""

# -------------------------------
# Confirm
# -------------------------------
$confirm = Read-Host "Proceed with terraform init and terraform apply --auto-approve ? (Y/N)"
if ($confirm -notin @("Y","y")) {
    Write-Host "Operation cancelled."
    exit
}

# -------------------------------
# Terraform execution
# -------------------------------
Push-Location $backendDir
try {
    Write-Host ""
    Write-Host "Running terraform init..."
    terraform init

    if ($LASTEXITCODE -ne 0) {
        throw "terraform init failed."
    }

    Write-Host ""
    Write-Host "Running terraform apply --auto-approve..."
    terraform apply --auto-approve

    if ($LASTEXITCODE -ne 0) {
        throw "terraform apply failed."
    }
}
finally {
    Pop-Location
}

# -------------------------------
# Save backend info
# -------------------------------
@"
=========================================
 BACKEND DETAILS (KEEP THIS SAFE)
=========================================

Subscription ID          : $subscriptionId
Storage Account Name     : $storageAccountName
Storage Container        : tfstate

IMPORTANT:
- You WILL need this storage account name again
- Future labs assume this backend exists
- If your environment is reset, rerun this script

=========================================
"@ | Set-Content -Path $infoFile -Encoding UTF8

# -------------------------------
# Final output
# -------------------------------
Write-Host ""
Write-Host "========================================="
Write-Host " BACKEND BOOTSTRAP COMPLETE"
Write-Host "========================================="
Write-Host ""
Write-Host "!!! IMPORTANT - WRITE THIS DOWN !!!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Storage Account Name : $storageAccountName" -ForegroundColor Cyan
Write-Host ""
Write-Host "You WILL need this for future labs." -ForegroundColor Yellow
Write-Host ""
Write-Host "Details saved to: $infoFile"
Write-Host ""
Write-Host "========================================="