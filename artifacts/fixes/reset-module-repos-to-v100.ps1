# Reset module repos back to v1.0.0 only
# WARNING: This deletes later tags locally and remotely, and force-resets main to v1.0.0

$Repos = @(
    "C:\module-repos\terraform-azure-module-network",
    "C:\module-repos\terraform-azure-module-security"
)

$KeepTag = "v1.0.0"

foreach ($Repo in $Repos) {

    Write-Host ""
    Write-Host "====================================================="
    Write-Host "Processing repo: $Repo"
    Write-Host "====================================================="

    if (-not (Test-Path $Repo)) {
        Write-Host "Repo path not found: $Repo" -ForegroundColor Red
        continue
    }

    Set-Location $Repo

    Write-Host "Fetching latest refs..."
    git fetch origin --tags --prune

    Write-Host "Checking required tag exists..."
    git rev-parse $KeepTag 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Required tag $KeepTag not found. Skipping repo." -ForegroundColor Red
        continue
    }

    Write-Host "Resetting local main to $KeepTag..."
    git checkout main
    git reset --hard $KeepTag
    git clean -fd

    Write-Host "Force pushing main back to $KeepTag..."
    git push origin main --force

    Write-Host "Removing local tags except $KeepTag..."
    $localTags = git tag

    foreach ($tag in $localTags) {
        if ($tag -ne $KeepTag) {
            Write-Host "Deleting local tag: $tag"
            git tag -d $tag
        }
    }

    Write-Host "Removing remote tags except $KeepTag..."
    $remoteTags = git ls-remote --tags origin |
        ForEach-Object {
            ($_ -split "\s+")[1] -replace "refs/tags/", ""
        } |
        Where-Object {
            $_ -and ($_ -notlike "*^{}") -and ($_ -ne $KeepTag)
        }

    foreach ($tag in $remoteTags) {
        Write-Host "Deleting remote tag: $tag"
        git push origin ":refs/tags/$tag"
    }

    Write-Host "Final fetch/prune..."
    git fetch origin --tags --prune

    Write-Host "Remaining local tags:"
    git tag

    Write-Host "Remaining remote tags:"
    git ls-remote --tags origin
}

Write-Host ""
Write-Host "Reset complete. Module repos should now be back to main at v1.0.0 with only v1.0.0 tagged." -ForegroundColor Green