# Golf League Port Configuration Guide

## Overview

The Golf League development environment now uses a configurable port system to address the inconsistent Vue.js server port issues. Instead of hardcoded ports scattered across scripts and documentation, the system now uses centralized configuration.

## Configuration Files

### 1. Vue.js Environment Configuration
**File**: `golfleague-ui/.env.development`
```bash
# Vue.js development server port
VITE_SERVER_PORT=3123
```

### 2. PowerShell Configuration Functions
**File**: `dev-config.ps1`
```powershell
# Provides centralized configuration functions for all scripts
function Get-DevConfig { ... }
function Get-VuePort { ... }
function Get-VueUrl { ... }
function Find-ActualVuePort { ... }
```

## How It Works

1. **Environment Loading**: Vite automatically loads `.env.development` and uses `VITE_SERVER_PORT`
2. **Script Integration**: All PowerShell scripts import `dev-config.ps1` and use configuration functions
3. **Auto-increment Support**: If configured port is busy, Vite will try next available port
4. **Smart Detection**: Scripts can detect actual running port even if auto-incremented

## Customizing Your Port

### Change Default Port
1. Edit `golfleague-ui/.env.development`
2. Change `VITE_SERVER_PORT=3123` to your preferred port (e.g., `VITE_SERVER_PORT=4000`)
3. All scripts will automatically use the new port

### Example: Using Port 4000
```bash
# golfleague-ui/.env.development
VITE_SERVER_PORT=4000
```

After this change:
- Vue.js will start on port 4000 (or next available if busy)
- All scripts will check port 4000 for Vue.js status
- URLs displayed by scripts will show `http://localhost:4000`

## Script Updates

All development scripts have been updated to use the configurable port system:

### Updated Scripts
- ✅ `dev-helper.ps1` - Uses configurable port for status checks
- ✅ `smart-start.ps1` - Uses configurable port in service URLs
- ✅ `start-dev-environment.ps1` - Uses configurable port for starting/checking Vue
- ✅ `stop-dev-environment.ps1` - Uses configurable port for stopping Vue processes
- ✅ `check-dev-status.ps1` - Uses configurable port for status checks
- ✅ `load-sample-data.ps1` - Uses configurable port in success messages

### Vite Configuration Updates
- ✅ `vite.config.js` - Reads `VITE_SERVER_PORT` from environment
- ✅ `strictPort: false` - Allows auto-increment when port is busy

## Benefits

### Before (Hardcoded Ports)
```powershell
# Different ports scattered across files
$vueStatus = Test-ServiceStatus -ServiceName "Vue.js Dev Server" -Url "http://localhost:3123" -Port 3123
# Sometimes 3124, 3125, etc. in different scripts - inconsistent!
```

### After (Configurable Ports)
```powershell
# Centralized configuration
. .\dev-config.ps1
$vuePort = Get-VuePort
$vueUrl = Get-VueUrl
$vueStatus = Test-ServiceStatus -ServiceName "Vue.js Dev Server" -Url $vueUrl -Port $vuePort
```

## Advanced Configuration

### Port Range Detection
The system includes smart port detection that checks a range starting from the configured port:

```powershell
function Find-ActualVuePort {
    $configuredPort = Get-VuePort
    for ($port = $configuredPort; $port -le ($configuredPort + 10); $port++) {
        $connections = netstat -ano | Select-String ":$port.*LISTENING"
        if ($connections) {
            foreach ($connection in $connections) {
                # Check if this is actually a Node.js/Vite process
                $parts = $connection -split '\s+' | Where-Object { $_ -ne '' }
                if ($parts.Length -ge 5) {
                    $processId = $parts[4]
                    $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
                    if ($process -and $process.ProcessName -eq "node") {
                        return $port
                    }
                }
            }
        }
    }
    return $null
}
```

### Environment Variables
The system respects standard Vite environment variable conventions:
- `.env.development` - Development environment (loaded automatically)
- `.env.local` - Local overrides (gitignored, highest priority)
- `.env` - Global defaults (lowest priority)

## Troubleshooting

### Port Conflicts
If you get port conflicts:
1. Check what's using your port: `netstat -ano | findstr :3123`
2. Either stop the conflicting service or change your configured port
3. Vite will auto-increment, but scripts will detect the actual port

### Configuration Not Loading
If configuration changes aren't taking effect:
1. Restart the Vue.js dev server
2. Check that `.env.development` is in the `golfleague-ui` directory
3. Verify environment variable format (no spaces around `=`)

### Script Errors
If scripts can't find Vue.js:
1. Run `.\dev-helper.ps1` to check actual status
2. Check terminal output for actual Vue.js port
3. Verify `dev-config.ps1` is in the repository root

## Migration Notes

This change is backward compatible:
- Default port remains 3123
- Existing documentation updated to reference configurable ports
- All scripts maintain the same CLI interface
- Auto-increment behavior preserved and enhanced

## Future Enhancements

Potential future improvements:
- Azure Functions port configuration
- Database connection string configuration  
- Full environment file for all service ports
- VS Code launch configurations using environment variables
