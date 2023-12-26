## TODO: Check deluge version number
param(
	[Parameter()]
	[switch]$dt = $false
)

$settingHeader = '[Settings]'
$settingValue = 'gtk-application-prefer-dark-theme='
$exeName = "deluge.exe"

# Scoop install directory
$scoopInstall = "$env:USERPROFILE\scoop\apps\deluge\current\"

# Default install directory
$defaultInstallDir = "C:\Program Files\Deluge\"
$isDefault = $false
$currentInstallPath = $scoopInstall

if ( Test-Path ($defaultInstallDir + $exeName)) {
	$isDefault = $true
	$currentInstallPath = $defaultInstallDir
}


# Checks if default exists or if scoop.
if ( $isDefault -Or (Test-Path ($currentInstallPath + $exeName)) ) {
	$shareName = "\share"
	$gtkName = "\gtk-3.0"
	$settingsFile = "\settings.ini"
	$validPaths = $true

	# Hopeful Path: Test for share and GTK.
	if (!(Test-Path ($currentInstallPath + $shareName + $gtkName + $settingsFile))) {
		# Test for share
		$validPaths = $false

		if (Test-Path ($currentInstallPath + $shareName)) {
			$validPaths = $true
			# mkdir $gtkName
			$currentSettingsPath = $currentInstallPath + $shareName + $gtkName
			Write-Host "Created: GTK Folder"
			New-Item -ItemType Directory -Path $currentSettingsPath

			# make settings file
			Write-Host "Created: settings.ini"
			New-Item -ItemType File -Path $currentSettingsPath + $settingsFile
		}
	}

	if ( $validPaths ) {
		$currentSettingsPath = ($currentInstallPath + $shareName + $gtkName + $settingsFile)
		$settingsFileContent = Get-Content -Path $currentSettingsPath
		$changes = $false

		# Missing header section in settings file.
		if (-not ($settingsFileContent -contains $settingHeader)) {
			$changes = $true
			$settingsFileContent += "`n$settingHeader"
		}

		$passedModeString = $dt.ToString().ToLower()
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
		}
	}
	else {
		Write-Host "Couldn't create paths"
	}
}
else {
	Write-Host "Could not find deluge install."
}
# Sad Path
