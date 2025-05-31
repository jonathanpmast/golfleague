#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Unified Golf League development environment management script
.DESCRIPTION
    This script provides a single entry point for managing the development environment:
    - Start/stop all services
    - Check service status
    - Load sample data
    - Configure ports and settings
.PARAMETER Action
    The action to perform: start, stop, status, restart, sample-data, test-azurite
.PARAMETER Service
    Optional service filter: All, CosmosDB, Azurite, Functions, Vue
.PARAMETER Force
    Force stop running services before starting
.PARAMETER IncludeCosmosDB
    Include Cosmos DB when stopping all services
.EXAMPLE
    .\dev.ps1 start
    .\dev.ps1 stop -Force
    .\dev.ps1 status
    .\dev.ps1 restart -Service Vue
    .\dev.ps1 sample-data
#>

param(
    [Parameter(Position=0)]
    [ValidateSet("start", "stop", "status", "restart", "sample-data", "test-azurite", "help")]
    [string]$Action = "help",
    
    [ValidateSet("All", "CosmosDB", "Azurite", "Functions", "Vue")]
    [string]$Service = "All",
    
    [switch]$Force,
    [switch]$IncludeCosmosDB
)

# Import core libraries
try {
    . .\dev-core.ps1
    Write-Verbose "Loaded dev-core.ps1 successfully"
}
catch {
    Write-Error "Failed to load dev-core.ps1: $_"
    exit 1
}

