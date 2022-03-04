prep=~/projects/prep/prep
$prep '\$pair' '.' pair.ohm pair.glue |\
    $prep '\$true' '.' truefalsenil.ohm truefalsenil.glue |\
    $prep '\$false' '.' truefalsenil.ohm truefalsenil.glue |\
    $prep '\$nil' '.' truefalsenil.ohm truefalsenil.glue
    

