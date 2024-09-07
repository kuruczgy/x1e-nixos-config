# NixOS configs for Snapdragon X Elite based devices

Note that I only have the Lenovo Yoga Slim 7x, so the repo will be focused around this device for the foreseeable future.

## What does and does not work

With this config, the following are working for me:

- Booting from USB and NVMe
- Wi-Fi
- GPU acceleration
- Sway and Firefox
- Battery indicator

Many other things are rumored to be working and have drivers, but I wasn't able to get everything working yet. For example suspend to RAM is inconsistent, and the speakers aren't working for me yet.

## Build

The default setting is to cross-compile from x86_64 to aarch64, if your build system is not `x86_64-linux` you have to modify `buildSystem` in `flake.nix`.

If you would like to attempt using this on something other than the Lenovo Yoga Slim 7x, modify `hardware.deviceTree.name` to point to the appropriate device tree.

Run `nix build .#nixosConfigurations.iso.config.system.build.isoImage`. Note that since there is no binary cache for cross-compiled packages, this will compile everything from scratch, and will take several hours even on a powerful machine.

## Setup guide

### Preparation

First, you might want to start building the ISO already (see above), as it does take multiple hours to build if you are cross-compiling.

If you already have installed Windows or are not interested in doing so, you can [skip to the section about booting the ISO](#booting-the-install-iso).

### Initial setup & windows install

When you first unbox the device, connect a charger, then hold the power button (right side) for ~2 seconds to power on the device.

The device will boot into the windows installer. Most of the steps should be pretty self explanatory, a couple notes:

- Apparently you can't choose the language, so you have to go through the installer in the language of the country where you purchased the laptop.

- When the installer asks you to connect to Wi-Fi, you can press `Shift+F10` (`Shift+Fn+F10` on the keyboard) to launch the command prompt, and type `oobe\bypassnro` to disable requiring Wi-Fi for installation. The laptop will reboot, you have to go through the previous installer steps again, but now an option to skip connecting to Wi-Fi appears. If you choose this you won't be required to use a Microsoft account.

- Go through the rest of the installation. Now you should be booted into a Windows desktop. (You can now change the language if you want.)

At this point, it's recommended to disable BitLocker so Windows will still boot without Secure Boot enabled. Search for "Device encryption settings" in the start menu, and turn "Device encryption" off. This will take a couple minutes to finish.

Next, you probably want to shrink your Windows partition to make space for the Linux root filesystem. Search for "Create and format hard disk partitions" in the start menu, and shrink the (C:) partition by some amount. After this, you should create a new partition in the now free space.

### Booting the install ISO

Reboot the laptop, and enter the UEFI menu by pressing F2 (no need for the Fn key) while the big "YOGA" logo is showing.

Go to "Security > Secure Boot", and disable it. Then go to "Exit" and select "Exit Saving Changes". (At this point you might want to boot into Windows again just to check if it still works.)

Next, build the install ISO [as described above](#build). When this is done, you should copy the ISO to a USB drive. (E.g. with something like `dd if=result/iso/cd.iso of=/dev/sdX bs=4M status=progress conv=fdatasync`.)

Connect the USB drive to the laptop (if yours is USB-A you can use the adapter that comes in the box), enter the boot menu using F12, and boot from the USB drive.

### Installation

Installation should mostly be like any [regular NixOS install](https://nixos.org/manual/nixos/stable/#sec-installation-manual).

First, connect to Wi-Fi:

```console
$ sudo systemctl start wpa_supplicant
$ wpa_cli
> add_network
> set_network 0 ssid "myssid"
> set_network 0 psk "mypassword"
> enable_network 0
```

Next, enter a root shell, and format the partition you previously created:

```console
$ sudo -i
# mkfs.ext4 -L root /dev/nvme0n1pX
```

Next, mount the root filesystem and the EFI partition. (By default the EFI partition created by Windows has the label `SYSTEM_DRV`.)

```console
# mount /dev/disk/by-label/root /mnt
# mkdir -p /mnt/boot
# mount /dev/disk/by-label/SYSTEM_DRV /mnt/boot
```

Finally, run `nixos-install`. Note that this repository is symlinked at `/x1e-nixos-config` for convenience:

```console
# nixos-install --root /mnt --no-channel-copy --no-root-password --flake $(readlink /x1e-nixos-config)#system
```

Note that this could also take over an hour and more than 50% of the battery to compile and install everything, you probably want to have the charger plugged in. The laptop will also get quite hot, be careful with touching it near the hinge.

Now you should have NixOS installed, but you won't be able to boot it yet, you still have to modify the EFI boot configuration.

Reboot into the ISO again, but now select the "EFI Shell" option. For some reason the shell is tiny and appears in the bottom right corner, and the keyboard input is very slow, but you only need to enter a few commands. (You can often use tab completion to reduce the amount of typing necessary.)

Run `map -r -b` to reset the filesystem mappings and list them. Look for a `FS*` entry with a path like `PcieRoot(*)/.../NVMe(...)/HD(0x1, ...)`. For me it was `FS4`, so I will use it as an example. Switch to this partition, and verify that it is the right one:

```console
Shell> FS4:
FS4:\> ls EFI\systemd
```

You should see `systemd-bootaa64.efi` listed. Configure it as the default boot option, and then verify that it was added successfully:

```console
FS4:\> bcfg boot add 0 EFI\systemd\systemd-bootaa64.efi "NixOS"
FS4:\> bcfg boot dump
```

Now you can use the `reset` command to reboot, and after booting again you should see the `systemd-boot` menu with options for both NixOS and Windows.

After booting into NixOS, you can log in with the user `user` using the password `nixos`. You can change the default password using `passwd`.
