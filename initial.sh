REPEAT='y'
while [[ $REPEAT == 'y' ]]; do
	clear
	echo    '--------------------------------------------------------'
	echo    '[o_o] Disks installed on your system are as follows...'
	echo -e '--------------------------------------------------------\n\n'
	fdisk -l
	echo -e '\n\n--------------------------------------------------------'
	read -p '[o_o] Enter disk name to install ARCH -> ' DISKNM

	echo	 '[o_o] Create partitions as follows'
	echo	 '		+550M		EFI System'
	echo	 ' 		+2G			Linux Swap (optional)'
	echo -e  '		remaining 	Linux File System\n'

	read -p 'Press any key to continue...'

	cfdisk $DISKNM

	clear
	fdisk -l $DISKNM

	read -p "[o_o] If you have made any mistek type 'y' to repeat...or press enter to continue..." REPEAT
done

REPEAT='y'
while [[ $REPEAT == 'y' ]]; do
	clear
	lsblk $DISKNM
	echo -e '\n\n[o_o] Mention your partitions in /dev/sdXX format'
	read -p '[o_o] Enter EFI partition  -> ' EFIPART
	read -p '[o_o] Enter Boot partition -> ' BOOTPART
	read -p "[o_o] Enter Swap partition (Enter to skip) -> " SWAPPART 

	read -p "[o_o] If you have made any mistek type 'y' to repeat...or press enter to continue..." REPEAT
done

# EFI partition setup
mkfs.fat -F32 $EFIPART

# swap partion setup
if [[ $SWAPPART -ne '' ]]; then
	mkswap $SWAPPART
	swapon $SWAPPART
fi

# boot partition setup
mkfs.ext4 $BOOTPART 

# mount bootpartition to mnt
mount $BOOTPART /mnt
echo '[o_o] Disks are initialized...'

echo '[o_o] Installing base packages and linux kernal, firmware using pacstrap...'
pacstrap /mnt base linux linux-firmware

clear
echo '[o_o] Generating file system table...'
genfstab -U /mnt >> /mnt/etc/fstab
echo '[o_o] Changing root...'
echo '[o_o] Run base.sh to continue further installation...'
arch-chroot /mnt
