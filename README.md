# rescue-dg

**rescue-dg** is bootable root file system for Kirkwood SoC devices,
residing in NAND flash, produced with Buildroot-2021.05, and built
completely from scratch.  It has a variety of utilities and apps in it for
setting up SATA/USB/MMC storage, networking, uboot environment, backup
of data (rsync), cloning (dd) and recovering drive contents (ddrescue).
It also makes an excellent, fast and lightweight base for running [Entware](https://github.com/Entware/Entware/wiki).

Tested on/supports five machine types/machids (so far):
- Pogoplug V2 (aka Pink/Gray or pogo_e02)
- Pogoplug V4 (without SATA port)
- Seagate GoFlexHome/FreeAgent-GoFlexNet (these 2 devices use the same image tarball)
- Zyxel NAS-320 2-bay NAS
-  ? Will your machine type be next? 
---
### Downloads

See __[Releases](https://github.com/davygravy/rescue-dg/releases)__ for current available tarballs and source : click on  __> Assets__ at bottom of any release for a list of downloads.

 ---
 ### Contents
 
Uses linux 5.6.5, minimized for kernel/uImage size.
Utilities include:
 - network : `dropbear`, `ntpd`, `wget` (https-capable), `scp`
 - crypto and email: `msmtp`, `gnutls`, `ca-certificates`
 - `fdisk`, `gdisk`; `lsblk`, `blkid`, etc.; Support for GPT
 - e2fsprogs (not the busybox version)
 - mtd-utils (`nandwrite`, `ubi*`, etc)
 - ntfs and dosfs utils
 - nfs utils
 - `ddrescue`
 - `rsync`
 - `nano`
 - `avahi` (device will advertise ssh service by its name rescue.local)
 - `screen`
 - `busybox` (with a wide array of functions)
 - uboot support: `fw_{print,set}env`; bodhi's `uboot.2016.05-tld-1.environment.*` files in `/usr/share/uboot/`
 - aliases:
     - `ll`= `ls -lna`
     - `rmtrw`={remount rootfs as rw}
     - `rmtro`={remount rootfs as ro}
 - ...lots more...


---  
### Setup for building it:

Fulfill the basic requirements stated on the Buildroot site. On a fresh Debian 10 install, I added:
`apt install build-essential bc git rsync ncurses-dev libssl-dev mtd-utils geany`


__Note__:  I was in sudoers group, but `which ubinize` yielded nothing.  I had to add `/usr/sbin` to my path so that `ubinize` would be called correctly (see `custom-rs/post-processv3.sh` script).  `ubinize` is in the mtd-utils package and is essential for converting the raw `rootfs.tar` to a ubifs format.  For me, something like `export PATH="/usr/sbin:$PATH"` worked, along with a simple invocation of `ubinize` just to test it.



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
    nano custom-rs/post-processv3.sh # check over paths 
    # the above might not be necessary since I tried to enable relative paths
    # careful here below... 
    which ubinize  # if you can't see ubinize as a sudoer, then add its parent directory to your path
    #  export PATH="/usr/sbin:$PATH" ; echo $PATH # look for /usr/sbin in your path...
    make menuconfig  # Do a thorough sanity check for file paths; Turn on any other machids that you want to build.
                     # You can find machids of many different kirkwood boxes with this command
                     #   grep -e 'kirkwood-' output/build/linux-5.6.5/arch/arm/boot/dts/*
                     # The machid/name is entered in Kernel > "In-tree Device Tree Source file names"
    make # creates the rootfs and kernel


If you change the location/naming of your directories, then you'll have to be cautious about changing the file paths in the configs and {post,pre}-process scripts.  Build time with a 3.6GHz quad-core Debian box is a litle over an hour, though you can reduce that somewhat for subsequent builds by using a persistent download (dl) directory and keeping the source archive.

---
### Output and Images from the above setup

Binaries and tarballs will be in `output/images`. The script `post-processv3.sh` will create a directory in `output/images/machid` for each machine variant, e.g. `pogo_e02`, `pogoplug_series_4`, etc.

The `uImage.kirkwood.<machid>.mtd1.img` (*kernels*) have the dtb appended to them, and as such, are machine-specific.  This simplifies the testing and flashing of the images, and does not require the installer to make large changes to the uboot environment.

The `rootfs-mtd2.img` (*root filesystem*) are identical for all machids.

__Everything you need, though, is in the `rootfs-USB-kirkwood-<machid>.tar` tarballs.__ These contain essentially the same contents as the `rootfs-mtd2.img`, plus `/boot/uImage` for that machid, and `/flash_images/*.img`. The idea is to boot the USB roots w/ kernel as a test on your machine.  After you are satisfied with function of the kernel and rootfs, you can just `cd` to  `/flash_images/`, and then flash to NAND.  This way, you can try before you buy, so to speak.  __It is strongly advised that you use the rootfs-USB-kirkwood-\<machid>.tar tarball rootfs to test the system on your machine before flashing.__   

---
### Testing and Installation on your device

The wiki section has a disclaimer and bare-bones directions for [uboot changes, testing, and installation to flash](https://github.com/davygravy/rescue-dg/wiki/Testing-and-Flashing).  Flash at your own risk... read fully and test before you flash.
