# rescue-dg

**rescue-dg** is bootable root file system for Kirkwood SoC devices,
residing in NAND flash, produced with Buildroot-2021.05, and built
completely from scratch.  It has a variety of utilities and apps in it for
setting up SATA/USB/MMC storage, networking, uboot environment, backup
of data (rsync), cloning (dd) and recovering drive contents (ddrescue).

Tested on/supports four machine types/machids:
- Pogoplug V2 (aka Pink,though I have a gray V2)
- Pogoplug V4/Mobile (with and without SATA port)
- Seagate GoFlexHome/GoFlexNet (counting these as one type)
- Zyxel NAS-320 2-bay NAS 

 
Uses linux 5.6.5, minimized for kernel/uImage size.
Utilities include:
 - network : dropbear, ntpd, wget(https-capable), scp
 - fdisk, gdisk; lsblk, blkid, etc. Support for GPT
 - e2fsprogs (not the busybox version)
 - mtd-utils (nandwrite, ubi*, etc)
 - ntfs and dosfs utils
 - nfs utils
 - ddrescue
 - rsync
 - nano
 - avahi (device will advertise ssh service by its name rescue.local)
 - screen
 - busybox (with a wide array of functions)
 - uboot suoport: fw_{print,set}env; bodhi's uboot.2016.05-tld-1.environment.* files in /usr/share/uboot/
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
script).  `ubinize` is in the mtd-utils package and is essential for converting the raw `rootfs.tar` to a ubifs format.  For me,something like `export PATH=/usr/sbin:$PATH` , followed directly by executing `ubinize` without any operands, worked for me.




    mkdir $HOME/Buildroot
    cd $HOME/Buildroot
    wget https://github.com/buildroot/buildroot/archive/refs/tags/2021.05.tar.gz
    tar xzvf 2021.05.tar.gz
    cd buildroot-2021.05
    wget https://github.com/davygravy/rescue-dg/archive/refs/heads/main.zip
    unzip main.zip
    mv rescue-dg-main/custom-rs .
    rm -r rescue-dg-main/
    cp custom-rs/buildroot-rs-config  .config        
    cp custom-rs/busybox_v1.33.0.config package/busybox/busybox.config  
    chmod +x custom-rs/post-processv3.sh
    nano custom-rs/post-processv3.sh # change any absolute paths to agree w/ your $HOME
    make menuconfig  # Do a thorough sanity check for file paths; Turn on any other machids that you want to build.
                     # You can find machids of many different kirkwood boxes with this command
                     #   grep -e 'kirkwood-' output/build/linux-5.6.5/arch/arm/boot/dts/*
                     # The machid/name is entered in Kernel > "In-tree Device Tree Source file names"
    make # creates the rootfs and kernel


If you change the location/naming of your directories, then you'll have to be cautious about changing the file paths in the configs and {post,pre}-process scripts.  Build time with a 3.6GHz quad-core Debian box is a litle over an hour.  

Binaries and tarballs will be in `output/images`. The script `post-processv3.sh` will create a directory in `output/images/machid` for each machine variant, e.g. `pogo_e02`, `pogoplug_series_4`, etc.

The *kernels* (uImage.mtd1.img) have the dtb appended to them, and as such, are machine-specific.  This simplifies the testing and flashing of the images, and does not require the installer to make large changes to the uboot environment.

The *rootfs.mtd2.img* are identical for all machids.

The `rootfs-USB-kirkwood-<machid>.tar` tarballs are supplied so that you can boot your machine on these first, and test both the kernel and the rootfs on your machine, before flashing in the contents of /flash_images/. They have essentially the same rootfs as the mtd2.img files, and also contain `/boot/uImage` for that machid, as well as the `/flash_images/*.img` files which are for flashing to NAND.  This way, you can try before you buy, so to speak.  __It is strongly advised that you use the rootfs-USB-kirkwood-<machid>.tar tarball rootfs to test the system on yours machine before flashing.__   

The wiki section has a disclaimer and bare-bones directions for uboot changes, testing, and installation to flash.
