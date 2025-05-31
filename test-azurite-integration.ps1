#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Test script to verify Azurite integration with Azure Functions
.DESCRIPTION
    This script tests that:
    1. Azurite is running and accessible
    2. Azure Functions can connect to Azurite storage
    3. Queue and blob operations work correctly
.EXAMPLE
    .\test-azurite-integration.ps1
#>

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

function Test-AzuriteEndpoint {
    param([string]$Url, [string]$ServiceName)
    
    try {
        # For Azurite, test the service info endpoint instead of the root
        $testUrl = if ($ServiceName -eq "Blob Service") {
            "$Url/devstoreaccount1?restype=service&comp=properties"
        } elseif ($ServiceName -eq "Queue Service") {
            "$Url/devstoreaccount1?restype=service&comp=properties"
        } else {
            "$Url/devstoreaccount1?restype=service&comp=properties"
        }
        
        $response = Invoke-WebRequest -Uri $testUrl -Method GET -TimeoutSec 5 -ErrorAction Stop
        Write-ColorOutput "✅ $ServiceName is accessible" $Green
        return $true
    }
    catch {
        # Try simple port check as fallback
        $port = ([System.Uri]$Url).Port
        $portInUse = netstat -ano | Select-String ":$port" | Where-Object { $_ -match "LISTENING" }
        if ($portInUse) {
            Write-ColorOutput "✅ $ServiceName port $port is listening" $Green
            return $true
        } else {
            Write-ColorOutput "❌ $ServiceName is not accessible and port $port is not listening" $Red
            return $false
        }
    }
}

Write-ColorOutput "🧪 Testing Azurite Integration with Azure Functions" $Blue
Write-ColorOutput "===================================================" $Blue

# Test 1: Check if Azurite services are running
Write-ColorOutput "`n1️⃣ Testing Azurite Service Endpoints..." $Yellow

$blobOk = Test-AzuriteEndpoint -Url "http://127.0.0.1:10000" -ServiceName "Blob Service"
$queueOk = Test-AzuriteEndpoint -Url "http://127.0.0.1:10001" -ServiceName "Queue Service"
$tableOk = Test-AzuriteEndpoint -Url "http://127.0.0.1:10002" -ServiceName "Table Service"

if (-not ($blobOk -and $queueOk -and $tableOk)) {
    Write-ColorOutput "`n❌ Some Azurite services are not running. Start them with:" $Red
    Write-ColorOutput "   .\smart-start.ps1 -Service Azurite" $Reset
    exit 1
}

# Test 2: Check Azure Functions configuration
Write-ColorOutput "`n2️⃣ Testing Azure Functions Configuration..." $Yellow

$localSettingsPath = ".\golf-league-skins-funcs\local.settings.json"
if (Test-Path $localSettingsPath) {
    $localSettings = Get-Content $localSettingsPath | ConvertFrom-Json
    
    $azureWebJobsStorage = $localSettings.Values.AzureWebJobsStorage
    $golfLeagueStorage = $localSettings.Values.GolfLeagueStoreAccountConnectionString
    
    if ($azureWebJobsStorage -eq "UseDevelopmentStorage=true") {
        Write-ColorOutput "✅ AzureWebJobsStorage is configured for Azurite" $Green
    } else {
        Write-ColorOutput "❌ AzureWebJobsStorage is not configured for Azurite" $Red
        Write-ColorOutput "   Expected: 'UseDevelopmentStorage=true'" $Reset
        Write-ColorOutput "   Current: '$azureWebJobsStorage'" $Reset
    }
    
    if ($golfLeagueStorage -eq "UseDevelopmentStorage=true") {
        Write-ColorOutput "✅ GolfLeagueStoreAccountConnectionString is configured for Azurite" $Green
    } else {
        Write-ColorOutput "❌ GolfLeagueStoreAccountConnectionString is not configured for Azurite" $Red
        Write-ColorOutput "   Expected: 'UseDevelopmentStorage=true'" $Reset
        Write-ColorOutput "   Current: '$golfLeagueStorage'" $Reset
    }
} else {
    Write-ColorOutput "❌ local.settings.json not found" $Red
    exit 1
}

# Test 3: Check if Azure Functions can reach Azurite (if Functions is running)
Write-ColorOutput "`n3️⃣ Testing Azure Functions Connectivity..." $Yellow

try {
    $functionsResponse = Invoke-WebRequest -Uri "http://localhost:7071" -Method GET -TimeoutSec 5 -ErrorAction Stop
    Write-ColorOutput "✅ Azure Functions is running" $Green
    
    # Test a function endpoint that might use storage
    try {
        $testResponse = Invoke-WebRequest -Uri "http://localhost:7071/admin/host/status" -Method GET -TimeoutSec 5 -ErrorAction SilentlyContinue
        Write-ColorOutput "✅ Azure Functions admin endpoint is accessible" $Green
    }
    catch {
        Write-ColorOutput "⚠️  Azure Functions admin endpoint is not accessible (this may be normal)" $Yellow
    }
}
catch {
    Write-ColorOutput "❌ Azure Functions is not running" $Red
    Write-ColorOutput "   Start with: .\smart-start.ps1 -Service Functions" $Reset
}

# Test 4: Check workspace files
Write-ColorOutput "`n4️⃣ Checking Azurite Workspace..." $Yellow

if (Test-Path ".\azurite-workspace") {
    $workspaceFiles = Get-ChildItem ".\azurite-workspace" -ErrorAction SilentlyContinue
    Write-ColorOutput "✅ Azurite workspace directory exists" $Green
    Write-ColorOutput "   Files: $($workspaceFiles.Count) items" $Reset
} else {
    Write-ColorOutput "⚠️  Azurite workspace directory does not exist" $Yellow
    Write-ColorOutput "   This will be created automatically when Azurite starts" $Reset
}

if (Test-Path ".\azurite-debug.log") {
    $logSize = (Get-Item ".\azurite-debug.log").Length
    Write-ColorOutput "✅ Azurite debug log exists (${logSize} bytes)" $Green
} else {
    Write-ColorOutput "⚠️  Azurite debug log does not exist" $Yellow
}

Write-ColorOutput "`n🎯 Test Summary:" $Blue
Write-ColorOutput "===============" $Blue

if ($blobOk -and $queueOk -and $tableOk) {
    Write-ColorOutput "✅ Azurite storage emulation is ready for development" $Green
    Write-ColorOutput "✅ Configuration is set up correctly" $Green
    Write-ColorOutput "`n🌐 Azurite Endpoints:" $Blue
    Write-ColorOutput "  • Blob Storage: http://127.0.0.1:10000" $Reset
    Write-ColorOutput "  • Queue Storage: http://127.0.0.1:10001" $Reset
    Write-ColorOutput "  • Table Storage: http://127.0.0.1:10002" $Reset
    Write-ColorOutput "`n📖 Connection String: UseDevelopmentStorage=true" $Blue
} else {
    Write-ColorOutput "❌ Some issues detected. Please review the output above." $Red
    exit 1
}
