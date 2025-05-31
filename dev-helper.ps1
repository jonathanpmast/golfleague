#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Smart development environment helper for Golf League
.DESCRIPTION
    Checks service status and provides recommendations for next actions.
    Returns status codes for programmatic use.
.PARAMETER CheckOnly
    Only check status, don't provide action recommendations
.PARAMETER Service
    Check specific service: CosmosDB, Functions, Vue, Azurite, or All
.EXAMPLE
    .\dev-helper.ps1
.EXAMPLE
    .\dev-helper.ps1 -Service Functions
.EXAMPLE
    .\dev-helper.ps1 -CheckOnly
#>

param(
    [switch]$CheckOnly,
    [ValidateSet("CosmosDB", "Functions", "Vue", "Azurite", "All")]
    [string]$Service = "All"
)

# Import dev configuration
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
    try {
        if ($IgnoreSSLErrors) {
            $response = Invoke-WebRequest -Uri $Url -Method GET -SkipCertificateCheck -TimeoutSec 3 -ErrorAction Stop
        } else {
            $response = Invoke-WebRequest -Uri $Url -Method GET -TimeoutSec 3 -ErrorAction Stop
        }
        
        if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 401 -or $response.StatusCode -eq 403) {
            $status.Running = $true
            $status.Method = "HTTP"
            return $status
        }
    }
    catch {
        # HTTP failed, try port check
    }
    
    # Try port check as fallback
    $portInUse = netstat -ano | Select-String ":$Port" | Where-Object { $_ -match "LISTENING" }
    if ($portInUse) {
        $status.Running = $true
        $status.Method = "Port"
        return $status
    }
    
    return $status
}

function Get-ServiceStatuses {
    $services = @()
    
    if ($Service -eq "All" -or $Service -eq "CosmosDB") {
        $services += Test-ServiceStatus -ServiceName "Cosmos DB Emulator" -Url "https://127.0.0.1:8081" -Port 8081 -IgnoreSSLErrors
    }
    
    if ($Service -eq "All" -or $Service -eq "Azurite") {
        $services += Test-ServiceStatus -ServiceName "Azurite Storage Emulator" -Url "http://127.0.0.1:10000" -Port 10000
    }
    
    if ($Service -eq "All" -or $Service -eq "Functions") {
        $services += Test-ServiceStatus -ServiceName "Azure Functions" -Url "http://localhost:7071" -Port 7071
    }
      if ($Service -eq "All" -or $Service -eq "Vue") {
        # Use configurable Vue port
        $vuePort = Get-VuePort
        $vueUrl = Get-VueUrl
        
        # Check multiple possible Vue ports starting from configured port
        $vueFound = $false
        for ($port = $vuePort; $port -le ($vuePort + 5); $port++) {
            $vueStatus = Test-ServiceStatus -ServiceName "Vue.js Dev Server" -Url "http://localhost:$port" -Port $port
            if ($vueStatus.Running) {
                $services += $vueStatus
                $vueFound = $true
                break
            }
        }
        if (-not $vueFound) {
            $services += Test-ServiceStatus -ServiceName "Vue.js Dev Server" -Url $vueUrl -Port $vuePort
        }
    }
    
    return $services
}

function Show-ServiceStatus {
    param($Services)
    
    Write-ColorOutput "🔍 Golf League Development Environment Status" $Blue
    Write-ColorOutput "==============================================" $Blue
    
    foreach ($service in $Services) {
        $icon = if ($service.Running) { "✅" } else { "❌" }
        $color = if ($service.Running) { $Green } else { $Red }
        $method = if ($service.Running) { " ($($service.Method))" } else { "" }
        
        Write-ColorOutput "$icon $($service.Name) - Port $($service.Port)$method" $color
        if ($service.Running) {
            Write-ColorOutput "   $($service.Url)" $Reset
        }
    }
}

function Show-ActionRecommendations {
    param($Services)
    
    $notRunning = $Services | Where-Object { -not $_.Running }
    
    Write-ColorOutput "`n💡 Recommended Actions:" $Blue
    
    if ($notRunning.Count -eq 0) {
        Write-ColorOutput "🎉 All requested services are running!" $Green
        Write-ColorOutput "Ready for development!" $Green
        return
    }
    
    foreach ($service in $notRunning) {
        Write-ColorOutput "🚀 Start $($service.Name):" $Yellow
          switch ($service.Name) {
            "Cosmos DB Emulator" {
                Write-ColorOutput "   # Start manually or run:" $Reset
                Write-ColorOutput "   .\start-dev-environment.ps1 -SkipFunctions -SkipVue -SkipAzurite" $Reset
            }
            "Azurite Storage Emulator" {
                Write-ColorOutput "   # Run:" $Reset
                Write-ColorOutput "   azurite --silent --location ./azurite-workspace --debug ./azurite-debug.log" $Reset
            }
            "Azure Functions" {
                Write-ColorOutput "   # Use VS Code task or run:" $Reset
                Write-ColorOutput "   cd golf-league-skins-funcs && func host start --port 7071" $Reset
            }
            "Vue.js Dev Server" {
                Write-ColorOutput "   # Run:" $Reset
                Write-ColorOutput "   cd golfleague-ui && npm run dev" $Reset
            }
        }
    }
    
    if ($notRunning.Count -eq $Services.Count) {
        Write-ColorOutput "`n🏃‍♂️ Quick Start All:" $Yellow
        Write-ColorOutput "   .\start-dev-environment.ps1" $Reset
    }
}

# Main execution
$services = Get-ServiceStatuses
Show-ServiceStatus -Services $services

if (-not $CheckOnly) {
    Show-ActionRecommendations -Services $services
}

# Return exit code for programmatic use
$allRunning = ($services | Where-Object { -not $_.Running }).Count -eq 0
if ($allRunning) {
    exit 0  # All services running
} else {
    exit 1  # Some services not running
}
