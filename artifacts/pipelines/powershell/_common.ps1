# _common.ps1  (known-good for: guided\artifacts\pipelines\powershell)
# PowerShell 5.1 compatible

Set-StrictMode -Version Latest

function Get-LabRoot {
  # _common.ps1 is in: <guided>\artifacts\pipelines\powershell\_common.ps1
  # We want:               <guided>
  return (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
}

function Get-EnvPath {
  param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("dev","test","prod")]
    [string]$Environment
  )

  $labRoot = Get-LabRoot
  $envPath = Join-Path $labRoot ("lab6\guided\envs\" + $Environment)

  if (-not (Test-Path $envPath)) {
    throw "Environment folder not found: $envPath"
  }

  return $envPath
}

function Get-TfvarsPath {
  param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("dev","test","prod")]
    [string]$Environment
  )

  $envPath = Get-EnvPath -Environment $Environment
  $tfvars  = Join-Path $envPath "terraform.tfvars"

  if (-not (Test-Path $tfvars)) {
    throw "TFVARS file not found for '$Environment'. Expected: $tfvars"
  }

  return $tfvars
}

function Invoke-Terraform {
  param(
    [Parameter(Mandatory=$true)]
    [string]$WorkingDirectory,

    [Parameter(Mandatory=$true)]
    [string[]]$Args,

    [Parameter(Mandatory=$true)]
    [string]$DisplayName
  )

  Write-Host ""
  Write-Host "============================================================"
  Write-Host $DisplayName
  Write-Host "Working directory: $WorkingDirectory"
  Write-Host "Command: terraform $($Args -join ' ')"
  Write-Host "============================================================"
  Write-Host ""

  Push-Location $WorkingDirectory
  try {
    & terraform @Args
    if ($LASTEXITCODE -ne 0) {
      throw "Terraform command failed ($DisplayName). Exit code: $LASTEXITCODE"
    }
  }
  finally {
    Pop-Location
  }
}

function Get-NetworkPinnedVersion {
  param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("dev","test","prod")]
    [string]$Environment
  )

  $envPath = Get-EnvPath -Environment $Environment
  $mainTf  = Join-Path $envPath "main.tf"

  if (-not (Test-Path $mainTf)) {
    throw "main.tf not found in $envPath"
  }

  $content = Get-Content -Raw -Path $mainTf

  # Match ONLY the network module ref (avoid catching the security module ref)
  $m = [regex]::Match(
    $content,
    '(?i)terraform-azure-module-network\.git\?ref=v?(\d+\.\d+\.\d+)'
  )

  if (-not $m.Success) {
    throw "Could not detect NETWORK module version for '$Environment'. Expected ...terraform-azure-module-network.git?ref=vX.Y.Z in $mainTf"
  }

  return $m.Groups[1].Value
}

function Compare-SemVer {
  param(
    [Parameter(Mandatory=$true)][string]$A,
    [Parameter(Mandatory=$true)][string]$B
  )

  try {
    $va = [version]$A
    $vb = [version]$B
  }
  catch {
    throw "Invalid version comparison. A='$A', B='$B'. Expected format like 1.2.3"
  }

  if ($va -lt $vb) { return -1 }
  if ($va -gt $vb) { return  1 }
  return 0
}

function Assert-PromotionAllowed {
  param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("dev","test","prod")]
    [string]$TargetEnvironment
  )

  # Rules (match your lab narrative):
  # - Dev validates new versions (dev can always run)
  # - Test cannot advance ahead of dev (network pin)
  # - Prod cannot advance ahead of test (network pin)

  if ($TargetEnvironment -eq "dev") { return }

  if ($TargetEnvironment -eq "test") {
    $devVer  = Get-NetworkPinnedVersion -Environment "dev"
    $testVer = Get-NetworkPinnedVersion -Environment "test"

    if ((Compare-SemVer -A $testVer -B $devVer) -gt 0) {
      throw "Promotion blocked: test network ($testVer) is ahead of dev network ($devVer). Promote dev first (or align pins)."
    }
    return
  }

  if ($TargetEnvironment -eq "prod") {
    $testVer = Get-NetworkPinnedVersion -Environment "test"
    $prodVer = Get-NetworkPinnedVersion -Environment "prod"

    if ((Compare-SemVer -A $prodVer -B $testVer) -gt 0) {
      throw "Promotion blocked: prod network ($prodVer) is ahead of test network ($testVer). Promote test first (or align pins)."
    }
    return
  }
}

function Invoke-Promotion {
  param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("dev","test","prod")]
    [string]$Environment
  )

  Assert-PromotionAllowed -TargetEnvironment $Environment

  $envPath     = Get-EnvPath -Environment $Environment
  $tfvarsPath  = Get-TfvarsPath -Environment $Environment
  $networkVer  = Get-NetworkPinnedVersion -Environment $Environment
  $planFile    = "tfplan"   # must be set unconditionally for StrictMode

  Write-Host ""
  Write-Host "============================================================"
  Write-Host " Local Pipeline Promotion"
  Write-Host " Environment : $Environment"
  Write-Host " Network Ref : v$networkVer"
  Write-Host " TFVARS      : $tfvarsPath"
  Write-Host "============================================================"
  Write-Host ""

  Invoke-Terraform -WorkingDirectory $envPath -Args @("--version") -DisplayName "Terraform Version"

  Invoke-Terraform -WorkingDirectory $envPath -Args @(
    "init",
    "-input=false"
  ) -DisplayName "Terraform Init ($Environment)"

  Invoke-Terraform -WorkingDirectory $envPath -Args @(
    "validate"
  ) -DisplayName "Terraform Validate ($Environment)"

  Invoke-Terraform -WorkingDirectory $envPath -Args @(
    "plan",
    "-input=false",
    "-var-file=$tfvarsPath",
    "-out=$planFile"
  ) -DisplayName "Terraform Plan ($Environment)"

  Invoke-Terraform -WorkingDirectory $envPath -Args @(
    "apply",
    "-input=false",
    "-auto-approve",
    $planFile
  ) -DisplayName "Terraform Apply ($Environment)"

  Write-Host ""
  Write-Host "SUCCESS: Promotion pipeline completed for '$Environment'."
  Write-Host ""
}
