# Find fastest mirrors
reflector --latest 20 --sort rate --save /etc/pacman.d/mirrorlist --protocol https --download-timeout 5
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf

timedatectl set-ntp true
timedatectl status
pacman -S --no-confirm archlinux-keyring


lsblk
echo "Enter the drive: "
read drive
cfdisk $drive 
echo "Enter the linux partition: "
read partition
mkfs.btrfs $partition
read -p "Did you also create efi partition? [y/n]" answer
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

mkdir /mnt/{boot,home,var}
mount -o noatime,compress=zstd,space_cache=v2,subvol=@ $partition /mnt
mount -o noatime,compress=zstd,space_cache=v2,subvol=@home $partition /mnt/home
mount -o subvol=@var $partition /mnt/var

mount $efipartition /mnt/boot
lsblk

pacstrap /mnt base linux-lts linux-firmware nvim intel-ucode btrfs-progs efibootmgr networkmanager grub grub-btrfs
genfstab -U /mnt >> /mnt/etc/fstab
sed '1,/^#part2$/d' `basename $0` > /mnt/arch_install2.sh
chmod +x /mnt/arch_install2.sh
arch-chroot /mnt ./arch_install2.sh
exit

# Second Part
pacman -S --noconfirm sed
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
ln -sf /usr/share/zoneinfo/US/Pacific /etc/localtime
hwclock --systohc
rm /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "Hostname: "
read hostname
echo $hostname > /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts
sed -i 's/MODULES=()/MODULES=(btrfs)/g' /etc/mkinitcpio.conf
mkinitcpio -P linux-lts
passwd
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
sed -i 's/quiet/pci=noaer/g' /etc/default/grub
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=3/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

pacman -S xorg-server xorg-xkill mpv pipewire pipewire-pulse alsa-utils adobe-source-sans-fonts base-devel gst-libav gst-plugins-good unzip wget xdg-utils xdg-user-dirs plasma-desktop imagemagick dolphin alacritty btop fuse2 lsd zsh mlocate git ttf-anonymous-pro ttf-bitstream-vera ttf-droid ttf-liberation ttf-nerd-fonts-symbols ttf-ubuntu-font-family jre8-openjdk feh linux-lts-headers

systemctl enable NetworkManager
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo "Enter Username: "
read username
useradd -m $username
usermod -aG wheel,video $username
exit

# Final
umount -l /mnt
reboot
