<#
.SYNOPSIS
Changes the theme for the Windows version of Deluge, to use the GTK-3 Dark mode.

.DESCRIPTION
Creates or modifys the current installation of deluge to enable or disable dark mode, this is done non destrutively, if other settings exist they wont be harmed.

.PARAMETER EnableDarkMode
Default value is false, unless this switch is provided during execution.

.PARAMETER CustomInstallLocation
This can be used if deluge is installed a unique location, provide the folder containing deluge.exe.

.EXAMPLE
.\Change-DelugeDarkMode -EnableDarkMode

This will enable dark mode for any deluge installs in typical locations.

.EXAMPLE
.\Change-DelugeDarkMode -EnableDarkMode -CustomInstallLocation "D:\Software\Tools\Deluge"

An example using a custom install location

.NOTES
We check if deluge is installed with Scoop, if its not we then look at "program files" if deluge still isn't present we fail.

#>
param(
	[switch]$EnableDarkMode = $false,
	[String]$CustomInstallLocation
)

$ErrorActionPreference = 'Stop'

$exeName = 'deluge.exe'

# Used to keep track of directory
$currentInstallPath = $null
$validInstallPath = $false

# Scoop install directory
$scoopInstall = "$env:USERPROFILE\scoop\apps\deluge\current\"

# Default install directory
$defaultInstallDir = 'C:\Program Files\Deluge\'


# Check install locations
if ($CustomInstallLocation) {
	$CustomInstallLocation += '\'
	if ( $CustomInstallLocation -contains '.exe') {
		$CustomInstallLocation = $CustomInstallLocation.Substring(0, $CustomInstallLocation.LastIndexOf('\'))
	}

	if (Test-Path -Path ($CustomInstallLocation + $exeName)) {
		$validInstallPath = $true

		$currentInstallPath = $CustomInstallLocation
	}
	else {
		Write-Host "Could not find deluge.exe in $CustomInstallLocation"
	}
}
elseif (Test-Path -Path ($defaultInstallDir + $exeName)) {
	Write-Host "Found Deluge in $defaultInstallDir"
	$validInstallPath = $true
	$currentInstallPath = $defaultInstallDir
}
elseif ( Test-Path -Path ("$env:USERPROFILE\scoop")) {
	#Checking Scoop
	Write-Host 'Scoop folder exists, checking deluge.'

	#Regex is expensive
	#$scoopDelugePresent = ( scoop list | Format-List -Property "Name" | Out-String | Select-String -pattern "deluge")
	$scoopDelugePresent = scoop prefix 'deluge'
	if ($scoopDelugePresent -And (Test-Path -Path ($scoopInstall + $exeName))) {
		Write-Host 'Found Scoop, Deluge install location.'
		$validInstallPath = $true

		$currentInstallPath = $scoopInstall
	}
	else {
		Write-Host "Deluge not found `n $scoopDelugePresent"
	}
}
else {
	Write-Host 'No install path found.'
}

if ($validInstallPath) {
	$shareName = '\share'
	$gtkName = '\gtk-3.0'
	$settingsFile = '\settings.ini'
	$validPaths = $true
	try {
		# Hopeful Path: Test for share and GTK.
		if (-not (Test-Path -Path ($currentInstallPath + $shareName + $gtkName + $settingsFile))) {
			# Test for share
			$validPaths = $false

			if (Test-Path -Path ($currentInstallPath + $shareName)) {
				$validPaths = $true
				# mkdir $gtkName
				$currentSettingsPath = ($currentInstallPath + $shareName + $gtkName)
				New-Item -ItemType Directory -Path $currentSettingsPath
				Write-Host 'Created: GTK Folder'

				# make settings file
				New-Item -ItemType File -Path ($currentSettingsPath + $settingsFile)
				Write-Host 'Created: settings.ini'

			}
		}

		if ( $validPaths ) {
			$currentSettingsPath = ($currentInstallPath + $shareName + $gtkName + $settingsFile)
			$settingsFileContent = Get-Content -Path $currentSettingsPath
			$changes = $false

			$settingHeader = '[Settings]'
			# Missing header section in settings file.
			if (-not ($settingsFileContent -contains $settingHeader)) {
				$changes = $true
				$settingsFileContent += "`n$settingHeader"
			}

			$settingValue = 'gtk-application-prefer-dark-theme='
			$passedModeString = $EnableDarkMode.ToString().ToLower()
			$darkValueLineNumber = (Select-String -Path $currentSettingsPath -Pattern $settingValue).LineNumber

			# Missing dark mode key, add it.
			if ($null -eq $darkValueLineNumber) {
				$changes = $true
				$settingsFileContent += "`n$settingValue$passedModeString"
			}
			else {
				$changes = $true
				$valueLineNumber = $darkValueLineNumber - 1

				# The setting key exists, replace the value of it
				$settingsFileContent[$valueLineNumber] = $settingsFileContent[$valueLineNumber] -replace '=.*$', "=$passedModeString"
			}
			if ($changes) {
				#We are only adding the header and default dark mode value
				$settingsFileContent | Set-Content -Path $currentSettingsPath -Force
				Write-Host 'Changes made successfully.'
			}
		}
	}
	catch {
		Write-Error "An error occured, try running this script as administrator: $_"
	}
}
else {
	Write-Error 'Could not find deluge install.'
}
# Sad Path
