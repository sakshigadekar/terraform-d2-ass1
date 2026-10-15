
$ErrorActionPreference = "Stop"

Write-Output "Starting IIS installation for Sakshi's assignment..."

# Install IIS and its management tools
Install-WindowsFeature -Name Web-Server -IncludeManagementTools

# Configure IIS to start automatically
Set-Service -Name W3SVC -StartupType Automatic

# Start IIS
Start-Service -Name W3SVC

# Create a custom webpage
$html = @'
<!DOCTYPE html>
<html>
<head>
    <title>Sakshi - Terraform Assignment 1</title>
</head>
<body>
    <h1>Hello from Sakshi's Azure Windows VM!</h1>
    <p>IIS has been installed using a Terraform provisioner.</p>
    <p>Assignment: Terraform Azure - Hands-On Assignment 1</p>
</body>
</html>
'@

Set-Content `
    -Path "C:\inetpub\wwwroot\index.html" `
    -Value $html `
    -Encoding UTF8

# Verify that the IIS service is running
$service = Get-Service -Name W3SVC

if ($service.Status -ne "Running") {
    throw "IIS service is not running."
}

if ($service.StartType -ne "Automatic") {
    throw "IIS service is not configured for automatic startup."
}

Write-Output "IIS installation completed successfully."
Get-Service -Name W3SVC

