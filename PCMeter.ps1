# This powershell script requires Windows 10 Version 1709+
# Run with > iex (iwr https://raw.githubusercontent.com/zenvent/perfmeter/main/demo.ps1).Content
# zac@zenvent.com 12/23/2023

# Get-Counter one or more string queries to filter data
$cpuQuery= '\Processor(_Total)\% Processor Time'
$ramQuery= '\Memory\% Committed Bytes In Use'
$netQuery = '\Network Interface(*)\Bytes Total/sec'
$gpuQuery= '\GPU Engine(*)\Utilization Percentage' # NVIDIA
# gpuQuery= '\AMD GPU\Utilization (%)' # AMD

$totalNics = (Get-NetAdapter | Where-Object { $_.InterfaceDescription -match 'Ethernet|Wi-Fi' }).Count

function Get-SystemMetrics{
    # Call Get-Counter with all queries, rather than one at a time. Each call takes 1s.
    $a = (Get-Counter $cpuQuery, $ramQuery, $netQuery, $gpuQuery).CounterSamples.CookedValue

    # CPU is the first returned in array, only one value.
    $cpuPercent = [math]::Round($a[0])

    # RAM is the second returned in array, only one value.
    $ramPercent = [math]::Round($a[1])

    # Network only reports actual usage in bytes, for each NIC, so one or more is returned. $a[2...]
    # Also assumed max throughput is 1GB persecond, scale as necessary.
    $netBytes = @( $a | Select-Object -Skip 2 -First $totalNics)
    $netTotal = ($netBytes | Measure-Object -Sum).Sum
    $netPercent = [math]::Round($netTotal/10000000)

    # GPU may report differently per brand (NVIDIA/AMD/INTEL)
    # NVIDIA returns a collection of all core utilization indiviually and must be summed
    $gpuCores = @( $a | Select-Object -Skip (2+$totalNics))
    $gpuTotal = ($gpuCores | Measure-Object -Sum).Sum
    $gpuPercent = [math]::Round($gpuTotal)

    # Return as compressed JSON
    $metricsJson = @{
        'cpu' = $cpuPercent
        'ram' = $ramPercent
        'net' = $netPercent
        'gpu' = $gpuPercent
    } | ConvertTo-Json -Compress

    Write-Host $metricsJson

    return $metricsJson
}

while($true){
    try {
        # Search and connect to first (and assumed only) COMM port
        $comPort = [System.IO.Ports.SerialPort]::getportnames()[0]
        $serial = New-Object System.IO.Ports.SerialPort($comPort, 9600, 'None', 8, 'One')
        $serial.Open()

        while ($serial.IsOpen) {
            $serial.WriteLine(@(Get-SystemMetrics))
        }
    }catch {
        Write-Host "Failed to connect to device."
        Start-Sleep -Seconds 10
    }
    finally {
        if ($serial.IsOpen) {
            $serial.Close()
        }
    }
}