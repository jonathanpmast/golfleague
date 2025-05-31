# Golf League Development Environment Configuration

## Port Configuration

The development environment now uses configurable ports defined in environment files:

### Configuration Files
- **Vue.js Configuration**: `golfleague-ui/.env.development`
  - `VITE_SERVER_PORT=3123` (default, can be customized)
- **PowerShell Configuration**: `dev-config.ps1` 
  - Provides functions to read port configuration across all scripts

### Service Ports and URLs
- **Cosmos DB Emulator**: Port 8081, HTTPS (https://127.0.0.1:8081)
- **Azurite Storage Emulator**: Ports 10000-10002, HTTP
  - Blob: http://127.0.0.1:10000
  - Queue: http://127.0.0.1:10001  
  - Table: http://127.0.0.1:10002
- **Azure Functions**: Port 7071, HTTP (http://localhost:7071)
- **Vue.js Dev Server**: Port configured in `.env.development` (default 3123), HTTP

### Customizing Vue.js Port
To change the default Vue.js port:
1. Edit `golfleague-ui/.env.development`
2. Change `VITE_SERVER_PORT=3123` to your preferred port
3. All scripts will automatically use the new port

## Development Workflow

### ⚠️ IMPORTANT: Always Check Status First
Before starting any services, **ALWAYS** run the status check script:
```powershell
.\check-dev-status.ps1
```

### Service Management
1. **Status Check**: `.\check-dev-status.ps1`
2. **Start All**: `.\start-dev-environment.ps1`
3. **Stop All**: `.\stop-dev-environment.ps1`

## Process Detection Methods

### Cosmos DB Emulator
- **HTTP Check**: https://127.0.0.1:8081 (ignore SSL errors)
- **Process Names**: "*cosmos*", "*documentdb*"
- **Port Check**: netstat for port 8081

### Azurite Storage Emulator
- **HTTP Check**: http://127.0.0.1:10000 (Blob service)
- **Process Names**: "node" (with azurite in command line)
- **Port Check**: netstat for ports 10000, 10001, 10002
- **Connection String**: `UseDevelopmentStorage=true`

### Azure Functions
- **HTTP Check**: http://localhost:7071
- **Process Names**: "func"
- **Port Check**: netstat for port 7071

### Vue.js Development Server
- **HTTP Check**: Configured URL (default http://localhost:3123)
- **Process Names**: "node"
- **Port Check**: netstat for configured port
- **Auto-increment**: If port is busy, Vite will automatically try next available port

## AI Assistant Permanent Configuration

### 🚨 CRITICAL WORKFLOW RULES

1. **NEVER start services without checking status first**
2. **ALWAYS use `.\dev-helper.ps1` before any service operations**  
3. **PREFER `.\smart-start.ps1` over manual commands**
4. **USE existing VS Code tasks when appropriate**

### 📜 Standard Operating Procedure

```powershell
# Step 1: Always check status first
.\dev-helper.ps1

# Step 2: If services needed, use smart start
.\smart-start.ps1

# Step 3: For specific services only
.\smart-start.ps1 -Service [Functions|Vue|CosmosDB|Azurite]

# Step 4: Test Azurite integration
.\test-azurite-integration.ps1
```

### 🔧 Service Management Commands

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `.\dev-helper.ps1` | Check status + recommendations | Always first step |
| `.\smart-start.ps1` | Start only needed services | When services required |
| `.\smart-start.ps1 -Force` | Restart all services | When troubleshooting |
| `.\check-dev-status.ps1` | Detailed status report | Detailed diagnostics |

### 🎯 Quick Status Reference

**Current Typical State:**
- Cosmos DB: Port 8081 (HTTPS with SSL ignore)
- Azurite Storage: Ports 10000-10002 (HTTP)
- Azure Functions: Port 7071 (HTTP)
- Vue.js: Port configured in environment (default 3123), may auto-increment if busy

### 🚫 Deprecated Patterns

```powershell
# ❌ OLD WAY: Manual service starting
cd "golf-league-skins-funcs" && func host start --port 7071

# ✅ NEW WAY: Smart status-aware starting  
.\smart-start.ps1 -Service Functions
```

### Service Start Commands
```powershell
# Only if Azure Functions not running
cd "c:\Projects\golfleague\golf-league-skins-funcs" && func host start --port 7071

# Only if Vue.js not running  
cd "c:\Projects\golfleague\golfleague-ui" && npm run dev
```

### VS Code Tasks Available
- `func: 0` - Start Azure Functions (with npm install dependency)
- `npm install` - Install Azure Functions dependencies
- `npm: install - golf-league-data-loader` - Install data loader dependencies

## Common Port Conflicts
- Vue.js may auto-increment from configured port if busy (e.g., 3123 → 3124 → 3125)
- Always check the terminal output for the actual port being used
- All scripts automatically detect the actual running port

## Development URLs (when all services running)
**Note**: Replace `3123` with actual port shown in terminal if auto-incremented

- **Golf League App**: http://localhost:3123/ (or actual port from terminal)
- **Default League**: http://localhost:3123/bmgnky
- **Config Page**: http://localhost:3123/bmgnky/config  
- **Score Entry**: http://localhost:3123/bmgnky/scores
- **Skins Results**: http://localhost:3123/bmgnky/skins
- **Cosmos DB Explorer**: https://127.0.0.1:8081/_explorer/index.html
- **Azurite Storage**: http://127.0.0.1:10000 (Blob), 10001 (Queue), 10002 (Table)

## League Parameterization Support
The application now supports multiple leagues via URL parameters:
- Pattern: `/{leagueName}/{page}`
- Default: `bmgnky`
- Examples: `/testleague/config`, `/anotherleague/scores`
