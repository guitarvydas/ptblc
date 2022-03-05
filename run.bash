prep=~/projects/prep/prep
$prep '\$pair' '.' pair.ohm pair.glue |\
    $prep '.' '$' truefalsenil.ohm truefalsenil.glue --stop=1 |\
    $prep '.' '$' blc.ohm blc.glue --stop=1
    

