<#
Polaris + VMware PowerCLI REST backend for VCMoni
Run:  pwsh -File server_polaris.ps1
#>
Param(
    [int]$Port = 8000,
    [string]$IP = '0.0.0.0'
)

$ErrorActionPreference = 'Stop'

# Ensure modules
$modules = @('Polaris', 'VMware.PowerCLI', 'ImportExcel')
foreach ($m in $modules) {
    if (-not (Get-Module -ListAvailable -Name $m)) {
        Write-Host "Installing PowerShell module $m..." -ForegroundColor Cyan
        Install-Module -Name $m -Scope CurrentUser -Force -AllowClobber | Out-Null
    }
}

Import-Module Polaris
Import-Module VMware.PowerCLI -ErrorAction Stop
Import-Module ImportExcel -ErrorAction SilentlyContinue
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false | Out-Null

$Global:VISession = $null

# Helper functions
function Get-JsonBody {
    param([switch]$AsHash)
    $body = (Get-PolarisRequest).Body | ConvertFrom-Json -ErrorAction Stop
    if ($AsHash) { return @{} + $body } else { return $body }
}

function Require-Session {
    if (-not $Global:VISession) {
        Set-PolarisResponse -StatusCode 401 -Body (@{ detail = 'Not logged in' } | ConvertTo-Json)
        throw 'Not logged in'
    }
}

# Serve static front-end
New-PolarisStaticRoute -FolderPath (Join-Path $PSScriptRoot 'static') -RouteRoot '/'
New-PolarisStaticRoute -FilePath  (Join-Path $PSScriptRoot 'static/index.html') -Method Get -Route '/'

# LOGIN
New-PolarisRoute -Method POST -Path '/login' -ScriptBlock {
    $body = Get-JsonBody -AsHash
    try {
        $Global:VISession = Connect-VIServer -Server $body.server -User $body.username -Password $body.password -Force -WarningAction SilentlyContinue
        Set-PolarisResponse -StatusCode 200 -Body (@{ status = 'ok' } | ConvertTo-Json)
    }
    catch {
        Set-PolarisResponse -StatusCode 401 -Body (@{ detail = 'Login failed' } | ConvertTo-Json)
    }
}

# OVERVIEW
New-PolarisRoute -Method GET -Path '/overview' -ScriptBlock {
    Require-Session
    $res = @{ 
        clusters   = (Get-Cluster).Count
        hosts      = (Get-VMHost).Count
        vms        = (Get-VM).Count
        datastores = (Get-Datastore).Count
    } | ConvertTo-Json
    Set-PolarisResponse -StatusCode 200 -Body $res
}

# CLUSTERS (placeholder utilisation)
New-PolarisRoute -Method GET -Path '/clusters' -ScriptBlock {
    Require-Session
    $list = foreach ($cl in Get-Cluster) {
        $cpu  = 50; $mem = 60; $stor = 40
        [pscustomobject]@{
            name        = $cl.Name
            cpu_pct     = $cpu
            mem_pct     = $mem
            storage_pct = $stor
            capacity    = @{ cpu_pct = 85 - $cpu; mem_pct = 85 - $mem; storage_pct = 85 - $stor }
        }
    }
    Set-PolarisResponse -Body ($list | ConvertTo-Json -Depth 4)
}

# HOSTS
New-PolarisRoute -Method GET -Path '/hosts' -ScriptBlock {
    Require-Session
    $data = Get-VMHost | Select-Object Name,@{N='cpu';E={$_.NumCpu}},@{N='memory';E={$_.MemoryTotalMB}},State
    Set-PolarisResponse -Body ($data | ConvertTo-Json)
}

# VMS
New-PolarisRoute -Method GET -Path '/vms' -ScriptBlock {
    Require-Session
    $data = Get-VM | Select-Object Name,@{N='cpu';E={$_.NumCpu}},@{N='memory';E={$_.MemoryMB}},PowerState
    Set-PolarisResponse -Body ($data | ConvertTo-Json)
}

# DATASTORES
New-PolarisRoute -Method GET -Path '/datastores' -ScriptBlock {
    Require-Session
    $data = Get-Datastore | Select-Object Name,@{N='capacity_gb';E={[math]::Round($_.CapacityGB,1)}},@{N='free_gb';E={[math]::Round($_.FreeSpaceGB,1)}},Type
    Set-PolarisResponse -Body ($data | ConvertTo-Json)
}

# NETWORKS
New-PolarisRoute -Method GET -Path '/networks' -ScriptBlock {
    Require-Session
    $data = Get-VirtualPortGroup | Select-Object Name,VLanId
    Set-PolarisResponse -Body ($data | ConvertTo-Json)
}

# CAPACITY calculator
New-PolarisRoute -Method POST -Path '/capacity' -ScriptBlock {
    $body = Get-JsonBody -AsHash
    $result = @{}
    foreach ($k in $body.Keys) { $result[$k] = [math]::Max(0, 85 - [double]$body[$k]) }
    Set-PolarisResponse -Body ($result | ConvertTo-Json)
}

# EXPORT EXCEL
New-PolarisRoute -Method GET -Path '/export' -ScriptBlock {
    Require-Session
    $tmp = Join-Path $env:TEMP "vc_report_$([guid]::NewGuid().Guid).xlsx"
    Get-Cluster | Export-Excel -Path $tmp -WorksheetName 'clusters'
    Get-VMHost | Export-Excel -Path $tmp -WorksheetName 'hosts' -Append
    Get-VM | Export-Excel -Path $tmp -WorksheetName 'vms' -Append
    Get-Datastore | Export-Excel -Path $tmp -WorksheetName 'datastores' -Append
    Get-VirtualPortGroup | Export-Excel -Path $tmp -WorksheetName 'networks' -Append

    $bytes = [System.IO.File]::ReadAllBytes($tmp)
    $base64 = [System.Convert]::ToBase64String($bytes)
    Set-PolarisResponse -StatusCode 200 -Headers @{ 'Content-Disposition' = 'attachment; filename=vc_report.xlsx' ; 'Content-Type' = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' } -Body $bytes -IsByteResponse
}

# Start server
Start-Polaris -Port $Port -IPAddress $IP
