prep=./prep/prep
cdir=`pwd`

echo original input
cat - >/tmp/_temp
cat /tmp/_temp
echo

echo macro expansion
$prep '.' '$' pair.ohm pair.glue --stop=1 </tmp/_temp |\
    $prep '.' '$' truefalsenil.ohm truefalsenil.glue --stop=1 --support=$cdir/support.js >/tmp/_preprocessed
cat /tmp/_preprocessed

echo convert to bits as ASCII
$prep '.' '$' blc.ohm blc.glue --stop=1 --support=$cdir/support.js </tmp/_preprocessed

echo convert to Scheme
#$prep '.' '$' blc.ohm blc2scm.glue --stop=1 --support=$cdir/support.js --trace </tmp/_preprocessed
$prep '.' '$' blc.ohm blc2scm.glue --stop=1 --support=$cdir/support.js </tmp/_preprocessed


