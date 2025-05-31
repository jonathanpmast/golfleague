#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Core service management library for Golf League development environment
#>

# Import configuration
. .\dev-config.ps1

# =============================================================================
# OUTPUT FORMATTING
# =============================================================================
$Global:Colors = @{
    Green  = "`e[32m"
    Yellow = "`e[33m"
    Red    = "`e[31m"
    Blue   = "`e[34m"
    Reset  = "`e[0m"
}

function Write-ColorOutput {
    param([string]$Message, [string]$Color = $Global:Colors.Reset)
    Write-Host "$Color$Message$($Global:Colors.Reset)"
}

function Write-Header {
    param([string]$Title)
    Write-ColorOutput "`n🚀 $Title" $Global:Colors.Blue
    Write-ColorOutput ("=" * ($Title.Length + 3)) $Global:Colors.Blue
}

# =============================================================================
# SERVICE STATUS TESTING
# =============================================================================
function Test-ServicePort {
    param([int]$Port)
    $portInUse = netstat -ano | Select-String ":$Port" | Where-Object { $_ -match "LISTENING" }
    return $null -ne $portInUse
}

function Test-ServiceHttp {
    param(
        [string]$Url,
        [switch]$IgnoreSSLErrors,
        [int]$TimeoutSec = 3
    )
    
    try {
        if ($IgnoreSSLErrors) {
            $response = Invoke-WebRequest -Uri $Url -Method GET -SkipCertificateCheck -TimeoutSec $TimeoutSec -ErrorAction Stop
        } else {
            $response = Invoke-WebRequest -Uri $Url -Method GET -TimeoutSec $TimeoutSec -ErrorAction Stop
        }
        return ($response.StatusCode -eq 200 -or $response.StatusCode -eq 401 -or $response.StatusCode -eq 403)
    }
    catch {
        return $false
    }
}

function Test-ServiceStatus {
    param(
        [string]$ServiceName,
        [string]$Url,
        [int]$Port,
        [switch]$IgnoreSSLErrors
    )
    
    $status = @{
        Name = $ServiceName
        Running = $false
        Port = $Port
        Url = $Url
        Method = "Unknown"
    }
    
    # Try HTTP check first
    if ($Url -and (Test-ServiceHttp -Url $Url -IgnoreSSLErrors:$IgnoreSSLErrors)) {
        $status.Running = $true
        $status.Method = "HTTP"
        return $status
    }
    
    # Fallback to port check
    if (Test-ServicePort -Port $Port) {
        $status.Running = $true
        $status.Method = "Port"
        return $status
    }
    
    return $status
}

# =============================================================================
# SERVICE MANAGEMENT
# =============================================================================
function Get-AllServiceStatuses {
    param([string]$Filter = "All")
    
    $services = @()
    $config = Get-DevConfig
    
    if ($Filter -eq "All" -or $Filter -eq "CosmosDB") {
        $services += Test-ServiceStatus -ServiceName "Cosmos DB Emulator" -Url "https://127.0.0.1:8081" -Port $config.CosmosPort -IgnoreSSLErrors
    }
    
    if ($Filter -eq "All" -or $Filter -eq "Azurite") {
        $services += Test-ServiceStatus -ServiceName "Azurite Storage Emulator" -Url "http://127.0.0.1:$($config.AzuriteBlob)" -Port $config.AzuriteBlob
    }
    
    if ($Filter -eq "All" -or $Filter -eq "Functions") {
        $services += Test-ServiceStatus -ServiceName "Azure Functions" -Url "http://localhost:$($config.FunctionsPort)" -Port $config.FunctionsPort
    }
    
    if ($Filter -eq "All" -or $Filter -eq "Vue") {
        # Check for Vue.js on configured port or auto-incremented ports
        $vueFound = $false
        for ($port = $config.VuePort; $port -le ($config.VuePort + 5); $port++) {
            $vueStatus = Test-ServiceStatus -ServiceName "Vue.js Dev Server" -Url "http://localhost:$port" -Port $port
            if ($vueStatus.Running) {
                $services += $vueStatus
                $vueFound = $true
                break
            }
        }
        if (-not $vueFound) {
            $services += Test-ServiceStatus -ServiceName "Vue.js Dev Server" -Url (Get-VueUrl) -Port $config.VuePort
        }
    }
    
    return $services
}

