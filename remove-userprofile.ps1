# remove-userprofile.ps1
#
# Deze code wordt beheerd op github.com/csgliudger/remove-userprofile
#
# Dit script verwijderd een gebruikersprofiel op de opgegeven computer
Function RestartScript() {
	Write-Host ""
	Write-Host "Nogmaals uitvoeren: [J,N]?"
	$restart = Read-Host
	If ($restart -eq "j") {
		Main
	}
}

Function Main {
	Clear-Host
	Write-Host "remove-userprofile.ps1"
	Write-Host ""
	Write-Host "Dit script verwijderd een gebruikersprofiel op de opgegeven computer."
	Write-Host ""
	Write-Host "Meer informatie over het gebruik is de vinden op WikiSB-pagina"
	Write-Host " - Werkinstructie verwijderen gebruikersprofiel"
	Write-Host ""

	$hostname = Read-Host "Computernaam (bijv. D1489)"
	$username = Read-Host "Te verwijderen profiel (bijv. ptester)"


	Write-Host "Verbinding maken met computer $hostname..."
	If (-Not (Test-Connection -ComputerName $hostname -Count 1 -ErrorAction 0)) {
		Write-Host "Computer $hostname is niet bereikbaar"
		Return RestartScript
	}

	Write-Host "Verbinding gemaakt met computer $hostname"
	Write-Host "Profielen ophalen..."
	$userProfiles = Get-WmiObject -Class Win32_UserProfile -Computer $hostname -ErrorAction 0
	$countProfiles = $userProfiles.count
	Write-Host "Aantal gevonden profielen: $countProfiles"

	Foreach ($profile in $userProfiles) {
		$sid = New-Object System.Security.Principal.SecurityIdentifier($profile.sid)
		$ntAccount = $sid.Translate([System.Security.Principal.NTAccount])
		$profileUser = $ntAccount.value.split("\")[1]
		If ($profileUser -eq $username) {
			Try {
				Write-Host "Profiel van $username gevonden"
				Write-Host "Profiel van $username verwijderen..."
				$profile.delete()
				Write-Host "Profiel van $username is verwijderd"
			}
			Catch [Exception] {
				Write-Host "Verwijderen van het profiel van $username is mislukt"
			}
			$profileFound = $TRUE
			Break
		}
	}
	If (-Not ($profileFound)) {
		Write-Host "Geen profiel gevonden voor gebruiker $username"
	}
	Write-Host "=== remove-userprofile.ps1 afgesloten"
	RestartScript
}

. Main
