# Utility Functions

function Get-PlatformInfo {
    $arch = [System.Environment]::GetEnvironmentVariable("PROCESSOR_ARCHITECTURE")
    switch ($arch) {
        "AMD64" { return "X64" }
        "IA64" { return "X64" }
        "ARM64" { return "X64" }
        "EM64T" { return "X64" }
        "x86" { return "X86" }
        default { throw "Unknown architecture: $arch. Submit a bug report." }
    }
}

function Request-String($url) {
    $webClient = New-Object System.Net.WebClient
    $webClient.Headers.Add("User-Agent", "Lethal Mod Installer PowerShell Script")
    return $webClient.DownloadString($url)
}
function Request-Stream($url) {
    $webClient = New-Object System.Net.WebClient
    $webClient.Headers.Add("User-Agent", "Lethal Mod Installer PowerShell Script")
    return [System.IO.MemoryStream]::new($webClient.DownloadData($url))
}

function Expand-Stream($zipStream, $destination) {
    # Create a temporary file to save the stream content
    $tempFilePath = [System.IO.Path]::GetTempFileName()

    # replace the temporary file extension with .zip
    $tempFilePath = [System.IO.Path]::ChangeExtension($tempFilePath, "zip")

    # Save the stream content to the temporary file
    $zipStream.Seek(0, [System.IO.SeekOrigin]::Begin)
    $fileStream = [System.IO.File]::OpenWrite($tempFilePath)
    $zipStream.CopyTo($fileStream)
    $fileStream.Close()

    # extract the temporary file to the destination folder
    Expand-Archive -Path $tempFilePath -DestinationPath $destination -Force

    # Delete the temporary file
    Remove-Item -Path $tempFilePath -Force
}

function Get-Arg($arguments, $argName) {
    $argIndex = [Array]::IndexOf($arguments, $argName)
    if ($argIndex -eq -1) {
        throw "Argument $argName not found"
    }
    return $arguments[$argIndex + 1]
}

# Main Installation Function

function Install ($arguments) {
    Write-Host "Please send thanks to Daddy Ganni 🙏`n"

    $response = Request-String "https://api.github.com/repos/BepInEx/BepInEx/releases/latest"
    $jsonObject = ConvertFrom-Json $response
    $platform2Asset = @{}

    foreach ($asset in $jsonObject.assets) {
        if ($null -eq $asset) { continue }

        switch -Wildcard ($asset.name) {
            "BepInEx_unix*" { $platform2Asset["Unix"] = $asset.browser_download_url; break }
            "BepInEx_x64*" { $platform2Asset["X64"] = $asset.browser_download_url; break }
            "BepInEx_x86*" { $platform2Asset["X86"] = $asset.browser_download_url; break }
        }
    }

    $platform = Get-PlatformInfo
    Write-Host "Detected platform: $platform"

    $assetUrl = $platform2Asset[$platform]
    if ($null -eq $assetUrl) {
        throw "Failed to find asset for platform $platform"
    }

    Write-Host "Downloading $assetUrl"
    $stream = Request-Stream $assetUrl
    Write-Host "Downloaded $assetUrl`n"

    $lethalCompanyPath = (Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 1966720").InstallLocation
    if ($null -eq $lethalCompanyPath) {
        throw "Steam Lethal Company install not found"
    }
    
    $bepInExPath = Join-Path $lethalCompanyPath "BepInEx"
    Write-Host "Lethal Company path: $lethalCompanyPath`n"

    if (Test-Path $bepInExPath) {
        Write-Host "Deleting old files"
        Remove-Item $bepInExPath -Recurse -Force
        Write-Host "Deleted old files`n"
    }

    Write-Host "Installing BepInEx"
    Expand-Stream $stream $lethalCompanyPath
    Write-Host "Installed BepInEx`n"

    # Can add your own arguments here
    Install-Mod "2018" "LC_API" (Get-Arg $arguments "-lcApi") $lethalCompanyPath
    Install-Mod "notnotnotswipez" "MoreCompany" (Get-Arg $arguments "-moreCompany") $lethalCompanyPath
    Install-Mod "x753" "More_Suits" (Get-Arg $arguments "-moreSuits") $lethalCompanyPath
    Install-Mod "Sligili" "More_Emotes" (Get-Arg $arguments "-moreEmotes") $lethalCompanyPath
    Install-Mod "IntegrityChaos" "Diversity" (Get-Arg $arguments "-diversity") $lethalCompanyPath
}

function Install-Mod($modAuthor, $modName, $version, $path) {
    Write-Host "Downloading and installing $modName by $modAuthor"
    $url = "https://thunderstore.io/package/download/$modAuthor/$modName/$version/"
    $stream = Request-Stream $url
    Expand-Stream $stream $path
    Write-Host "Installed $modName`n"
}

# Script Execution

try {
    Install $args
    Write-Host "Install successful"
} catch {
    Write-Host "Install failed: $_"
}

Read-Host “Press ENTER to exit...”
