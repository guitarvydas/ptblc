prep=~/projects/prep/prep
cdir=`pwd`
cat - >/tmp/_temp
cat /tmp/_temp
$prep '\$pair' '.' pair.ohm pair.glue </tmp/_temp |\
    $prep '.' '$' truefalsenil.ohm truefalsenil.glue --stop=1 --support=$cdir/support.js |\
    $prep '.' '$' blc.ohm blc.glue --stop=1 --support=$cdir/support.js
    

