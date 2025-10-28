    $ErrorActionPreference = 'Stop'

    Function Get-SystemArchitecture {
        $isWow64 = Get-WmiObject -Query "SELECT * FROM Win32_ComputerSystem" | ForEach-Object {
            $_.SystemType -match "x64"
        }

        if ($isWow64) {
            return "64"
        } else {
            return ""
        }
    }

    Function Invoke-NGEN {
        $architecture = Get-SystemArchitecture
        $cmd = "$($env:windir)\Microsoft.NET\Framework$($architecture)\v4.0.30319\ngen.exe"

        if (Test-Path -LiteralPath $cmd) {
            $arguments = "update /queue /force"
            try {
                $ngen_result = Invoke-Expression "$cmd $arguments"
            }
            catch {
                Write-Error "Failed to execute '$cmd $arguments': $($_.Exception.Message)"
            }

            $arguments = "executeQueuedItems"
            try {
                $executed_queued_items = Invoke-Expression "$cmd $arguments"
            }
            catch {
                Write-Error "Failed to execute '$cmd $arguments': $($_.Exception.Message)"
            }
            $executed_queued_items
        }
    }