function Show-ServiceStatuses {
    param(
        [Parameter(Mandatory)]$Services,
        [string]$Title = "Development Environment Status"
    )
    
    Write-Header $Title
    
    foreach ($service in $Services) {
        $icon = if ($service.Running) { "✅" } else { "❌" }
        $color = if ($service.Running) { $Global:Colors.Green } else { $Global:Colors.Red }
        $method = if ($service.Running) { " ($($service.Method))" } else { "" }
        
        Write-ColorOutput "$icon $($service.Name) - Port $($service.Port)$method" $color
        if ($service.Running) {
            Write-ColorOutput "   $($service.Url)" $Global:Colors.Reset
        }
    }
}

function Show-DevelopmentSummary {
    Write-Header "Development Environment Ready"
    
    $config = Get-DevConfig
    
    Write-ColorOutput "🌐 Available Services:" $Global:Colors.Blue
    Write-ColorOutput "  • Cosmos DB Emulator: https://127.0.0.1:$($config.CosmosPort)" $Global:Colors.Reset
    Write-ColorOutput "  • Azurite Storage: http://127.0.0.1:$($config.AzuriteBlob)" $Global:Colors.Reset
    Write-ColorOutput "  • Azure Functions: http://localhost:$($config.FunctionsPort)" $Global:Colors.Reset
    Write-ColorOutput "  • Vue.js App: $(Get-VueUrl)" $Global:Colors.Reset
    
    Write-ColorOutput "`n📋 Quick Actions:" $Global:Colors.Blue
    Write-ColorOutput "  • Check Status: .\dev.ps1 status" $Global:Colors.Reset
    Write-ColorOutput "  • Stop All: .\dev.ps1 stop" $Global:Colors.Reset
    Write-ColorOutput "  • Restart: .\dev.ps1 start -Force" $Global:Colors.Reset
}

# =============================================================================
# SERVICE OPERATIONS
# =============================================================================
function Stop-ProcessOnPort {
    param(
        [int]$Port,
        [string]$ServiceName = "Service",
        [switch]$Force
    )
    
    $processes = netstat -ano | Select-String ":$Port" | Where-Object { $_ -match "LISTENING" }
    
    if (-not $processes) {
        Write-ColorOutput "✅ $ServiceName is not running on port $Port" $Global:Colors.Green
        return $true
    }
    
    foreach ($process in $processes) {
        $pid = ($process.ToString() -split '\s+')[-1]
        
        if ($pid -match '^\d+$') {
            try {
                $processInfo = Get-Process -Id $pid -ErrorAction SilentlyContinue
                if ($processInfo) {
                    Write-ColorOutput "🛑 Stopping $ServiceName (PID: $pid, Process: $($processInfo.ProcessName))" $Global:Colors.Yellow
                    
                    if ($Force) {
                        Stop-Process -Id $pid -Force
                    } else {
                        Stop-Process -Id $pid
                    }
                    
                    # Wait a moment for the process to stop
                    Start-Sleep -Seconds 2
                    
                    Write-ColorOutput "✅ $ServiceName stopped successfully" $Global:Colors.Green
                }
            }
            catch {
                Write-ColorOutput "❌ Failed to stop $ServiceName (PID: $pid): $_" $Global:Colors.Red
                return $false
            }
        }
    }
    
    return $true
}

