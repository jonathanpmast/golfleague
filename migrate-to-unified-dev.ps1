#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Migration helper for transitioning to the new unified dev.ps1 system
.DESCRIPTION
    This script helps transition from the old PowerShell scripts to the new unified dev.ps1 system.
    It provides compatibility shims and migration guidance.
.EXAMPLE
    .\migrate-to-unified-dev.ps1
#>

param(
    [switch]$DryRun,
    [switch]$Backup,
    [switch]$Force
)

# Import core libraries
. .\dev-core.ps1

function Show-MigrationStatus {
    Write-Header "Development Script Migration Status"
    
    $oldScripts = @(
        @{ Name = "start-dev-environment.ps1"; NewCommand = ".\dev.ps1 start"; Status = "REPLACE" },
        @{ Name = "stop-dev-environment.ps1"; NewCommand = ".\dev.ps1 stop"; Status = "REPLACE" },
        @{ Name = "check-dev-status.ps1"; NewCommand = ".\dev.ps1 status"; Status = "REPLACE" },
        @{ Name = "smart-start.ps1"; NewCommand = ".\dev.ps1 start -Force"; Status = "REPLACE" },
        @{ Name = "load-sample-data.ps1"; NewCommand = ".\dev.ps1 sample-data"; Status = "REPLACE" },
        @{ Name = "test-azurite-integration.ps1"; NewCommand = ".\dev.ps1 test-azurite"; Status = "REPLACE" },
        @{ Name = "dev-helper.ps1"; NewCommand = ".\dev.ps1 status"; Status = "CONSOLIDATE" }
    )
    
    Write-ColorOutput "Old Script → New Command Migration:" $Global:Colors.Yellow
    foreach ($script in $oldScripts) {
        $exists = Test-Path $script.Name
        $icon = if ($exists) { "📄" } else { "❌" }
        $color = if ($exists) { $Global:Colors.Reset } else { $Global:Colors.Red }
        
        Write-ColorOutput "$icon $($script.Name) → $($script.NewCommand)" $color
        if ($script.Status -eq "REPLACE") {
            Write-ColorOutput "   Status: Can be fully replaced" $Global:Colors.Green
        } else {
            Write-ColorOutput "   Status: Functionality consolidated" $Global:Colors.Yellow
        }
    }
}

function Backup-OldScripts {
    $backupDir = ".\backup-old-scripts-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    
    Write-ColorOutput "📦 Creating backup directory: $backupDir" $Global:Colors.Yellow
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    
    $scriptsToBackup = @(
        "start-dev-environment.ps1",
        "stop-dev-environment.ps1", 
        "check-dev-status.ps1",
        "smart-start.ps1",
        "load-sample-data.ps1",
        "test-azurite-integration.ps1",
        "dev-helper.ps1"
    )
    
    foreach ($script in $scriptsToBackup) {
        if (Test-Path $script) {
            Copy-Item $script -Destination $backupDir
            Write-ColorOutput "✅ Backed up: $script" $Global:Colors.Green
        }
    }
    
    # Create a migration guide in the backup directory
    $migrationGuide = @"
# Migration Guide - Backup Created $(Get-Date)

This backup contains the old PowerShell scripts that have been replaced by the unified dev.ps1 system.

## Old Script → New Command Mapping:

- start-dev-environment.ps1 → .\dev.ps1 start
- stop-dev-environment.ps1 → .\dev.ps1 stop  
- check-dev-status.ps1 → .\dev.ps1 status
- smart-start.ps1 → .\dev.ps1 start -Force
- load-sample-data.ps1 → .\dev.ps1 sample-data
- test-azurite-integration.ps1 → .\dev.ps1 test-azurite
- dev-helper.ps1 → .\dev.ps1 status

## New Unified Commands:

```powershell
# Start all services
.\dev.ps1 start

# Start with force (replaces smart-start.ps1)
.\dev.ps1 start -Force

# Start only specific services
.\dev.ps1 start -Service Vue
.\dev.ps1 start -Service Functions

# Check status
.\dev.ps1 status

# Stop services
.\dev.ps1 stop
.\dev.ps1 stop -Force
.\dev.ps1 stop -IncludeCosmosDB

# Restart services
.\dev.ps1 restart
.\dev.ps1 restart -Service Functions

# Load sample data
.\dev.ps1 sample-data

# Test Azurite
.\dev.ps1 test-azurite

# Get help
.\dev.ps1 help
```

## Benefits of New System:

- Single entry point for all operations
- Consistent parameter handling
- Better error handling and status reporting  
- Consolidated code (no duplication)
- Configurable ports via dev-config.ps1
- Enhanced service detection and management

## Rollback Instructions:

If you need to rollback to the old scripts:
1. Copy the backed up scripts back to the main directory
2. The old scripts will work as before
3. The new dev.ps1, dev-core.ps1, and dev-config.ps1 can coexist

"@

    $migrationGuide | Out-File -FilePath "$backupDir\MIGRATION-GUIDE.md" -Encoding UTF8
    Write-ColorOutput "📋 Created migration guide: $backupDir\MIGRATION-GUIDE.md" $Global:Colors.Blue
    
    return $backupDir
}

