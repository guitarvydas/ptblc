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
$prep '.' '$' blc.ohm blc2ascii.glue --stop=1 --support=$cdir/support.js </tmp/_preprocessed

echo insert Apply
$prep '.' '$' blc.ohm blc2apply.glue --stop=1 --support=$cdir/support.js </tmp/_preprocessed >/tmp/_apply
cat /tmp/_apply

# echo insert Lambda
# $prep '.' '$' applyblc.ohm blc2lambda.glue --stop=1 --support=$cdir/support.js </tmp/_apply

# echo convert to Scheme
# #$prep '.' '$' blc.ohm blc2scm.glue --stop=1 --support=$cdir/support.js --trace </tmp/_preprocessed
# $prep '.' '$' blc.ohm blc2scm.glue --stop=1 --support=$cdir/support.js </tmp/_preprocessed


