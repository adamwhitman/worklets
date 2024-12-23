## EVAULATION CODE 

exit 1

## REMEDIATION CODE

function Get-AllInstalledSoftware {
    $foundSoftware = @()

    # Check 64-bit hive on 64-bit devices
    if ([System.Environment]::Is64BitOperatingSystem) {
        $hklm64 = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry64)
        $skey64 = $hklm64.OpenSubKey("Software\Microsoft\Windows\CurrentVersion\Uninstall")
        if ($skey64) {
            $unkeys64 = $skey64.GetSubKeyNames()
            foreach ($key in $unkeys64) {
                $subKey = $skey64.OpenSubKey($key)
                if ($subKey -and $subKey.GetValue('DisplayName') -and !($subKey.GetValue("SystemComponent"))) {
                    $foundSoftware += [PSCustomObject]@{
                        DisplayName     = $subKey.GetValue("DisplayName")
                        DisplayVersion  = $subKey.GetValue("DisplayVersion")
                        Publisher       = $subKey.GetValue("Publisher")
                    }
                }
            }
        }
    }

    # Check 32-bit hive on all devices
    $skey32 = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
    foreach ($key in Get-ChildItem $skey32 -ErrorAction SilentlyContinue | Get-ItemProperty | Where-Object {($_.DisplayName -ne $null -and !($_.SystemComponent))}) {
        $foundSoftware += [PSCustomObject]@{
            DisplayName     = $key.DisplayName
            DisplayVersion  = $key.DisplayVersion
            Publisher       = $key.Publisher
        }
    }

    # Scan HKU for user-specific installations
    New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS | Out-Null
    foreach ($usr in Get-ChildItem -Path "HKU:\") {
        foreach ($guid in Get-ChildItem "HKU:\$usr\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" -ErrorAction SilentlyContinue | Get-ItemProperty | Where-Object {($_.DisplayName -ne $null -and !($_.SystemComponent))}) {
            $foundSoftware += [PSCustomObject]@{
                DisplayName     = $guid.DisplayName
                DisplayVersion  = $guid.DisplayVersion
                Publisher       = $guid.Publisher
            }
        }
    }
    Remove-PSDrive HKU -ErrorAction SilentlyContinue

    return $foundSoftware
}

# Retrieve all installed software
$AllInstalledSoftware = Get-AllInstalledSoftware
Write-Output $AllInstalledSoftware
