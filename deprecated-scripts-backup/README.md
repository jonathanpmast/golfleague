# Deprecated PowerShell Scripts Backup

This directory contains backup copies of the individual PowerShell development scripts that were consolidated into the unified `dev.ps1` system on **May 30, 2025**.

## Scripts Archived

### 📁 2025-05-30/
Contains the following deprecated scripts that were replaced by the unified system:

| **Deprecated Script** | **Replaced By** | **Backup Status** |
|----------------------|-----------------|-------------------|
| `start-dev-environment.ps1` | `.\dev.ps1 start` | ✅ Backed up |
| `stop-dev-environment.ps1` | `.\dev.ps1 stop` | ✅ Backed up |
| `check-dev-status.ps1` | `.\dev.ps1 status` | ✅ Backed up |
| `smart-start.ps1` | `.\dev.ps1 start -Force` | ✅ Backed up |
| `load-sample-data.ps1` | `.\dev.ps1 sample-data` | ✅ Backed up |
| `test-azurite-integration.ps1` | `.\dev.ps1 test-azurite` | ✅ Backed up |
| `dev-helper.ps1` | `.\dev.ps1 status` | ✅ Backed up |

## Current Active Scripts

The following scripts remain active in the main project directory:

- **✅ `dev.ps1`** - Unified development environment management script
- **✅ `dev-core.ps1`** - Core service management library
- **✅ `dev-config.ps1`** - Configuration and port management
- **✅ `migrate-to-unified-dev.ps1`** - Migration helper for transitioning from old scripts

## Restoration

If you need to restore any of these scripts temporarily:

```powershell
# Copy a specific script back to main directory
Copy-Item ".\deprecated-scripts-backup\2025-05-30\start-dev-environment.ps1" ".\"

# Or restore all scripts
Copy-Item ".\deprecated-scripts-backup\2025-05-30\*.ps1" ".\"
```

## Migration Command Reference

### Old → New Command Mapping

```powershell
# Starting services
.\start-dev-environment.ps1           # → .\dev.ps1 start
.\smart-start.ps1                     # → .\dev.ps1 start -Force

# Stopping services  
.\stop-dev-environment.ps1            # → .\dev.ps1 stop
.\stop-dev-environment.ps1 -Force     # → .\dev.ps1 stop -Force

# Checking status
.\check-dev-status.ps1                # → .\dev.ps1 status
.\dev-helper.ps1                      # → .\dev.ps1 status

# Loading data
.\load-sample-data.ps1                # → .\dev.ps1 sample-data

# Testing integrations
.\test-azurite-integration.ps1        # → .\dev.ps1 test-azurite
```

## Consolidation Benefits

The unified system provides:

- **Single Entry Point**: One script instead of 7+ individual scripts
- **Consistent Interface**: Standardized parameters and output
- **Enhanced Features**: Rich colored output, better error handling
- **Service Filtering**: Granular control over individual services
- **Comprehensive Help**: Built-in documentation and examples

## Documentation

See the main project documentation for details on the unified system:

- `DEV-SCRIPTS.md` - Updated development script documentation
- `POWERSHELL-CONSOLIDATION-SUCCESS.md` - Complete consolidation summary
- Run `.\dev.ps1 help` for comprehensive usage information

---
**Backup Created**: May 30, 2025  
**Consolidation Project**: Complete Success ✅  
**Scripts Archived**: 7 individual scripts → 1 unified system
