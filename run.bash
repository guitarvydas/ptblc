prep=~/projects/prep/prep
cdir=`pwd`
$prep '\$pair' '.' pair.ohm pair.glue |\
    $prep '.' '$' truefalsenil.ohm truefalsenil.glue --stop=1 --support=$cdir/support.js |\
    $prep '.' '$' blc.ohm blc.glue --stop=1 --support=$cdir/support.js
    

