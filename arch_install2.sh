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

pacman -Syu xorg-server xorg-xkill mpv pipewire pipewire-pulse alsa-utils adobe-source-sans-fonts base-devel gst-libav gst-plugins-good unzip wget xdg-utils xdg-user-dirs btop fuse2 lsd zsh mlocate git ttf-anonymous-pro ttf-bitstream-vera ttf-droid ttf-liberation ttf-nerd-fonts-symbols ttf-ubuntu-font-family jre8-openjdk feh linux-lts-headers

systemctl enable NetworkManager
echo "Enter Username: "
read username
useradd -m $username
usermod -aG wheel,video $username
echo "NOTE: Install your own DE/WM and terminal! Rebooting..."
exit
