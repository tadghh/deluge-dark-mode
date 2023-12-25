## TODO: Add paramter to enable or disable
## TODO: Check deluge version number
$settingHeader = '[Settings]'
$settingValue = 'gtk-application-prefer-dark-theme='

$exeName = "deluge.exe"

# Scoop install directory
$scoopInstall = "$env:USERPROFILE\scoop\apps\deluge\*\"

# Default install directory
$defaultInstallDir = "C:\Program Files\Deluge\"
$isDefault = False
$currentInstallPath = ""

if ( Test-Path $defaultInstallDir + $exeName) {
	$isDefault = True
	$currentInstallPath = $defaultInstallDir
}
else {
	$currentInstallPath = $scoopInstall
}



# Checks if default exists or if scoop
if ( $isDefault -Or Test-Path $currentInstallPath + $exeName ) {
	$shareName = "\share"
	$gtkName = "\gtk-3.0"
	$settingsFile = "\settings.ini"
	$validPaths = False

	# Hopeful Path: Test for share and GTK
	if (!(Test-Path $currentInstallPath + $shareName +$gtkName+$settingsFile)) {
		# Test for share
		if (Test-Path $currentInstallPath + $shareName) {
			# mkdir $gtkName
			$currentSettingsPath = $currentInstallPath + $shareName + $gtkName
			Write-Host "Created: GTK Folder"
			New-Item -ItemType Directory -Path $currentSettingsPath

			# make settings file
			Write-Host "Created: settings.ini"
			New-Item -ItemType File -Path $currentSettingsPath + $settingsFile
		}
	}

	# Check and write to settings.ini
	# Dont overwrite the whole file
	# Look for the string, dont add it if it exists


}
# Sad Path
Write-Host "Could not find deluge install."