#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Checks the status of Golf League local development environment
.DESCRIPTION
    This script checks if all required services are running:
    - Cosmos DB Emulator
    - Azure Functions Core Tools
    - Vue.js Development Server
.EXAMPLE
    .\check-dev-status.ps1
#>

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

function Test-ServiceRunning {
    param(
        [string]$ServiceName,
        [string]$Url,
        [switch]$IgnoreSSLErrors
    )
    
    try {
        if ($IgnoreSSLErrors) {
            $response = Invoke-WebRequest -Uri $Url -Method GET -SkipCertificateCheck -TimeoutSec 5 -ErrorAction Stop
        } else {
            $response = Invoke-WebRequest -Uri $Url -Method GET -TimeoutSec 5 -ErrorAction Stop
        }
        
        if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 401 -or $response.StatusCode -eq 403) {
            Write-ColorOutput "✅ $ServiceName - Running" $Green
            return $true
        }
    }
    catch {
        Write-ColorOutput "❌ $ServiceName - Not running" $Red
        return $false
    }
}

function Test-PortInUse {
    param([int]$Port, [string]$ServiceName)
    
    $portInUse = netstat -ano | Select-String ":$Port" | Where-Object { $_ -match "LISTENING" }
    if ($portInUse) {
        Write-ColorOutput "✅ $ServiceName - Port $Port in use" $Green
        return $true
    } else {
        Write-ColorOutput "❌ $ServiceName - Port $Port not in use" $Red
        return $false
    }
}

Write-ColorOutput "🔍 Golf League Development Environment Status" $Blue
Write-ColorOutput "=============================================" $Blue

$allRunning = $true

# Check Cosmos DB Emulator
Write-ColorOutput "`n🗄️  Cosmos DB Emulator:" $Yellow
$cosmosRunning = Test-ServiceRunning -ServiceName "Cosmos DB Emulator" -Url "https://127.0.0.1:8081" -IgnoreSSLErrors
if (-not $cosmosRunning) {
    $allRunning = $false
}

# Check Azure Functions
Write-ColorOutput "`n⚡ Azure Functions:" $Yellow
$functionsRunning = Test-ServiceRunning -ServiceName "Azure Functions" -Url "http://localhost:7071"
if (-not $functionsRunning) {
    $functionsRunning = Test-PortInUse -Port 7071 -ServiceName "Azure Functions"
}
if (-not $functionsRunning) {
    $allRunning = $false
}

# Check Vue.js Development Server
Write-ColorOutput "`n🖥️  Vue.js Development Server:" $Yellow
$vueUrl = Get-VueUrl
$vuePort = Get-VuePort
$vueRunning = Test-ServiceRunning -ServiceName "Vue.js Dev Server" -Url $vueUrl
if (-not $vueRunning) {
    $vueRunning = Test-PortInUse -Port $vuePort -ServiceName "Vue.js Dev Server"
}
if (-not $vueRunning) {
    $allRunning = $false
}

# Summary
Write-ColorOutput "`n📊 Summary:" $Blue
if ($allRunning) {
    Write-ColorOutput "🎉 All services are running!" $Green    Write-ColorOutput "`n🌐 Available URLs:" $Blue
    Write-ColorOutput "  • Cosmos DB Emulator: https://127.0.0.1:8081/_explorer/index.html" $Reset
    Write-ColorOutput "  • Azure Functions: http://localhost:7071" $Reset
    $vueUrl = Get-VueUrl
    Write-ColorOutput "  • Vue.js App: $vueUrl" $Reset
    
    Write-ColorOutput "`n📝 Available API endpoints:" $Blue
    Write-ColorOutput "  • GET  http://localhost:7071/{leagueName}/config" $Reset
    Write-ColorOutput "  • POST http://localhost:7071/{league}/config" $Reset
    Write-ColorOutput "  • GET  http://localhost:7071/{league}/scores/{roundYear?}/{roundNumber?}" $Reset
    Write-ColorOutput "  • POST http://localhost:7071/{league}/scores" $Reset
    Write-ColorOutput "  • GET  http://localhost:7071/{league}/skins/{roundYear?}/{roundNumber?}" $Reset
} else {
    Write-ColorOutput "⚠️  Some services are not running!" $Yellow
    Write-ColorOutput "💡 Run .\start-dev-environment.ps1 to start all services" $Blue
}

# Check for specific processes
Write-ColorOutput "`n🔍 Process Details:" $Yellow

# Cosmos DB processes
$cosmosProcesses = Get-Process -Name "*cosmos*", "*documentdb*" -ErrorAction SilentlyContinue
if ($cosmosProcesses) {
    Write-ColorOutput "  Cosmos DB processes found: $($cosmosProcesses.Count)" $Green
} else {
    Write-ColorOutput "  No Cosmos DB processes found" $Red
}

# Azure Functions processes
$funcProcesses = Get-Process -Name "func" -ErrorAction SilentlyContinue
if ($funcProcesses) {
    Write-ColorOutput "  Azure Functions processes found: $($funcProcesses.Count)" $Green
} else {
    Write-ColorOutput "  No Azure Functions processes found" $Red
}

# Node processes (for Vue)
$nodeProcesses = Get-Process -Name "node" -ErrorAction SilentlyContinue
if ($nodeProcesses) {
    Write-ColorOutput "  Node.js processes found: $($nodeProcesses.Count)" $Green
} else {
    Write-ColorOutput "  No Node.js processes found" $Red
}
