#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Starts the Golf League local development environment
.DESCRIPTION
    This script starts all required services for local development:
    - Cosmos DB Emulator
    - Azure Functions Core Tools
    - Vue.js Development Server
.EXAMPLE
    .\start-dev-environment.ps1
#>

param(
    [switch]$SkipCosmosDB,
    [switch]$SkipAzurite,
    [switch]$SkipFunctions,
    [switch]$SkipVue,
    [switch]$Verbose
)

# Import development configuration
. .\dev-config.ps1

# Set error action preference
$ErrorActionPreference = "Stop"

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

function Wait-ForService {
    param(
        [string]$ServiceName,
        [string]$Url,
        [int]$TimeoutSeconds = 60,
        [switch]$IgnoreSSLErrors
    )
    
    Write-ColorOutput "⏳ Waiting for $ServiceName to be ready..." $Yellow
    $startTime = Get-Date
    
    do {
        try {
            if ($IgnoreSSLErrors) {
                $response = Invoke-WebRequest -Uri $Url -Method GET -SkipCertificateCheck -TimeoutSec 5 -ErrorAction SilentlyContinue
            } else {
                $response = Invoke-WebRequest -Uri $Url -Method GET -TimeoutSec 5 -ErrorAction SilentlyContinue
            }
            
            if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 401 -or $response.StatusCode -eq 403) {
                Write-ColorOutput "✅ $ServiceName is ready!" $Green
                return $true
            }
        }
        catch {
            # Service not ready yet, continue waiting
        }
        
        Start-Sleep -Seconds 2
        $elapsed = (Get-Date) - $startTime
    } while ($elapsed.TotalSeconds -lt $TimeoutSeconds)
    
    Write-ColorOutput "❌ Timeout waiting for $ServiceName" $Red
    return $false
}

# Main script
Write-ColorOutput "🚀 Starting Golf League Development Environment" $Blue
Write-ColorOutput "================================================" $Blue

# Check if we're in the correct directory
if (-not (Test-Path ".\golfleague-ui\package.json" -PathType Leaf)) {
    Write-ColorOutput "❌ Please run this script from the root of the golf league repository" $Red
    exit 1
}

# Array to store background job information
$jobs = @()

