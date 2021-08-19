README:	/usr/share/uboot/ contents

These are generic values from a Pogoplug E02 from bohdi's files.

Use them ONLY as a guide, and be careful to customize them to your
device.

Suggestion:  When you have your uboot env variables set as you want them,
then back them up here.

Ex:  (remount RW before performing this, then RO when finished.)
fw_printenv > /usr/share/uboot/uboot_env-$(date +'%F-%T' | sed  's/[:]//g').txt

Another strategy is to export to an img file, but these are not visually readable.
