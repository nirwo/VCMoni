<#
PowerShell REST API backend using Pode + VMware PowerCLI.
Exposes same routes as previous Python backend.
Run with:  pwsh.exe -File server.ps1  (Windows) or pwsh ./server.ps1 (Linux/macOS)
#>

# Ensure required modules
$modules = @('Pode', 'VMware.PowerCLI', 'ImportExcel')
foreach ($m in $modules) {
    if (-not (Get-Module -ListAvailable -Name $m)) {
        Write-Host "Installing module $m..." -ForegroundColor Cyan
        Install-Module -Name $m -Scope CurrentUser -Force -ErrorAction Stop
    }
}

Import-Module Pode
Import-Module VMware.PowerCLI -ErrorAction Stop
Import-Module ImportExcel -ErrorAction SilentlyContinue
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false | Out-Null

$Global:VISession = $null

Start-PodeServer -Threads 4 -Address '0.0.0.0' -Port 8000 -ScriptBlock {
    Add-PodeEndpoint -Address '0.0.0.0' -Port 8000 -Protocol Http

    # Serve built frontend
    Add-PodeStaticRoute -Route '/' -Source './static/index.html'
    Add-PodeStaticRoute -Folder './static'

    function Ensure-Session {
        if (-not $Global:VISession) {
            Set-PodeResponseStatus -Code 401
            throw 'Not logged in'
        }
    }

    # LOGIN
    Add-PodeRoute -Method Post -Path '/login' -ScriptBlock {
        $body = Get-PodeRequestBody -AsJson
        try {
            $Global:VISession = Connect-VIServer -Server $body.server -User $body.username -Password $body.password -Force -WarningAction SilentlyContinue
            Write-PodeJsonResponse @{ status = 'ok' }
        }
        catch {
            Set-PodeResponseStatus -Code 401
            Write-PodeJsonResponse @{ detail = 'Login failed' }
        }
    }

    # OVERVIEW
    Add-PodeRoute -Method Get -Path '/overview' -ScriptBlock {
        Ensure-Session
        $res = @{ 
            clusters   = (Get-Cluster).Count
            hosts      = (Get-VMHost).Count
            vms        = (Get-VM).Count
            datastores = (Get-Datastore).Count
        }
        Write-PodeJsonResponse $res
    }

    # CLUSTERS with dummy utilisation (replace with real metrics)
    Add-PodeRoute -Method Get -Path '/clusters' -ScriptBlock {
        Ensure-Session
        $list = foreach ($cl in Get-Cluster) {
            $cpu  = 50; $mem = 60; $stor = 40  # TODO real calc
            [pscustomobject]@{
                name        = $cl.Name
                cpu_pct     = $cpu
                mem_pct     = $mem
                storage_pct = $stor
                capacity    = @{ cpu_pct = 85 - $cpu; mem_pct = 85 - $mem; storage_pct = 85 - $stor }
            }
        }
        Write-PodeJsonResponse $list
    }

    # HOSTS
    Add-PodeRoute -Method Get -Path '/hosts' -ScriptBlock {
        Ensure-Session
        $data = Get-VMHost | Select-Object Name,@{N='cpu';E={$_.NumCpu}},@{N='memory';E={$_.MemoryTotalMB}},State
        Write-PodeJsonResponse $data
    }

    # VMS
    Add-PodeRoute -Method Get -Path '/vms' -ScriptBlock {
        Ensure-Session
        $data = Get-VM | Select-Object Name,@{N='cpu';E={$_.NumCpu}},@{N='memory';E={$_.MemoryMB}},PowerState
        Write-PodeJsonResponse $data
    }

    # DATASTORES
    Add-PodeRoute -Method Get -Path '/datastores' -ScriptBlock {
        Ensure-Session
        $data = Get-Datastore | Select-Object Name,@{N='capacity_gb';E={[math]::Round($_.CapacityGB,1)}},@{N='free_gb';E={[math]::Round($_.FreeSpaceGB,1)}},Type
        Write-PodeJsonResponse $data
    }

    # NETWORKS
    Add-PodeRoute -Method Get -Path '/networks' -ScriptBlock {
        Ensure-Session
        $data = Get-VirtualPortGroup | Select-Object Name,VLanId
        Write-PodeJsonResponse $data
    }

    # CAPACITY calc
    Add-PodeRoute -Method Post -Path '/capacity' -ScriptBlock {
        $body = Get-PodeRequestBody -AsJson
        $resp = @{}
        foreach ($k in $body.Keys) { $resp[$k] = [math]::Max(0, 85 - [double]$body[$k]) }
        Write-PodeJsonResponse $resp
    }

    # EXPORT to Excel
    Add-PodeRoute -Method Get -Path '/export' -ScriptBlock {
        Ensure-Session
        $tmp = Join-Path $env:TEMP "vc_report_$([guid]::NewGuid().Guid).xlsx"
        Get-Cluster | Export-Excel -Path $tmp -WorksheetName 'clusters'
        Get-VMHost | Export-Excel -Path $tmp -WorksheetName 'hosts' -Append
        Get-VM | Export-Excel -Path $tmp -WorksheetName 'vms' -Append
        Get-Datastore | Export-Excel -Path $tmp -WorksheetName 'datastores' -Append
        Get-VirtualPortGroup | Export-Excel -Path $tmp -WorksheetName 'networks' -Append
        Write-PodeFileResponse -Path $tmp -ContentType 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' -FileDownloadName 'vc_report.xlsx'
    }
}
