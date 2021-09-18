# timezone setup
timedatectl set-ntp true &>/dev/null
while [[ 1 ]]; do
	clear
	echo -e '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
	echo '[o_o] Setting up timezone...'
	echo -e '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n'
	BASE_FILE_PATH='/usr/share/zoneinfo'
	ls $BASE_FILE_PATH
	echo -e '\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n'
	read -p '[o_o] Enter your zone - ' ZONE
	echo -e '\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
	if [ ! -d $BASE_FILE_PATH'/'$ZONE ]; then
		echo '[*_*] You entered invalid zoneinfo'
		sleep 5
		continue
	fi

	clear
	echo -e '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
	echo '[*_*] Setting up timezone...'
	echo -e '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n'
	ls $BASE_FILE_PATH'/'$ZONE
	echo -e '\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n'
	read -p '[o_o] Enter your timezone - ' TIMEZONE
		echo -e '\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
	if [ ! -f $BASE_FILE_PATH'/'$ZONE'/'$TIMEZONE ]; then
		echo '[*_*] you entered invalid timezone'
		sleep 5
		exit
	fi
	break
done
ln -sf $BASE_FILE_PATH'/'$ZONE'/'$TIMEZONE /etc/localtime &>/dev/null
hwclock --systohc &>/dev/null
clear
echo '[o_o] Timezone setup complete...'

# setting up local
echo -e '\n[o_o] Settingup locale...'
echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
echo 'LANG="en_US.UTF-8"' > /etc/locale.conf
locale-gen &>/dev/null

# setting up hotnames
echo -e '\n[o_o] Settingup hostname...'
read -p '[o_o] Enter hostname for your machine -> ' HNAME
echo $HNAME > /etc/hostname
echo -e "127.0.0.1		localhost\n::1		localhost\n127.0.1.1	$HNAME.localdomain $HNAME" > /etc/hosts
echo -e '[o_o] Host setup complete...\n'

# users and passwords
read -p '[o_o] Would you like to setup root user. (y/n) -> ' RUSER
if [ $RUSER == 'y' ]; then
	passwd
fi

read -p '[o_o] Would you like to add user. (y/n) ->' NEWUSR
while [[ $NEWUSR == 'y' ]]; do
	read -p '[o_o] Enter username -> ' USERNAME
	useradd -m $USERNAME
	passwd $USERNAME
	echo '[o_o] $USERNAME is created...adding it to wheel, audio, video, storage, optical group'
	usermod -aG wheel,audio,video,storage,optical $USERNAME
	echo -e '\n'
	read -p '[o_o] Would you like to add another user. (y/n) ->' NEWUSR
done

# seting up sudo 
echo '\n[o_o] Installing sudo...'
pacman -S sudo nano
clear

REPEAT='y'
while [[ $REPEAT == 'y' ]]; do
	clear
	echo '[o_o] In the next step nano editor will openup. If you did not understand press "Control+x" to exit. You can do this agin if required'
	echo '[o_o] You are suppouse to uncomment this line.'
	echo -e '\n%wheel ALL=(ALL) ALL\n\n'
	read -p '[o_o] Type "ok" to procced -> ' OK

	if [[ $OK == 'ok' ]]; then
		EDITOR=nano visudo
	fi
	echo -e '------------------------------------------------------------------------\n'
	read -p "[o_o] If you have made any mistek type 'y' to repeat...or press enter to continue..." REPEAT
done

clear
echo "[o_o] Installing grub..."
pacman -S grub efibootmgr dosfstools os-prober mtools
clear

mkdir /boot/EFI
lsblk
read -p '[o_o] Enter EFI partition (/dev/sdXX) -> ' EFIPART
mount $EFIPART /boot/EFI 
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck 
grub-mkconfig -o /boot/grub/grub.cfg

echo '[o_o] Installing and seting up NetworkManager'
pacman -S networkmanager
systemctl enable NetworkManager 

echo '[*_o] Arch Linux is installed type these commands'
echo 'exit'
echo 'umount -l /mnt'
echo 'reboot'
