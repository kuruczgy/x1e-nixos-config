# NixOS configs for Snapdragon X Elite based devices

Note that I only have the Lenovo Yoga Slim 7x, so the repo will be focused around this device for the foreseeable future.

## Other projects with support for Snapdragon X Elite devices

- [Ubuntu Concept](https://discourse.ubuntu.com/t/ubuntu-24-10-concept-snapdragon-x-elite/48800): Supports many X Elite based laptops
- [Cadmium](https://github.com/Maccraft123/Cadmium): Also for the Yoga Slim 7x
- [Ubuntu for the Snapdragon Dev Kit](https://github.com/jglathe/linux_ms_dev_kit/wiki/Bringing-up-the-SnapDragon-Dev-Kit-for-Windows-with-Linux-%E2%80%90-*with*-working-display)
- Surface Pro 11: [Arch Linux ARM](https://github.com/dwhinham/linux-surface-pro-11) and [NixOS](https://github.com/andre4ik3/nixos-surface-pro-11)

## Feature Matrix

|                         |  Lenovo Yoga Slim 7x | Notes                                                                            |
| ----------------------- | -------------------: | -------------------------------------------------------------------------------- |
| Identifier              | `lenovo-yoga-slim7x` |                                                                                  |
| Battery Charging        |                   ✅ |                                                                                  |
| Battery Indicator       |                   ✅ | Not working in EL2. (More info [below](#running-virtual-machines-with-kvm).)     |
| Bluetooth               |                   ✅ |                                                                                  |
| Camera                  |                   ❌ |                                                                                  |
| Display                 |                   ✅ |                                                                                  |
| GPU Acceleration        |                   ✅ |                                                                                  |
| Hardware Video Decoding |                   ❌ |                                                                                  |
| Hibernate               |                   ❔ |                                                                                  |
| Keyboard                |                   ✅ |                                                                                  |
| Lid switch              |                   ✅ |                                                                                  |
| Microphone              |                   ❌ |                                                                                  |
| NVMe                    |                   ✅ |                                                                                  |
| Power Profiles          |                   ❌ |                                                                                  |
| RTC                     |                   ✅ |                                                                                  |
| Speakers                |                   ❌ |                                                                                  |
| Suspend                 |                   🟨 | Spurious wakeups can happen. Battery consumption still high (approx. 3.8%/hour). |
| Thermal throttling      |                   ❌ |                                                                                  |
| Touchpad                |                   ✅ |                                                                                  |
| Touchscreen             |                   ✅ |                                                                                  |
| TPM                     |                   ❌ |                                                                                  |
| USB-C 4                 |                   ❔ |                                                                                  |
| USB-C Booting           |                   ✅ |                                                                                  |
| USB-C DP Alt Mode       |                   🟨 | Mostly working. Right side port broken for some reason.                          |
| USB-C PCIe              |                   ❌ |                                                                                  |
| Wi-Fi                   |                   ✅ |                                                                                  |

Some things may be working and have drivers, but are not yet included here.

## Getting the installer ISO

Binary releases of the install ISO are available, or alternately you can compile it yourself (described below).

Note that the device tree in the releases is hardcoded for the Lenovo Yoga Slim 7x, so if you want to attempt installing on any other machine you have to build the installer yourself.

### Build

There are two main ways to build the ISO:

1. The default setting is to cross-compile from x86_64 to aarch64. This takes several hours as all packages are compiled from scratch.
1. Using WSL on the device to build using Nix. This generally takes 25 minutes as only the kernel is compiled from scratch.

If your build system is not `x86_64-linux` you have to modify `buildSystem` in `flake.nix`, e.g. to `aarch64-linux` if building in WSL.

If you build using WSL, you can install Nix in e.g. Ubuntu WSL by installing Nix as usual [following the guide for multi-user Nix (the package manager)](https://nixos.org/download/). (One can also install [NixOS in WSL](https://github.com/nix-community/NixOS-WSL), however, this requires an existing NixOS installation to build the `aarch64` version as the project only distributes pre-built `x86_64-linux` versions.)

If you would like to attempt using this on something other than the Lenovo Yoga Slim 7x, enable the appropriate `hardware.<device>.enable` option.

Run `nix build .#nixosConfigurations.iso.config.system.build.isoImage` to build the ISO. You might need to add the `--extra-experimental-features 'nix-command flakes'` flag if flakes are not enabled in your Nix config (e.g. in WSL).

## Setup guide

### Preparation

If you are building the install ISO yourself you might want to start already (see above), as it does take multiple hours to build if you are cross-compiling.

If you already have installed Windows or are not interested in doing so, you can [skip to the section about booting the ISO](#booting-the-install-iso).

### Initial setup & windows install

_Note that these instructions were written for the Lenovo Yoga Slim 7x, the steps might be slightly different for other devices._

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

Next, build the install ISO [as described above](#build). When this is done, you should copy the ISO to a USB drive. (E.g. with something like `dd if=result/iso/nixos-x1e80100-lenovo-yoga-slim7x.iso of=/dev/sdX bs=4M status=progress conv=fdatasync`.)

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

Finally, run `nixos-install`. Note that this repository is available as `x1e-nixos-config` in the flake registry:

```console
# nixos-install --root /mnt --no-channel-copy --no-root-password --flake x1e-nixos-config#system
```

Explanation:

- `--no-channel-copy` disables copying channels. If you would like to use a non-flake config with channels (which I don't recommend), you should omit this option.
- `--no-root-password` disables setting a root password. Omit this if you don't have any other way to get into the installed system and need a root password.
- `--flake x1e-nixos-config#system` specifies the example flake-based configuration to be used that comes with this repository. Note that if you have already [created your own NixOS configuration](#making-your-own-nixos-configuration) for the to-be-installed system, you can use that here. (Either by specifying `--flake /path/to/your/config#your-hostname` or by placing your non-flake config at `/mnt/etc/nixos/configuration.nix` and omitting this option. Importantly, `nixos-generate-config` is **not** expected to work.) Note that if you install the flake-based example configuration, you won't easily be able to switch to a non-flake-based one.

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

To connect to Wi-Fi, use `nmtui`. (Do **not** try manually starting the `wpa_supplicant` service, that's only for the installer.)

No login manager is installed, by default only a command line interface is available. (You can run `exec sway` manually if you want to quickly get a graphical interface.)

## Making your own NixOS configuration

### Creating a new flake-based configuration

Copy the contents of [`examples/flake-based-config`](/examples/flake-based-config) from this repository. You might also want to copy `flake.lock` from the root of the repository to get the same nixpkgs version to start out with. Make sure to replace occurrences of "system" in `flake.nix` with your chosen hostname. It's also advised to set up a git repository to track the changes you make to the configuration.

Once you made your modifications, you can use `sudo nixos-rebuild switch --flake .#system` to apply them. (Replace "system" with the hostname you chose previously.)

To update your system, you can use `nix flake update`, which will update all flake inputs, including nixpkgs and this repository. It can happen that this repository becomes incompatible with some future version of nixpkgs. If an evaluation error happens due to such an incompatibility, feel free to file an issue, and we will try to update the pinned nixpkgs version and fix the issue.

### Integration into your existing flake-based config

If you already have a repository with all your NixOS configurations, you can use the `x1e` module exported from this repository, which only sets necessary hardware specific options.

Reference it in your flake inputs like this:

```nix
x1e-nixos-config.url = "github:kuruczgy/x1e-nixos-config";
x1e-nixos-config.inputs.nixpkgs.follows = "nixpkgs";
```

and then use the `x1e-nixos-config.nixosModules.x1e` module. Set one of the `hardware.<device>.enable` options.

### Usage without flakes

You should be able to import [`default.nix`](/default.nix) and reference the module as its `nixosModules.x1e` attribute.

## Running virtual machines with KVM

By default the firmware runs Linux in the EL1 privilege level, but EL2 is needed for KVM. Coaxing the firmware into running Linux in EL2 is rather involved, see the [slbounce](https://github.com/TravMurav/slbounce) README for more information about the process.

`slbounce` uses `tcblaunch.exe` (this is a signed binary, and there are currently no known alternatives), which you will need to manually copy from your Windows installation from `C:\Windows\System32\tcblaunch.exe` into the root of the ESP. The SHA256 hash of my `tcblaunch.exe` is `5dfcd0253b6ee99499ab33cac221e8a9cea47f3fdf6d4e11de9a9f3c4770d03d`, I am not sure whether other versions also exist out there. If yours is different, please report its hash and whether it worked for you.

To enable the `el2` specialization, which you can then select in the systemd-boot menu, set `x1e.el2.enable = true;` in your config.

This is deliberately a separate non-default boot option, since some hardware support does not work under EL2.

## Contributing

### Code formatting

All Nix code in the repository is formatted using [nixfmt](https://github.com/NixOS/nixfmt).

Use the `nix fmt` command to format all files before committing your changes.
