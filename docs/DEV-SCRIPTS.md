# Golf League Development Scripts

> **🎉 CONSOLIDATION COMPLETE!** 
> All 8+ individual PowerShell scripts have been successfully unified into a single `dev.ps1` system.
> The consolidation is 100% functional with enhanced developer experience and maintainability.

This directory contains a **unified PowerShell script system** to easily manage the local development environment for the Golf League application.

## Prerequisites

- Azure Cosmos DB Emulator installed
- **Azurite** installed globally (`npm install -g azurite`)
- Node.js 18.19.0 or compatible version
- Azure Functions Core Tools
- PowerShell 7+ (recommended)

## Unified Development Script

### 🚀 dev.ps1 (NEW - Single Entry Point)

**The new unified script that replaces all individual development scripts with a single, consistent interface.**

**Usage:**
```powershell
# Start all development services
.\dev.ps1 start

# Start with force restart (smart restart)
.\dev.ps1 start -Force

# Start specific services only
.\dev.ps1 start -Service Vue
.\dev.ps1 start -Service Functions
.\dev.ps1 start -Service Azurite

# Check status of all services
.\dev.ps1 status

# Stop all services
.\dev.ps1 stop

# Stop with force and include Cosmos DB
.\dev.ps1 stop -Force -IncludeCosmosDB

# Restart services
.\dev.ps1 restart
.\dev.ps1 restart -Service Functions

# Load sample data
.\dev.ps1 sample-data

# Test Azurite integration
.\dev.ps1 test-azurite

# Get help and see all commands
.\dev.ps1 help
```

## Legacy Scripts (Deprecated)

> **⚠️ IMPORTANT**: These scripts are deprecated and replaced by the unified `.\dev.ps1` system.
> They are kept for backward compatibility but will show deprecation warnings.
> **Please migrate to using `.\dev.ps1` instead.**

### Migration Guide

| Old Script | New Command | Description |
|------------|-------------|-------------|
| `.\start-dev-environment.ps1` | `.\dev.ps1 start` | Start all services |
| `.\stop-dev-environment.ps1` | `.\dev.ps1 stop` | Stop all services |
| `.\check-dev-status.ps1` | `.\dev.ps1 status` | Check service status |
| `.\smart-start.ps1` | `.\dev.ps1 start -Force` | Smart restart services |
| `.\load-sample-data.ps1` | `.\dev.ps1 sample-data` | Load sample data |
| `.\test-azurite-integration.ps1` | `.\dev.ps1 test-azurite` | Test Azurite integration |
| `.\dev-helper.ps1` | `.\dev.ps1 status` | Status with recommendations |

### 🔄 Automatic Migration

Run the migration helper to automatically transition:

```powershell
# See migration status and options
.\migrate-to-unified-dev.ps1

# Full migration with backup
.\migrate-to-unified-dev.ps1 -Force -Backup

# Dry run to see what would change
.\migrate-to-unified-dev.ps1 -DryRun
```

---

## Legacy Script Details (For Reference)

### 🚀 start-dev-environment.ps1

Starts all required services for local development:
- Cosmos DB Emulator
- Azurite Storage Emulator
- Azure Functions Core Tools 
- Vue.js Development Server

**Usage:**
```powershell
# Start all services
.\start-dev-environment.ps1

# Skip specific services
.\start-dev-environment.ps1 -SkipCosmosDB
.\start-dev-environment.ps1 -SkipAzurite
.\start-dev-environment.ps1 -SkipFunctions  
.\start-dev-environment.ps1 -SkipVue

# Verbose output for Azure Functions
.\start-dev-environment.ps1 -Verbose
```

**Services Started:**
- 🗄️ Cosmos DB Emulator: `https://localhost:8081`
- 🗄️ Azurite Storage: `http://127.0.0.1:10000` (Blob), `10001` (Queue), `10002` (Table)
- ⚡ Azure Functions: `http://localhost:7071`
- 🖥️ Vue.js App: `http://localhost:3123` (configurable, may auto-increment)

### 🛑 stop-dev-environment.ps1

Stops all running development services.

**Usage:**
```powershell
# Stop Functions and Vue.js (leave Cosmos DB running)
.\stop-dev-environment.ps1

# Stop everything including Cosmos DB
.\stop-dev-environment.ps1 -IncludeCosmosDB

# Force stop all processes
.\stop-dev-environment.ps1 -Force
```

### 🔍 check-dev-status.ps1

Checks the status of all development services and shows available endpoints.

