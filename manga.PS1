$path = split-path -parent $MyInvocation.MyCommand.Definition
cd $path
$client = new-object System.Net.WebClient

#$manga = "...."

#$mnum = "...."
#$mmax = "...."

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

If ($list -eq "true"){
$list = Get-Content -Path $cp
[array]::Reverse($list)
$index = 0
$list | Foreach{$index++;echo `r;Write-Host -NoNewline $index":::`"Chapter_ID`":";$_.Split(",") | select -First 3 -skip 1 | foreach {Write-Host -NoNewline $_","}}
echo `r`n
$tit = (Read-Host)
If (!!$tit){
$tit | Invoke-Expression
}}

If (!!$chap){
& $path\chapter.PS1
exit
}

If (!$mmax){$mmax = (Get-Content $cp).count}
If (!$mnum){$mnum = 1}

$mnum--
$mstart = {
$chap = (Get-Content $cp | select -last 1 -skip $mnum).split("""") | select -first 1 -skip 1


& $path\chapter.PS1
$mnum++

if ($mnum -eq $mmax) {
exit}

&$mstart
}
&$mstart
