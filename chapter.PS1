$path = split-path -parent $MyInvocation.MyCommand.Definition
cd $path
$client = new-object System.Net.WebClient

$md = "https://mangadex.org"

#$chap = "...."

if (!$manga) {$manga = "manga"}
If(!(test-path $path\$manga)){New-Item $path\$manga -type directory -Force | Out-Null}

#---------
$temp = "$path\temp"
$api = "$temp\api.txt"
$cson = "$temp\chap.json"
If(!(test-path $temp)){New-Item $temp -type directory -Force | Out-Null}

$client.DownloadFile("$md/api/chapter/$chap","$cson")

(Get-Content $cson).Split(",") > $api

$skip = (Select-String $api -pattern "`"hash`":" | Select-Object -ExpandProperty LineNumber)
$hash = (Get-Content $api | select -first 1 -skip ($skip-1)).replace('"', "").replace("hash:", "")

$skip = (Select-String $api -pattern "`"volume`":" | Select-Object -ExpandProperty LineNumber)
$tit = (Get-Content $api | select -first 1 -skip ($skip-1)).replace('"', "").replace("volume:", "Vol")

$skip = (Select-String $api -pattern "`"chapter`":" | Select-Object -ExpandProperty LineNumber)
$tit += (Get-Content $api | select -first 1 -skip ($skip-1)).replace('"', "").replace("chapter:", "Ch")

$skip = (Select-String $api -pattern "`"server`":" | Select-Object -ExpandProperty LineNumber)
$server = ((Get-Content $api | select -first 1 -skip ($skip-1)).replace('"', "").replace("server:", "").replace("\", ""))

$skip = (Select-String $api -pattern "`"page_array`":" | Select-Object -ExpandProperty LineNumber)
$end = ((Select-String $api -pattern "\]" | Select-Object -ExpandProperty LineNumber)-$skip)

#Get-Content $api | select -first $end -skip ($skip-1)


$pages = "$temp\pages.txt"
(Get-Content $api | select -first ($end+1) -skip ($skip-1)).replace('"', "").replace("page_array:[", "").replace("]", "") > $pages

$num = 0
$max = (Get-Content $pages).count

echo " "
Get-Variable chap
if ($mnum) {Get-Variable mnum}
echo " "

$output = "$path\$manga\$tit"
New-Item $output -type directory -Force | Out-Null

$start = {

$host.UI.RawUI.WindowTitle = "$manga Chap:$mnum/$mmax Page:$num/$max"

$png = (Get-Content $pages | select -first 1 -skip $num)
$client.DownloadFile("$server$hash/$png","$output\$png")

echo "$server$hash/$png"
$num++
$host.UI.RawUI.WindowTitle = "$manga Chap:$mnum/$mmax Page:$num/$max"

if ($num -eq $max) {
exit}

start-sleep -seconds 3
&$start
}
&$start
