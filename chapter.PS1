$path = split-path -parent $MyInvocation.MyCommand.Definition
cd $path
$client = new-object System.Net.WebClient

$md = "https://mangadex.org"
#$chap = ....

#$output = "$path\$chap"
$output = "$path\$manga\$chap"

New-Item $manga\$chap -type directory -Force | Out-Null

#---------

$client.DownloadFile("$md/api/chapter/$chap","chap.json")

(Get-Content $path\chap.json).Split(",") > api.txt

$skip = (Select-String api.txt -pattern "hash" | Select-Object -ExpandProperty LineNumber)
$hash = (Get-Content api.txt | select -first 1 -skip ($skip-1)).replace('"', "").replace("hash:", "")

$skip = (Select-String api.txt -pattern "server" | Select-Object -ExpandProperty LineNumber)
$server = ((Get-Content api.txt | select -first 1 -skip ($skip-1)).replace('"', "").replace("server:", "").replace("\", ""))

$skip = (Select-String api.txt -pattern "page_array" | Select-Object -ExpandProperty LineNumber)
$end = ((Select-String api.txt -pattern "\]" | Select-Object -ExpandProperty LineNumber)-$skip)
#Get-Content api.txt | select -first $end -skip ($skip-1)

$pages = "pages.txt"
(Get-Content api.txt | select -first ($end+1) -skip ($skip-1)).replace('"', "").replace("page_array:[", "").replace("]", "") > $pages

$num = 0
$max = (Get-Content $pages).count

echo " "
Get-Variable chap
Get-Variable mnum
echo " "

$start = {

$png = (Get-Content $pages | select -first 1 -skip $num)
$client.DownloadFile("$server$hash/$png","$output\$png")

echo "$server$hash/$png"


$num = $num+1

if ($num -eq $max) {
exit}

&$start
}
&$start

