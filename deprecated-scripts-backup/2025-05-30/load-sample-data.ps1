#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Loads sample configuration data into the local Cosmos DB
.DESCRIPTION
    This script loads the sample golf course configuration from config_data.json
    into the local Cosmos DB emulator for testing purposes.
.EXAMPLE
    .\load-sample-data.ps1
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

Write-ColorOutput "📊 Loading Sample Configuration Data" $Blue
Write-ColorOutput "====================================" $Blue

try {
    # Check if we're in the correct directory
    if (-not (Test-Path ".\golf-league-data-loader\config_data.json" -PathType Leaf)) {
        Write-ColorOutput "❌ config_data.json not found. Please run from repository root." $Red
        exit 1
    }

    # Check if Azure Functions are running
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:7071" -Method GET -TimeoutSec 5 -ErrorAction Stop
        Write-ColorOutput "✅ Azure Functions detected on port 7071" $Green
    }
    catch {
        Write-ColorOutput "❌ Azure Functions not running. Please start with .\start-dev-environment.ps1" $Red
        exit 1
    }

    # Read the sample configuration data
    Write-ColorOutput "📖 Reading sample configuration..." $Yellow
    $configData = Get-Content ".\golf-league-data-loader\config_data.json" -Raw | ConvertFrom-Json

    # Convert to the format expected by the API
    $apiPayload = @{
        id = $configData.id
        leagueName = "bmgnky"  # Default league name from local.settings.json
        courseData = $configData.courseData
    } | ConvertTo-Json -Depth 10

    # Send to SaveConfig API
    Write-ColorOutput "📤 Sending configuration to API..." $Yellow
    $headers = @{
        'Content-Type' = 'application/json'
    }

    try {
        $response = Invoke-RestMethod -Uri "http://localhost:7071/bmgnky/config" -Method POST -Body $apiPayload -Headers $headers
        Write-ColorOutput "✅ Configuration data loaded successfully!" $Green
        
        # Test retrieval
        Write-ColorOutput "🔍 Testing data retrieval..." $Yellow
        $retrievedConfig = Invoke-RestMethod -Uri "http://localhost:7071/bmgnky/config" -Method GET
        
        if ($retrievedConfig.courseData.name -eq $configData.courseData.name) {
            Write-ColorOutput "✅ Data retrieval test passed!" $Green
            Write-ColorOutput "📊 Loaded course: $($retrievedConfig.courseData.name)" $Blue
            Write-ColorOutput "🏌️  Total holes: $($retrievedConfig.courseData.holes.Count)" $Blue
            
            $totalPar = ($retrievedConfig.courseData.holes | Measure-Object -Property par -Sum).Sum
            Write-ColorOutput "⛳ Total par: $totalPar" $Blue
        } else {
            Write-ColorOutput "⚠️  Data retrieval test failed - data may not have been saved correctly" $Yellow
        }
        
    }
    catch {
        Write-ColorOutput "❌ Failed to load configuration data: $($_.Exception.Message)" $Red
        
        if ($_.Exception.Message -like "*500*") {
            Write-ColorOutput "💡 This might be because the Cosmos DB database doesn't exist yet." $Yellow
            Write-ColorOutput "   Try running the setup script first: node setup-cosmos-db.js" $Yellow
        }
        exit 1
    }    Write-ColorOutput "`n🎉 Sample data loaded successfully!" $Green
    $vueUrl = Get-VueUrl
    Write-ColorOutput "🌐 You can now test the application at $vueUrl" $Blue

}
catch {
    Write-ColorOutput "❌ Error: $($_.Exception.Message)" $Red
    exit 1
}
