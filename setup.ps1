param(
    [Parameter(Mandatory)]
    [string]$NetboxURI,
    [Parameter(Mandatory)]
    [string]$NetboxAPIKey
)

$URITest = Invoke-WebRequest $NetboxURI

if ($URITest.StatusCode -eq 200 -and $URITest.RawContent.Contains("API-Version")) {
    $configuration = Get-Content -Path "settings.example.json" | ConvertFrom-Json 
    $configuration.netbox_url = $NetboxURI
    $configuration.netbox_key = $NetboxAPIKey
    $configuration | ConvertTo-Json | Set-Content -Path "settings.json"

    if ($PSVersionTable.PSVersion.Major -lt 7 -or ($PSVersionTable.PSVersion.Major -eq 7 -and $ISWindows)) {
        # windows uses "python" for python3, and not python3 like linux does
        python -m venv venv; .\venv\Scripts\Activate.ps1; pip3 install -r .\requirements.txt; deactivate
    }
    else { 
        # anything but windows, on ps version 7
        python3 -m venv venv; .\venv\Scripts\Activate.ps1; pip3 install -r .\requirements.txt; deactivate
    }
}
else { 
    Write-Error "Netbox URI Invalid. Exiting...\n"
}
