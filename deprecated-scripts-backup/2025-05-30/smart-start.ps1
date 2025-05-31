#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Smart service starter for Golf League development
.DESCRIPTION
    Checks what services are running and only starts what's needed.
    Prevents duplicate processes and provides clear feedback.
.PARAMETER Force
    Force start all services even if some are already running
.PARAMETER Service
    Start specific service: CosmosDB, Functions, Vue, or All
.EXAMPLE
    .\smart-start.ps1
.EXAMPLE
    .\smart-start.ps1 -Service Functions
.EXAMPLE
    .\smart-start.ps1 -Force
#>

param(
    [switch]$Force,    [ValidateSet("CosmosDB", "Functions", "Vue", "Azurite", "All")]
    [string]$Service = "All"
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

Write-ColorOutput "🚀 Smart Service Starter for Golf League" $Blue
Write-ColorOutput "=========================================" $Blue

# Check current status first
Write-ColorOutput "`n🔍 Checking current service status..." $Yellow
& .\dev-helper.ps1 -CheckOnly -Service $Service

$statusCode = $LASTEXITCODE

if ($statusCode -eq 0 -and -not $Force) {
    Write-ColorOutput "`n✅ All requested services are already running!" $Green
    Write-ColorOutput "💡 Use -Force to restart services if needed" $Yellow
      # Show URLs for convenience
    Write-ColorOutput "`n🌐 Available URLs:" $Blue
    if ($Service -eq "All" -or $Service -eq "CosmosDB") {
        Write-ColorOutput "  • Cosmos DB: https://127.0.0.1:8081/_explorer/index.html" $Reset
    }
    if ($Service -eq "All" -or $Service -eq "Azurite") {
        Write-ColorOutput "  • Azurite Storage: http://127.0.0.1:10000 (Blob), 10001 (Queue), 10002 (Table)" $Reset
    }
    if ($Service -eq "All" -or $Service -eq "Functions") {
        Write-ColorOutput "  • Azure Functions: http://localhost:7071" $Reset
    }    if ($Service -eq "All" -or $Service -eq "Vue") {
        $vueUrl = Get-VueUrl
        Write-ColorOutput "  • Vue.js App: $vueUrl/ (check terminal for actual port)" $Reset
        Write-ColorOutput "  • Default League: $vueUrl/bmgnky" $Reset
    }
    
    exit 0
}

Write-ColorOutput "`n🏃‍♂️ Starting needed services..." $Yellow

if ($Force) {
    Write-ColorOutput "⚠️  Force mode: Will start all services" $Yellow
}

# Start services based on what's needed
switch ($Service) {
    "All" {
        if ($Force) {
            Write-ColorOutput "`n🛑 Stopping existing services first..." $Red
            & .\stop-dev-environment.ps1 -IncludeCosmosDB
            Start-Sleep -Seconds 2
        }
        Write-ColorOutput "`n🚀 Starting all services..." $Green
        & .\start-dev-environment.ps1
    }
    "CosmosDB" {
        Write-ColorOutput "`n🗄️ Starting Cosmos DB Emulator..." $Green
        & .\start-dev-environment.ps1 -SkipFunctions -SkipVue -SkipAzurite
    }
    "Azurite" {
        Write-ColorOutput "`n🗄️ Starting Azurite Storage Emulator..." $Green
        if (-not (Test-Path "./azurite-workspace")) {
            New-Item -ItemType Directory -Path "./azurite-workspace" -Force | Out-Null
        }
        Start-Process pwsh -ArgumentList "-Command", "azurite --silent --location ./azurite-workspace --debug ./azurite-debug.log" -WindowStyle Normal
        Write-ColorOutput "Started Azurite in new window (silent mode with debug logging)" $Green
    }
    "Functions" {
        Write-ColorOutput "`n⚡ Starting Azure Functions..." $Green
        Start-Process pwsh -ArgumentList "-Command", "cd 'c:\Projects\golfleague\golf-league-skins-funcs'; func host start --port 7071" -WindowStyle Normal
        Write-ColorOutput "Started Azure Functions in new window" $Green
    }
    "Vue" {
        Write-ColorOutput "`n🖥️ Starting Vue.js Development Server..." $Green
        Start-Process pwsh -ArgumentList "-Command", "cd 'c:\Projects\golfleague\golfleague-ui'; npm run dev" -WindowStyle Normal
        Write-ColorOutput "Started Vue.js in new window (check for actual port)" $Green
    }
}

Write-ColorOutput "`n⏳ Waiting for services to start..." $Yellow
Start-Sleep -Seconds 5

# Check final status
Write-ColorOutput "`n🔍 Final status check..." $Yellow
& .\dev-helper.ps1 -Service $Service