try {
    # 1. Start Cosmos DB Emulator
    if (-not $SkipCosmosDB) {
        Write-ColorOutput "🗄️  Starting Cosmos DB Emulator..." $Yellow
        
        # Check if Cosmos DB is already running
        $cosmosProcess = Get-Process -Name "Microsoft.Azure.Cosmos.Emulator" -ErrorAction SilentlyContinue
        if ($cosmosProcess) {
            Write-ColorOutput "✅ Cosmos DB Emulator is already running" $Green
        } else {
            # Start Cosmos DB Emulator
            $cosmosPath = "${env:ProgramFiles}\Azure Cosmos DB Emulator\Microsoft.Azure.Cosmos.Emulator.exe"
            if (Test-Path $cosmosPath) {
                Start-Process -FilePath $cosmosPath -ArgumentList "/NoUI" -WindowStyle Hidden
                # Wait for Cosmos DB to be ready
                if (-not (Wait-ForService -ServiceName "Cosmos DB Emulator" -Url "https://localhost:8081" -IgnoreSSLErrors -TimeoutSeconds 120)) {
                    throw "Failed to start Cosmos DB Emulator"
                }
            } else {
                Write-ColorOutput "⚠️  Cosmos DB Emulator not found. Please install it manually." $Yellow
                Write-ColorOutput "   Download from: https://docs.microsoft.com/en-us/azure/cosmos-db/local-emulator" $Yellow
            }
        }    } else {
        Write-ColorOutput "⏭️  Skipping Cosmos DB Emulator" $Yellow
    }    # 2. Start Azurite Storage Emulator
    if (-not $SkipAzurite) {
        Write-ColorOutput "🗄️  Starting Azurite Storage Emulator..." $Yellow
        
        # Check if Azurite is already running on port 10000
        $portInUse = netstat -ano | Select-String ":10000" | Where-Object { $_ -match "LISTENING" }
        
        if ($portInUse) {
            Write-ColorOutput "✅ Azurite appears to be already running on port 10000" $Green
        } else {
            # Create azurite workspace directory if it doesn't exist
            if (-not (Test-Path "./azurite-workspace")) {
                New-Item -ItemType Directory -Path "./azurite-workspace" -Force | Out-Null
                Write-ColorOutput "📁 Created azurite-workspace directory" $Blue
            }
            
            # Start Azurite in background
            $azuriteJob = Start-Job -ScriptBlock {
                param($WorkingDir)
                Set-Location $WorkingDir
                & azurite --silent --location ./azurite-workspace --debug ./azurite-debug.log
            } -ArgumentList (Get-Location).Path
            
            $jobs += @{
                Name = "Azurite Storage Emulator"
                Job = $azuriteJob
                Port = 10000
                Url = "http://127.0.0.1:10000"
            }
            
            # Wait for Azurite to be ready
            if (-not (Wait-ForService -ServiceName "Azurite Storage Emulator" -Url "http://127.0.0.1:10000" -TimeoutSeconds 30)) {
                Write-ColorOutput "⚠️  Azurite may still be starting up. Check the azurite-debug.log file." $Yellow
            } else {
                Write-ColorOutput "📦 Azurite Storage Services:" $Blue
                Write-ColorOutput "   • Blob: http://127.0.0.1:10000" $Reset
                Write-ColorOutput "   • Queue: http://127.0.0.1:10001" $Reset
                Write-ColorOutput "   • Table: http://127.0.0.1:10002" $Reset
            }
        }
    } else {
        Write-ColorOutput "⏭️  Skipping Azurite Storage Emulator" $Yellow
    }    # 3. Start Azure Functions
    if (-not $SkipFunctions) {
        Write-ColorOutput "⚡ Starting Azure Functions..." $Yellow
        
        # Check if Azure Functions is already running on port 7071
        $portInUse = netstat -ano | Select-String ":7071" | Where-Object { $_ -match "LISTENING" }
        
        if ($portInUse) {
            Write-ColorOutput "✅ Azure Functions appears to be already running on port 7071" $Green
        } else {
            # Start Azure Functions in background
            $funcJob = Start-Job -ScriptBlock {
                param($WorkingDir, $VerboseMode)
                Set-Location $WorkingDir
                if ($VerboseMode) {
                    & func start --verbose
                } else {
                    & func start
                }
            } -ArgumentList (Resolve-Path ".\golf-league-skins-funcs").Path, $Verbose.IsPresent
            
            $jobs += @{
                Name = "Azure Functions"
                Job = $funcJob
                Port = 7071
                Url = "http://localhost:7071"
            }
            
            # Wait for Azure Functions to be ready
            if (-not (Wait-ForService -ServiceName "Azure Functions" -Url "http://localhost:7071" -TimeoutSeconds 60)) {
                Write-ColorOutput "⚠️  Azure Functions may still be starting up. Check the output manually." $Yellow
            }
        }
    } else {
        Write-ColorOutput "⏭️  Skipping Azure Functions" $Yellow
    }    # 4. Start Vue.js Development Server
    if (-not $SkipVue) {
        Write-ColorOutput "🖥️  Starting Vue.js Development Server..." $Yellow
        
        $vuePort = Get-VuePort
        $vueUrl = Get-VueUrl
        
        # Check if Vue dev server is already running
        $vuePortInUse = netstat -ano | Select-String ":$vuePort" | Where-Object { $_ -match "LISTENING" }
        
        if ($vuePortInUse) {
            Write-ColorOutput "✅ Vue.js dev server appears to be already running on port $vuePort" $Green
        } else {
            # Start Vue.js in background
            $vueJob = Start-Job -ScriptBlock {
                param($WorkingDir)
                Set-Location $WorkingDir
                & npm run dev
            } -ArgumentList (Resolve-Path ".\golfleague-ui").Path
            
            $jobs += @{
                Name = "Vue.js Dev Server"
                Job = $vueJob
                Port = $vuePort
                Url = $vueUrl
            }
            
            # Wait for Vue.js to be ready
            if (-not (Wait-ForService -ServiceName "Vue.js Dev Server" -Url $vueUrl -TimeoutSeconds 60)) {
                Write-ColorOutput "⚠️  Vue.js dev server may still be starting up. Check the output manually." $Yellow
            }
        }
    } else {
        Write-ColorOutput "⏭️  Skipping Vue.js Development Server" $Yellow
    }    # Summary
    Write-ColorOutput "`n🎉 Development Environment Started!" $Green
    Write-ColorOutput "====================================" $Green
    Write-ColorOutput "🗄️  Cosmos DB Emulator: https://localhost:8081" $Green
    Write-ColorOutput "⚡ Azure Functions: http://localhost:7071" $Green
    $vueUrl = Get-VueUrl
    Write-ColorOutput "🖥️  Vue.js App: $vueUrl" $Green
    Write-ColorOutput ""
    Write-ColorOutput "📝 Available endpoints:" $Blue
    Write-ColorOutput "  • GET  /{leagueName}/config" $Reset
    Write-ColorOutput "  • POST /{league}/config" $Reset
    Write-ColorOutput "  • GET  /{league}/scores/{roundYear?}/{roundNumber?}" $Reset
    Write-ColorOutput "  • POST /{league}/scores" $Reset
    Write-ColorOutput "  • GET  /{league}/skins/{roundYear?}/{roundNumber?}" $Reset

    if ($jobs.Count -gt 0) {
        Write-ColorOutput "`n⚠️  Background services started. Press Ctrl+C to stop all services." $Yellow
        Write-ColorOutput "   Or run .\stop-dev-environment.ps1 to stop services." $Yellow
        
        # Keep script running and monitor jobs
        try {
            while ($true) {
                # Check if any jobs have failed
                foreach ($jobInfo in $jobs) {
                    if ($jobInfo.Job.State -eq "Failed") {
                        Write-ColorOutput "❌ $($jobInfo.Name) has failed!" $Red
                        Receive-Job -Job $jobInfo.Job
                    }
                }
                Start-Sleep -Seconds 5
            }
        }
        catch {
            Write-ColorOutput "`n🛑 Shutting down services..." $Yellow
        }
        finally {
            # Clean up jobs
            foreach ($jobInfo in $jobs) {
                if ($jobInfo.Job.State -eq "Running") {
                    Write-ColorOutput "🛑 Stopping $($jobInfo.Name)..." $Yellow
                    Stop-Job -Job $jobInfo.Job -Force
                }
                Remove-Job -Job $jobInfo.Job -Force
            }
        }
    }

} catch {
    Write-ColorOutput "❌ Error: $($_.Exception.Message)" $Red
    
    # Clean up any started jobs
    foreach ($jobInfo in $jobs) {
        if ($jobInfo.Job.State -eq "Running") {
            Stop-Job -Job $jobInfo.Job -Force
        }
        Remove-Job -Job $jobInfo.Job -Force
    }
    
    exit 1
}