function Create-CompatibilityShims {
    Write-ColorOutput "🔗 Creating compatibility shim scripts..." $Global:Colors.Yellow
    
    $shims = @{
        "start-dev-environment.ps1" = @"
#!/usr/bin/env pwsh
# COMPATIBILITY SHIM - Use .\dev.ps1 start instead
Write-Warning "This script is deprecated. Use '.\dev.ps1 start' instead."
Write-Host "Executing: .\dev.ps1 start `$args"
& .\dev.ps1 start @args
"@
        "stop-dev-environment.ps1" = @"
#!/usr/bin/env pwsh  
# COMPATIBILITY SHIM - Use .\dev.ps1 stop instead
Write-Warning "This script is deprecated. Use '.\dev.ps1 stop' instead."
Write-Host "Executing: .\dev.ps1 stop `$args"
& .\dev.ps1 stop @args
"@
        "check-dev-status.ps1" = @"
#!/usr/bin/env pwsh
# COMPATIBILITY SHIM - Use .\dev.ps1 status instead  
Write-Warning "This script is deprecated. Use '.\dev.ps1 status' instead."
Write-Host "Executing: .\dev.ps1 status `$args"
& .\dev.ps1 status @args
"@
        "smart-start.ps1" = @"
#!/usr/bin/env pwsh
# COMPATIBILITY SHIM - Use .\dev.ps1 start -Force instead
Write-Warning "This script is deprecated. Use '.\dev.ps1 start -Force' instead."
Write-Host "Executing: .\dev.ps1 start -Force `$args"
& .\dev.ps1 start -Force @args
"@
        "load-sample-data.ps1" = @"
#!/usr/bin/env pwsh
# COMPATIBILITY SHIM - Use .\dev.ps1 sample-data instead
Write-Warning "This script is deprecated. Use '.\dev.ps1 sample-data' instead."
Write-Host "Executing: .\dev.ps1 sample-data `$args"
& .\dev.ps1 sample-data @args
"@
    }
    
    foreach ($script in $shims.Keys) {
        if (-not $DryRun) {
            $shims[$script] | Out-File -FilePath $script -Encoding UTF8
        }
        Write-ColorOutput "✅ Created shim: $script" $Global:Colors.Green
    }
}

# Main execution
Write-Header "Golf League Development Script Migration"

if ($DryRun) {
    Write-ColorOutput "🧪 DRY RUN MODE - No changes will be made" $Global:Colors.Yellow
}

Show-MigrationStatus

Write-ColorOutput "`n📋 Migration Options:" $Global:Colors.Blue
Write-ColorOutput "1. Full Migration (recommended)" $Global:Colors.Reset
Write-ColorOutput "   - Backup old scripts" $Global:Colors.Reset  
Write-ColorOutput "   - Replace with compatibility shims" $Global:Colors.Reset
Write-ColorOutput "   - Use new .\dev.ps1 going forward" $Global:Colors.Reset
Write-ColorOutput ""
Write-ColorOutput "2. Gradual Migration" $Global:Colors.Reset
Write-ColorOutput "   - Keep old scripts alongside new system" $Global:Colors.Reset
Write-ColorOutput "   - Manually switch to .\dev.ps1 when ready" $Global:Colors.Reset
Write-ColorOutput ""
Write-ColorOutput "3. Status Only" $Global:Colors.Reset
Write-ColorOutput "   - Just show what would change" $Global:Colors.Reset

if (-not $Force -and -not $DryRun) {
    $choice = Read-Host "`nChoose migration option (1/2/3) or 'q' to quit"
    
    switch ($choice) {
        "1" {
            Write-ColorOutput "`n🚀 Starting full migration..." $Global:Colors.Blue
            
            if ($Backup -or (Read-Host "Create backup of old scripts? (y/n)") -eq "y") {
                $backupDir = Backup-OldScripts
                Write-ColorOutput "✅ Backup created: $backupDir" $Global:Colors.Green
            }
            
            Create-CompatibilityShims
            
            Write-ColorOutput "`n✅ Migration complete!" $Global:Colors.Green
            Write-ColorOutput "You can now use .\dev.ps1 for all development operations." $Global:Colors.Reset
            Write-ColorOutput "Old script names will show deprecation warnings but still work." $Global:Colors.Yellow
        }
        "2" {
            Write-ColorOutput "`n📝 Gradual migration selected." $Global:Colors.Blue
            Write-ColorOutput "Both old and new systems will coexist." $Global:Colors.Reset
            Write-ColorOutput "Start using .\dev.ps1 when ready, old scripts remain unchanged." $Global:Colors.Reset
        }
        "3" {
            Write-ColorOutput "`n📊 Status-only mode - no changes made." $Global:Colors.Blue
        }
        "q" {
            Write-ColorOutput "Migration cancelled." $Global:Colors.Yellow
            exit 0
        }
        default {
            Write-ColorOutput "Invalid choice. Migration cancelled." $Global:Colors.Red
            exit 1
        }
    }
} elseif ($Force) {
    Write-ColorOutput "`n🚀 Force mode: Creating full migration..." $Global:Colors.Blue
    
    if ($Backup) {
        $backupDir = Backup-OldScripts
        Write-ColorOutput "✅ Backup created: $backupDir" $Global:Colors.Green
    }
    
    Create-CompatibilityShims
    Write-ColorOutput "`n✅ Migration complete!" $Global:Colors.Green
}

Write-ColorOutput "`n📚 Next Steps:" $Global:Colors.Blue
Write-ColorOutput "- Try: .\dev.ps1 help" $Global:Colors.Reset
Write-ColorOutput "- Try: .\dev.ps1 status" $Global:Colors.Reset
Write-ColorOutput "- Try: .\dev.ps1 start" $Global:Colors.Reset
Write-ColorOutput "- Update any documentation or CI/CD scripts to use .\dev.ps1" $Global:Colors.Reset
Write-ColorOutput "- See docs/PORT-CONFIGURATION-GUIDE.md for port configuration" $Global:Colors.Reset