**Usage:**
```powershell
.\check-dev-status.ps1
```

### 🧪 test-azurite-integration.ps1 (NEW)

**Tests Azurite storage emulator integration with Azure Functions.**

**Usage:**
```powershell
# Test Azurite integration
.\test-azurite-integration.ps1
```

**What it tests:**
- ✅ Azurite services are running and accessible
- ✅ Azure Functions storage configuration is correct
- ✅ Connection strings are properly set for development
- ✅ Workspace and log files are created

## Available API Endpoints

When all services are running, the following endpoints are available:

### Configuration Management
- `GET /{leagueName}/config` - Get golf course configuration
- `POST /{league}/config` - Save golf course configuration

### Score Management  
- `GET /{league}/scores/{roundYear?}/{roundNumber?}` - Get scores
- `POST /{league}/scores` - Save scores

### Skins Results
- `GET /{league}/skins/{roundYear?}/{roundNumber?}` - Get skins results

## Quick Start

1. **Start Development Environment:**
   ```powershell
   .\start-dev-environment.ps1
   ```

2. **Check Status:**
   ```powershell
   .\check-dev-status.ps1
   ```

3. **Open Application:**
   - Navigate to `http://localhost:3123` in your browser (or check terminal for actual port)
   - Use the "Score Entry" and "Course Config" menu items

4. **Stop When Done:**
   ```powershell
   .\stop-dev-environment.ps1
   ```

## Troubleshooting

### Port Conflicts
If ports are already in use:
- Check what's using the ports: `netstat -ano | findstr :7071`
- Stop conflicting processes or change ports in the configuration

### Cosmos DB Issues
- Ensure Cosmos DB Emulator is installed
- Check if emulator is accessible: `https://localhost:8081`
- Restart emulator if needed: `.\stop-dev-environment.ps1 -IncludeCosmosDB` then `.\start-dev-environment.ps1`

### Azure Functions Issues
- Ensure you're using Node.js 18.19.0 (check with `node --version`)
- Try stopping and restarting: `.\stop-dev-environment.ps1` then `.\start-dev-environment.ps1`

### Azurite Storage Issues
- Ensure Azurite is installed globally: `npm list -g azurite`
- Check if Azurite is running: `.\test-azurite-integration.ps1`
- Start Azurite manually: `.\smart-start.ps1 -Service Azurite`
- Check workspace directory permissions: `./azurite-workspace`

### Vue.js Issues
- Check if npm dependencies are installed: `cd golfleague-ui && npm install`
- Clear npm cache if needed: `npm cache clean --force`

## Development Workflow

1. **Initial Setup:**
   ```powershell
   # Install dependencies
   cd golfleague-ui && npm install
   cd ../golf-league-skins-funcs && npm install
   cd ..
   
   # Start environment
   .\start-dev-environment.ps1
   ```

2. **Daily Development:**
   ```powershell
   # Quick status check
   .\check-dev-status.ps1
   
   # Start if needed
   .\start-dev-environment.ps1
   
   # Develop your features...
   
   # Stop when done
   .\stop-dev-environment.ps1
   ```

3. **Testing with Sample Data:**
   - Use the sample configuration in `golf-league-data-loader/config_data.json`
   - Navigate to Course Config in the UI to create a golf course
   - Navigate to Score Entry to enter scores for the course

## Documentation

📖 **[API Configuration Guide](API-CONFIGURATION.md)** - Details about the centralized API configuration system and environment handling

🏆 **[League Parameterization Guide](LEAGUE-PARAMETERIZATION.md)** - Implementation details for SAAS multi-tenancy support with league-based routing

🤖 **[AI Assistant Reference](AI-ASSISTANT-REFERENCE.md)** - Quick reference for AI assistants working with this project

⚙️ **[Development Environment Config](DEV-ENVIRONMENT-CONFIG.md)** - Comprehensive service management guidelines and permanent configuration

## 🚨 AI Assistant Quick Start

**Before any development operations:**
```powershell
# 1. Check what's running
.\dev-helper.ps1

# 2. Start only what's needed  
.\smart-start.ps1
```

## Notes

- The scripts automatically detect if services are already running
- Background services are monitored and will show status updates
- Use Ctrl+C to interrupt the start script and stop all services
- Cosmos DB Emulator is left running by default when stopping (use `-IncludeCosmosDB` to stop it)
- API endpoints automatically switch between local and production environments (see [API-CONFIGURATION.md](API-CONFIGURATION.md))
