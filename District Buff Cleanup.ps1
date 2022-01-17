Function Get-FileName($initialDirectory) {
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "JSON (*.json)| *.json"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.FileName
}

$file = Get-FileName

#Make sure to run this file with Powershell using right click!
#Also make sure DDSaveEditor.jar is in the same directory as this script.
#Turn any of these options from $false to $true to toggle their effects.

#Creates a backup in the directory of the file selected.
$backupFile = $false
#Removes *all* buffs from heroes, not just ones with their source being 26 (bsrc_district).
$aggressiveClean = $false

if ($backupFile){
	Write-Output "Backing up file..."
	Copy-Item $($file) -Destination "$($file).bak"
}

Write-Output "Decoding file..."

java -jar DDSaveEditor.jar decode -o $file $file

Write-Output "Removing District Buffs..."

if ($aggressiveClean){
	Write-Output "Using Aggressive Clean."
	$find = "(?:,\n[^\S]*)?.\d[^,]*stat_type[^}]*[^,\n]*(?:,\n[^\S]*)?"
} if (!$aggressiveClean){
	Write-Output "Using Safe Clean."
	$find = ".\d[^,]*stat_type[^}]*source\W : 26[^}]*[^,\n]*(?:,\n[^\S]*)?|,\n[^\S]*.\d[^,]*stat_type[^}]*source\W : 26[^}]*[^,\n]*"
}

(Get-Content $file -Raw | ForEach-Object {$_ -replace $find, ""})| Set-Content $file

Write-Output "Encoding file..."

java -jar DDSaveEditor.jar encode -o $file $file