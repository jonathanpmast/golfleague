#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Reads local development configuration
.DESCRIPTION
    Reads environment variables and configuration for local development
.EXAMPLE
    $config = Get-DevConfig
    $vuePort = $config.VuePort
#>

function Get-DevConfig {
    $config = @{
        VuePort = 3123
        FunctionsPort = 7071
        CosmosPort = 8081
        AzuriteBlob = 10000
        AzuriteQueue = 10001
        AzuriteTable = 10002
    }
    
    # Try to read from .env.development file
    $envFile = ".\golfleague-ui\.env.development"
    if (Test-Path $envFile) {
        $envContent = Get-Content $envFile -ErrorAction SilentlyContinue
        foreach ($line in $envContent) {
            if ($line -match "^VITE_SERVER_PORT=(\d+)") {
                $config.VuePort = [int]$matches[1]
            }
            elseif ($line -match "^FUNCTIONS_PORT=(\d+)") {
                $config.FunctionsPort = [int]$matches[1]
            }
            elseif ($line -match "^COSMOS_PORT=(\d+)") {
                $config.CosmosPort = [int]$matches[1]
            }
            elseif ($line -match "^AZURITE_BLOB_PORT=(\d+)") {
                $config.AzuriteBlob = [int]$matches[1]
            }
            elseif ($line -match "^AZURITE_QUEUE_PORT=(\d+)") {
                $config.AzuriteQueue = [int]$matches[1]
            }
            elseif ($line -match "^AZURITE_TABLE_PORT=(\d+)") {
                $config.AzuriteTable = [int]$matches[1]
            }
        }
    }
    
    # Check for .env.local override (gitignored, for personal settings)
    $localEnvFile = ".\golfleague-ui\.env.local"
    if (Test-Path $localEnvFile) {
        $envContent = Get-Content $localEnvFile -ErrorAction SilentlyContinue
        foreach ($line in $envContent) {
            if ($line -match "^VITE_SERVER_PORT=(\d+)") {
                $config.VuePort = [int]$matches[1]
            }
        }
    }
    
    return $config
}

function Get-VuePort {
    $config = Get-DevConfig
    return $config.VuePort
}

function Get-VueUrl {
    $port = Get-VuePort
    return "http://localhost:$port"
}

function Find-ActualVuePort {
    $startPort = Get-VuePort
    $maxPort = $startPort + 10
    
    for ($port = $startPort; $port -le $maxPort; $port++) {
        $portInUse = netstat -ano | Select-String ":$port" | Where-Object { $_ -match "LISTENING" }
        if ($portInUse) {
            try {
                $response = Invoke-WebRequest -Uri "http://localhost:$port" -Method GET -TimeoutSec 2 -ErrorAction SilentlyContinue
                if ($response.StatusCode -eq 200) {
                    return $port
                }
            }
            catch {
                # Port in use but not responding to HTTP - might be Vue starting up
                continue
            }
        }
    }
    
    return $startPort  # Return default if not found
}
