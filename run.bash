prep=~/projects/prep/prep
cdir=`pwd`
cat - >/tmp/_temp
cat /tmp/_temp
echo
$prep '\$pair' '.' pair.ohm pair.glue </tmp/_temp |\
    $prep '.' '$' truefalsenil.ohm truefalsenil.glue --stop=1 --support=$cdir/support.js >/tmp/_preprocessed
cat /tmp/_preprocessed
$prep '.' '$' blc.ohm blc.glue --stop=1 --support=$cdir/support.js </tmp/_preprocessed
    

