param (
	[switch]$Brave,
	[switch]$Firefox,
	[switch]$Ui,
	[switch]$Defender
)

$tempDir = Join-Path -Path $([System.IO.Path]::GetTempPath()) -ChildPath $([System.Guid]::NewGuid())
New-Item $tempDir -ItemType Directory -Force | Out-Null
Push-Location $tempDir

# Install Brave Browser
if ($Brave) {
	& curl.exe -LSs "https://laptop-updates.brave.com/latest/winx64" -o "$tempDir\BraveSetup.exe"

	& "$tempDir\BraveSetup.exe" /silent /install 2>&1 | Out-Null

	do {
		$processesFound = Get-Process | Where-Object { "BraveSetup" -contains $_.Name } | Select-Object -ExpandProperty Name
		if ($processesFound) {
			Write-Output "Still running BraveSetup."
			Start-Sleep -Seconds 2
		} else {
			Remove-Item "$tempDir" -ErrorAction SilentlyContinue -Force -Recurse
		}
	} until (!$processesFound)

	Stop-Process -Name "brave" -Force -ErrorAction SilentlyContinue
	exit
}

# Install Firefox Browser
if ($Firefox) {
	$firefoxArch = 'win64'

	Write-Output "Downloading Firefox..."
	& curl.exe -LSs "https://download.mozilla.org/?product=firefox-latest-ssl&os=$firefoxArch&lang=en-US" -o "$tempDir\firefox.exe"
	Start-Process -FilePath "$tempDir\firefox.exe" -WindowStyle Hidden -ArgumentList '/S /ALLUSERS=1' -Wait 2>&1 | Out-Null
	exit
}

# Install StartAllBack
if ($Ui) {
	Write-Output "Downloading StartAllBack..."
	& curl.exe -LSs "https://www.startallback.com/download.php" -o "$tempDir\startallback.exe"
	& "$tempDir\startallback.exe" /elevated /silent 2>&1 | Out-Null
	exit
}

# Download Defender Disabler
if ($Defender) {
	& curl.exe -LSs "https://github.com/pgkt04/defender-control/releases/latest/download/disable-defender.exe" -o "$tempDir\defender.exe"
	& "$tempDir\defender.exe" -s 2>&1 | Out-Null
	exit
}

Pop-Location
Remove-Item -Path $tempDir -Force -Recurse *>$null