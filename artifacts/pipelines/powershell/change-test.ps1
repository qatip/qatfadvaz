# pipelines/promote-test.ps1
$ErrorActionPreference = "Stop"

. "$PSScriptRoot\_common.ps1"

Invoke-Promotion -Environment "test"
