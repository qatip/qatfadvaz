# Print-Statefile.ps1
# Shows Terraform backend cache identity if present.
# If not found, explains init vs local state clearly.

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$backendCachePath = ".terraform/terraform.tfstate"
$localStatePath   = "terraform.tfstate"

function Read-JsonFile {
    param([Parameter(Mandatory=$true)][string]$Path)
    return (Get-Content $Path -Raw | ConvertFrom-Json)
}

function Get-OrMissing {
    param(
        [Parameter(Mandatory=$true)][object]$Cfg,
        [Parameter(Mandatory=$true)][string]$Name
    )
    if ($Cfg -and ($Cfg.PSObject.Properties.Name -contains $Name)) {
        $v = $Cfg.$Name
        if ($null -ne $v -and "$v".Trim().Length -gt 0) { return "$v" }
    }
    return "<missing>"
}

Write-Host ""

# Prefer backend cache (remote backend)
if (Test-Path $backendCachePath) {

    $cache = Read-JsonFile $backendCachePath

    if (-not $cache.backend -or -not $cache.backend.type -or -not $cache.backend.config) {
        Write-Host "Terraform backend identity:"
        Write-Host "  <backend cache present but incomplete>"
        Write-Host ""
        exit 0
    }

    $backendType = $cache.backend.type
    $config      = $cache.backend.config

    Write-Host "Terraform backend identity (from cached init config):"
    Write-Host "  Backend Type: $backendType"
    Write-Host ""

    if ($backendType -eq "azurerm") {
        Write-Host ("  resource_group_name: {0}" -f (Get-OrMissing $config "resource_group_name"))
        Write-Host ("  storage_account_name: {0}" -f (Get-OrMissing $config "storage_account_name"))
        Write-Host ("  container_name: {0}" -f (Get-OrMissing $config "container_name"))
        Write-Host ("  key: {0}" -f (Get-OrMissing $config "key"))
        Write-Host ""
    }
    else {
        Write-Host ("  key: {0}" -f (Get-OrMissing $config "key"))
        Write-Host ""
    }

    exit 0
}

# No backend cache found
Write-Host "Terraform backend identity:"
Write-Host "  <backend cache not found>"
Write-Host ""
Write-Host "This usually means:"
Write-Host "  - You have not run 'terraform init' in this folder yet, OR"
Write-Host "  - A local state file is in use (terraform.tfstate) rather than a remote backend."
Write-Host ""

if (Test-Path $localStatePath) {
    Write-Host "Note: A local state file exists here:"
    Write-Host "  $localStatePath"
    Write-Host ""
}

exit 0
