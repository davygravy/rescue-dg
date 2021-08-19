# rescue-dg

**rescue-dg** is bootable root file system for Kirkwood SoC devices,
residing in NAND flash, produced using Buildroot-2021.05

Built from scratch, against buildroot-2021.05. 

Tested on/supports four machine types/machids:
- Pogoplug V2 (aka Pink,though I have a gray V2)
- Pogoplug V4/Mobile (with and without SATA port)
- Seagate GoFlexHome/GoFlexNet (counting these as one type)
- Zyxel NAS-320 2-bay NSA

 
Uses linux 5.6.5, minimized for kernel/uImage size, culled hardware unlikely to be connected to a Kirkwood device during rescue/setup.
Utilities include:
 - network utilities and apps: dropbear, ntpd, wget(https-capable)
 - fdisk and gdisk
 - e2fsprogs (not the busybox version)
 - mtd-utils (nandwrite, ubi*, etc)
 -ntfs and dosfs utils
 - nfs utils
 - ddrescue
 - rsync
 - nano
 - avahi (device will advertise ssh service by its name rescue.local)
 - screen
 - busybox (with a wide array of functions)
 - aliases:
     - ll=ls -lna
     - rmtrw={remount rootfs as rw}
     - rmtro={remount rootfs as ro}
 - ...lots more...

  
---  
# Setting up and building it:

Fulfill the basic requirements stated on the Buildroot site. On a fresh Debian 10 install, I added:
`apt install build-essential git rsync ncurses-dev libssl-dev
mtd-utils geany`



__Note__:  I was in sudoers group, but still had to add `/usr/sbin` to
my path so that `ubinize` would be called correctly (see `custom-rs/post-processv3.sh`
script).  `ubinize` is in the mtd-utils package and is essential for converting the raw `rootfs.tar` to a ubifs format.  For me,something like `export PATH=/usr/sbin:$PATH` , followed directly by executing `ubinize` with operands, worked for me.




    mkdir $HOME/Buildroot
    cd $HOME/Buildroot
    wget https://github.com/buildroot/buildroot/archive/refs/tags/2021.05.tar.gz
    tar xzvf 2021.05.tar.gz
    cd buildroot-2021.05
    wget https://github.com/davygravy/rescue-dg/archive/refs/heads/main.zip
    unzip main.zip
    mv rescue-dg-main/custom-rs .F
    rm -r rescue-dg-main/
    ln custom-rs/buildroot-rs-config  .config
    chmod +x custom-rs/post-processv3.sh
    make menuconfig  # as a sanity check for paths, or if you want turn on any other machids.
                     # you can find machids of many different kirkwood boxes with this command
                     #   grep -e 'kirkwood-' output/build/linux-5.6.5/arch/arm/boot/dts/*
                     # the machid/name is entered in Kernel > "In-tree Device Tree Source file names"
    make


If you change the location/naming of your directories, then you'll have to be cautious about changing the file paths in most/many/all of the configs.  Build time with a 3.6GHz quad-core Debian box is a litle over an hour.  

Binaries and tarballs will be in `output/images`. The script `post-processv3.sh` will create a directory in `output/images/machid` for each machine variant, e.g. `pogo_e02`, `pogoplug_series_4`, etc.

The *kernels* (uImage.mtd1.img) have the dtb appended to them, and as such, are machine-specific.  This simplifies the testing and flashing of the images, and does not require the installer to make large changes to the uboot environment.

The *rootfs.mtd2.img* are identical for all machids.

The `usb-rescue-<machid>.tar` tarballs have essentially the same rootfs as the mtd2.img files, but also contain `/boot/uImage` for that machid, as well as the `/flash-images/*.img` files which are for flashing to NAND.

The wiki section has a disclaimer and bare-bones directions for uboot changes, testing, and installation to flash.
