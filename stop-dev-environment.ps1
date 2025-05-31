#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Stops the Golf League local development environment
.DESCRIPTION
    This script stops all services related to the Golf League local development:
    - Azure Functions Core Tools (func processes)
    - Vue.js Development Server (node processes on configured port)
    - Optionally stops Cosmos DB Emulator
.EXAMPLE
    .\stop-dev-environment.ps1
.EXAMPLE
    .\stop-dev-environment.ps1 -IncludeCosmosDB
#>

param(
    [switch]$IncludeCosmosDB,
    [switch]$Force
)

# Import development configuration
. .\dev-config.ps1

# Colors for output
$Green = "`e[32m"
$Yellow = "`e[33m"
$Red = "`e[31m"
$Blue = "`e[34m"
$Reset = "`e[0m"

function Write-ColorOutput {
    param([string]$Message, [string]$Color = $Reset)
    Write-Host "$Color$Message$Reset"
}

function Stop-ProcessOnPort {
    param([int]$Port, [string]$ServiceName)
    
    $connections = netstat -ano | Select-String ":$Port" | Where-Object { $_ -match "LISTENING" }
      if ($connections) {
        foreach ($connection in $connections) {
            $parts = $connection -split '\s+' | Where-Object { $_ -ne '' }
            if ($parts.Length -ge 5) {
                $processId = $parts[4]
                try {
                    $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
                    if ($process) {
                        Write-ColorOutput "🛑 Stopping $ServiceName (PID: $processId)..." $Yellow
                        if ($Force) {
                            Stop-Process -Id $processId -Force
                        } else {
                            Stop-Process -Id $processId
                        }
                        Write-ColorOutput "✅ Stopped $ServiceName" $Green
                    }
                }
                catch {
                    Write-ColorOutput "⚠️  Could not stop process $processId for $ServiceName" $Yellow
                }
            }
        }
    } else {
        Write-ColorOutput "ℹ️  $ServiceName not running on port $Port" $Reset
    }
}

Write-ColorOutput "🛑 Stopping Golf League Development Environment" $Blue
Write-ColorOutput "==============================================" $Blue

try {
    # Stop Vue.js Development Server (configured port)
    Write-ColorOutput "🖥️  Stopping Vue.js Development Server..." $Yellow
    $vuePort = Get-VuePort
    Stop-ProcessOnPort -Port $vuePort -ServiceName "Vue.js Dev Server"

    # Stop Azure Functions (port 7071)
    Write-ColorOutput "⚡ Stopping Azure Functions..." $Yellow
    Stop-ProcessOnPort -Port 7071 -ServiceName "Azure Functions"
    
    # Also stop any func.exe processes
    $funcProcesses = Get-Process -Name "func" -ErrorAction SilentlyContinue
    foreach ($process in $funcProcesses) {
        Write-ColorOutput "🛑 Stopping func process (PID: $($process.Id))..." $Yellow
        if ($Force) {
            Stop-Process -Id $process.Id -Force
        } else {
            Stop-Process -Id $process.Id
        }
    }    # Stop any node processes that might be related to our development
    $nodeProcesses = Get-Process -Name "node" -ErrorAction SilentlyContinue
    $vuePort = Get-VuePort
    foreach ($process in $nodeProcesses) {
        try {
            $commandLine = (Get-WmiObject Win32_Process -Filter "ProcessId = $($process.Id)").CommandLine
            if ($commandLine -match "vite|vue|golfleague" -or $commandLine -match "$vuePort") {
                Write-ColorOutput "🛑 Stopping Node.js process: $($process.Id)" $Yellow
                if ($Force) {
                    Stop-Process -Id $process.Id -Force
                } else {
                    Stop-Process -Id $process.Id
                }
            }
        }
        catch {
            # Ignore errors when checking command line
        }
    }

    # Optionally stop Cosmos DB Emulator
    if ($IncludeCosmosDB) {
        Write-ColorOutput "🗄️  Stopping Cosmos DB Emulator..." $Yellow
        
        $cosmosProcesses = @(
            "Microsoft.Azure.Cosmos.Emulator",
            "Microsoft.Azure.Cosmos.GatewayService", 
            "Microsoft.Azure.Cosmos.Master",
            "Microsoft.Azure.Cosmos.Server",
            "CosmosDB.Emulator"
        )
        
        foreach ($processName in $cosmosProcesses) {
            $processes = Get-Process -Name $processName -ErrorAction SilentlyContinue
            foreach ($process in $processes) {
                Write-ColorOutput "🛑 Stopping $processName (PID: $($process.Id))..." $Yellow
                if ($Force) {
                    Stop-Process -Id $process.Id -Force
                } else {
                    Stop-Process -Id $process.Id
                }
            }
        }
        
        Write-ColorOutput "✅ Cosmos DB Emulator stopped" $Green
    } else {
        Write-ColorOutput "ℹ️  Cosmos DB Emulator left running (use -IncludeCosmosDB to stop it)" $Reset
    }

    Write-ColorOutput "`n✅ Development environment stopped!" $Green

} catch {
    Write-ColorOutput "❌ Error stopping services: $($_.Exception.Message)" $Red
    Write-ColorOutput "💡 Try running with -Force parameter" $Yellow
    exit 1
}

Write-ColorOutput "`n💡 To start the environment again, run: .\start-dev-environment.ps1" $Blue
