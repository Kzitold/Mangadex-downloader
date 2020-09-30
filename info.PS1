$path = split-path -parent $MyInvocation.MyCommand.Definition
cd $path
$client = new-object System.Net.WebClient

#$manga = "...."

$lang = "gb"
$md = "https://mangadex.org"

$temp = "$path\tp"
If (!$manga) {$manga = (Read-Host `$manga = )
}
New-Item $temp -type directory -Force | Out-Null
$json = "$temp\manga.json"
$client.DownloadFile("$md/api/manga/$manga","$json")
$cp = "$temp\chapters.txt"
(((Get-Content $json).split("}")).replace('"chapter":{', '') | Select-String -pattern "`"lang_code`":`"$lang`"")| Set-Content $cp

$brack = {
Do {
$le = ($test.Split("{") | select -first 1)
$ri = ($test.Split("}") | select -first 1)

If (($test.length - $le.length + 1) -gt ($test.length - $ri.length + 1)){


$output += ("....." * $index) + $le + "{" + "`r`n"
$test = ($test.Remove(0,$le.length + 1))
$index ++

If ($count -gt 0){$count--}}

If (($test.length - $ri.length + 1) -gt ($test.length - $le.length + 1)){

$output += ("....." * $index) + $ri + "}" + "`r`n"
$index--
$test = ($test.Remove(0,$ri.length + 1))}

} until ($ri.length -eq $le.length)

$output += ("....." * $index) + $ri + "`r`n"
$test = ($test.Remove(0,$ri.length))
$output > $path\test.txt
}

$index = 0
$output = $null

$sk = ((Get-Content $temp\manga.json).replace("`":`"","`":`"`r`n").split("`r`n") | Select-String -Pattern "`"description`":") | select -ExpandProperty LineNumber
If (!($PSEdition -eq "Core")){$sk++}
$description = (((Get-Content $temp\manga.json).replace("`":`"","`":`"`r`n").split("`r`n") | select -first 1 -skip $sk)).replace("`",`"","`r`n").split("`r`n") | select -first 1
$edit = $description.replace("\r\n","`r`n").replace(".",".`r`n").replace("?","?`r`n").replace("?","?`r`n")

$cp = "$temp\chapters.txt"

((Get-Content $temp\manga.json).Replace($description,$edit)).replace(",`"",",`r`n`"").split("`r`n") | foreach { $test = $_;.$brack}
$gen = ($output.split("`r`n") | Select-String -Pattern "`"genres`":" | select -ExpandProperty Line).split(":") | select -last 1
$sk = $edit.split("`r`n") | Select-String -SimpleMatch "[spoiler]" |select -First 1 -ExpandProperty LineNumber

#Clear-Host

if($sk -gt 0){
$edit.split("`r`n") | select -First ($sk - 1)
}Else {$edit.split("`r`n")}
Write-host "`r`n"
Write-host -NoNewline "Tags:" ($gen.replace("[","").replace("]","").split(",") | foreach {If ($_ -gt 0){((get-content $path\tags.txt)[($_ - 1)]) + ","}})
Write-host "`r`n"
Write-host "Chapters:"(Get-Content $cp).count
pause
