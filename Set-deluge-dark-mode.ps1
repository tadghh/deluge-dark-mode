## TODO: Add paramter to enable or disable
## TODO: Check deluge version number
$settingHeader = '[Settings]'
$settingValue = 'gtk-application-prefer-dark-theme='

$exeName = "deluge.exe"

# Scoop install directory
$scoopInstall = "$env:USERPROFILE\scoop\apps\deluge\current\"

# Default install directory
$defaultInstallDir = "C:\Program Files\Deluge\"
$isDefault = $false
$currentInstallPath = ""

if ( Test-Path ($defaultInstallDir + $exeName)) {
	$isDefault = $true
	$currentInstallPath = $defaultInstallDir
}
else {
	$currentInstallPath = $scoopInstall
}



# Checks if default exists or if scoop
if ( $isDefault -Or (Test-Path ($currentInstallPath + $exeName)) ) {
	$shareName = "\share"
	$gtkName = "\gtk-3.0"
	$settingsFile = "\settings.ini"
	$validPaths = $true

	# Hopeful Path: Test for share and GTK
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
		$currentSettingsPath = $currentInstallPath + $shareName + $gtkName + $settingsFile

		$temp = $false

		# Write settings $settingHeader
		if ($false -eq $settingsHeaderExists) {
			Write-Host "Didn't find header"
			$settingsFileContent += ("`n" + $settingHeader)
		}

		#Check if value exists already, otherwise add it
		$darkValueLineNumber = (Select-String -Path $currentSettingsPath -Pattern $settingValue -List).LineNumber
		if ( $null -eq $darkValueLineNumber) {
			$settingsFileContent += ("`n" + $settingValue + "true")
		}
		else {
			# The value exists, replace the value of it
			# System link issue, current folder and version folder
			Write-Host "Mod"
			$fileContent2 = (Get-Content -Path "D:\Personal\Projects\Coding\Powershell\deluge-dark-mode\settings.ini")
			Write-Host $fileContent2.Count

			Write-Host "Before"
			foreach ($line in $fileContent) {
				Write-Host $line
			}

			#Update file content, false should be param later
			$regex = '^\s*gtk-application-prefer-dark-theme\s*=\s*(true|false)\s*$'
			$newValue = 'gtk-application-prefer-dark-theme=false'

			$null = (Get-Content $currentSettingsPath) -replace $regex, $newValue | Set-Content -Path $currentSettingsPath -Force
			Write-Host "After"

			foreach ($line in $fileContent) {
				Write-Host $line
			}
			#$fileContent | Set-Content -Path $currentSettingsPath -Force
			$temp = $true
		}
		if ($temp -eq $false) {
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