# Main script logic
switch ($Action) {
    "start" {
        Write-Header "Starting Golf League Development Environment"
        $success = Start-NeededServices -ServiceFilter $Service -Force:$Force
        if ($success) {
            Start-Sleep -Seconds 3  # Give services time to fully start
            $services = Get-AllServiceStatuses -Filter $Service
            Show-ServiceStatuses -Services $services -Title "Current Status"
            Show-DevelopmentSummary
        }
    }
    
    "stop" {
        Write-Header "Stopping Golf League Development Environment"
        if ($Service -eq "All") {
            Stop-AllServices -IncludeCosmosDB:$IncludeCosmosDB -Force:$Force
        } else {
            # Stop specific service
            $config = Get-DevConfig
            switch ($Service) {
                "Vue" {
                    Stop-ProcessOnPort -Port $config.VuePort -ServiceName "Vue.js Dev Server" -Force:$Force
                }
                "Functions" {
                    Stop-ProcessOnPort -Port $config.FunctionsPort -ServiceName "Azure Functions" -Force:$Force
                }
                "Azurite" {
                    Stop-ProcessOnPort -Port $config.AzuriteBlob -ServiceName "Azurite Storage" -Force:$Force
                }
                "CosmosDB" {
                    Write-ColorOutput "🗄️  Note: Cosmos DB Emulator should be stopped manually from system tray" $Global:Colors.Yellow
                }
            }
        }
        
        Write-ColorOutput "`n✅ Stop operation completed" $Global:Colors.Green
    }
    
    "status" {
        $services = Get-AllServiceStatuses -Filter $Service
        Show-ServiceStatuses -Services $services -Title "Development Environment Status"
        
        # Show additional info
        Write-Section "Configuration"
        $config = Get-DevConfig
        Write-ColorOutput "  Vue.js Port: $($config.VuePort) ($(Get-VueUrl))" $Global:Colors.Reset
        Write-ColorOutput "  Functions Port: $($config.FunctionsPort)" $Global:Colors.Reset
        Write-ColorOutput "  Cosmos DB Port: $($config.CosmosPort)" $Global:Colors.Reset
        Write-ColorOutput "  Azurite Ports: Blob($($config.AzuriteBlob)), Queue($($config.AzuriteQueue)), Table($($config.AzuriteTable))" $Global:Colors.Reset
        
        $actualVuePort = Find-ActualVuePort
        if ($actualVuePort -and $actualVuePort -ne $config.VuePort) {
            Write-ColorOutput "  Vue.js Actual Port: $actualVuePort" $Global:Colors.Yellow
        }
    }
    
    "restart" {
        Write-Header "Restarting Golf League Development Environment"
        
        # Stop first
        if ($Service -eq "All") {
            Stop-AllServices -IncludeCosmosDB:$IncludeCosmosDB -Force:$Force
        } else {
            # Stop specific service
            $config = Get-DevConfig
            switch ($Service) {
                "Vue" { Stop-ProcessOnPort -Port $config.VuePort -ServiceName "Vue.js Dev Server" -Force:$Force }
                "Functions" { Stop-ProcessOnPort -Port $config.FunctionsPort -ServiceName "Azure Functions" -Force:$Force }
                "Azurite" { Stop-ProcessOnPort -Port $config.AzuriteBlob -ServiceName "Azurite Storage" -Force:$Force }
            }
        }
        
        Start-Sleep -Seconds 2
        
        # Start again
        $success = Start-NeededServices -ServiceFilter $Service -Force:$false
        if ($success) {
            Start-Sleep -Seconds 3
            $services = Get-AllServiceStatuses -Filter $Service
            Show-ServiceStatuses -Services $services -Title "Restart Complete"
        }
    }
    
    "sample-data" {
        Write-Header "Loading Sample Data"
        
        # Check if Functions are running
        $config = Get-DevConfig
        $functionsStatus = Test-ServiceStatus -ServiceName "Azure Functions" -Url "http://localhost:$($config.FunctionsPort)" -Port $config.FunctionsPort
        
        if (-not $functionsStatus.Running) {
            Write-ColorOutput "❌ Azure Functions not running. Starting it first..." $Global:Colors.Yellow
            Start-AzureFunctions | Out-Null
            if (-not (Wait-ForServiceReady -ServiceName "Azure Functions" -Url "http://localhost:$($config.FunctionsPort)" -TimeoutSeconds 30)) {
                Write-ColorOutput "❌ Failed to start Azure Functions" $Global:Colors.Red
                exit 1
            }
        }
        
        # Load sample data using existing script logic
        Write-ColorOutput "📊 Loading sample data..." $Global:Colors.Yellow
        
        try {
            # Call the API endpoints to load data
            $baseUrl = "http://localhost:$($config.FunctionsPort)/api"
            
            Write-ColorOutput "  • Loading players..." $Global:Colors.Reset
            $playersResponse = Invoke-RestMethod -Uri "$baseUrl/players" -Method POST -ContentType "application/json" -Body '{"loadSampleData": true}'
            
            Write-ColorOutput "  • Loading games..." $Global:Colors.Reset  
            $gamesResponse = Invoke-RestMethod -Uri "$baseUrl/games" -Method POST -ContentType "application/json" -Body '{"loadSampleData": true}'
            
            Write-ColorOutput "✅ Sample data loaded successfully!" $Global:Colors.Green
            Write-ColorOutput "  View in Vue.js app: $(Get-VueUrl)" $Global:Colors.Reset
        }
        catch {
            Write-ColorOutput "❌ Failed to load sample data: $_" $Global:Colors.Red
            exit 1
        }
    }
    
    "test-azurite" {
        Write-Header "Testing Azurite Integration"
        
        # Check if Azurite is running
        $config = Get-DevConfig
        $azuriteStatus = Test-ServiceStatus -ServiceName "Azurite Storage" -Url "http://127.0.0.1:$($config.AzuriteBlob)" -Port $config.AzuriteBlob
        
        if (-not $azuriteStatus.Running) {
            Write-ColorOutput "❌ Azurite not running. Starting it first..." $Global:Colors.Yellow
            Start-AzuriteStorage | Out-Null
            Start-Sleep -Seconds 3
        }
        
        Write-ColorOutput "🧪 Running Azurite integration tests..." $Global:Colors.Yellow
        
        try {
            # Test blob storage
            $testBlob = "test-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
            $testContent = "Test content from dev.ps1"
            
            # This would need Azure.Storage.Blobs package - simplified for now
            Write-ColorOutput "  • Testing blob storage connection..." $Global:Colors.Reset
            $testResult = Test-ServiceHttp -Url "http://127.0.0.1:$($config.AzuriteBlob)/devstoreaccount1" -TimeoutSec 5
            
            if ($testResult) {
                Write-ColorOutput "✅ Azurite blob storage is accessible" $Global:Colors.Green
            } else {
                Write-ColorOutput "❌ Azurite blob storage test failed" $Global:Colors.Red
            }
            
            Write-ColorOutput "  • Azurite Blob URL: http://127.0.0.1:$($config.AzuriteBlob)" $Global:Colors.Reset
            Write-ColorOutput "  • Azurite Queue URL: http://127.0.0.1:$($config.AzuriteQueue)" $Global:Colors.Reset
            Write-ColorOutput "  • Azurite Table URL: http://127.0.0.1:$($config.AzuriteTable)" $Global:Colors.Reset
        }
        catch {
            Write-ColorOutput "❌ Azurite test failed: $_" $Global:Colors.Red
        }
    }
    
    "help" {
        Write-Header "Golf League Development Environment Manager"
        
        Write-ColorOutput "Usage: .\dev.ps1 <action> [options]" $Global:Colors.Blue
        Write-ColorOutput ""
        Write-ColorOutput "Actions:" $Global:Colors.Yellow
        Write-ColorOutput "  start        Start development services" $Global:Colors.Reset
        Write-ColorOutput "  stop         Stop development services" $Global:Colors.Reset
        Write-ColorOutput "  status       Check service status" $Global:Colors.Reset
        Write-ColorOutput "  restart      Restart services" $Global:Colors.Reset
        Write-ColorOutput "  sample-data  Load sample data into the system" $Global:Colors.Reset
        Write-ColorOutput "  test-azurite Test Azurite storage integration" $Global:Colors.Reset
        Write-ColorOutput "  help         Show this help message" $Global:Colors.Reset
        Write-ColorOutput ""
        Write-ColorOutput "Options:" $Global:Colors.Yellow
        Write-ColorOutput "  -Service <name>     Filter by service: All, CosmosDB, Azurite, Functions, Vue" $Global:Colors.Reset
        Write-ColorOutput "  -Force              Force stop services before starting" $Global:Colors.Reset
        Write-ColorOutput "  -IncludeCosmosDB    Include Cosmos DB when stopping all" $Global:Colors.Reset
        Write-ColorOutput "  -Verbose            Enable verbose output" $Global:Colors.Reset
        Write-ColorOutput ""
        Write-ColorOutput "Examples:" $Global:Colors.Yellow
        Write-ColorOutput "  .\dev.ps1 start                    # Start all services" $Global:Colors.Reset
        Write-ColorOutput "  .\dev.ps1 start -Service Vue       # Start only Vue.js" $Global:Colors.Reset
        Write-ColorOutput "  .\dev.ps1 stop -Force              # Force stop all services" $Global:Colors.Reset
        Write-ColorOutput "  .\dev.ps1 restart -Service Functions  # Restart only Functions" $Global:Colors.Reset
        Write-ColorOutput "  .\dev.ps1 status                   # Check all service status" $Global:Colors.Reset
        Write-ColorOutput "  .\dev.ps1 sample-data              # Load sample data" $Global:Colors.Reset
        Write-ColorOutput ""        Write-ColorOutput "Configuration:" $Global:Colors.Yellow
        Write-ColorOutput "  Edit .env.development and dev-config.ps1 to change ports" $Global:Colors.Reset
        Write-ColorOutput "  See docs/PORT-CONFIGURATION-GUIDE.md for details" $Global:Colors.Reset
    }
      default {
        Write-ColorOutput "❌ Unknown action: $Action" $Global:Colors.Red
        Write-ColorOutput "Use '.\dev.ps1 help' for usage information" $Global:Colors.Reset
        exit 1
    }
}
