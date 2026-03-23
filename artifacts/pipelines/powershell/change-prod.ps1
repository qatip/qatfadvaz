# pipelines/promote-prod.ps1
$ErrorActionPreference = "Stop"

. "$PSScriptRoot\_common.ps1"

Invoke-Promotion -Environment "prod"
