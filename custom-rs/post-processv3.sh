#!/bin/bash

#   Set up for relative paths:
#	 (BINARIES_DIR within buildroot env did not work for me)
#eval (make -s printvars VARS=BINARIES_DIR)		#  Also didn't work; not sure why
#  Immediate working directory is this one; define the Binaries Directory
IWD=$(pwd)
echo IWD=$IWD
BD=$IWD/output/images
echo BD=$BD 

#	delete any old machs/ content

rm -r $BD/machs

#	make a pristine/original/backup copy of the rootfs.tar tarball
cp $BD/rootfs.tar $BD/rootfs.tar.bkp

#	define the config for creating the ubifs rootfs
cat <<END >$BD/rootfs.cfg
[ubifs]
mode=ubi
image=$BD/rootfs.ubifs
vol_id=0
vol_type=dynamic
vol_name=rootfs
vol_flags=autoresize
END

#	create a directories for /etc/issue, /boot/uImage* files and  flash images
mkdir $BD/etc
mkdir $BD/boot
mkdir $BD/flash_images
#	needed for some later operations

#	ubinize it to get the mtd2.img file which will be flashed to mtd2
#	this is a generic rootfs for mtd2 that has no machine (machid) specific files in it
ubinize -o $BD/rootfs-mtd2.img -m 2048 -p 128KiB -s 512 $BD/rootfs.cfg
#	the mtd2.img file for all MACHIDs is finalized;   any further
#	customization can be done by user after flashing/installing


#	for all the USB images we must take out the mountrootRO
#	that are appropriate only for UBIFS or JFFS
cd $BD
tar --delete --file=$BD/rootfs.tar  ./etc/init.d/S05mountrootro


#	for the same reason
#	remove the ubifs etc/fstab from the tarball
#	extract the etc/fstab.ext3 to the current directory
#	change its name and reinsert it as the new etc/fstab
#tar --delete --file=$BD/rootfs.tar  ./etc/fstab
cd   $BD
tar --extract --file=$BD/rootfs.tar  ./etc/fstab.ext3
tar --delete  --file=$BD/rootfs.tar  ./etc/fstab.ext3

mv	  $BD/etc/fstab.ext3  $BD/etc/fstab
tar --update --file=$BD/rootfs.tar  ./etc/fstab





#	Kernel processing for all MACHID's and stamping the images
#

for	MACHID in `ls $BD/uImage* | xargs -n 1 basename | sed 's/uImage.//g'`
do

#	make a rootfs USB tarball just for this MACHID
cp	$BD/rootfs.tar $BD/rootfs-USB-$MACHID.tar


#	Kernel uImage processing
#	convert kernel uImage.$MACHID to a mtd1 image, in BD
dd if=$BD/uImage.$MACHID  of=$BD/uImage.$MACHID-mtd1.img bs=512K conv=sync
#	copy in the kernel uImage to the generic name uImage
cp  $BD/uImage.$MACHID     $BD/boot/uImage
#	append the /boot/uImage contents into the USB/sda rootfs
cd  $BD
tar --append --file=$BD/rootfs-USB-$MACHID.tar  ./boot/uImage


#	copy/mv in the contents mtdN flash images for mtd{1,2}
mv	$BD/uImage.$MACHID-mtd1.img		$BD/flash_images/uImage.$MACHID-mtd1.img
cp	$BD/rootfs-mtd2.img				$BD/flash_images/rootfs-mtd2.img
ls $BD/flash_images/
#	append flash_images/ contents to into the USB-$MACHID.tar also
tar --append --file=$BD/rootfs-USB-$MACHID.tar  ./flash_images/*


#	create a text tag-file with the MACHID and DATE in its filename, append that to the USB rootfs
STAMP=$MACHID'__'`(date +'%F-%T' | sed  's/[:]//g')`
echo $STAMP
echo $STAMP > $BD/$STAMP.txt
tar --append --file=$BD/rootfs-USB-$MACHID.tar	./$STAMP.txt
#	create a custom issue banner with the same stamp
echo "                               "  >					$BD/etc/issue
echo "============================================= " 	>>	$BD/etc/issue
echo "Kirkwood SoC Rescue System"		>>					$BD/etc/issue
echo $STAMP	     						>>					$BD/etc/issue
echo "============================================= "	>>	$BD/etc/issue
echo "                               "  >>					$BD/etc/issue
#	and append it into the tarball
tar --update --file=$BD/rootfs-USB-$MACHID.tar  ./etc/issue



#	create dir(s) for this MACHID
mkdir -p $BD/machs/$MACHID/flash_images
#	mv all flash images, USB tarballs and stamp there
mv  $BD/flash_images/*          $BD/machs/$MACHID/flash_images/
mv  $BD/rootfs-USB-$MACHID.tar  $BD/machs/$MACHID/rootfs-USB-$MACHID.tar
mv	$BD/$STAMP.txt				$BD/machs/$MACHID/$STAMP.txt



#	house cleaning 
rm  $BD/boot/uImage*

done


#	house cleaning
rm	$BD/rootfs.cfg
rm -r $BD/etc
rm -r $BD/boot
rm -r $BD/flash_images
#	careful with that -f below!  if it fails, it does so quietly.
rm  -f 	$BD/rootfs-mtd2.img
#	and restore backup to original
mv  $BD/rootfs.tar.bkp  $BD/rootfs.tar




