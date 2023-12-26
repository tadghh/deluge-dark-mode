# Deluge Dark Mode
Enables dark mode for Deluge on Windows.

## Preview
<div align="center">
  <img src="https://github.com/tadghh/deluge-dark-mode/assets/47073445/6037f976-0e57-4052-826a-18d63986d352"/>
</div>

## Notes
- Built with Powershell 7
- Tested on Windows 10 21H2

## Auto install
Use the following script to easily enable Deluge dark mode, it will download and run the script, after execution the script is deleted (may require admininstrator depending on install location).
```pwsh
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tadghh/deluge-dark-mode/main/Change-DelugeDarkMode.ps1" -OutFile "$env:TEMP\Change-DelugeDarkMode.ps1";
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force;
& "$env:TEMP\Change-DelugeDarkMode.ps1" -EnableDarkMode;
Remove-Item "$env:TEMP\Change-DelugeDarkMode.ps1" -Force
```
## Examples

This will enable dark mode for any deluge installs in typical locations.
```pwsh
.\Change-DelugeDarkMode -EnableDarkMode
```

For those who have a custom install location.
```pwsh
.\Change-DelugeDarkMode -EnableDarkMode -CustomInstallLocation "D:\Software\Tools\Deluge"
```

To disable, remove the -EnableDarkMode switch and provide the custom intsall location if you have one. 
```pwsh
.\Change-DelugeDarkMode -CustomInstallLocation "D:\Software\Tools\Deluge"
```



## Contributing
Feel free to report issues or make additions.
