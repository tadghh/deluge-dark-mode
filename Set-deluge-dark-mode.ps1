## TODO: Check deluge version number
param(
	[Parameter()]
	[switch]$dt = $false,
	[String]$installLocation
)
$ErrorActionPreference = "Stop"

$settingHeader = '[Settings]'
$settingValue = 'gtk-application-prefer-dark-theme='
$exeName = "deluge.exe"

# Scoop install directory
$scoopInstall = "$env:USERPROFILE\scoop\apps\deluge\current\"
$defaultInstallDir = "C:\Program Files\Deluge\"
$currentInstallPath = $null
$validInstallPath = $false

# Check install locations
if ($installLocation) {
	$installLocation += "\"
	if ( $installLocation -contains ".exe") {
		$installLocation = $installLocation.Substring(0, $installLocation.LastIndexOf('\'))
	}

	if (Test-Path ($installLocation + $exeName)) {
		$validInstallPath = $true

		$currentInstallPath = $installLocation
	}
	else {
		Write-Host "Could not find deluge.exe in $installLocation"
	}
}
elseif (Test-Path ($defaultInstallDir + $exeName)) {
	Write-Host "Found Deluge in $defaultInstallDir"
	$validInstallPath = $true
	$currentInstallPath = $defaultInstallDir
}
elseif ( Test-Path ("$env:USERPROFILE\scoop")) {
	#Checking Scoop
	Write-Host "Scoop folder exists, checking deluge"

	#Regex is expensive
	#$scoopDelugePresent = ( scoop list | Format-List -Property "Name" | Out-String | Select-String -pattern "deluge")
	$scoopDelugePresent = scoop prefix "deluge"
	if ($scoopDelugePresent -And (Test-Path ($scoopInstall + $exeName))) {
		Write-Host "Found Scoop, Deluge install location"
		$validInstallPath = $true

		$currentInstallPath = $scoopInstall
	}
	else {
		Write-Host "Deluge not found `n $scoopDelugePresent"
	}
}
else {
	Write-Host "No install path found"
}


# Checks if default exists or if scoop.
if ($validInstallPath) {
	$shareName = "\share"
	$gtkName = "\gtk-3.0"
	$settingsFile = "\settings.ini"
	$validPaths = $true
	try {
		# Hopeful Path: Test for share and GTK.
		if (-not (Test-Path ($currentInstallPath + $shareName + $gtkName + $settingsFile))) {
			# Test for share
			$validPaths = $false

			if (Test-Path ($currentInstallPath + $shareName)) {
				$validPaths = $true
				# mkdir $gtkName
				$currentSettingsPath = ($currentInstallPath + $shareName + $gtkName)
				New-Item -ItemType Directory -Path $currentSettingsPath
				Write-Host "Created: GTK Folder"

				# make settings file
				New-Item -ItemType File -Path ($currentSettingsPath + $settingsFile)
				Write-Host "Created: settings.ini"

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
				$settingsFileContent | Set-Content -Path $currentSettingsPath -Force -ErrorAction Stop
			}
		}
	}
	catch {
		Write-Error "An error occured, try running this script as administrator: $_"
	}
}
else {
	Write-Error "Could not find deluge install."
}
# Sad Path
