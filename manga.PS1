$path = split-path -parent $MyInvocation.MyCommand.Definition
cd $path
$client = new-object System.Net.WebClient

$md = "https://mangadex.org"
$manga = 32834

New-Item $manga -type directory -Force | Out-Null
$client.DownloadFile("$md/api/manga/$manga","$path\manga.json")

((Get-Content manga.json).split("}")).replace('"chapter":{', '') | Select-String -pattern '"lang_code":"gb"' | Select-Object -Property Line | Set-Content chapters.txt

$cp = "chapters.txt"
$max = (Get-Content $cp).count
$mnum = 0

$mstart = {
$chap = (Get-Content $cp | select -last 1 -skip $mnum).split("""") | select -first 1 -skip 1

& $path\chapter.PS1

$mnum = $mnum+1

if ($mnum -eq $max) {
exit}

&$mstart
}
&$mstart