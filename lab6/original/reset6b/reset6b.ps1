Write-Host "========================================="
Write-Host " Lab 6b Reset Script"
Write-Host "========================================="

$ErrorActionPreference = "Stop"

# Script location: lab6\original\recovery6b
$scriptPath   = Split-Path -Parent $MyInvocation.MyCommand.Path
$originalPath = Split-Path $scriptPath -Parent
$lab6Root     = Split-Path $originalPath -Parent
$repoRoot     = Split-Path $lab6Root -Parent

# Paths
$sourceEnvs   = Join-Path $scriptPath "envs"
$targetGuided = Join-Path $lab6Root "guided"
$tfvarsPath   = Join-Path $repoRoot "artifacts\lz-state-backend-bootstrap\terraform.tfvars"

# Validate required paths
if (!(Test-Path $sourceEnvs)) {
    throw "Source envs folder not found: $sourceEnvs"
}

if (!(Test-Path $targetGuided)) {
    throw "Target guided folder not found: $targetGuided"
}

if (!(Test-Path $tfvarsPath)) {
    throw "terraform.tfvars not found: $tfvarsPath"
}

Write-Host ""
Write-Host "Source envs      : $sourceEnvs"
Write-Host "Target guided    : $targetGuided"
Write-Host "Bootstrap tfvars : $tfvarsPath"
Write-Host ""

$confirm = Read-Host "This will DELETE the contents of lab6\guided and rebuild it for Lab 6b. Continue? (Y/N)"
if ($confirm -notin @("Y","y")) {
    Write-Host "Operation cancelled."
    exit
}

# Read tfvars
$tfvarsContent = Get-Content -Path $tfvarsPath -Raw

$storageMatch = [regex]::Match($tfvarsContent, '(?m)^\s*state_storage_account_name\s*=\s*"([^"]+)"')
$subMatch     = [regex]::Match($tfvarsContent, '(?m)^\s*subscription_id\s*=\s*"([^"]+)"')

if (!$storageMatch.Success) {
    throw "Could not find state_storage_account_name in $tfvarsPath"
}

if (!$subMatch.Success) {
    throw "Could not find subscription_id in $tfvarsPath"
}

$storageAccountName = $storageMatch.Groups[1].Value
$subscriptionId     = $subMatch.Groups[1].Value

Write-Host "Resolved values from bootstrap tfvars:"
Write-Host "  storage_account_name = $storageAccountName"
Write-Host "  subscription_id      = $subscriptionId"
Write-Host ""

# Step 1: clear guided folder contents
Write-Host "Clearing guided folder..."
Get-ChildItem -Path $targetGuided -Force | Remove-Item -Recurse -Force
Write-Host "Guided folder cleared."
Write-Host ""

# Step 2: copy envs into guided
Write-Host "Copying envs into guided..."
Copy-Item -Path $sourceEnvs -Destination $targetGuided -Recurse -Force
Write-Host "envs copied."
Write-Host ""

# Step 3: update providers.tf in dev/test/prod
$envNames = @("dev", "test", "prod")

foreach ($envName in $envNames) {
    $providersPath = Join-Path $targetGuided "envs\$envName\providers.tf"

    if (!(Test-Path $providersPath)) {
        throw "providers.tf not found for environment '$envName' at: $providersPath"
    }

    Write-Host "Updating $providersPath ..."

    $content = Get-Content -Path $providersPath -Raw

    $content = [regex]::Replace(
        $content,
        '(?m)^(\s*storage_account_name\s*=\s*)".*?"',
        { param($m) $m.Groups[1].Value + '"' + $storageAccountName + '"' }
    )

    $content = [regex]::Replace(
        $content,
        '(?m)^(\s*subscription_id\s*=\s*)".*?"',
        { param($m) $m.Groups[1].Value + '"' + $subscriptionId + '"' }
    )

    Set-Content -Path $providersPath -Value $content
}

Write-Host ""
Write-Host "========================================="
Write-Host " Lab 6b guided folder rebuilt"
Write-Host " providers.tf files updated"
Write-Host "========================================="