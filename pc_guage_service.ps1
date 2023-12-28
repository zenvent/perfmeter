# Run perf script as backround windows service
$serviceName = "PcGuageService"
$serviceDisplayName = "Pc Guage Service"
$serviceDescription = "Updates USB display with PC performance metrics"
$executablePath = "C:\Users\YOU\pc_guages.ps1"

# Create service
New-Service -Name $serviceName -BinaryPathName "powershell.exe -File $executablePath" -DisplayName $serviceDisplayName -Description $serviceDescription

# Set service to start automatically
Set-Service -Name $serviceName -StartupType Automatic

# Start the service
Start-Service -Name $serviceName

# Display success message
Write-Output "Service '$serviceName' created and started successfully."
