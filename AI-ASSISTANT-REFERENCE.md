# AI Assistant Quick Reference - Golf League Development

## 🚨 UNIFIED DEVELOPMENT SYSTEM

The Golf League project now uses a **unified development script system** with consolidated PowerShell scripts and organized documentation.

### Main Development Script: `dev.ps1`
**Single command interface for all development operations**

```powershell
# ✅ ALWAYS start here - Check current status
.\dev.ps1 status

# ✅ Start all services (only what's needed)
.\dev.ps1 start

# ✅ Stop all services safely
.\dev.ps1 stop

# ✅ Restart all services
.\dev.ps1 restart

# ✅ Get help and examples
.\dev.ps1 help
```

## ⚡ Service Management Commands

```powershell
# Status checking with colored output and recommendations
.\dev.ps1 status                          # All services
.\dev.ps1 status -Service Vue             # Vue.js only
.\dev.ps1 status -Service Functions       # Azure Functions only
.\dev.ps1 status -Service Azurite         # Azurite Storage only
.\dev.ps1 status -Service CosmosDB        # Cosmos DB only

# Service control (starts only if needed)
.\dev.ps1 start -Service Vue              # Start Vue.js dev server
.\dev.ps1 start -Service Functions        # Start Azure Functions
.\dev.ps1 stop -Service Azurite           # Stop Azurite Storage

# Testing and utilities
.\dev.ps1 sample-data                     # Load sample data
.\dev.ps1 test-azurite                    # Test Azurite connection
```

## 🚫 Deprecated Commands (DO NOT USE)

```powershell
# ❌ OLD SYSTEM - These scripts no longer exist:
.\dev-helper.ps1
.\smart-start.ps1
.\start-dev-environment.ps1
.\stop-dev-environment.ps1
.\check-dev-status.ps1
```

## 📁 Documentation Structure

**All documentation moved to organized `docs/` folder:**

- **[docs/README.md](docs/README.md)** - Documentation navigation guide
- **[docs/DEV-SCRIPTS.md](docs/DEV-SCRIPTS.md)** - Complete development guide
- **[docs/API-CONFIGURATION.md](docs/API-CONFIGURATION.md)** - API setup and configuration
- **[docs/PORT-CONFIGURATION-GUIDE.md](docs/PORT-CONFIGURATION-GUIDE.md)** - Port customization
- **[docs/DEVELOPMENT-WORKFLOW.md](docs/DEVELOPMENT-WORKFLOW.md)** - Development best practices

## 🔧 Configuration and Customization

```powershell
# View current configuration
.\dev.ps1 status

# Customize ports (see docs/PORT-CONFIGURATION-GUIDE.md)
# Edit .env.development file in golfleague-ui folder

# Example port configuration:
VUE_CLI_SERVICE_OPTIONS_PORT=3125
```

## 🌐 Default Development URLs

**Active when services are running:**

- **Main App**: http://localhost:3125/bmgnky
- **League Config**: http://localhost:3125/bmgnky/config  
- **Score Entry**: http://localhost:3125/bmgnky/scores
- **Skins Page**: http://localhost:3125/bmgnky/skins
- **API Base**: http://localhost:7071/api
- **Cosmos DB Explorer**: https://127.0.0.1:8081/_explorer/index.html
- **Azurite Storage**: http://127.0.0.1:10000

## 🎯 League Parameterization

**Multi-league support built-in:**
- **URL Pattern**: `/{leagueName}/{page}`
- **Default League**: `bmgnky`
- **Test Leagues**: 
  - `/testleague/config`
  - `/anotherleague/scores`
  - `/newleague/skins`

## 🛠️ VS Code Integration

```powershell
# Use VS Code tasks when appropriate (for dependencies)
run_vs_code_task(workspaceFolder="c:\\Projects\\golfleague", id="npm: install - golfleague-ui")
run_vs_code_task(workspaceFolder="c:\\Projects\\golfleague", id="npm: install - golf-league-skins-funcs")

# ✅ PREFERRED: Use unified dev script for service management
.\dev.ps1 start
```

## 📋 Recommended Development Workflow

```powershell
# 1. Check current status
.\dev.ps1 status

# 2. Start services (only what's needed)
.\dev.ps1 start

# 3. Verify all services are running
.\dev.ps1 status

# 4. Open development URLs
# Main: http://localhost:3125/bmgnky
# API:  http://localhost:7071/api

# 5. During development - restart as needed
.\dev.ps1 restart -Service Vue      # Restart Vue.js only
.\dev.ps1 restart                   # Restart all services

# 6. When done developing
.\dev.ps1 stop
```

## 🔄 Migration from Old Scripts

If you have references to old scripts, use the migration helper:

```powershell
# Get migration guidance
.\migrate-to-unified-dev.ps1
```

## 🚨 Important Notes for AI Assistants

1. **Always use `.\dev.ps1`** - Single source of truth for all operations
2. **Check status first** - `.\dev.ps1 status` before any operations
3. **Use service-specific commands** - `-Service Vue|Functions|Azurite|CosmosDB`
4. **Reference docs folder** - All documentation in `docs/` with navigation guide
5. **Avoid manual commands** - Let the unified script handle service management

---

**System Status**: ✅ **Unified Development System Active**  
**Script Consolidation**: Complete (8 scripts → 1 interface)  
**Documentation**: Organized in `docs/` folder  
**Last Updated**: January 2025 - Post consolidation
