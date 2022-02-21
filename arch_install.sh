# Find fastest mirrors
reflector --latest 20 --sort rate --save /etc/pacman.d/mirrorlist --protocol https --download-timeout 5
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf

timedatectl set-ntp true
timedatectl status
pacman -S --noconfirm archlinux-keyring


lsblk
echo "Enter the drive: "
read drive
cfdisk $drive 
echo "Enter the linux partition: "
read partition
mkfs.btrfs -f $partition
read -p "Did you also create efi partition? [y/n] " answer
if [[ $answer = y ]] ; then
  echo "Enter EFI partition: "
  read efipartition
  mkfs.vfat -F 32 $efipartition
fi

mount $partition /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@var
umount /mnt

mount -o noatime,compress=zstd,space_cache=v2,subvol=@ $partition /mnt
mount -o noatime,compress=zstd,space_cache=v2,subvol=@home $partition /mnt/home
mount -o subvol=@var $partition /mnt/var

mount $efipartition /mnt/boot
lsblk

pacstrap /mnt base linux-lts linux-firmware nvim intel-ucode btrfs-progs efibootmgr networkmanager grub grub-btrfs
genfstab -U /mnt >> /mnt/etc/fstab
wget https://github.com/UltraToon/Arch_install.sh/edit/main/arch_install2.sh
chmod +x /mnt/arch_install2.sh
arch-chroot /mnt ./arch_install2.sh
exit

# PART 2 happens here.

# Final
umount -l /mnt
reboot