function Stop-AllServices {
    param(
        [switch]$IncludeCosmosDB,
        [switch]$Force
    )
    
    $config = Get-DevConfig
    $success = $true
    
    Write-ColorOutput "🛑 Stopping development services..." $Global:Colors.Yellow
    
    # Stop Vue.js
    if (-not (Stop-ProcessOnPort -Port $config.VuePort -ServiceName "Vue.js Dev Server" -Force:$Force)) {
        $success = $false
    }
    
    # Stop Azure Functions
    if (-not (Stop-ProcessOnPort -Port $config.FunctionsPort -ServiceName "Azure Functions" -Force:$Force)) {
        $success = $false
    }
    
    # Stop Azurite
    if (-not (Stop-ProcessOnPort -Port $config.AzuriteBlob -ServiceName "Azurite Storage" -Force:$Force)) {
        $success = $false
    }
    
    # Optionally stop Cosmos DB
    if ($IncludeCosmosDB) {
        Write-ColorOutput "🗄️  Note: Cosmos DB Emulator should be stopped manually from system tray" $Global:Colors.Yellow
    }
    
    return $success
}

function Start-NeededServices {
    param(
        [string]$ServiceFilter = "All",
        [switch]$Force
    )
    
    Write-ColorOutput "🚀 Starting development services..." $Global:Colors.Blue
    
    # Get current service statuses first
    $services = Get-AllServiceStatuses -Filter $ServiceFilter
    $config = Get-DevConfig
    $success = $true
    
    foreach ($service in $services) {
        if ($service.Running -and -not $Force) {
            Write-ColorOutput "✅ $($service.Name) is already running on port $($service.Port)" $Global:Colors.Green
            continue
        }
        
        if ($Force -and $service.Running) {
            Write-ColorOutput "🔄 Restarting $($service.Name)..." $Global:Colors.Yellow
            Stop-ProcessOnPort -Port $service.Port -ServiceName $service.Name -Force:$Force
            Start-Sleep -Seconds 2
        }
        
        # Start the service based on its name
        $started = $false
        switch -Wildcard ($service.Name) {
            "*Cosmos*" {
                Write-ColorOutput "🗄️  Starting Cosmos DB Emulator..." $Global:Colors.Blue
                Write-ColorOutput "   Note: Start Cosmos DB Emulator manually if not running" $Global:Colors.Yellow
                $started = $true  # Assume it will be started manually
            }
            "*Azurite*" {
                Write-ColorOutput "💾 Starting Azurite Storage Emulator..." $Global:Colors.Blue
                Start-Process -FilePath "azurite" -ArgumentList "--silent", "--location", "c:\azurite", "--debug", "c:\azurite\debug.log" -WindowStyle Hidden
                Start-Sleep -Seconds 3
                $started = Test-ServicePort -Port $config.AzuriteBlob
            }
            "*Azure Functions*" {
                Write-ColorOutput "⚡ Starting Azure Functions..." $Global:Colors.Blue
                Set-Location "api"
                Start-Process -FilePath "func" -ArgumentList "start", "--port", $config.FunctionsPort -WindowStyle Hidden
                Set-Location ".."
                Start-Sleep -Seconds 5
                $started = Test-ServicePort -Port $config.FunctionsPort
            }
            "*Vue*" {
                Write-ColorOutput "🎨 Starting Vue.js Development Server..." $Global:Colors.Blue
                Set-Location "ui"
                Start-Process -FilePath "npm" -ArgumentList "run", "dev" -WindowStyle Hidden
                Set-Location ".."
                Start-Sleep -Seconds 5
                $started = Test-ServicePort -Port $config.VuePort
            }
        }
        
        if ($started) {
            Write-ColorOutput "✅ $($service.Name) started successfully" $Global:Colors.Green
        } else {
            Write-ColorOutput "❌ Failed to start $($service.Name)" $Global:Colors.Red
            $success = $false
        }
    }
    
    return $success
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================
function Find-ActualVuePort {
    $config = Get-DevConfig
    
    # Check configured port and next few ports (Vue often auto-increments)
    for ($port = $config.VuePort; $port -le ($config.VuePort + 5); $port++) {
        if (Test-ServicePort -Port $port) {
            return $port
        }
    }
    
    return $config.VuePort  # Return default if none found
}

function Write-Section {
    param([string]$Title)
    Write-ColorOutput "`n$Title" $Global:Colors.Blue
    Write-ColorOutput ("-" * $Title.Length) $Global:Colors.Blue
}
