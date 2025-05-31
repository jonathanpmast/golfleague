# Golf League

A web application for managing golf league scores, skins calculation, and course configuration. This project serves as a technology exploration platform while providing practical value for golf league management.

## Features

- **Score Entry**: Easy score tracking for golf rounds
- **Skins Calculation**: Automatic calculation of skins winners
- **Course Configuration**: Flexible golf course setup and management
- **Multi-tenancy**: Support for multiple golf leagues

## Quick Start

1. **Start Development Environment**:
   ```powershell
   .\dev.ps1 start
   ```

2. **Check Status**:
   ```powershell
   .\dev.ps1 status
   ```

3. **Access Application**:
   - Open `http://localhost:3123` in your browser

## Development

This project uses a unified PowerShell script system for development environment management:

- `.\dev.ps1 start` - Start all services
- `.\dev.ps1 stop` - Stop all services  
- `.\dev.ps1 status` - Check service status
- `.\dev.ps1 help` - Show all available commands

## Documentation

Comprehensive documentation is available in the [`docs/`](docs/) folder:

- **[Development Guide](docs/DEV-SCRIPTS.md)** - Complete development environment setup
- **[API Configuration](docs/API-CONFIGURATION.md)** - API setup and configuration
- **[Port Configuration](docs/PORT-CONFIGURATION-GUIDE.md)** - Customizing ports and services
- **[Architecture](docs/LEAGUE-PARAMETERIZATION.md)** - Multi-tenancy and architecture details

## AI Assistant Reference

For AI assistants working with this project, see [`AI-ASSISTANT-REFERENCE.md`](AI-ASSISTANT-REFERENCE.md) for quick reference information.

## Technology Stack

- **Frontend**: Vue.js 3 with Vite
- **Backend**: Azure Functions (Node.js)
- **Database**: Azure Cosmos DB (with local emulator)
- **Storage**: Azure Storage (with Azurite emulator)
- **Development**: PowerShell automation scripts

---

*A practical project for golf league management and technology exploration.*