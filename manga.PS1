$path = split-path -parent $MyInvocation.MyCommand.Definition
cd $path
$client = new-object System.Net.WebClient

#$manga = "...."

#$mnum = "...."
#$max = "...."

$lang = "gb"
$md = "https://mangadex.org"

$temp = "$path\temp"
If (!$manga) {$manga = (Read-Host `$manga = )}
New-Item $temp -type directory -Force | Out-Null
New-Item $path\$manga -type directory -Force | Out-Null
$json = "$temp\manga.json"
$client.DownloadFile("$md/api/manga/$manga","$json")
$cp = "$temp\chapters.txt"
(((Get-Content $json).split("}")).replace('"chapter":{', '') | Select-String -pattern "`"lang_code`":`"$lang`"")| Set-Content $cp

If (!$max){$max = (Get-Content $cp).count}
If (!$mnum){$mnum = "1"}

$prompt = {
$tit = (Read-Host)
If ($tit -eq ""){
echo "done"
} Else{
$tit | Invoke-Expression
.$prompt}}

If ($list -eq "true"){
$list = Get-Content -Path $cp
[array]::Reverse($list)
$index = 0
$list | Foreach{$index++;echo `r`n;Write-Host -NoNewline $index":::`"Chapter_ID`":";$_.Split(",") | select -First 3 -skip 1 | foreach {Write-Host -NoNewline $_","}}
echo `r`n
.$prompt
}

Get-Variable max

$mnum = $mnum - 1
$mstart = {
$chap = (Get-Content $cp | select -last 1 -skip $mnum).split("""") | select -first 1 -skip 1


& $path\chapter.PS1
$mnum = ([int]$mnum+1)

if ($mnum -eq $max) {
exit}

&$mstart
}
&$mstart
