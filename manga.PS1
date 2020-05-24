$path = split-path -parent $MyInvocation.MyCommand.Definition
cd $path
$client = new-object System.Net.WebClient

#$manga = "...."

#$mnum = "...."
#$nxt = "...."
#$last = "...."

$lang = "gb"
$md = "https://mangadex.org"

New-Item $path\$manga -type directory -Force | Out-Null
$client.DownloadFile("$md/api/manga/$manga","$path\manga.json")
((Get-Content manga.json).split("}")).replace('"chapter":{', '') | Select-String -pattern "`"lang_code`":`"$lang`"" | Set-Content $path\chapters.txt

$cp = "$path\chapters.txt"

$max = (Get-Content $cp).count

If (-NOT ($mnum -gt 0)){
$mnum = "0"}
If ($nxt -gt 0){
$max = ([int]$mnum + $nxt)}
If ($last -gt 0){
$mnum = ([int]$max - $last)}

Get-Variable max

$mstart = {
$chap = (Get-Content $cp | select -last 1 -skip $mnum).split("""") | select -first 1 -skip 1
& $path\chapter.PS1
$mnum = ([int]$mnum+1)

if ($mnum -eq $max) {
exit}

&$mstart
}
&$mstart
