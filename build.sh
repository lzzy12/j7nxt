#!/bin/bash
# Build Script By Tkkg1994 and djb77
# Modified by DarkLord1731/ XDA Developers

# ---------
# VARIABLES
# ---------
ARCH=arm64
BUILD_CROSS_COMPILE=~/Toolchains/aarch64-cortex_a53-linux-gnueabi-uber/bin/aarch64-cortex_a53-linux-gnueabi-
BUILD_JOB_NUMBER=`grep processor /proc/cpuinfo|wc -l`
RDIR=$(pwd)
OUTDIR=$RDIR/arch/$ARCH/boot
DTSDIR=$RDIR/arch/$ARCH/boot/dts
DTBDIR=$OUTDIR/dtb
DTCTOOL=$RDIR/scripts/dtc/dtc
INCDIR=$RDIR/include
PAGE_SIZE=2048
DTB_PADDING=0
ZIPLOC=zip
RAMDISKLOC=ramdisk

# ---------
# FUNCTIONS
# ---------
FUNC_CLEAN()
{
make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
	CROSS_COMPILE=$BUILD_CROSS_COMPILE clean
make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
	CROSS_COMPILE=$BUILD_CROSS_COMPILE mrproper
rm -rf $RDIR/arch/arm64/boot/dtb
rm -f $RDIR/arch/$ARCH/boot/dts/*.dtb
rm -f $RDIR/arch/$ARCH/boot/boot.img-dtb
rm -f $RDIR/arch/$ARCH/boot/boot.img-zImage
rm -f $RDIR/oxygen/boot.img
rm -f $RDIR/oxygen/*.zip
rm -f $RDIR/oxygen/$RAMDISKLOC/G610x/image-new.img
rm -f $RDIR/oxygen/$RAMDISKLOC/G610x/ramdisk-new.cpio.gz
rm -f $RDIR/oxygen/$RAMDISKLOC/G610x/split_img/boot.img-dtb
rm -f $RDIR/oxygen/$RAMDISKLOC/G610x/split_img/boot.img-zImage
rm -f $RDIR/oxygen/$RAMDISKLOC/G610x/image-new.img
rm -f $RDIR/oxygen/$ZIPLOC/G610x/*.zip
rm -f $RDIR/oxygen/$ZIPLOC/G610x/*.img
rm -f $RDIR/oxygen/$RAMDISKLOC/J710X/image-new.img
rm -f $RDIR/oxygen/$RAMDISKLOC/J710X/ramdisk-new.cpio.gz
rm -f $RDIR/oxygen/$RAMDISKLOC/J710X/split_img/boot.img-dtb
rm -f $RDIR/oxygen/$RAMDISKLOC/J710X/split_img/boot.img-zImage
rm -f $RDIR/oxygen/$RAMDISKLOC/J710X/image-new.img
rm -f $RDIR/oxygen/$ZIPLOC/J710X/*.zip
rm -f $RDIR/oxygen/$ZIPLOC/J710X/*.img
}

FUNC_BUILD_DTB()
{
[ -f "$DTCTOOL" ] || {
	echo "You need to run ./build.sh first!"
	exit 1
}
case $MODEL in
on7xelte)
	DTSFILES="exynos7870-on7xelte_swa_open_00 exynos7870-on7xelte_swa_open_01 
		exynos7870-on7xelte_swa_open_02"
	;;
j7xelte)
	DTSFILES="exynos7870-j7xelte_eur_open_00 exynos7870-j7xelte_eur_open_01
		exynos7870-j7xelte_eur_open_02 exynos7870-j7xelte_eur_open_03
		exynos7870-j7xelte_eur_open_04"
	;;
*)
	echo "Unknown device: $MODEL"
	exit 1
	;;
esac
mkdir -p $OUTDIR $DTBDIR
cd $DTBDIR || {
	echo "Unable to cd to $DTBDIR!"
	exit 1
}
rm -f ./*
echo "Processing dts files."
for dts in $DTSFILES; do
	echo "=> Processing: ${dts}.dts"
	${CROSS_COMPILE}cpp -nostdinc -undef -x assembler-with-cpp -I "$INCDIR" "$DTSDIR/${dts}.dts" > "${dts}.dts"
	echo "=> Generating: ${dts}.dtb"
	$DTCTOOL -p $DTB_PADDING -i "$DTSDIR" -O dtb -o "${dts}.dtb" "${dts}.dts"
done
echo "Generating dtb.img."
$RDIR/scripts/dtbTool/dtbTool -o "$OUTDIR/dtb.img" -d "$DTBDIR/" -s $PAGE_SIZE
echo "Done."
}

FUNC_BUILD_ZIMAGE()
{
echo ""
make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
	CROSS_COMPILE=$BUILD_CROSS_COMPILE \
	$KERNEL_DEFCONFIG
make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
	CROSS_COMPILE=$BUILD_CROSS_COMPILE
echo ""
}

FUNC_BUILD_RAMDISK()
{
mv $RDIR/arch/$ARCH/boot/Image $RDIR/arch/$ARCH/boot/boot.img-zImage
mv $RDIR/arch/$ARCH/boot/dtb.img $RDIR/arch/$ARCH/boot/boot.img-dtb
case $MODEL in
on7xelte)
	rm -f $RDIR/oxygen/ramdisk/G610x/split_img/boot.img-zImage
	rm -f $RDIR/oxygen/ramdisk/G610x/split_img/boot.img-dtb
	mv -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/oxygen/ramdisk/G610x/split_img/boot.img-zImage
	mv -f $RDIR/arch/$ARCH/boot/boot.img-dtb $RDIR/oxygen/ramdisk/G610x/split_img/boot.img-dtb
	cd $RDIR/oxygen/ramdisk/G610x
	./repackimg.sh
	echo SEANDROIDENFORCE >> image-new.img
	;;
j7xelte)
	rm -f $RDIR/oxygen/ramdisk/J710x/split_img/boot.img-zImage
	rm -f $RDIR/oxygen/ramdisk/J710x/split_img/boot.img-dtb
	mv -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/oxygen/ramdisk/J710x/split_img/boot.img-zImage
	mv -f $RDIR/arch/$ARCH/boot/boot.img-dtb $RDIR/oxygen/ramdisk/J710x/split_img/boot.img-dtb
	cd $RDIR/oxygen/ramdisk/J710x
	./repackimg.sh
	echo SEANDROIDENFORCE >> image-new.img
	;;
*)
	echo "Unknown device: $MODEL"
	exit 1
	;;
esac
}

FUNC_BUILD_BOOTIMG()
{
	(
	FUNC_BUILD_ZIMAGE
	FUNC_BUILD_DTB
	FUNC_BUILD_RAMDISK
	) 2>&1	 | tee -a oxygen/build.log
}
FUNC_BUILD_ZIP()
{
echo ""
echo "Building Zip File"
cd $ZIP_FILE_DIR
zip -gq $ZIP_NAME -r * -x "*~"
chmod a+r $ZIP_NAME
mv -f $ZIP_FILE_TARGET $RDIR/oxygen/$ZIP_NAME
cd $RDIR
}


OPTION_1()
{
MODEL=on7xelte
KERNEL_DEFCONFIG=Oxygen_on7xelte_defconfig
VERSION_NUMBER=$(<oxygen/G610x)
FUNC_BUILD_BOOTIMG
mv -f $RDIR/oxygen/ramdisk/G610x/image-new.img $RDIR/oxygen/$ZIPLOC/G610x/boot.img
ZIP_FILE_DIR=$RDIR/oxygen/$ZIPLOC/G610x
ZIP_NAME=Oxygen.G610x.v$VERSION_NUMBER.zip
ZIP_FILE_TARGET=$ZIP_FILE_DIR/$ZIP_NAME
FUNC_BUILD_ZIP
echo ""
echo "Build Successful"
echo ""
}

OPTION_2()
{
MODEL=j7xelte
KERNEL_DEFCONFIG=Oxygen_j7xelte_defconfig
VERSION_NUMBER=$(<oxygen/J710x)
FUNC_BUILD_BOOTIMG
mv -f $RDIR/oxygen/ramdisk/J710x/image-new.img $RDIR/oxygen/$ZIPLOC/J710x/boot.img
ZIP_FILE_DIR=$RDIR/oxygen/$ZIPLOC/J710x
ZIP_NAME=Oxygen.J710x.v$VERSION_NUMBER.zip
ZIP_FILE_TARGET=$ZIP_FILE_DIR/$ZIP_NAME
FUNC_BUILD_ZIP
echo ""
echo "Build Successful"
echo ""
}

OPTION_0()
{
echo "Cleaning Workspace"
FUNC_CLEAN
}

if [ $1 == 0 ]; then
	OPTION_0
fi
if [ $1 == 1 ]; then
	OPTION_1
fi
if [ $1 == 2 ]; then
	OPTION_2
fi

# Program Start
rm -rf oxygen/build.log
clear
echo "      XYGEN     EN      OX     O     OXY   GENOXYGE    YGENOXYGEN   OXYG    YG"
echo "    ENOXYGE   XYGE    GE    YGEN   GEN   OXYGENOX     NOXYGENO     GENOXY   OX"
echo "   XYG   XYG     YG  OX       YGE  XY   EN            EN           YG NO   EN"
echo "   NO     OX      XYGE          YGEN    YG            YGENOX       OX  EN  YG"
echo "   GE     EN      NOX            XYG    OX    OX      OXYGE        EN  YG  OX"
echo "   XY     YG     YGENO           NOX    ENO   EN      EN           YG   XY EN"
echo "   NOX   NOX    NOX  EN          GEN     GE   YG      YG           OX   NOXYG"
echo "    ENOXYGE     GE    GENO       XYG      XYGENOX     OXYGENOX     EN    ENOX"
echo "     GENOX     OX      Y         NOX        XYGE      ENOXYG       YG    YGEN"
echo ""
echo "0) Clean Workspace"
echo ""
echo "1) Build Oxygen_Kernel for J7 Prime"
echo ""
echo "2) Build Oxygen_Kernel for J7 2016"
echo ""
read -p "Please select an option: " prompt
echo ""
if [ $prompt == "0" ]; then
	OPTION_0
	echo ""
	echo ""
	echo ""
	echo ""
	. build.sh
elif [ $prompt == "1" ]; then
	OPTION_1
	echo ""
	echo ""
	echo ""
	echo ""
elif [ $prompt == "2" ]; then
	OPTION_2
	echo ""
	echo ""
	echo ""
	echo ""
fi
